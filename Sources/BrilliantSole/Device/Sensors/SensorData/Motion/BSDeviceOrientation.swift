//
//  BSDeviceOrientation.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

@EnumName
public enum BSDeviceOrientation: UInt8, CaseIterable, Sendable {
    case portraitUpright
    case landscapeLeft
    case portraitUpsideDown
    case landscapeRight
    case unknown
}
