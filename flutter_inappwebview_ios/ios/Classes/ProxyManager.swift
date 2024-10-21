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
        super.init(channel: FlutterMethodChannel(name: ProxyManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar!.messenger()))
        self.plugin = plugin
    }
    
    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case "setProxyOverride":
            if let args = arguments?["settings"] as? [String: Any] {
                let settings = ProxySettings.fromMap(args)
                let proxyConfiguration = resolveProxyConfiguration(settings)
                let websiteDataStore = WKWebsiteDataStore.default()
                websiteDataStore.proxyConfigurations = [proxyConfiguration]
                result(true)
                break
            } else {
                result(false)
                break
            }
        case "clearProxyOverride":
            WKWebsiteDataStore.default().proxyConfigurations = []
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    private func resolveProxyConfiguration (_ settings: ProxySettings) -> ProxyConfiguration {
        let components = settings.proxyUrl.replacingOccurrences(of: "//", with: "").components(separatedBy: ":")
        let includesScheme = components.count == 3
        let schemeType = includesScheme ? components[0] : "HTTP"
        let host = includesScheme ? components[1] : components[0]
        let port = includesScheme ? components[2] : components[1]
        
        let endpoint = NWEndpoint.hostPort(host: .ipv4(IPv4Address(host)!), port: NWEndpoint.Port(port)!)
        var proxyConfiguration = schemeType == "SOCKS" ?
        ProxyConfiguration(socksv5Proxy: endpoint) : ProxyConfiguration(httpCONNECTProxy: endpoint)
        
        proxyConfiguration.allowFailover = settings.allowFailover
        proxyConfiguration.excludedDomains = settings.excludedDomains
        proxyConfiguration.matchDomains = settings.matchDomains
        return proxyConfiguration
    }
    
    public override func dispose() {
        super.dispose()
        plugin = nil
    }
    
    deinit {
        dispose()
    }
}

private class ProxySettings {
    let allowFailover: Bool
    let excludedDomains: [String]
    let matchDomains: [String]
    let proxyUrl: String
    
    init(
        proxyUrl: String = "",
        allowFailover: Bool = false,
        excludedDomains: [String] = [],
        matchDomains: [String] = []
    ) {
        self.proxyUrl = proxyUrl
        self.allowFailover = allowFailover
        self.excludedDomains = excludedDomains
        self.matchDomains = matchDomains
    }
    
    static func fromMap(_ map: [String: Any]) -> ProxySettings {
        let allowFailover = map["allowFailover"] as? Bool ?? false
        let excludedDomains = map["excludedDomains"] as? [String] ?? []
        let matchDomains = map["matchDomains"] as? [String] ?? []
        let proxyUrl = map["proxyUrl"] as? String ?? ""
        
        return ProxySettings(
            proxyUrl: proxyUrl,
            allowFailover: allowFailover,
            excludedDomains: excludedDomains,
            matchDomains: matchDomains
        )
    }
}
