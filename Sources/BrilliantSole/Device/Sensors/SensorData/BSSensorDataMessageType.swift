//
//  BSSensorDataMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import UkatonMacros

@EnumName
public enum BSSensorDataMessageType: UInt8, BSEnum {
    case getPressurePositions
    case getSensorScalars
    case sensorData
}
