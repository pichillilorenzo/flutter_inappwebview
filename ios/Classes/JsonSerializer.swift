/*The MIT License (MIT)
 Copyright (c) 2015 Peter Helstrup Jensen
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.*/

import Foundation

/// Handles Convertion from instances of objects to JSON strings. Also helps with casting strings of JSON to Arrays or Dictionaries.
open class JSONSerializer {
    
    /**
     Errors that indicates failures of JSONSerialization
     - JsonIsNotDictionary:    -
     - JsonIsNotArray:            -
     - JsonIsNotValid:            -
     */
    public enum JSONSerializerError: Error {
        case jsonIsNotDictionary
        case jsonIsNotArray
        case jsonIsNotValid
    }
    
    //http://stackoverflow.com/questions/30480672/how-to-convert-a-json-string-to-a-dictionary
    /**
     Tries to convert a JSON string to a NSDictionary. NSDictionary can be easier to work with, and supports string bracket referencing. E.g. personDictionary["name"].
     - parameter jsonString:    JSON string to be converted to a NSDictionary.
     - throws: Throws error of type JSONSerializerError. Either JsonIsNotValid or JsonIsNotDictionary. JsonIsNotDictionary will typically be thrown if you try to parse an array of JSON objects.
     - returns: A NSDictionary representation of the JSON string.
     */
    open static func toDictionary(_ jsonString: String) throws -> NSDictionary {
        if let dictionary = try jsonToAnyObject(jsonString) as? NSDictionary {
            return dictionary
        } else {
            throw JSONSerializerError.jsonIsNotDictionary
        }
    }
    
    /**
     Tries to convert a JSON string to a NSArray. NSArrays can be iterated and each item in the array can be converted to a NSDictionary.
     - parameter jsonString:    The JSON string to be converted to an NSArray
     - throws: Throws error of type JSONSerializerError. Either JsonIsNotValid or JsonIsNotArray. JsonIsNotArray will typically be thrown if you try to parse a single JSON object.
     - returns: NSArray representation of the JSON objects.
     */
    open static func toArray(_ jsonString: String) throws -> NSArray {
        if let array = try jsonToAnyObject(jsonString) as? NSArray {
            return array
        } else {
            throw JSONSerializerError.jsonIsNotArray
        }
    }
    
    /**
     Tries to convert a JSON string to AnyObject. AnyObject can then be casted to either NSDictionary or NSArray.
     - parameter jsonString:    JSON string to be converted to AnyObject
     - throws: Throws error of type JSONSerializerError.
     - returns: Returns the JSON string as AnyObject
     */
    fileprivate static func jsonToAnyObject(_ jsonString: String) throws -> Any? {
        var any: Any?
        
        if let data = jsonString.data(using: String.Encoding.utf8) {
            do {
                any = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            }
            catch let error as NSError {
                let sError = String(describing: error)
                NSLog(sError)
                throw JSONSerializerError.jsonIsNotValid
            }
        }
        return any
    }
    
    /**
     Generates the JSON representation given any custom object of any custom class. Inherited properties will also be represented.
     - parameter object:    The instantiation of any custom class to be represented as JSON.
     - returns: A string JSON representation of the object.
     */
    open static func toJson(_ object: Any, prettify: Bool = false) -> String {
        var json = ""
        if (!(object is Array<Any>)) {
            json += "{"
        }
        let mirror = Mirror(reflecting: object)
        
        var children = [(label: String?, value: Any)]()
        
        if let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children) {
            children += mirrorChildrenCollection
        }
        else {
            let mirrorIndexCollection = AnyCollection(mirror.children)
            children += mirrorIndexCollection
        }
        
        var currentMirror = mirror
        while let superclassChildren = currentMirror.superclassMirror?.children {
            let randomCollection = AnyRandomAccessCollection(superclassChildren)!
            children += randomCollection
            currentMirror = currentMirror.superclassMirror!
        }
        
        var filteredChildren = [(label: String?, value: Any)]()
        
        for (optionalPropertyName, value) in children {
            
            if let optionalPropertyName = optionalPropertyName {
                
                if !optionalPropertyName.contains("notMapped_") {
                    filteredChildren.append((optionalPropertyName, value))
                }
                
            }
            else {
                filteredChildren.append((nil, value))
            }
        }
        
        var skip = false
        let size = filteredChildren.count
        var index = 0
        
        var first = true
        
        for (optionalPropertyName, value) in filteredChildren {
            skip = false
            
            let propertyName = optionalPropertyName
            let property = Mirror(reflecting: value)
            
            var handledValue = String()
            
            if propertyName != nil && propertyName == "some" && property.displayStyle == Mirror.DisplayStyle.struct {
                handledValue = toJson(value)
                skip = true
            }
            else if (value is Int ||
                value is Int32 ||
                value is Int64 ||
                value is Double ||
                value is Float ||
                value is Bool) && property.displayStyle != Mirror.DisplayStyle.optional {
                handledValue = String(describing: value)
            }
            else if let array = value as? [Int?] {
                handledValue += "["
                for (index, value) in array.enumerated() {
                    handledValue += value != nil ? String(value!) : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [Double?] {
                handledValue += "["
                for (index, value) in array.enumerated() {
                    handledValue += value != nil ? String(value!) : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [Float?] {
                handledValue += "["
                for (index, value) in array.enumerated() {
                    handledValue += value != nil ? String(value!) : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [Bool?] {
                handledValue += "["
                for (index, value) in array.enumerated() {
                    handledValue += value != nil ? String(value!) : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [String?] {
                handledValue += "["
                for (index, value) in array.enumerated() {
                    handledValue += value != nil ? "\"\(value!)\"" : "null"
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? [String] {
                handledValue += "["
                for (index, value) in array.enumerated() {
                    handledValue += "\"\(value)\""
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if let array = value as? NSArray {
                handledValue += "["
                for (index, value) in array.enumerated() {
                    if !(value is Int) &&
                        !(value is Int32) &&
                        !(value is Int64) &&
                        !(value is Double) && !(value is Float) && !(value is Bool) && !(value is String) {
                        handledValue += toJson(value)
                    }
                    else {
                        handledValue += "\(value)"
                    }
                    handledValue += (index < array.count-1 ? ", " : "")
                }
                handledValue += "]"
            }
            else if property.displayStyle == Mirror.DisplayStyle.class ||
                property.displayStyle == Mirror.DisplayStyle.struct ||
                String(describing: value).contains("#") {
                handledValue = toJson(value)
            }
            else if property.displayStyle == Mirror.DisplayStyle.optional {
                let str = String(describing: value)
                if str != "nil" {
                    // Some optional values cannot be unpacked if type is "Any"
                    // We remove the "Optional(" and last ")" from the value by string manipulation
                    var d = String(str).dropFirst(9)
                    d = d.dropLast(1)
                    handledValue = String(d)
                } else {
                    handledValue = "null"
                }
            }
            else {
                handledValue = String(describing: value) != "nil" ? "\"\(value)\"" : "null"
            }
            
            if !skip {
                
                // if optional propertyName is populated we'll use it
                if let propertyName = propertyName {
                    json += "\"\(propertyName)\": \(handledValue)" + (index < size-1 ? ", " : "")
                }
                    // if not then we have a member an array
                else {
                    // if it's the first member we need to prepend ]
                    if first {
                        json += "["
                        first = false
                    }
                    // if it's not the last we need a comma. if it is the last we need to close ]
                    json += "\(handledValue)" + (index < size-1 ? ", " : "]")
                }
                
            } else {
                json = "\(handledValue)" + (index < size-1 ? ", " : "")
            }
            
            index += 1
        }
        
        if !skip {
            if (!(object is Array<Any>)) {
                json += "}"
            }
        }
        
        if prettify {
            let jsonData = json.data(using: String.Encoding.utf8)!
            let jsonObject = try! JSONSerialization.jsonObject(with: jsonData, options: [])
            let prettyJsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            json = NSString(data: prettyJsonData, encoding: String.Encoding.utf8.rawValue)! as String
        }
        
        return json
    }
    
    
}
