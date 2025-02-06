//
//  BSBaseClient+Scanning.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

import Foundation

extension BSBaseClient {
    func parseIsScanningAvailable(_ data: Data) {
        guard let isScanningAvailable = Bool.parse(data) else {
            return
        }
        self.isScanningAvailable = isScanningAvailable
    }

    func checkIfScanning() {
        logger.debug("checking if scanning")
        sendMessages([.init(type: .isScanning)])
    }

    func parseIsScanning(_ data: Data) {
        guard let isScanning = Bool.parse(data) else {
            return
        }
        self.isScanning = isScanning
    }
}
