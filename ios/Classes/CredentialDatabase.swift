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
                for (protectionSpace, credentials) in CredentialDatabase.credentialStore!.allCredentials {
                    let protectionSpaceDict = [
                        "host": protectionSpace.host,
                        "protocol": protectionSpace.protocol,
                        "realm": protectionSpace.realm,
                        "port": protectionSpace.port
                        ] as [String : Any?]
                    
                    var crendentials: [[String: String?]] = []
                    for c in credentials {
                        if let username = c.value.user, let password = c.value.password {
                            let credential: [String: String] = [
                                "username": username,
                                "password": password,
                            ]
                            crendentials.append(credential)
                        }
                    }
                    
                    if crendentials.count > 0 {
                        let dict = [
                            "protectionSpace": protectionSpaceDict,
                            "credentials": crendentials
                            ] as [String : Any]
                        allCredentials.append(dict)
                    }                }
                result(allCredentials)
                break
            case "getHttpAuthCredentials":
                let host = arguments!["host"] as! String
                let urlProtocol = arguments!["protocol"] as? String
                let urlPort = arguments!["port"] as? Int ?? 0
                var realm = arguments!["realm"] as? String;
                if let r = realm, r.isEmpty {
                    realm = nil
                }
                var crendentials: [[String: String?]] = []

                for (protectionSpace, credentials) in CredentialDatabase.credentialStore!.allCredentials {
                    if protectionSpace.host == host && protectionSpace.realm == realm &&
                    protectionSpace.protocol == urlProtocol && protectionSpace.port == urlPort {
                        for c in credentials {
                            if let username = c.value.user, let password = c.value.password {
                                let credential: [String: String] = [
                                    "username": username,
                                    "password": password,
                                ]
                                crendentials.append(credential)
                            }
                        }
                        break
                    }
                }
                result(crendentials)
                break
            case "setHttpAuthCredential":
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
                CredentialDatabase.credentialStore!.set(credential, for: URLProtectionSpace(host: host, port: urlPort, protocol: urlProtocol, realm: realm, authenticationMethod: NSURLAuthenticationMethodHTTPBasic))
                result(true)
                break
            case "removeHttpAuthCredential":
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
                
                for (protectionSpace, credentials) in CredentialDatabase.credentialStore!.allCredentials {
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
                    CredentialDatabase.credentialStore!.remove(c, for: protectionSpace)
                }
                
                result(true)
                break
            case "removeHttpAuthCredentials":
                let host = arguments!["host"] as! String
                let urlProtocol = arguments!["protocol"] as? String
                let urlPort = arguments!["port"] as? Int ?? 0
                var realm = arguments!["realm"] as? String;
                if let r = realm, r.isEmpty {
                    realm = nil
                }
                
                var credentialsToRemove: [URLCredential] = [];
                var protectionSpaceCredential: URLProtectionSpace? = nil
                
                for (protectionSpace, credentials) in CredentialDatabase.credentialStore!.allCredentials {
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
                        CredentialDatabase.credentialStore!.remove(credential, for: protectionSpace)
                    }
                }
                
                result(true)
                break
            case "clearAllAuthCredentials":
                for (protectionSpace, credentials) in CredentialDatabase.credentialStore!.allCredentials {
                    for credential in credentials {
                        CredentialDatabase.credentialStore!.remove(credential.value, for: protectionSpace)
                    }
                }
                result(true)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
        }
    }
}
