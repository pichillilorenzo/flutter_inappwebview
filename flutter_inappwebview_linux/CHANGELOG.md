## 0.1.0-beta.2

- Implemented `PlatformContainerController` (`getAllContainerNames`, `hasContainer`, `deleteContainer`, `clearContainerData`) and `InAppWebViewSettings.containerId` via per-container `WebKitNetworkSession`s (WPE WebKit 2.40+)
- Implemented `InAppWebViewSettings.proxySettings` for WebViews with a `containerId` or `incognito`
- `ProxyController.setProxyOverride` and `clearProxyOverride` also apply to container and incognito sessions, and with a `containerId` set or clear that container's proxy, the same setting as `InAppWebViewSettings.proxySettings`; a rule set with no usable proxy is refused
- Proxy rule URLs without a scheme are treated as `http://`, as on Android, instead of leaving requests unproxied
- `deleteContainer` also drops the proxy set for that container

## 0.1.0-beta.1

- Initial release.
