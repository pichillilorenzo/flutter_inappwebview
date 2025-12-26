export interface InAppWebViewSettings {
  javaScriptBridgeEnabled?: boolean;
  javaScriptBridgeOriginAllowList?: string[];
  javaScriptCanOpenWindowsAutomatically?: boolean;
  verticalScrollBarEnabled?: boolean;
  horizontalScrollBarEnabled?: boolean;
  disableVerticalScroll?: boolean;
  disableHorizontalScroll?: boolean;
  disableContextMenu?: boolean;
}

export interface InAppWebView {
  viewId: any,
  iframeId: string,
  iframe?: HTMLIFrameElement | null,
  iframeContainer?: HTMLDivElement | null,
  isFullscreen: boolean,
  documentTitle?: string | null,
  functionMap: {
    "window.open"?: any;
  },
  settings: InAppWebViewSettings,
  javaScriptBridgeEnabled: boolean,
  disableContextMenuHandler: (event: Event) => boolean,
  prepare: (settings: { [key: string]: any }) => void,
  setSettings: (newSettings: InAppWebViewSettings) => void,
  reload: () => void,
  goBack: () => void,
  goForward: () => void,
  goBackOrForward: (steps: number) => void,
  evaluateJavascript: (source: string) => any,
  stopLoading: () => void,
  getUrl: () => string | null | undefined,
  getTitle: () => string | null | undefined,
  injectJavascriptFileFromUrl: (urlFile: string, scriptHtmlTagAttributes: { [key: string]: any }) => void,
  injectCSSCode: (source: string) => void,
  injectCSSFileFromUrl: (urlFile: string, cssLinkHtmlTagAttributes: { [key: string]: any }) => void,
  scrollTo: (x: number, y: number, animated: boolean) => void,
  scrollBy: (x: number, y: number, animated: boolean) => void,
  printCurrentPage: () => void,
  getContentHeight: () => number | null | undefined,
  getContentWidth: () => number | null | undefined,
  getSelectedText: () => string | null | undefined,
  getScrollX: () => number | null | undefined,
  getScrollY: () => number | null | undefined,
  isSecureContext: () => boolean,
  canScrollVertically: () => boolean,
  canScrollHorizontally: () => boolean,
  getSize: () => { width: number, height: number }
}

export interface InAppWebViewPlugin {
  createFlutterInAppWebView: (viewId: number | string, iframe: HTMLIFrameElement, iframeContainer: HTMLDivElement, bridgeSecret: string) => InAppWebView,
  getCookieExpirationDate: (timestamp: number) => string,
  nativeAsyncCommunication: (method: string, viewId: number | string, args?: any[]) => Promise<string>,
  nativeSyncCommunication: (method: string, viewId: number | string, args?: any[]) => string,
  nativeCommunication: <T>(method: string, viewId: number | string, args?: any[]) => T,
}

export interface JavaScriptBridgeHandler {
  callHandler: (handlerName: string, ...args: any[]) => Promise<any>
}

export enum UserScriptInjectionTime {
  AT_DOCUMENT_START = 0,
  AT_DOCUMENT_END = 1
}

export interface UserScript {
  allowedOriginRules?: string[] | null;
  forMainFrameOnly: boolean;
  groupName?: string | null;
  injectionTime: UserScriptInjectionTime;
  source: string;
}