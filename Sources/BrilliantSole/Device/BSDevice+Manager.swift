//
//  BSDevice+Manager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/29/25.
//

extension BSDevice {
    var managers: [any BSManager] {
        [batteryManager,
         informationManager,
         sensorConfigurationManager,
         sensorDataManager,
         vibrationManager,
         fileTransferManager,
         tfliteManager,
         wifiManager,
         smpManager]
    }

    func setupManagers() {
        setupBatteryManager()
        setupDeviceInformationManager()
        setupInformationManager()
        setupSensorConfiguration()
        setupSensorData()
        setupVibrationManager()
        setupFileTransfer()
        setupTfliteManager()
        setupWifiManager()
        setupFirmwareManager()
        for manager in managers {
            manager.setSendTxMessages { txMessages, sendImmediately in
                self.sendTxMessages(txMessages, sendImmediately: sendImmediately)
            }
        }
    }

    func resetManagers() {
        managers.forEach { $0.reset() }
    }
}
