//
//  BSSmpEventType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSSmpEventType: UInt8, CaseIterable, Sendable {
    case firmwareImages
    case firmwareUploadProgress
    case firmwareStatus
    case firmwareUploadComplete
}
