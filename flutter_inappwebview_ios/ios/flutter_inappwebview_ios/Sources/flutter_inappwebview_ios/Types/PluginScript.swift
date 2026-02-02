//
//  PluginScript.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 17/02/21.
//

import Foundation
import WebKit

public class PluginScript: UserScript {
    var requiredInAllContentWorlds = false
    var messageHandlerNames: [String] = []
    
    public override init(source: String, injectionTime: WKUserScriptInjectionTime, forMainFrameOnly: Bool) {
        super.init(source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly)
    }
    
    public init(groupName: String, source: String, injectionTime: WKUserScriptInjectionTime, forMainFrameOnly: Bool, allowedOriginRules: [String]?, requiredInAllContentWorlds: Bool = false, messageHandlerNames: [String] = []) {
        super.init(groupName: groupName, source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly, allowedOriginRules: allowedOriginRules)
        self.requiredInAllContentWorlds = requiredInAllContentWorlds
        self.messageHandlerNames = messageHandlerNames
    }
    
    @available(iOS 14.0, *)
    public override init(source: String, injectionTime: WKUserScriptInjectionTime, forMainFrameOnly: Bool, in contentWorld: WKContentWorld) {
        super.init(source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly, in: contentWorld)
        self.contentWorld = contentWorld
    }
    
    @available(iOS 14.0, *)
    public init(source: String, injectionTime: WKUserScriptInjectionTime, forMainFrameOnly: Bool, in contentWorld: WKContentWorld, requiredInAllContentWorlds: Bool = false, messageHandlerNames: [String] = []) {
        super.init(source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly, in: contentWorld)
        self.requiredInAllContentWorlds = requiredInAllContentWorlds
        self.messageHandlerNames = messageHandlerNames
    }

    @available(iOS 14.0, *)
    public init(groupName: String, source: String, injectionTime: WKUserScriptInjectionTime, forMainFrameOnly: Bool, in contentWorld: WKContentWorld,
                allowedOriginRules: [String]?, requiredInAllContentWorlds: Bool = false, messageHandlerNames: [String] = []) {
        super.init(groupName: groupName, source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly, in: contentWorld, allowedOriginRules: allowedOriginRules)
        self.requiredInAllContentWorlds = requiredInAllContentWorlds
        self.messageHandlerNames = messageHandlerNames
    }
    
    public func copyAndSet(groupName: String? = nil,
                           source: String? = nil,
                           injectionTime: WKUserScriptInjectionTime? = nil,
                           forMainFrameOnly: Bool? = nil,
                           requiredInAllContentWorlds: Bool? = nil,
                           allowedOriginRules: [String]? = nil,
                           messageHandlerNames: [String]? = nil) -> PluginScript {
        if #available(iOS 14.0, *) {
            return PluginScript(
                groupName: groupName ?? self.groupName!,
                source: source ?? self.source,
                injectionTime: injectionTime ?? self.injectionTime,
                forMainFrameOnly: forMainFrameOnly ?? self.isForMainFrameOnly,
                in: self.contentWorld,
                allowedOriginRules: allowedOriginRules ?? self.allowedOriginRules,
                requiredInAllContentWorlds: requiredInAllContentWorlds ?? self.requiredInAllContentWorlds,
                messageHandlerNames: messageHandlerNames ?? self.messageHandlerNames
            )
        }
        return PluginScript(
            groupName: groupName ?? self.groupName!,
            source: source ?? self.source,
            injectionTime: injectionTime ?? self.injectionTime,
            forMainFrameOnly: forMainFrameOnly ?? self.isForMainFrameOnly,
            allowedOriginRules: allowedOriginRules ?? self.allowedOriginRules,
            requiredInAllContentWorlds: requiredInAllContentWorlds ?? self.requiredInAllContentWorlds,
            messageHandlerNames: messageHandlerNames ?? self.messageHandlerNames
        )
    }
    
    @available(iOS 14.0, *)
    public func copyAndSet(groupName: String? = nil,
                           source: String? = nil,
                           injectionTime: WKUserScriptInjectionTime? = nil,
                           forMainFrameOnly: Bool? = nil,
                           contentWorld: WKContentWorld? = nil,
                           allowedOriginRules: [String]? = nil,
                           requiredInAllContentWorlds: Bool? = nil,
                           messageHandlerNames: [String]? = nil) -> PluginScript {
        return PluginScript(
            groupName: groupName ?? self.groupName!,
            source: source ?? self.source,
            injectionTime: injectionTime ?? self.injectionTime,
            forMainFrameOnly: forMainFrameOnly ?? self.isForMainFrameOnly,
            in: contentWorld ?? self.contentWorld,
            allowedOriginRules: allowedOriginRules ?? self.allowedOriginRules,
            requiredInAllContentWorlds: requiredInAllContentWorlds ?? self.requiredInAllContentWorlds,
            messageHandlerNames: messageHandlerNames ?? self.messageHandlerNames
        )
    }

    static func == (lhs: PluginScript, rhs: PluginScript) -> Bool {
        if #available(iOS 14.0, *) {
            return lhs.groupName == rhs.groupName &&
                lhs.source == rhs.source &&
                lhs.injectionTime == rhs.injectionTime &&
                lhs.isForMainFrameOnly == rhs.isForMainFrameOnly &&
                lhs.contentWorld == rhs.contentWorld &&
                lhs.allowedOriginRules == rhs.allowedOriginRules &&
                lhs.requiredInAllContentWorlds == rhs.requiredInAllContentWorlds &&
                lhs.messageHandlerNames == rhs.messageHandlerNames
        } else {
            return lhs.groupName == rhs.groupName &&
                lhs.source == rhs.source &&
                lhs.injectionTime == rhs.injectionTime &&
                lhs.isForMainFrameOnly == rhs.isForMainFrameOnly &&
                lhs.allowedOriginRules == rhs.allowedOriginRules &&
                lhs.requiredInAllContentWorlds == rhs.requiredInAllContentWorlds &&
                lhs.messageHandlerNames == rhs.messageHandlerNames
        }
    }
}
