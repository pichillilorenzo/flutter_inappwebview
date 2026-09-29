//
//  ProxyManager.swift
//  flutter_inappwebview
//

import Foundation
import WebKit
import FlutterMacOS

@available(macOS 14.0, *)
public class ProxyManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_proxycontroller"

    private var plugin: InAppWebViewFlutterPlugin?

    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(name: ProxyManager.METHOD_CHANNEL_NAME, binaryMessenger: plugin.registrar.messenger))
        self.plugin = plugin
    }

    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        // An empty containerId names no container, as in InAppWebViewSettings.
        let containerId = (arguments?["containerId"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        switch call.method {
        case "setProxyOverride":
            if let args = arguments?["settings"] as? [String:Any?],
               let settings = ProxySettings.fromMap(map: args) {
                result(setProxyOverride(settings, containerId: containerId))
            } else {
                result(false)
            }
            break
        case "clearProxyOverride":
            clearProxyOverride(containerId: containerId)
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    // A proxy as the plugin hands it to a store: the configurations, and the
    // key of the settings they were built from (ProxySettings.key).
    struct ProxyRoute {
        let configurations: [ProxyConfiguration]
        let key: String
        static let direct = ProxyRoute(configurations: [], key: "")
    }

    // Who uses which proxy: one app-wide entry, one per container, and one
    // per incognito store that named its own. A store uses its own entry if
    // it has one, else the app-wide one, else no proxy. ProxyController and
    // InAppWebViewSettings.proxySettings both write here, and a store only
    // ever gets what this resolves to, so the two cannot disagree. Entries
    // last for the process; none of it is saved.
    private static var globalRoute: ProxyRoute?
    private static var containerRoutes: [String: ProxyRoute] = [:]
    // Incognito stores (WKWebsiteDataStore.nonPersistent()) are one per
    // WebView and have no id to address them by. Weak: they go with their
    // WebView. The value is the store's own route, or none to follow the
    // app-wide one.
    private final class PrivateRoute {
        let route: ProxyRoute?
        init(_ route: ProxyRoute?) { self.route = route }
    }
    private static let privateStores = NSMapTable<WKWebsiteDataStore, PrivateRoute>.weakToStrongObjects()
    private static let routesLock = NSLock()

    static func route(forContainer containerId: String?) -> ProxyRoute {
        routesLock.lock()
        defer { routesLock.unlock() }
        if let containerId = containerId, let own = containerRoutes[containerId] {
            return own
        }
        return globalRoute ?? .direct
    }

    // Sets (or, with nil, clears) the app-wide entry or a container's, and
    // moves every live store it reaches, including the ones WebViews are
    // open on.
    static func setRoute(_ route: ProxyRoute?, forContainer containerId: String?) {
        routesLock.lock()
        if let containerId = containerId {
            containerRoutes[containerId] = route
        } else {
            globalRoute = route
        }
        routesLock.unlock()
        applyRoutes()
    }

    // Brings every store the plugin knows of in line with the table.
    // setProxyConfigurations leaves a store already on its route alone, so
    // only the stores whose route changed are touched.
    static func applyRoutes() {
        setProxyConfigurations(route(forContainer: nil), on: WKWebsiteDataStore.default())
        for (containerId, store) in ContainerManager.allCachedDataStoresByContainer() {
            setProxyConfigurations(route(forContainer: containerId), on: store)
        }
        routesLock.lock()
        let incognito = (privateStores.keyEnumerator().allObjects as? [WKWebsiteDataStore] ?? [])
            .map { ($0, privateStores.object(forKey: $0)?.route) }
        routesLock.unlock()
        for (store, own) in incognito {
            setProxyConfigurations(own ?? route(forContainer: nil), on: store)
        }
    }

    // A container's store is created lazily, when a WebView or
    // ContainerController first needs it; it takes the container's route
    // then. Called by ContainerManager.getOrCreateDataStore.
    static func applyRoute(to store: WKWebsiteDataStore, forContainer containerId: String) {
        setProxyConfigurations(route(forContainer: containerId), on: store)
    }

    // A WebView is about to be created on `store`. Its proxySettings, when
    // it names a usable proxy, is the same write as ProxyController's: to
    // its container's entry, or to its own for an incognito store. Unset,
    // it changes nothing. Either way the store gets what the table resolves
    // it to before the WebView's first request.
    static func bind(
        store: WKWebsiteDataStore, containerId: String?, incognito: Bool,
        proxySettings: ProxySettings?
    ) {
        let own = proxySettings?.toProxyRoute()
        if proxySettings != nil && own == nil {
            debugPrint("ProxyManager - proxySettings has no usable rule; leaving the proxy alone")
        }
        if let containerId = containerId {
            if let own = own {
                setRoute(own, forContainer: containerId)
            } else {
                applyRoute(to: store, forContainer: containerId)
            }
        } else if incognito {
            routesLock.lock()
            privateStores.setObject(PrivateRoute(own), forKey: store)
            routesLock.unlock()
            setProxyConfigurations(own ?? route(forContainer: nil), on: store)
        } else {
            if own != nil {
                debugPrint("ProxyManager - proxySettings needs a containerId or incognito; ignored")
            }
            setProxyConfigurations(route(forContainer: nil), on: store)
        }
    }

    @discardableResult
    public func setProxyOverride(_ settings: ProxySettings, containerId: String? = nil) -> Bool {
        guard let route = settings.toProxyRoute() else {
            debugPrint("ProxyManager - refusing a proxy override with no usable rule; leaving the current proxy alone")
            return false
        }
        ProxyManager.setRoute(route, forContainer: containerId)
        return true
    }

    public func clearProxyOverride(containerId: String? = nil) {
        ProxyManager.setRoute(nil, forContainer: containerId)
    }

    // WebKit moves a live store to a new proxy in one of two ways
    // (NetworkSessionCocoa::setProxyConfigData). Usually it swaps the proxy
    // on the store's nw_context, and the connections the store already has
    // open stay pooled on the old route: a WebView built on the store
    // afterwards can load through a proxy the store no longer has. When a
    // configuration needs the HTTP stack it rebuilds the store's
    // NSURLSessions instead, which closes their connections. An Oblivious
    // HTTP relay is such a configuration; scoped to a domain that never
    // resolves, it proxies nothing. Its gateway key configuration is never
    // used but has to parse (X25519, HKDF-SHA256, AES-128-GCM): WebKit drops
    // a relay whose key does not.
    private static let sessionRebuildConfiguration = ProxyConfiguration(
        obliviousHTTPRelay: ProxyConfiguration.RelayHop(
            http2RelayEndpoint: .hostPort(host: "relay.invalid", port: 443)),
        relayResourcePath: "/",
        gatewayKeyConfig: Data([0x01, 0x00, 0x20] + [UInt8](repeating: 0x07, count: 32)
                               + [0x00, 0x04, 0x00, 0x01, 0x00, 0x01]),
        matchDomains: ["session-rebuild.invalid"])

    // The key each store's configurations were last set from. Weak: a
    // non-persistent store is transient.
    private static let appliedProxyKeys = NSMapTable<WKWebsiteDataStore, NSString>.weakToStrongObjects()
    private static let appliedProxyKeysLock = NSLock()

    // Every proxy the plugin gives a store goes through here, with the key
    // it was built from ("" for none, which is also where a store starts).
    // A new key passes through the rebuild configuration first, so the
    // store drops the connections it opened on its old route. The same key
    // again, as when another WebView joins the store, leaves the store as
    // it is: rebuilding would cancel the loads of the WebViews already on it.
    static func setProxyConfigurations(_ route: ProxyRoute, on store: WKWebsiteDataStore) {
        appliedProxyKeysLock.lock()
        let previousKey = appliedProxyKeys.object(forKey: store) as String? ?? ""
        appliedProxyKeys.setObject(route.key as NSString, forKey: store)
        appliedProxyKeysLock.unlock()
        if route.key == previousKey {
            return
        }
        store.proxyConfigurations = route.configurations + [sessionRebuildConfiguration]
        store.proxyConfigurations = route.configurations
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

@available(macOS 14.0, *)
public class ProxySettings {
    var proxyRules: [ProxyRule]
    // The map these settings were read from, as sorted JSON: everything the
    // configurations are built from. ProxyConfiguration shows only a
    // proxy's kind and endpoint, while a route also changes with its
    // credentials, domains and failover.
    let key: String

    init(
        proxyRules: [ProxyRule],
        key: String
    ) {
        self.proxyRules = proxyRules
        self.key = key
    }

    public static func fromMap(map: [String:Any?]?) -> ProxySettings? {
        guard let map = map else {
            return nil
        }
        return ProxySettings(
            proxyRules: (map["proxyRules"] as! [[String:Any?]]).map { ProxyRule.fromMap(map: $0)! },
            key: ProxySettings.key(of: map)
        )
    }

    private static func key(of map: [String:Any?]) -> String {
        let object = map as NSDictionary
        if JSONSerialization.isValidJSONObject(object),
           let data = try? JSONSerialization.data(withJSONObject: object, options: .sortedKeys),
           let key = String(data: data, encoding: .utf8) {
            return key
        }
        return String(describing: map)
    }
    
    // nil when there are no rules or any rule failed to convert, rather than
    // the rules that did. A partial list applies a proxy the caller did not
    // ask for, and an empty one is worse than a no-op: WKWebsiteDataStore
    // routes an empty array to clearProxyConfigData, so an empty or
    // unparseable rule set would turn "use this proxy" into "stop using any
    // proxy" on a live session. clearProxyOverride is how a caller asks for
    // no proxy.
    func toProxyRoute() -> ProxyManager.ProxyRoute? {
        guard let proxyConfigurations = toProxyConfigurations() else {
            return nil
        }
        return ProxyManager.ProxyRoute(configurations: proxyConfigurations, key: key)
    }

    public func toProxyConfigurations() -> [ProxyConfiguration]? {
        if proxyRules.isEmpty {
            return nil
        }
        var proxyConfigurations: [ProxyConfiguration] = []
        for rule in proxyRules {
            guard let proxyConfiguration = rule.toProxyConfiguration() else {
                return nil
            }
            proxyConfigurations.append(proxyConfiguration)
        }
        return proxyConfigurations
    }
}

@available(macOS 14.0, *)
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

@available(macOS 14.0, *)
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
