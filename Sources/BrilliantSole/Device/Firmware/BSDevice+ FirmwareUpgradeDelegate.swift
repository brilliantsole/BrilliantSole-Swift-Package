//
//  BSDevice+ FirmwareUpgradeDelegate.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/8/25.
//

import Foundation
import iOSMcuManagerLibrary

extension BSDevice: FirmwareUpgradeDelegate {
    public func upgradeDidStart(controller: any FirmwareUpgradeController) {
        logger?.debug("firmware upgradeDidStart")
        firmwareUpgradeDidStartSubject.send(self)
    }
    
    public func upgradeStateDidChange(from previousState: FirmwareUpgradeState, to newState: FirmwareUpgradeState) {
        logger?.debug("firmware upgradeStateDidChange from \(String(describing: previousState)) to \(String(describing: newState))")
        firmwareUpgradeStateDidChangeSubject.send((self, previousState, newState))
    }
    
    public func upgradeDidComplete() {
        logger?.debug("firmware upgradeDidComplete")
        firmwareUpgradeDidCompleteSubject.send(self)
    }
    
    public func upgradeDidFail(inState state: FirmwareUpgradeState, with error: any Error) {
        logger?.debug("firmware upgradeDidFail inState \(String(describing: state)): \(error.localizedDescription)")
        firmwareUpgradeDidFailSubject.send((self, state, error))
    }
    
    public func upgradeDidCancel(state: FirmwareUpgradeState) {
        logger?.debug("firmware upgradeDidCancel state \(String(describing: state))")
        firmwareUpgradeDidCancelSubject.send((self, state))
    }
    
    public func uploadProgressDidChange(bytesSent: Int, imageSize: Int, timestamp: Date) {
        let progress = Float(bytesSent) / Float(imageSize)
        logger?.debug("firmware uploadProgressDidChange bytesSent: \(bytesSent), imageSize: \(imageSize), progress: \(progress * 100)% timestamp: \(timestamp)")
        firmwareUploadProgressDidChangeSubject.send((self, bytesSent, imageSize, progress, timestamp))
    }
}
