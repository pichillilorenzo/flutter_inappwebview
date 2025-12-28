# libwpe 1.0

`libwpe` defines interfaces which can be used by
[WebKit](https://webkit.org), and a mechanism for loading a *WPE backend*
which implements them. Using the public `libwpe` API decouples WebKit from
the platform-specific behaviour, which is implemented by each individual
backend.
