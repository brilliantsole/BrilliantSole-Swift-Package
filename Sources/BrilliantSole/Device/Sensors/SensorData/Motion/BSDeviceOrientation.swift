//
//  BSDeviceOrientation.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation
import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSDeviceOrientation: UInt8, BSEnum {
    case portraitUpright
    case landscapeLeft
    case portraitUpsideDown
    case landscapeRight
    case unknown
}
