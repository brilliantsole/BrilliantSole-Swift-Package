//
//  BSSensorType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

@EnumName
public enum BSSensorType: UInt8, CaseIterable {
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

    case barometer
}
