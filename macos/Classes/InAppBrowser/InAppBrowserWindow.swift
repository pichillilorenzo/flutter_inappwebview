//
//  InAppBrowserNavigationController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 14/02/21.
//

import Foundation

struct ToolbarIdentifiers {
    static let searchBar = NSToolbarItem.Identifier(rawValue: "SearchBar")
    static let backButton = NSToolbarItem.Identifier(rawValue: "BackButton")
    static let forwardButton = NSToolbarItem.Identifier(rawValue: "ForwardButton")
    static let reloadButton = NSToolbarItem.Identifier(rawValue: "ReloadButton")
}

public class InAppBrowserWindow : NSWindow, NSWindowDelegate, NSToolbarDelegate, NSSearchFieldDelegate {
    var searchItem: NSToolbarItem?
    var backItem: NSToolbarItem?
    var forwardItem: NSToolbarItem?
    var reloadItem: NSToolbarItem?
    
    var reloadButton: NSButton? {
        get {
            return reloadItem?.view as? NSButton
        }
    }
    var backButton: NSButton? {
        get {
            return backItem?.view as? NSButton
        }
    }
    var forwardButton: NSButton? {
        get {
            return forwardItem?.view as? NSButton
        }
    }
    var searchBar: NSSearchField? {
        get {
            if #available(macOS 11.0, *), let searchItem = searchItem as? NSSearchToolbarItem {
                return searchItem.searchField
            } else {
                return searchItem?.view as? NSSearchField
            }
        }
    }
    
    var browserSettings: InAppBrowserSettings?
    
    public func prepare() {
        title = ""
        collectionBehavior = .fullScreenPrimary
        delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMainWindowClose(_:)),
                                               name: NSWindow.willCloseNotification,
                                               object: NSApplication.shared.mainWindow)
        
        if #available(macOS 10.13, *) {
            let windowToolbar = NSToolbar()
            windowToolbar.delegate = self
            if #available(macOS 11.0, *) {
                searchItem = NSSearchToolbarItem(itemIdentifier: ToolbarIdentifiers.searchBar)
                (searchItem as! NSSearchToolbarItem).searchField.delegate = self
                toolbarStyle = .expanded
            } else {
                searchItem = NSToolbarItem(itemIdentifier: ToolbarIdentifiers.searchBar)
                let textField = NSSearchField()
                textField.usesSingleLineMode = true
                textField.delegate = self
                searchItem?.view = textField
            }
            searchItem?.label = ""
            windowToolbar.displayMode = .default
            
            backItem = NSToolbarItem(itemIdentifier: ToolbarIdentifiers.backButton)
            backItem?.label = ""
            if let webViewController = contentViewController as? InAppBrowserWebViewController {
                if #available(macOS 11.0, *) {
                    backItem?.view = NSButton(image: NSImage(systemSymbolName: "chevron.left",
                                                                  accessibilityDescription: "Go Back")!,
                                                   target: webViewController,
                                                   action: #selector(InAppBrowserWebViewController.goBack))
                } else {
                    backItem?.view = NSButton(title: "\u{2039}",
                                                target: webViewController,
                                                action: #selector(InAppBrowserWebViewController.goBack))
                }
            }
            
            forwardItem = NSToolbarItem(itemIdentifier: ToolbarIdentifiers.forwardButton)
            forwardItem?.label = ""
            if let webViewController = contentViewController as? InAppBrowserWebViewController {
                if #available(macOS 11.0, *) {
                    forwardItem?.view = NSButton(image: NSImage(systemSymbolName: "chevron.right",
                                                                  accessibilityDescription: "Go Forward")!,
                                                   target: webViewController,
                                                   action: #selector(InAppBrowserWebViewController.goForward))
                } else {
                    forwardItem?.view = NSButton(title: "\u{203A}",
                                                   target: webViewController,
                                                   action: #selector(InAppBrowserWebViewController.goForward))
                }
            }
            
            reloadItem = NSToolbarItem(itemIdentifier: ToolbarIdentifiers.reloadButton)
            reloadItem?.label = ""
            if let webViewController = contentViewController as? InAppBrowserWebViewController {
                if #available(macOS 11.0, *) {
                    reloadItem?.view = NSButton(image: NSImage(systemSymbolName: "arrow.counterclockwise",
                                                                  accessibilityDescription: "Reload")!,
                                                   target: webViewController,
                                                   action: #selector(InAppBrowserWebViewController.reload))
                } else {
                    reloadItem?.view = NSButton(title: "Reload",
                                                   target: webViewController,
                                                   action: #selector(InAppBrowserWebViewController.reload))
                }
            }
            
            if #available(macOS 10.14, *) {
                windowToolbar.centeredItemIdentifier = ToolbarIdentifiers.searchBar
            }
            toolbar = windowToolbar
        }
        
        forwardButton?.isEnabled = false
        backButton?.isEnabled = false
        
        if let browserSettings = browserSettings {
            if let toolbarTopFixedTitle = browserSettings.toolbarTopFixedTitle {
                title = toolbarTopFixedTitle
            }
            if !browserSettings.hideToolbarTop {
                toolbar?.isVisible = true
                if browserSettings.hideUrlBar {
                    if #available(macOS 11.0, *) {
                        (searchItem as! NSSearchToolbarItem).searchField.isHidden = true
                    } else {
                        searchItem?.view?.isHidden = true
                    }
                }
                if let bgColor = browserSettings.toolbarTopBackgroundColor, !bgColor.isEmpty {
                    backgroundColor = NSColor(hexString: bgColor)
                }
            }
            else {
                toolbar?.isVisible = false
            }
            if #available(macOS 11.0, *), let windowTitlebarSeparatorStyle = browserSettings.windowTitlebarSeparatorStyle {
                titlebarSeparatorStyle = windowTitlebarSeparatorStyle
            }
            alphaValue = browserSettings.windowAlphaValue
            if let windowStyleMask = browserSettings.windowStyleMask {
                styleMask = windowStyleMask
            }
            if let windowFrame = browserSettings.windowFrame {
                setFrame(windowFrame, display: true)
            }
        }
    }
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [ ToolbarIdentifiers.searchBar,
                 ToolbarIdentifiers.backButton,
                 ToolbarIdentifiers.forwardButton,
                 ToolbarIdentifiers.reloadButton,
                 .flexibleSpace ]
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace,
                ToolbarIdentifiers.searchBar,
                .flexibleSpace,
                ToolbarIdentifiers.reloadButton,
                ToolbarIdentifiers.backButton,
                ToolbarIdentifiers.forwardButton]
    }
    
    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch(itemIdentifier) {
        case ToolbarIdentifiers.searchBar:
            return searchItem
        case ToolbarIdentifiers.backButton:
            return backItem
        case ToolbarIdentifiers.forwardButton:
            return forwardItem
        case ToolbarIdentifiers.reloadButton:
            return reloadItem
        default:
            return nil
        }
    }
    
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            // ENTER key
            var searchField: NSSearchField? = nil
            if #available(macOS 11.0, *), let searchBar = searchItem as? NSSearchToolbarItem {
                searchField = searchBar.searchField
            } else if let searchBar = searchItem {
                searchField = searchBar.view as? NSSearchField
            }
            
            guard let searchField,
                  let urlEncoded = searchField.stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: urlEncoded) else {
                return false
            }
            
            let request = URLRequest(url: url)
            (contentViewController as? InAppBrowserWebViewController)?.webView?.load(request)
            
            return true
        }

        return false
    }
    
    public func hide() {
        orderOut(self)
        
    }
    
    public func show() {
        if #available(macOS 10.12, *),
           !(NSApplication.shared.mainWindow?.tabbedWindows?.contains(self) ?? false),
           browserSettings?.windowType == .tabbed {
            NSApplication.shared.mainWindow?.addTabbedWindow(self, ordered: .above)
        } else if !(NSApplication.shared.mainWindow?.childWindows?.contains(self) ?? false) {
            NSApplication.shared.mainWindow?.addChildWindow(self, ordered: .above)
        } else {
            orderFront(self)
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    public func setSettings(newSettings: InAppBrowserSettings, newSettingsMap: [String: Any]) {
        if newSettingsMap["hidden"] != nil, browserSettings?.hidden != newSettings.hidden {
            if newSettings.hidden {
                hide()
            }
            else {
                show()
            }
        }

        if newSettingsMap["hideUrlBar"] != nil, browserSettings?.hideUrlBar != newSettings.hideUrlBar {
            searchBar?.isHidden = newSettings.hideUrlBar
        }
        
        if newSettingsMap["hideToolbarTop"] != nil, browserSettings?.hideToolbarTop != newSettings.hideToolbarTop {
            toolbar?.isVisible = !newSettings.hideToolbarTop
        }

        if newSettingsMap["toolbarTopBackgroundColor"] != nil, browserSettings?.toolbarTopBackgroundColor != newSettings.toolbarTopBackgroundColor {
            if let bgColor = newSettings.toolbarTopBackgroundColor, !bgColor.isEmpty {
                backgroundColor = NSColor(hexString: bgColor)
            } else {
                backgroundColor = nil
            }
        }
        browserSettings = newSettings
    }
    
    public func windowWillClose(_ notification: Notification) {
        dispose()
    }
    
    @objc func onMainWindowClose(_ notification: Notification) {
        close()
    }
    
    
    public func dispose() {
        delegate = nil
        if let webViewController = contentViewController as? InAppBrowserWebViewController {
            webViewController.dispose()
        }
        if #available(macOS 11.0, *) {
            (searchItem as? NSSearchToolbarItem)?.searchField.delegate = nil
        } else {
            (searchItem?.view as? NSTextField)?.delegate = nil
            searchItem?.view = nil
        }
        searchItem = nil
        (backItem?.view as? NSButton)?.target = nil
        backItem?.view = nil
        backItem = nil
        (forwardItem?.view as? NSButton)?.target = nil
        forwardItem?.view = nil
        forwardItem = nil
        (reloadItem?.view as? NSButton)?.target = nil
        reloadItem?.view = nil
        reloadItem = nil
    }
    
    deinit {
        debugPrint("InAppBrowserWindow - dealloc")
        dispose()
    }
}
