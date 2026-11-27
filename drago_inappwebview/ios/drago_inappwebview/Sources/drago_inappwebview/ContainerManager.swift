//
//  ContainerManager.swift
//  drago_inappwebview
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
import Flutter

@available(iOS 17.0, *)
public class ContainerManager: ChannelDelegate {
    static let METHOD_CHANNEL_NAME = "com.pichillilorenzo/drago_inappwebview_containercontroller"

    // UserDefaults suite + key for the id ↔ UUID side-map.
    // - Suite name keeps our keys out of the host app's defaults.
    // - The dictionary is `containerId(String) → uuidString(String)`.
    // - Survives app restarts; wiped on app uninstall (which also
    //   wipes the underlying WKWebsiteDataStore data, so the two stay
    //   consistent).
    private static let registrySuiteName =
        "com.pichillilorenzo.drago_inappwebview.containers"
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

    // Process-wide cache of WKWebsiteDataStore wrappers keyed by their
    // derived UUID. Mirrors the same pattern as Linux's
    // container_session_cache: WKWebsiteDataStore(forIdentifier:) hands
    // out a new ObjC wrapper on every call, but they all back the same
    // on-disk store. Sharing one wrapper across every WebView that joins
    // a container removes one source of in-use refcount confusion when
    // remove(forIdentifier:) is called for deleteContainer — the
    // wrapper goes through one canonical path instead of being
    // duplicated per WebView and per controller method. Eviction is
    // explicit on deleteContainer, just before remove(forIdentifier:),
    // so the cache never holds a reference past the user-visible delete.
    private static var sharedStores: [UUID: WKWebsiteDataStore] = [:]
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
    // example/ios/RunnerTests can reach them via @testable import.
    static var didWarmUpWebKit = false

    static func ensureWebKitInitialized() {
        assert(Thread.isMainThread)
        if didWarmUpWebKit { return }
        _ = WKWebsiteDataStore.default()
        didWarmUpWebKit = true
    }

    // Return the cached WKWebsiteDataStore for `containerId`, creating
    // it on first access and recording the id ↔ UUID mapping for
    // getAllContainerNames. Both call sites (InAppWebView's bind in
    // preWKWebViewConfiguration, and ContainerManager's
    // clearContainerData) go through this — the WebView and the
    // controller end up holding *the same* wrapper instance for a
    // given container, which is the entire point of caching.
    public static func getOrCreateDataStore(forContainer containerId: String) -> WKWebsiteDataStore {
        ensureWebKitInitialized()
        let uuid = containerIdToUUID(containerId)
        sharedStoresLock.lock()
        defer { sharedStoresLock.unlock() }
        if let cached = sharedStores[uuid] {
            return cached
        }
        let store = WKWebsiteDataStore(forIdentifier: uuid)
        sharedStores[uuid] = store
        var map = loadIdMap()
        map[containerId] = uuid.uuidString
        saveIdMap(map)
        return store
    }

    // Called from deleteContainer just before remove(forIdentifier:) so
    // our cached wrapper isn't keeping the underlying store ref-counted
    // alive while WebKit tries to tear it down.
    private static func evictDataStore(forContainer containerId: String) {
        let uuid = containerIdToUUID(containerId)
        sharedStoresLock.lock()
        sharedStores.removeValue(forKey: uuid)
        sharedStoresLock.unlock()
    }

    // Kept for backwards compatibility with the bind site that doesn't
    // need the store back. New code should prefer getOrCreateDataStore.
    public static func registerContainerBinding(_ containerId: String, uuid: UUID) {
        var map = loadIdMap()
        map[containerId] = uuid.uuidString
        saveIdMap(map)
    }

    private var plugin: InAppWebViewFlutterPlugin?

    init(plugin: InAppWebViewFlutterPlugin) {
        super.init(channel: FlutterMethodChannel(
            name: ContainerManager.METHOD_CHANNEL_NAME,
            binaryMessenger: plugin.registrar.messenger()))
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
        // underlying store — every wrapper ref keeps the store alive
        // from WebKit's perspective, and our cache is the one held by
        // the plugin itself rather than the user's WKWebView. The
        // WebView-side wrapper is still keeping the store in use; this
        // doesn't fix that race (callers needing a wipe while a
        // WebView is bound should use clearContainerData), but it
        // removes us as a reason for the silent no-op.
        ContainerManager.evictDataStore(forContainer: containerId)
        let uuid = containerIdToUUID(containerId)
        WKWebsiteDataStore.remove(forIdentifier: uuid) { error in
            // Apple returns an error when the store doesn't exist or
            // when a WKWebView is still using it. Treat both as "did
            // not delete" — true means we deleted, false means we
            // didn't.
            let deleted = (error == nil)
            if deleted {
                var map = ContainerManager.loadIdMap()
                map.removeValue(forKey: containerId)
                ContainerManager.saveIdMap(map)
            }
            DispatchQueue.main.async { result(deleted) }
        }
    }

    // Clear all data inside the container without removing the data
    // store. Works while a WKWebView is still bound, which is the
    // case `deleteContainer` cannot serve — Apple's
    // remove(forIdentifier:) silently no-ops if any WKWebView still
    // references the store. removeData(ofTypes:modifiedSince:) has
    // no such constraint.
    //
    // Scoped to allWebsiteDataTypes() (cookies, DOM storage,
    // IndexedDB, ServiceWorkers, HTTP cache, fetch cache, etc.)
    // since .distantPast so nothing slips through a timespan filter.
    //
    // We deliberately do NOT touch the id ↔ UUID registry here —
    // the container itself stays alive; only its contents are gone.
    private func clearContainerData(_ containerId: String, result: @escaping FlutterResult) {
        // Go through the shared cache so we operate on the *same*
        // wrapper any live WebView is holding via its
        // configuration.websiteDataStore. WKWebsiteDataStore's
        // removeData routes through the underlying store anyway, but
        // sharing the wrapper keeps refcount semantics tidy and
        // mirrors the bind site.
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
