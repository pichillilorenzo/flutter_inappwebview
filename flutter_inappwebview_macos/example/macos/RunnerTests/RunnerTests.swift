import FlutterMacOS
import Cocoa
import Network
import WebKit
import XCTest

@testable import flutter_inappwebview_macos

// Unit tests for the Swift side of the plugin. See
// https://developer.apple.com/documentation/xctest for XCTest itself.

class RunnerTests: XCTestCase {


  // Regression guard for the cold-start EXC_BAD_ACCESS in
  // WTF::RunLoop::dispatch when fetchAllDataStoreIdentifiers /
  // WKWebsiteDataStore(forIdentifier:) is the first WebKit touch in
  // the process. See ContainerManager.ensureWebKitInitialized() docs.
  //
  // The XCTest target shares a process with anything earlier in the
  // suite, so we can't make this test truly "cold WebKit" — but we
  // can prove (a) the warmup helper still flips its flag and is
  // idempotent and (b) calling fetchAllDataStoreIdentifiers after
  // the warmup reaches its completion. If a future change drops the
  // warmup body or stops calling ensureWebKitInitialized at the
  // entry points, those properties stop holding.

  @available(macOS 14.0, *)
  func testEnsureWebKitInitializedIsIdempotent() {
    // Reset shared state so this test's assertion about the first
    // call is meaningful regardless of suite ordering.
    ContainerManager.didWarmUpWebKit = false

    ContainerManager.ensureWebKitInitialized()
    XCTAssertTrue(ContainerManager.didWarmUpWebKit,
                  "ensureWebKitInitialized should set the warmup flag on first call")

    // Second call is a no-op; the flag stays true and nothing crashes.
    ContainerManager.ensureWebKitInitialized()
    XCTAssertTrue(ContainerManager.didWarmUpWebKit)
  }

  @available(macOS 14.0, *)
  func testFetchAllDataStoreIdentifiersReachesCompletionAfterWarmup() {
    ContainerManager.ensureWebKitInitialized()

    let completion = expectation(description: "fetchAllDataStoreIdentifiers completion ran")
    WKWebsiteDataStore.fetchAllDataStoreIdentifiers { _ in
      // We don't care about the identifier list; we care that the
      // closure was reached. Pre-fix, WebKit could crash inside
      // WTF::RunLoop::dispatch before getting here.
      completion.fulfill()
    }
    waitForExpectations(timeout: 5)
  }

  // containerIdToUUID is the contract consumers pin their on-disk data
  // stores to: same string → same UUID across launches, rebuilds and
  // plugin versions. If this golden value ever drifts, every existing
  // container silently detaches from its data at the next app update —
  // so never "fix" the expected value here; fix whatever broke the
  // derivation instead. Expected value is SHA-256("ws-golden-container")
  // truncated to its first 16 bytes and formatted as a UUID. It is
  // deliberately identical to the iOS golden value: the derivation is
  // shared so a container id maps to the same UUID on both platforms.
  @available(macOS 14.0, *)
  func testContainerIdToUUIDIsStable() {
    XCTAssertEqual(containerIdToUUID("ws-golden-container").uuidString,
                   "EBC4B01E-6B6C-DAEB-E0D3-F38061A618A4")
    XCTAssertEqual(containerIdToUUID("ws-golden-container"),
                   containerIdToUUID("ws-golden-container"),
                   "same id must derive the same UUID within a process")
    XCTAssertNotEqual(containerIdToUUID("ws-golden-container"),
                      containerIdToUUID("ws-other-container"),
                      "distinct ids must not collide")
  }

  // The shared-wrapper cache is what keeps every WebView in a container
  // and every controller op on the same WKWebsiteDataStore instance —
  // wrapper duplication is what remove(forIdentifier:) counts as
  // "in use". Identity (===) is the property that matters, not equality.
  @available(macOS 14.0, *)
  func testGetOrCreateDataStoreReturnsSharedWrapper() {
    let first = ContainerManager.getOrCreateDataStore(forContainer: "runner-test-shared")
    let second = ContainerManager.getOrCreateDataStore(forContainer: "runner-test-shared")
    XCTAssertTrue(first === second,
                  "same containerId must resolve to the same wrapper instance")

    let other = ContainerManager.getOrCreateDataStore(forContainer: "runner-test-other")
    XCTAssertFalse(first === other,
                   "different containerIds must not share a wrapper")
  }

  // `proxySettings` is typed [String: Any?]?, which Objective-C cannot
  // represent, so @objcMembers emits no selector for it and ISettings.parse's
  // responds(to:) path would skip it; InAppWebViewSettings.parse binds it
  // explicitly. The value goes in as an NSDictionary because that is what
  // FlutterStandardMessageCodec decodes a Dart map into: the branch's
  // `as? [String: Any?]` has to survive that bridge, not just a native Swift
  // literal.
  @available(macOS 14.0, *)
  func testParseBindsProxySettings() {
    let proxyMap: NSDictionary = [
      "proxyRules": [["url": "socks5://127.0.0.1:9050"]]
    ]

    let parsed = InAppWebViewSettings().parse(settings: [
      "containerId": "runner-test-proxy",
      "proxySettings": proxyMap,
    ])

    XCTAssertNotNil(parsed.proxySettings,
                    "parse must bind proxySettings; preWKWebViewConfiguration skips a nil one")
    XCTAssertEqual(ProxySettings.fromMap(map: parsed.proxySettings)?.proxyRules.first?.url,
                   "socks5://127.0.0.1:9050",
                   "the bound map must still convert into ProxySettings")

    // containerId is a plain String?, which KVC does carry. It rides along
    // to show the failure was specific to the non-representable type
    // rather than to settings parsing at large.
    XCTAssertEqual(parsed.containerId, "runner-test-proxy")
  }

  // Companion to the above. If this ever starts responding, the property
  // became Objective-C representable and super.parse can carry it on its
  // own — at which point the explicit branch is redundant rather than
  // load-bearing, and this test is the place that says so.
  func testProxySettingsIsNotKeyValueCodable() {
    XCTAssertFalse(InAppWebViewSettings().responds(to: Selector(("proxySettings"))),
                   "no selector expected; if one appears the property type changed")
  }

  // ProxyManager keeps one table of who uses which proxy: an app-wide entry
  // and one per container. ProxyController and InAppWebViewSettings.
  // proxySettings both write to it, and a store only ever gets what it
  // resolves to. Each test uses containers of its own and leaves the
  // app-wide entry cleared.
  @available(macOS 14.0, *)
  private func route(_ key: String, ports: [UInt16]) -> ProxyManager.ProxyRoute {
    ProxyManager.ProxyRoute(
      configurations: ports.map {
        ProxyConfiguration(httpCONNECTProxy: .hostPort(host: "127.0.0.1",
                                                        port: NWEndpoint.Port(rawValue: $0)!))
      },
      key: key)
  }

  @available(macOS 14.0, *)
  private func settings(_ url: String) -> ProxySettings {
    ProxySettings.fromMap(map: ["proxyRules": [["url": url]] as [[String: Any?]]])!
  }

  private func freshContainer(_ name: String) -> String {
    "runner-test-\(name)-\(UUID().uuidString)"
  }

  // A container store is created lazily, the first time a WebView joins
  // the container, so it has to take the table's entry when it is created.
  @available(macOS 14.0, *)
  func testContainerStoreCreatedLaterTakesTheAppWideProxy() {
    ProxyManager.setRoute(route("app-wide", ports: [8083]), forContainer: nil)
    defer { ProxyManager.setRoute(nil, forContainer: nil) }

    let store = ContainerManager.getOrCreateDataStore(forContainer: freshContainer("replay"))
    XCTAssertEqual(store.proxyConfigurations.count, 1,
                   "a container store created while an app-wide proxy is set must carry it")
  }

  @available(macOS 14.0, *)
  func testContainerStoreCarriesNoProxyWithoutAnEntry() {
    let store = ContainerManager.getOrCreateDataStore(forContainer: freshContainer("none"))
    XCTAssertTrue(store.proxyConfigurations.isEmpty)
  }

  // A container with its own entry keeps it whatever the app-wide entry
  // does, cleared included.
  @available(macOS 14.0, *)
  func testAppWideProxyLeavesAContainerWithItsOwnAlone() {
    let id = freshContainer("own")
    let store = ContainerManager.getOrCreateDataStore(forContainer: id)
    // Two, so the count tells it from the single-entry app-wide proxy.
    ProxyManager.setRoute(route("own", ports: [9050, 9051]), forContainer: id)
    defer {
      ProxyManager.setRoute(nil, forContainer: id)
      ProxyManager.setRoute(nil, forContainer: nil)
    }

    ProxyManager.setRoute(route("app-wide", ports: [8083]), forContainer: nil)
    XCTAssertEqual(store.proxyConfigurations.count, 2)
    ProxyManager.setRoute(nil, forContainer: nil)
    XCTAssertEqual(store.proxyConfigurations.count, 2)
  }

  @available(macOS 14.0, *)
  func testContainerWithoutItsOwnFollowsTheAppWideProxy() {
    let store = ContainerManager.getOrCreateDataStore(forContainer: freshContainer("follows"))
    defer { ProxyManager.setRoute(nil, forContainer: nil) }

    ProxyManager.setRoute(route("app-wide", ports: [8083]), forContainer: nil)
    XCTAssertEqual(store.proxyConfigurations.count, 1)
    ProxyManager.setRoute(nil, forContainer: nil)
    XCTAssertTrue(store.proxyConfigurations.isEmpty)
  }

  // clearProxyOverride(containerId:) hands the container back to the
  // app-wide proxy, not to no proxy.
  @available(macOS 14.0, *)
  func testClearingAContainerFallsBackToTheAppWideProxy() {
    let id = freshContainer("cleared")
    let store = ContainerManager.getOrCreateDataStore(forContainer: id)
    defer { ProxyManager.setRoute(nil, forContainer: nil) }

    ProxyManager.setRoute(route("app-wide", ports: [8083]), forContainer: nil)
    ProxyManager.setRoute(route("own", ports: [9050, 9051]), forContainer: id)
    XCTAssertEqual(store.proxyConfigurations.count, 2)
    ProxyManager.setRoute(nil, forContainer: id)
    XCTAssertEqual(store.proxyConfigurations.count, 1)
  }

  // A WebView that names no proxy does not change its container's: opening
  // one must not move the WebViews already there.
  @available(macOS 14.0, *)
  func testWebViewWithoutProxySettingsLeavesItsContainerAlone() {
    let id = freshContainer("unset")
    let store = ContainerManager.getOrCreateDataStore(forContainer: id)
    ProxyManager.setRoute(route("own", ports: [9050, 9051]), forContainer: id)
    defer { ProxyManager.setRoute(nil, forContainer: id) }

    ProxyManager.bind(store: store, containerId: id, incognito: false, proxySettings: nil)
    XCTAssertEqual(store.proxyConfigurations.count, 2)
    XCTAssertEqual(ProxyManager.route(forContainer: id).key, "own")
  }

  // proxySettings on a WebView in a container is the same write as
  // ProxyController.setProxyOverride(containerId:), and either replaces
  // what the other set.
  @available(macOS 14.0, *)
  func testProxySettingsIsTheSameWriteAsProxyController() {
    let id = freshContainer("same")
    let store = ContainerManager.getOrCreateDataStore(forContainer: id)
    defer { ProxyManager.setRoute(nil, forContainer: id) }
    let fromWebView = settings("socks5://127.0.0.1:9050")

    ProxyManager.bind(store: store, containerId: id, incognito: false, proxySettings: fromWebView)
    XCTAssertEqual(ProxyManager.route(forContainer: id).key, fromWebView.key)
    XCTAssertEqual(store.proxyConfigurations.count, 1)

    ProxyManager.setRoute(route("controller", ports: [9050, 9051]), forContainer: id)
    XCTAssertEqual(store.proxyConfigurations.count, 2)

    ProxyManager.bind(store: store, containerId: id, incognito: false, proxySettings: fromWebView)
    XCTAssertEqual(store.proxyConfigurations.count, 1)
  }

  // Without a container or incognito, a WebView shares the default store,
  // and its proxySettings is ignored rather than applied to every WebView
  // on that store.
  @available(macOS 14.0, *)
  func testProxySettingsWithoutAContainerIsIgnored() {
    let store = WKWebsiteDataStore.default()
    ProxyManager.bind(store: store, containerId: nil, incognito: false,
                      proxySettings: settings("socks5://127.0.0.1:9050"))
    XCTAssertEqual(ProxyManager.route(forContainer: nil).key, "")
    XCTAssertTrue(store.proxyConfigurations.isEmpty)
  }

  // An incognito WebView owns its store, so its proxySettings is its own;
  // one that names none follows the app-wide proxy, changes included.
  @available(macOS 14.0, *)
  func testIncognitoStoresTakeTheirOwnOrTheAppWideProxy() {
    let own = WKWebsiteDataStore.nonPersistent()
    let follower = WKWebsiteDataStore.nonPersistent()
    defer { ProxyManager.setRoute(nil, forContainer: nil) }

    ProxyManager.bind(store: own, containerId: nil, incognito: true,
                      proxySettings: settings("socks5://127.0.0.1:9050"))
    ProxyManager.bind(store: follower, containerId: nil, incognito: true, proxySettings: nil)
    XCTAssertEqual(own.proxyConfigurations.count, 1)
    XCTAssertTrue(follower.proxyConfigurations.isEmpty)

    ProxyManager.setRoute(route("app-wide", ports: [8083, 8084]), forContainer: nil)
    XCTAssertEqual(own.proxyConfigurations.count, 1)
    XCTAssertEqual(follower.proxyConfigurations.count, 2)
  }

  // A change of route passes through a configuration that makes WebKit
  // rebuild the store's sessions. It is a means, not part of the route: the
  // store ends up with exactly what it was given.
  @available(macOS 14.0, *)
  func testSetProxyConfigurationsLeavesOnlyTheRouteAskedFor() {
    let store = ContainerManager.getOrCreateDataStore(forContainer: freshContainer("rebuild"))
    let socks = route("socks", ports: [9050])

    ProxyManager.setProxyConfigurations(socks, on: store)
    XCTAssertEqual(store.proxyConfigurations.count, 1)
    ProxyManager.setProxyConfigurations(socks, on: store)
    XCTAssertEqual(store.proxyConfigurations.count, 1)
    ProxyManager.setProxyConfigurations(.direct, on: store)
    XCTAssertTrue(store.proxyConfigurations.isEmpty)
  }

  // The key decides whether a store drops its connections, so it has to
  // change with anything that changes the route, not only the endpoint.
  @available(macOS 14.0, *)
  func testProxySettingsKeyCoversTheWholeRule() {
    func key(_ rule: [String: Any?]) -> String? {
      ProxySettings.fromMap(map: ["proxyRules": [rule] as [[String: Any?]]])?.key
    }
    let base: [String: Any?] = ["url": "socks5://127.0.0.1:9050", "username": "a", "password": "p"]
    XCTAssertEqual(key(base), key(["password": "p", "username": "a", "url": "socks5://127.0.0.1:9050"]))
    XCTAssertNotEqual(key(base), key(base.merging(["username": "b"]) { $1 }),
                      "a proxy can route by credentials")
    XCTAssertNotEqual(key(base), key(base.merging(["matchDomains": ["example.com"]]) { $1 }))
    XCTAssertNotEqual(key(base), key(base.merging(["url": "socks5://127.0.0.1:9051"]) { $1 }))
  }

  // toProxyConfigurations refuses a rule set that does not fully convert,
  // rather than handing back the rules that did. The empty array it used to
  // produce is not a no-op: WKWebsiteDataStore routes an empty array to
  // clearProxyConfigData, so one unusable rule would strip the proxy off a
  // live session instead of being refused.
  @available(macOS 14.0, *)
  func testPartiallyConvertibleRuleSetIsRefused() {
    let usable: [String: Any?] = [
      "proxyRules": [["url": "socks5://127.0.0.1:9050"]] as [[String: Any?]]
    ]
    XCTAssertEqual(ProxySettings.fromMap(map: usable)?.toProxyConfigurations()?.count, 1)

    // An empty url becomes "http://", which has no host, so that rule cannot
    // become a ProxyConfiguration.
    let partly: [String: Any?] = [
      "proxyRules": [["url": "socks5://127.0.0.1:9050"], ["url": ""]] as [[String: Any?]]
    ]
    XCTAssertNil(ProxySettings.fromMap(map: partly)?.toProxyConfigurations(),
                 "one unusable rule must refuse the whole set, not clear the proxy")
  }

  // An empty rule set names no proxy either. Its empty array would clear the
  // store's proxy the same way, so it is refused too; clearProxyOverride is
  // how a caller asks for no proxy.
  @available(macOS 14.0, *)
  func testEmptyRuleSetIsRefused() {
    let empty: [String: Any?] = ["proxyRules": [] as [[String: Any?]]]
    XCTAssertNil(ProxySettings.fromMap(map: empty)?.toProxyConfigurations(),
                 "an empty rule set must be refused, not clear the proxy")
  }

}
