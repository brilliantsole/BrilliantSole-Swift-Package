//
//  BSDeviceType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

@EnumName
public enum BSDeviceType: UInt8, CaseIterable, Sendable {
    case leftInsole
    case rightInsole
}
