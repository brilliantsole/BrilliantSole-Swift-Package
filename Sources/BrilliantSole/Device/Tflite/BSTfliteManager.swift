//
//  BSTfliteManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import OSLog
import UkatonMacros

@StaticLogger
class BSTfliteManager: BSBaseManager<BSTfliteMessageType> {
    override class var requiredMessageTypes: [BSTfliteMessageType]? {
        [
            .getTfliteName,
            .getTfliteTask,
            .getTfliteSensorRate,
            .getTfliteSensorTypes,
            .isTfliteReady,
            .getTfliteCaptureDelay,
            .getTfliteThreshold,
            .getTfliteInferencingEnabled,
        ]
    }

    override func onRxMessage(_ messageType: BSTfliteMessageType, data: Data) {
        switch messageType {
        case .getTfliteName:
            print("FILL")
        case .setTfliteName:
            print("FILL")
        case .getTfliteTask:
            print("FILL")
        case .setTfliteTask:
            print("FILL")
        case .getTfliteSensorRate:
            print("FILL")
        case .setTfliteSensorRate:
            print("FILL")
        case .getTfliteSensorTypes:
            print("FILL")
        case .setTfliteSensorTypes:
            print("FILL")
        case .isTfliteReady:
            print("FILL")
        case .getTfliteCaptureDelay:
            print("FILL")
        case .setTfliteCaptureDelay:
            print("FILL")
        case .getTfliteThreshold:
            print("FILL")
        case .setTfliteThreshold:
            print("FILL")
        case .getTfliteInferencingEnabled:
            print("FILL")
        case .setTfliteInferencingEnabled:
            print("FILL")
        case .tfliteInference:
            print("FILL")
        }
    }
}
