//
//  Util.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 12/02/21.
//

import Foundation
import WebKit

var SharedLastTouchPointTimestamp: [InAppWebView: Int64] = [:]

public class Util {
    public static func getUrlAsset(assetFilePath: String) throws -> URL {
        let key = SwiftFlutterPlugin.instance!.registrar!.lookupKey(forAsset: assetFilePath)
        guard let assetURL = Bundle.main.url(forResource: key, withExtension: nil) else {
            throw NSError(domain: assetFilePath + " asset file cannot be found!", code: 0)
        }
        return assetURL
    }
    
    public static func getAbsPathAsset(assetFilePath: String) throws -> String {
        let key = SwiftFlutterPlugin.instance!.registrar!.lookupKey(forAsset: assetFilePath)
        guard let assetAbsPath = Bundle.main.path(forResource: key, ofType: nil) else {
            throw NSError(domain: assetFilePath + " asset file cannot be found!", code: 0)
        }
        return assetAbsPath
    }
    
    public static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    public static func JSONStringify(value: Any, prettyPrinted: Bool = false) -> String {
        let options: JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : .init(rawValue: 0)
        if JSONSerialization.isValidJSONObject(value) {
            let data = try? JSONSerialization.data(withJSONObject: value, options: options)
            if data != nil {
                if let string = String(data: data!, encoding: .utf8) {
                    return string
                }
            }
        }
        return ""
    }
    
    @available(iOS 14.0, *)
    public static func getContentWorld(name: String) -> WKContentWorld {
        switch name {
        case "defaultClient":
            return WKContentWorld.defaultClient
        case "page":
            return WKContentWorld.page
        default:
            return WKContentWorld.world(name: name)
        }
    }
    
    @available(iOS 10.0, *)
    public static func getDataDetectorType(type: String) -> WKDataDetectorTypes {
        switch type {
            case "NONE":
                return WKDataDetectorTypes.init(rawValue: 0)
            case "PHONE_NUMBER":
                return .phoneNumber
            case "LINK":
                return .link
            case "ADDRESS":
                return .address
            case "CALENDAR_EVENT":
                return .calendarEvent
            case "TRACKING_NUMBER":
                return .trackingNumber
            case "FLIGHT_NUMBER":
                return .flightNumber
            case "LOOKUP_SUGGESTION":
                return .lookupSuggestion
            case "SPOTLIGHT_SUGGESTION":
                return .spotlightSuggestion
            case "ALL":
                return .all
            default:
                return WKDataDetectorTypes.init(rawValue: 0)
        }
    }
    
    @available(iOS 10.0, *)
    public static func getDataDetectorTypeString(type: WKDataDetectorTypes) -> [String] {
        var dataDetectorTypeString: [String] = []
        if type.contains(.all) {
            dataDetectorTypeString.append("ALL")
        } else {
            if type.contains(.phoneNumber) {
                dataDetectorTypeString.append("PHONE_NUMBER")
            }
            if type.contains(.link) {
                dataDetectorTypeString.append("LINK")
            }
            if type.contains(.address) {
                dataDetectorTypeString.append("ADDRESS")
            }
            if type.contains(.calendarEvent) {
                dataDetectorTypeString.append("CALENDAR_EVENT")
            }
            if type.contains(.trackingNumber) {
                dataDetectorTypeString.append("TRACKING_NUMBER")
            }
            if type.contains(.flightNumber) {
                dataDetectorTypeString.append("FLIGHT_NUMBER")
            }
            if type.contains(.lookupSuggestion) {
                dataDetectorTypeString.append("LOOKUP_SUGGESTION")
            }
            if type.contains(.spotlightSuggestion) {
                dataDetectorTypeString.append("SPOTLIGHT_SUGGESTION")
            }
        }
        if dataDetectorTypeString.count == 0 {
            dataDetectorTypeString = ["NONE"]
        }
        return dataDetectorTypeString
    }
    
    public static func getDecelerationRate(type: String) -> UIScrollView.DecelerationRate {
        switch type {
            case "NORMAL":
                return .normal
            case "FAST":
                return .fast
            default:
                return .normal
        }
    }
    
    public static func getDecelerationRateString(type: UIScrollView.DecelerationRate) -> String {
        switch type {
            case .normal:
                return "NORMAL"
            case .fast:
                return "FAST"
            default:
                return "NORMAL"
        }
    }
}
