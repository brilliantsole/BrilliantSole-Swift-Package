//
//  BSVibrationSegment.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/18/25.
//

import Foundation

public protocol BSVibrationSegment {
    var data: Data { get }
    static var type: BSVibrationType { get }
    var type: BSVibrationType { get }
}

public extension BSVibrationSegment {
    var type: BSVibrationType { Self.type }
}
