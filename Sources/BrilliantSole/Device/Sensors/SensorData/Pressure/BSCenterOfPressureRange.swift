//
//  BSCenterOfPressureRange.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import OSLog
import simd
import UkatonMacros

public typealias BSCenterOfPressure = simd_double2

@StaticLogger(disabled: true)
struct BSCenterOfPressureRange {
    var x: BSRange = .init()
    var y: BSRange = .init()

    mutating func reset() {
        x.reset()
        y.reset()
    }

    mutating func update(with value: BSCenterOfPressure) {
        x.update(with: Float(value.x))
        y.update(with: Float(value.y))
#if DEBUG
        let string = String(describing: self)
        logger?.debug("updated to \(string)")
#endif
    }

    func getNormalization(for value: BSCenterOfPressure) -> BSCenterOfPressure {
        .init(
            x: Double(x.getNormalization(for: Float(value.x), weightBySpan: false)),
            y: Double(y.getNormalization(for: Float(value.y), weightBySpan: false))
        )
    }

    mutating func updateAndGetNormalization(for value: BSCenterOfPressure) -> BSCenterOfPressure {
        update(with: value)
        return getNormalization(for: value)
    }
}
