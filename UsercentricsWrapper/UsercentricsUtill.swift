//
//  UsercentricsUtill.swift
//  UsercentricsWrapper
//
//  Created by Gevorg Kopalyan on 03.12.24.
//

import Foundation
import Usercentrics
import UsercentricsUI
import os

@objc public class UsercentricsUtill:NSObject{
    let logger = Logger(
        subsystem: "com.rockbite.UsercentricsWrapper",
        category: "main"
    )
    
    weak var delegate: SDKInitListener?
    var _isGDPR:Bool = false;
    var _isDebug:Bool = false;
    
    @objc public func showConcentDialog(){
        self.debugLog("UserCentricsImpl: showConcentDialog init banner")
        let banner = UsercentricsBanner()
        self.debugLog("UserCentricsImpl: showConcentDialog show banner")
        banner.showFirstLayer() { userResponse in
            // Handle userResponse
            self.debugLog("UserCentricsImpl: showConcentDialog response \(userResponse.consents)")
        }
    }
    
    @objc public func initUsercentricsSDK(
        rulesetId: String,
        isDebug: Bool,
        consentMediation: Bool
    ) {
        self._isDebug = isDebug
        /// Initialize Usercentrics with your configuration
        self.debugLog("UserCentricsImpl: init sdk")
        let options = UsercentricsOptions()
        options.ruleSetId = rulesetId
        options.loggerLevel = isDebug ? .debug : .none
        
        options.consentMediation = consentMediation
        
        UsercentricsCore.configure(options: options)
        
        self.debugLog("UserCentricsImpl: call isready")
        
        UsercentricsCore.isReady { [weak self] status in
            guard let self = self else { return }
            
            if(isDebug){
                cleanUserSession()
            }
            
            if status.geolocationRuleset != nil && status.geolocationRuleset?.bannerRequiredAtLocation == false {
                self.debugLog("UserCentricsImpl: not EU no banner needed")
                _isGDPR = false
                notifyDelegate(success: true, error: nil)
                return
            }
            
            if status.shouldCollectConsent {
                // Show banner to collect consent
                _isGDPR = true
                self.debugLog("UserCentricsImpl: should show a bnner")
                let banner = UsercentricsBanner()
                self.debugLog("UserCentricsImpl: show the bnner")
                banner.showFirstLayer() { userResponse in
                    // Handle userResponse
                    self.debugLog("UserCentricsImpl: banner response \(userResponse.consents)")
                    self.delegate?.sdkDidInitialize(success: true, error: nil)
                    self.debugLog("UserCentricsImpl: delegate called")
                }
                
            } else {
                // Apply consent with status.consents
                _isGDPR = true
                self.debugLog("UserCentricsImpl: apply consent")
                self.delegate?.sdkDidInitialize(success: true, error: nil)
                self.debugLog("UserCentricsImpl: delegate called")
            }
        } onFailure: { error in
            // Handle non-localized error
            self.logger
                .log("UserCentricsImpl: error \(error.localizedDescription)")
            self.delegate?.sdkDidInitialize(success: false, error: error)
            self.debugLog("UserCentricsImpl: delegate called")
        }
    }
    
    private func notifyDelegate(success: Bool, error: Error?) {
        delegate?.sdkDidInitialize(success: success, error: error)
        let isDelegateNull = (delegate != nil) ? true : false
        logger.log("UserCentricsImpl: delegate called \(isDelegateNull)" )
    }
    
    @objc public func isGDPR() -> Bool{
        return _isGDPR
    }
    
    @objc public func cleanUserSession() {
        self.debugLog("UserCentricsImpl: clear session in debug mode")
        UsercentricsCore.shared.clearUserSession(
            onSuccess: { status in
                // This callback is equivalent to isReady API
                self.logger
                    .log("UserCentricsImpl: clear session success")
            },
            onError: { error in
                // Handle non-localized error
                self.logger
                    .log(
                        "UserCentricsImpl: clear session error \(error.localizedDescription)"
                    )
            })
    }
    
    @objc(setSDKInitListener:)
    public func setListener(_ listener: SDKInitListener) {
        self.delegate = listener
    }
    
    func debugLog(_ message: String) {
        if _isDebug {
            self.logger.log("\(message, privacy: .public)")
        }
    }
}

@objc public protocol SDKInitListener: AnyObject {
    func sdkDidInitialize(success: Bool, error: Error?)
}
