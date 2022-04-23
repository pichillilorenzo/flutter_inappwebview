//
//  CredentialDatabase.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 29/10/2019.
//

import Foundation

class CredentialDatabase: NSObject, FlutterPlugin {

    static var registrar: FlutterPluginRegistrar?
    static var channel: FlutterMethodChannel?
    static var credentialStore: URLCredentialStorage?

    static func register(with registrar: FlutterPluginRegistrar) {
        
    }

    init(registrar: FlutterPluginRegistrar) {
        super.init()
        CredentialDatabase.registrar = registrar
        CredentialDatabase.credentialStore = URLCredentialStorage.shared
        
        CredentialDatabase.channel = FlutterMethodChannel(name: "com.pichillilorenzo/flutter_inappwebview_credential_database", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: CredentialDatabase.channel!)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
            case "getAllAuthCredentials":
                var allCredentials: [[String: Any?]] = []
                guard let credentialStore = CredentialDatabase.credentialStore else {
                    result(allCredentials)
                    return
                }
                for (protectionSpace, credentials) in credentialStore.allCredentials {
                    var crendentials: [[String: Any?]] = []
                    for c in credentials {
                        let credential: [String: Any?] = c.value.toMap()
                        crendentials.append(credential)
                    }
                    if crendentials.count > 0 {
                        let dict: [String : Any] = [
                            "protectionSpace": protectionSpace.toMap(),
                            "credentials": crendentials
                        ]
                        allCredentials.append(dict)
                    }
                }
                result(allCredentials)
                break
            case "getHttpAuthCredentials":
                var crendentials: [[String: Any?]] = []
                guard let credentialStore = CredentialDatabase.credentialStore else {
                    result(crendentials)
                    return
                }
            
                let host = arguments!["host"] as! String
                let urlProtocol = arguments!["protocol"] as? String
                let urlPort = arguments!["port"] as? Int ?? 0
                var realm = arguments!["realm"] as? String;
                if let r = realm, r.isEmpty {
                    realm = nil
                }

                for (protectionSpace, credentials) in credentialStore.allCredentials {
                    if protectionSpace.host == host && protectionSpace.realm == realm &&
                    protectionSpace.protocol == urlProtocol && protectionSpace.port == urlPort {
                        for c in credentials {
                            crendentials.append(c.value.toMap())
                        }
                        break
                    }
                }
                result(crendentials)
                break
            case "setHttpAuthCredential":
                guard let credentialStore = CredentialDatabase.credentialStore else {
                    result(false)
                    return
                }
            
                let host = arguments!["host"] as! String
                let urlProtocol = arguments!["protocol"] as? String
                let urlPort = arguments!["port"] as? Int ?? 0
                var realm = arguments!["realm"] as? String;
                if let r = realm, r.isEmpty {
                    realm = nil
                }
                let username = arguments!["username"] as! String
                let password = arguments!["password"] as! String
                let credential = URLCredential(user: username, password: password, persistence: .permanent)
                credentialStore.set(credential,
                                    for: URLProtectionSpace(host: host, port: urlPort, protocol: urlProtocol,
                                                            realm: realm, authenticationMethod: NSURLAuthenticationMethodHTTPBasic))
                result(true)
                break
            case "removeHttpAuthCredential":
                guard let credentialStore = CredentialDatabase.credentialStore else {
                    result(false)
                    return
                }
            
                let host = arguments!["host"] as! String
                let urlProtocol = arguments!["protocol"] as? String
                let urlPort = arguments!["port"] as? Int ?? 0
                var realm = arguments!["realm"] as? String;
                if let r = realm, r.isEmpty {
                    realm = nil
                }
                let username = arguments!["username"] as! String
                let password = arguments!["password"] as! String
                
                var credential: URLCredential? = nil;
                var protectionSpaceCredential: URLProtectionSpace? = nil
                
                for (protectionSpace, credentials) in credentialStore.allCredentials {
                    if protectionSpace.host == host && protectionSpace.realm == realm &&
                    protectionSpace.protocol == urlProtocol && protectionSpace.port == urlPort {
                        for c in credentials {
                            if c.value.user == username, c.value.password == password {
                                credential = c.value
                                protectionSpaceCredential = protectionSpace
                                break
                            }
                        }
                    }
                    if credential != nil {
                        break
                    }
                }
                
                if let c = credential, let protectionSpace = protectionSpaceCredential {
                    credentialStore.remove(c, for: protectionSpace)
                }
                
                result(true)
                break
            case "removeHttpAuthCredentials":
                guard let credentialStore = CredentialDatabase.credentialStore else {
                    result(false)
                    return
                }
            
                let host = arguments!["host"] as! String
                let urlProtocol = arguments!["protocol"] as? String
                let urlPort = arguments!["port"] as? Int ?? 0
                var realm = arguments!["realm"] as? String;
                if let r = realm, r.isEmpty {
                    realm = nil
                }
                
                var credentialsToRemove: [URLCredential] = [];
                var protectionSpaceCredential: URLProtectionSpace? = nil
                
                for (protectionSpace, credentials) in credentialStore.allCredentials {
                    if protectionSpace.host == host && protectionSpace.realm == realm &&
                    protectionSpace.protocol == urlProtocol && protectionSpace.port == urlPort {
                        protectionSpaceCredential = protectionSpace
                        for c in credentials {
                            if let _ = c.value.user, let _ = c.value.password {
                                credentialsToRemove.append(c.value)
                            }
                        }
                        break
                    }
                }
                
                if let protectionSpace = protectionSpaceCredential {
                    for credential in credentialsToRemove {
                        credentialStore.remove(credential, for: protectionSpace)
                    }
                }
                
                result(true)
                break
            case "clearAllAuthCredentials":
                guard let credentialStore = CredentialDatabase.credentialStore else {
                    result(false)
                    return
                }
            
                for (protectionSpace, credentials) in credentialStore.allCredentials {
                    for credential in credentials {
                        credentialStore.remove(credential.value, for: protectionSpace)
                    }
                }
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
    
    public func dispose() {
        CredentialDatabase.channel?.setMethodCallHandler(nil)
        CredentialDatabase.channel = nil
        CredentialDatabase.registrar = nil
        CredentialDatabase.credentialStore = nil
    }
}
