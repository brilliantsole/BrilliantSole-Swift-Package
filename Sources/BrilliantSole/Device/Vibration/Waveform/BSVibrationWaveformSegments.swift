//
//  BSVibrationWaveformSegment.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation

public typealias BSVibrationWaveformSegments = [BSVibrationWaveformSegment]

public extension Array where Element == BSVibrationWaveformSegment {
    var type: BSVibrationType { .waveform }

    func getData() -> Data {
        var data: Data = .init()
        data += prefix(Int(maxLength)).flatMap { $0.data }
        return data
    }
}
