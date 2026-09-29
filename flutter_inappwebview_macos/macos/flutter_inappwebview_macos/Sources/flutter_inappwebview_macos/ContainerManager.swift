//
//  ContainerManager.swift
//  flutter_inappwebview
//
//  MethodChannel handler for the per-WebView profile controller. Wraps
//  WKWebsiteDataStore's identifier-based APIs (iOS 17+ / macOS 14+) and
//  maintains an `containerId → UUID` side-map in UserDefaults so the
//  caller can read profile names back instead of opaque UUIDs.
//
//  The map is updated automatically when a containerId is bound (see
//  InAppWebView.preWKWebViewConfiguration's call to
//  ContainerManager.registerContainerBinding) and when a profile is
//  deleted via this controller. getAllContainerNames intersects the
//  registry with WKWebsiteDataStore.allDataStoreIdentifiers, so stale
//  registry entries (where the underlying store has been removed out
//  of band) are filtered out automatically.
//

import Foundation
import WebKit
import FlutterMacOS

@available(macOS 14.0, *)
public class ContainerManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_containercontroller"

    // UserDefaults suite + key for the id ↔ UUID side-map.
    // - Suite name keeps our keys out of the host app's defaults.
    // - The dictionary is `containerId(String) → uuidString(String)`.
    // - Survives app restarts; wiped on app uninstall (which also
    //   wipes the underlying WKWebsiteDataStore data, so the two stay
    //   consistent).
    private static let registrySuiteName =
        "com.pichillilorenzo.flutter_inappwebview.containers"
    private static let registryKey = "id_to_uuid"

    private static func registry() -> UserDefaults {
        return UserDefaults(suiteName: registrySuiteName) ?? UserDefaults.standard
    }

    private static func loadIdMap() -> [String: String] {
        return registry().dictionary(forKey: registryKey) as? [String: String] ?? [:]
    }

    private static func saveIdMap(_ map: [String: String]) {
        registry().set(map, forKey: registryKey)
    }

    // Process-wide cache of WKWebsiteDataStore wrappers keyed by
    // derived UUID. Same pattern as Linux's container_session_cache
    // and the iOS sibling: WKWebsiteDataStore(forIdentifier:) hands
    // out a new ObjC wrapper on every call, all backing the same
    // on-disk store. Sharing one wrapper across every WebView that
    // joins a container removes one source of in-use refcount
    // confusion when remove(forIdentifier:) is called. Eviction is
    // explicit on deleteContainer.
    private static var sharedStores: [UUID: WKWebsiteDataStore] = [:]
    private static var sharedStoreIds: [UUID: String] = [:]
    private static let sharedStoresLock = NSLock()

    // WebKit-init warm-up.
    //
    // fetchAllDataStoreIdentifiers and WKWebsiteDataStore(forIdentifier:)
    // post their results via WTF::RunLoop::main(). That singleton only
    // exists once WebKit has been initialized on the main thread —
    // RunLoop::initializeMain() runs as a side effect of the first real
    // WebKit use. If our identifier APIs are the very first WebKit touch
    // in the process (cold start, no WKWebView constructed yet), the
    // background completion can dispatch into an uninitialized run loop
    // and crash inside os_unfair_lock_lock with EXC_BAD_ACCESS at
    // address 0x40 — the lock at offset 0x40 of a null base. Symptom is
    // a SIGSEGV in JavaScriptCore::WTF::RunLoop::dispatch before any of
    // our completion code runs.
    //
    // Touching the default data store on the main thread forces
    // RunLoop::initializeMain(). We do it lazily, once, from every
    // entry point the plugin exposes that could be the first WebKit
    // touch: the platform-channel handler (covers
    // getAllContainerNames / hasContainer / deleteContainer /
    // clearContainerData) and the InAppWebView bind site via
    // getOrCreateDataStore. Both run on the main thread.
    // internal (not private) so the XCTest target in
    // example/macos/RunnerTests can reach them via @testable import.
    static var didWarmUpWebKit = false

    static func ensureWebKitInitialized() {
        assert(Thread.isMainThread)
        if didWarmUpWebKit { return }
        _ = WKWebsiteDataStore.default()
        didWarmUpWebKit = true
    }

    public static func getOrCreateDataStore(forContainer containerId: String) -> WKWebsiteDataStore {
        ensureWebKitInitialized()
        let uuid = containerIdToUUID(containerId)
        sharedStoresLock.lock()
        defer { sharedStoresLock.unlock() }
        if let cached = sharedStores[uuid] {
            return cached
        }
        let store = WKWebsiteDataStore(forIdentifier: uuid)
        // ProxyManager's table may already name a proxy for this container,
        // app-wide or its own, set before the store existed.
        ProxyManager.applyRoute(to: store, forContainer: containerId)
        sharedStores[uuid] = store
        sharedStoreIds[uuid] = containerId
        var map = loadIdMap()
        map[containerId] = uuid.uuidString
        saveIdMap(map)
        return store
    }

    // Every container store currently cached, with its containerId, for
    // ProxyManager.applyRoutes: a proxy change has to reach containers
    // already joined, and applyRoute covers the ones joined afterwards.
    static func allCachedDataStoresByContainer() -> [(String, WKWebsiteDataStore)] {
        sharedStoresLock.lock()
        defer { sharedStoresLock.unlock() }
        return sharedStores.compactMap { uuid, store in
            sharedStoreIds[uuid].map { ($0, store) }
        }
    }

    @discardableResult
    private static func evictDataStore(forContainer containerId: String) -> WKWebsiteDataStore? {
        let uuid = containerIdToUUID(containerId)
        sharedStoresLock.lock()
        let store = sharedStores.removeValue(forKey: uuid)
        sharedStoreIds.removeValue(forKey: uuid)
        sharedStoresLock.unlock()
        return store
    }

    // Puts back a store deleteContainer evicted but could not delete, as a
    // WebView still uses it: ProxyManager only reaches cached stores.
    private static func recacheDataStore(_ store: WKWebsiteDataStore, forContainer containerId: String) {
        let uuid = containerIdToUUID(containerId)
        sharedStoresLock.lock()
        defer { sharedStoresLock.unlock() }
        if sharedStores[uuid] == nil {
            sharedStores[uuid] = store
            sharedStoreIds[uuid] = containerId
        }
    }

    public static func registerContainerBinding(_ containerId: String, uuid: UUID) {
        var map = loadIdMap()
        map[containerId] = uuid.uuidString
        saveIdMap(map)
    }

    private var plugin: InAppWebViewFlutterPlugin?

    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(
            name: ContainerManager.METHOD_CHANNEL_NAME,
            binaryMessenger: plugin.registrar.messenger))
        self.plugin = plugin
    }

    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // First line of every public entry: see ensureWebKitInitialized's
        // docstring for the EXC_BAD_ACCESS at 0x40 we're avoiding here.
        ContainerManager.ensureWebKitInitialized()
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "getAllContainerNames":
            getAllContainerNames(result: result)
        case "hasContainer":
            guard let containerId = args?["containerId"] as? String, !containerId.isEmpty else {
                result(false); return
            }
            hasContainer(containerId, result: result)
        case "deleteContainer":
            guard let containerId = args?["containerId"] as? String, !containerId.isEmpty else {
                result(false); return
            }
            deleteContainer(containerId, result: result)
        case "clearContainerData":
            guard let containerId = args?["containerId"] as? String, !containerId.isEmpty else {
                result(false); return
            }
            clearContainerData(containerId, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getAllContainerNames(result: @escaping FlutterResult) {
        WKWebsiteDataStore.fetchAllDataStoreIdentifiers { uuids in
            let liveUUIDs = Set(uuids.map { $0.uuidString.lowercased() })
            let map = ContainerManager.loadIdMap()
            // Only return ids whose UUID is still materialized — drop
            // stale registry entries.
            let names = map.compactMap { (id, uuidStr) -> String? in
                liveUUIDs.contains(uuidStr.lowercased()) ? id : nil
            }
            DispatchQueue.main.async { result(names) }
        }
    }

    private func hasContainer(_ containerId: String, result: @escaping FlutterResult) {
        let target = containerIdToUUID(containerId).uuidString.lowercased()
        WKWebsiteDataStore.fetchAllDataStoreIdentifiers { uuids in
            let exists = uuids.contains { $0.uuidString.lowercased() == target }
            DispatchQueue.main.async { result(exists) }
        }
    }

    private func deleteContainer(_ containerId: String, result: @escaping FlutterResult) {
        // Drop our cached wrapper before WebKit tries to free the
        // underlying store — see iOS sibling for the rationale.
        // Weak: holding the store would itself keep it in use.
        weak var evicted = ContainerManager.evictDataStore(forContainer: containerId)
        let uuid = containerIdToUUID(containerId)
        WKWebsiteDataStore.remove(forIdentifier: uuid) { error in
            // Apple returns an error when the store doesn't exist or
            // when a WKWebView is still using it. Treat both as "did
            // not delete" — true means we deleted, false means we
            // didn't.
            let deleted = (error == nil)
            DispatchQueue.main.async {
                if deleted {
                    var map = ContainerManager.loadIdMap()
                    map.removeValue(forKey: containerId)
                    ContainerManager.saveIdMap(map)
                    // A deleted container takes its proxy with it: one
                    // created again under the same id starts from the
                    // app-wide proxy, like any new container.
                    ProxyManager.setRoute(nil, forContainer: containerId)
                } else if let store = evicted {
                    ContainerManager.recacheDataStore(store, forContainer: containerId)
                }
                result(deleted)
            }
        }
    }

    // Mirror of iOS clearContainerData. Same semantics: works while a
    // WKWebView is still bound to the data store, scoped to
    // allWebsiteDataTypes() since .distantPast, registry untouched.
    // Goes through the shared cache so we hit the same wrapper any
    // live WebView is holding.
    private func clearContainerData(_ containerId: String, result: @escaping FlutterResult) {
        let store = ContainerManager.getOrCreateDataStore(forContainer: containerId)
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        store.removeData(ofTypes: types, modifiedSince: .distantPast) {
            DispatchQueue.main.async { result(true) }
        }
    }

    public override func dispose() {
        super.dispose()
        plugin = nil
    }
}
