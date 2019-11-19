//
//  MyCookieManager.swift
//  flutter_inappbrowser
//
//  Created by Lorenzo on 26/10/18.
//

import Foundation
import WebKit

@available(iOS 11.0, *)
class MyCookieManager: NSObject, FlutterPlugin {

    static var registrar: FlutterPluginRegistrar?
    static var channel: FlutterMethodChannel?
    static var httpCookieStore: WKHTTPCookieStore?
    
    static func register(with registrar: FlutterPluginRegistrar) {
        
    }
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        MyCookieManager.registrar = registrar
        MyCookieManager.httpCookieStore = WKWebsiteDataStore.default().httpCookieStore
        
        MyCookieManager.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappbrowser_cookiemanager", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: MyCookieManager.channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "setCookie":
                let url = arguments!["url"] as! String
                let name = arguments!["name"] as! String
                let value = arguments!["value"] as! String
                let domain = arguments!["domain"] as! String
                let path = arguments!["path"] as! String
                let expiresDate = arguments!["expiresDate"] as? Int
                let maxAge = arguments!["maxAge"] as? Int
                let isSecure = arguments!["isSecure"] as? Bool
                
                MyCookieManager.setCookie(url: url, name: name, value: value, domain: domain, path: path, expiresDate: expiresDate, maxAge: maxAge, isSecure: isSecure, result: result)
                break
            case "getCookies":
                let url = arguments!["url"] as! String
                MyCookieManager.getCookies(url: url, result: result)
                break
            case "deleteCookie":
                let url = arguments!["url"] as! String
                let name = arguments!["name"] as! String
                let domain = arguments!["domain"] as! String
                let path = arguments!["path"] as! String
                MyCookieManager.deleteCookie(url: url, name: name, domain: domain, path: path, result: result)
                break;
            case "deleteCookies":
                let url = arguments!["url"] as! String
                let domain = arguments!["domain"] as! String
                let path = arguments!["path"] as! String
                MyCookieManager.deleteCookies(url: url, domain: domain, path: path, result: result)
                break;
            case "deleteAllCookies":
                MyCookieManager.deleteAllCookies(result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public static func setCookie(url: String,
                          name: String,
                          value: String,
                          domain: String,
                          path: String,
                          expiresDate: Int?,
                          maxAge: Int?,
                          isSecure: Bool?,
                          result: @escaping FlutterResult) {
        var properties: [HTTPCookiePropertyKey: Any] = [:]
        properties[.originURL] = url
        properties[.name] = name
        properties[.value] = value
        properties[.domain] = domain
        properties[.path] = path
        if expiresDate != nil {
            properties[.expires] = NSDate(timeIntervalSince1970: Double(expiresDate!))
        }
        if maxAge != nil {
            properties[.maximumAge] = String(maxAge!)
        }
        properties[.secure] = (isSecure != nil && isSecure!) ? "TRUE" : "FALSE"
        
        let cookie = HTTPCookie(properties: properties)!
        MyCookieManager.httpCookieStore!.setCookie(cookie, completionHandler: {() in
            result(true)
        })
    }
    
    public static func getCookies(url: String, result: @escaping FlutterResult) {
        var cookieList: [[String: Any]] = []
        MyCookieManager.httpCookieStore!.getAllCookies { (cookies) in
            for cookie in cookies {
                if cookie.domain.contains(URL(string: url)!.host!) {
                    cookieList.append([
                        "name": cookie.name,
                        "value": cookie.value
                    ])
                }
            }
            result(cookieList)
        }
    }
    
    public static func deleteCookie(url: String, name: String, domain: String, path: String, result: @escaping FlutterResult) {
        MyCookieManager.httpCookieStore!.getAllCookies { (cookies) in
            for cookie in cookies {
                var originURL = ""
                if cookie.properties![.originURL] is String {
                    originURL = cookie.properties![.originURL] as! String
                }
                else if cookie.properties![.originURL] is URL {
                    originURL = (cookie.properties![.originURL] as! URL).absoluteString
                }
                if (!originURL.isEmpty && originURL != url) {
                    continue
                }
                if cookie.domain.contains(domain) && cookie.name == name && cookie.path == path {
                    MyCookieManager.httpCookieStore!.delete(cookie, completionHandler: {
                        result(true)
                    })
                    return
                }
            }
            result(false)
        }
    }
    
    public static func deleteCookies(url: String, domain: String, path: String, result: @escaping FlutterResult) {
        MyCookieManager.httpCookieStore!.getAllCookies { (cookies) in
            for cookie in cookies {
                var originURL = ""
                if cookie.properties![.originURL] is String {
                    originURL = cookie.properties![.originURL] as! String
                }
                else if cookie.properties![.originURL] is URL{
                    originURL = (cookie.properties![.originURL] as! URL).absoluteString
                }
                if (!originURL.isEmpty && originURL != url) {
                    continue
                }
                if cookie.domain.contains(domain) && cookie.path == path {
                    MyCookieManager.httpCookieStore!.delete(cookie, completionHandler: nil)
                }
            }
            result(true)
        }
    }
    
    public static func deleteAllCookies(result: @escaping FlutterResult) {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeCookies])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{
            result(true)
        })
    }
}
