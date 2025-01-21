//
//  BSTfliteTask.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import UkatonMacros

@EnumName
public enum BSTfliteTask: UInt8, CaseIterable, Sendable {
    case classification
    case regression
}
