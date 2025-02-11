//
//  BSFileType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
public enum BSFileType: UInt8, BSEnum {
    case tflite

    var fileExtension: String {
        switch self {
        case .tflite:
            return "tflite"
        }
    }
}
