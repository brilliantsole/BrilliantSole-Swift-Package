//
//  BSDevice+ FirmwareUpgradeDelegate.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/8/25.
//

import Foundation
import iOSMcuManagerLibrary

extension BSDevice: FirmwareUpgradeDelegate {
    public func upgradeDidStart(controller: any iOSMcuManagerLibrary.FirmwareUpgradeController) {
        logger?.debug("firmware upgradeDidStart")
    }
    
    public func upgradeStateDidChange(from previousState: iOSMcuManagerLibrary.FirmwareUpgradeState, to newState: iOSMcuManagerLibrary.FirmwareUpgradeState) {
        logger?.debug("firmware upgradeStateDidChange from \(String(describing: previousState)) to \(String(describing: newState))")
    }
    
    public func upgradeDidComplete() {
        logger?.debug("firmware upgradeDidComplete")
    }
    
    public func upgradeDidFail(inState state: iOSMcuManagerLibrary.FirmwareUpgradeState, with error: any Error) {
        logger?.debug("firmware upgradeDidFail inState \(String(describing: state)): \(error.localizedDescription)")
    }
    
    public func upgradeDidCancel(state: iOSMcuManagerLibrary.FirmwareUpgradeState) {
        logger?.debug("firmware upgradeDidCancel state \(String(describing: state))")
    }
    
    public func uploadProgressDidChange(bytesSent: Int, imageSize: Int, timestamp: Date) {
        let progress = Float(bytesSent) / Float(imageSize)
        logger?.debug("firmware uploadProgressDidChange bytesSent: \(bytesSent), imageSize: \(imageSize), progress: \(progress * 100)% timestamp: \(timestamp)")
    }
}
