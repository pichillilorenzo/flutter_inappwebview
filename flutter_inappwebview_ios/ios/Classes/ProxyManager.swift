//
//  ProxyManager.swift
//  flutter_inappwebview
//

import Foundation
import WebKit

@available(iOS 17.0, *)
public class ProxyManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_proxycontroller"

    private var plugin: SwiftFlutterPlugin?

    init(plugin: SwiftFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: ProxyManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar.messenger()))
        self.plugin = plugin
    }

    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case "setProxyOverride":
            if let args = arguments?["settings"] as? [String:Any?],
               let settings = ProxySettings.fromMap(map: args) {
                setProxyOverride(settings)
                result(true)
            } else {
                result(false)
            }
            break
        case "clearProxyOverride":
            clearProxyOverride()
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    public func setProxyOverride(_ settings: ProxySettings) {
        let proxyConfigurations = settings.toProxyConfigurations()
        WKWebsiteDataStore.default().proxyConfigurations = proxyConfigurations
        WKWebsiteDataStore.nonPersistent().proxyConfigurations = proxyConfigurations
    }
    
    public func clearProxyOverride() {
        WKWebsiteDataStore.default().proxyConfigurations = []
        WKWebsiteDataStore.nonPersistent().proxyConfigurations = []
    }

    public override func dispose() {
        super.dispose()
        plugin = nil
    }

    deinit {
        debugPrint("ProxyManager - dealloc")
        dispose()
    }
}

@available(iOS 17.0, *)
public class ProxySettings {
    var proxyRules: [ProxyRule]

    init(
        proxyRules: [ProxyRule]
    ) {
        self.proxyRules = proxyRules
    }

    public static func fromMap(map: [String:Any?]?) -> ProxySettings? {
        guard let map = map else {
            return nil
        }
        return ProxySettings(
            proxyRules: (map["proxyRules"] as! [[String:Any?]]).map { ProxyRule.fromMap(map: $0)! }
        )
    }
    
    public func toProxyConfigurations() -> [ProxyConfiguration] {
        var proxyConfigurations: [ProxyConfiguration] = []
        for rule in proxyRules {
            if let proxyConfiguration = rule.toProxyConfiguration() {
                proxyConfigurations.append(proxyConfiguration)
            }
        }
        return proxyConfigurations
    }
}

@available(iOS 17.0, *)
public class ProxyRule {
    var url: String
    var allowFailover: Bool?
    var excludedDomains: [String]?
    var matchDomains: [String]?
    var username: String?
    var password: String?
    var relayHop1: ProxyRelayHop?
    var relayHop2: ProxyRelayHop?

    init(
        url: String,
        allowFailover: Bool?,
        excludedDomains: [String]?,
        matchDomains: [String]?,
        username: String?,
        password: String?,
        relayHop1: ProxyRelayHop?,
        relayHop2: ProxyRelayHop?
    ) {
        self.url = url
        self.allowFailover = allowFailover
        self.excludedDomains = excludedDomains
        self.matchDomains = matchDomains
        self.username = username
        self.password = password
        self.relayHop1 = relayHop1
        self.relayHop2 = relayHop2
    }

    public static func fromMap(map: [String:Any?]?) -> ProxyRule? {
        guard let map = map else {
            return nil
        }
        return ProxyRule(
            url: map["url"] as! String,
            allowFailover: map["allowFailover"] as? Bool,
            excludedDomains: map["excludedDomains"] as? [String],
            matchDomains: map["matchDomains"] as? [String],
            username: map["username"] as? String,
            password: map["password"] as? String,
            relayHop1: ProxyRelayHop.fromMap(map: map["relayHop1"] as? [String:Any?]),
            relayHop2: ProxyRelayHop.fromMap(map: map["relayHop2"] as? [String:Any?])
        )
    }
    
    public func toProxyConfiguration() -> ProxyConfiguration? {
        guard let endpointUrl = URL(string: url.contains("://") ? url : "http://" + url),
              let port: NWEndpoint.Port = .init(rawValue: UInt16(endpointUrl.port ?? 80)),
              let host = endpointUrl.host else {
            return nil
        }
        
        var endpointHost = NWEndpoint.Host(host)
        if let ipv4 = IPv4Address(host) {
            endpointHost = .ipv4(ipv4)
        } else if let ipv6 = IPv6Address(host) {
            endpointHost = .ipv6(ipv6)
        }
        let endpoint = NWEndpoint.hostPort(host: endpointHost, port: port)
        var proxyConfiguration: ProxyConfiguration
        let proxyRelayHops: [ProxyRelayHop] = [relayHop1, relayHop2].filter({ $0 != nil }).map({ $0! })
        if !proxyRelayHops.isEmpty {
            proxyConfiguration = ProxyConfiguration(relayHops: proxyRelayHops.compactMap({ $0.toRelayHop() }))
        } else {
            proxyConfiguration = endpointUrl.scheme?.lowercased() == "socks5" ?
            ProxyConfiguration(socksv5Proxy: endpoint) :
            ProxyConfiguration(httpCONNECTProxy: endpoint, tlsOptions: endpointUrl.scheme?.lowercased() == "https" ? .init() : nil)
        }

        if let allowFailover = allowFailover {
            proxyConfiguration.allowFailover = allowFailover
        }
        if let excludedDomains = excludedDomains {
            proxyConfiguration.excludedDomains = excludedDomains
        }
        if let matchDomains = matchDomains {
            proxyConfiguration.matchDomains = matchDomains
        }
        if let username = username, let password = password {
            proxyConfiguration.applyCredential(username: username, password: password)
        }
        return proxyConfiguration
    }
}

@available(iOS 17.0, *)
public class ProxyRelayHop {
    var http3RelayEndpoint: String?
    var http2RelayEndpoint: String?
    var additionalHTTPHeaders: [String:String]?
    
    init(
        http3RelayEndpoint: String,
        http2RelayEndpoint: String?,
        additionalHTTPHeaders: [String:String]?
    ) {
        self.http3RelayEndpoint = http3RelayEndpoint
        self.http2RelayEndpoint = http2RelayEndpoint
        self.additionalHTTPHeaders = additionalHTTPHeaders
    }
    
    init(
        http2RelayEndpoint: String,
        additionalHTTPHeaders: [String:String]?
    ) {
        self.http2RelayEndpoint = http2RelayEndpoint
        self.additionalHTTPHeaders = additionalHTTPHeaders
    }
    
    public static func fromMap(map: [String:Any?]?) -> ProxyRelayHop? {
        guard let map = map else {
            return nil
        }
        let http3RelayEndpoint = map["http3RelayEndpoint"] as? String
        let http2RelayEndpoint = map["http2RelayEndpoint"] as? String
        let additionalHTTPHeaders = map["additionalHTTPHeaders"] as? [String:String]
        if http3RelayEndpoint == nil, http2RelayEndpoint == nil {
            return nil
        }
        if http3RelayEndpoint != nil {
            return ProxyRelayHop(
                http3RelayEndpoint: http3RelayEndpoint!,
                http2RelayEndpoint: http2RelayEndpoint,
                additionalHTTPHeaders: additionalHTTPHeaders
            )
        }
        return ProxyRelayHop(
            http2RelayEndpoint: http2RelayEndpoint!,
            additionalHTTPHeaders: additionalHTTPHeaders
        )
    }
    
    public func toRelayHop() -> ProxyConfiguration.RelayHop? {
        if let http3RelayEndpoint = http3RelayEndpoint,
           let url = URL(string: http3RelayEndpoint) {
            var http2Endpoint: NWEndpoint? = nil
            if let http2RelayEndpoint = http2RelayEndpoint,
               let url2 = URL(string: http2RelayEndpoint) {
                http2Endpoint = NWEndpoint.url(url2)
            }
            return ProxyConfiguration.RelayHop(http3RelayEndpoint: NWEndpoint.url(url),
                                               http2RelayEndpoint: http2Endpoint,
                                               additionalHTTPHeaderFields: additionalHTTPHeaders ?? [:])
        }
        if let http2RelayEndpoint = http2RelayEndpoint,
           let url = URL(string: http2RelayEndpoint) {
            return ProxyConfiguration.RelayHop(http2RelayEndpoint: NWEndpoint.url(url),
                                               additionalHTTPHeaderFields: additionalHTTPHeaders ?? [:])
        }
        return nil
    }
}
