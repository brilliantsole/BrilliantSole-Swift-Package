//
//  BSSensorType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSSensorType: UInt8, BSEnum {
    case pressure

    case acceleration
    case gravity
    case linearAcceleration
    case gyroscope
    case magnetometer
    case gameRotation
    case rotation

    case orientation
    case activity
    case stepCount
    case stepDetection
    case deviceOrientation

    case tapDetection

    case barometer

    case camera
    case microphone

    /// provides data at a continuous rate (as opposed to one-off events)
    public var isContinuous: Bool {
        switch self {
        case .activity, .stepCount, .stepDetection, .tapDetection, .camera, .microphone: // TODO: - make graph for microphone loudness later
            false
        default:
            true
        }
    }

    public var isMotion: Bool {
        switch self {
        case .acceleration, .gravity, .linearAcceleration, .gyroscope, .magnetometer, .gameRotation, .rotation, .orientation, .activity, .deviceOrientation, .stepCount, .stepDetection, .tapDetection:
            true
        default:
            false
        }
    }

    public var dataType: Any.Type {
        switch self {
        case .pressure:
            BSPressureDataTuple.self
        case .acceleration, .gravity, .linearAcceleration, .gyroscope, .magnetometer:
            BSVector3D.self
        case .gameRotation, .rotation:
            BSQuaternion.self
        case .orientation:
            BSRotation3D.self
        case .activity:
            BSActivityFlags.self
        case .stepCount:
            BSStepCount.self
        case .stepDetection:
            Void.self
        case .deviceOrientation:
            BSDeviceOrientation.self
        case .tapDetection:
            Void.self
        case .barometer:
            BSBarometer.self
        case .camera:
            Void.self // parsed using CameraManager
        case .microphone:
            Void.self // parsed using MicrophoneManager
        }
    }
}
