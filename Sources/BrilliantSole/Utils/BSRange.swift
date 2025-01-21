//
//  BSRange.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import OSLog
import UkatonMacros

@StaticLogger
public struct BSRange {
    public private(set) var min: Float = -.infinity
    public private(set) var max: Float = .infinity
    public private(set) var span: Float = 0

    public mutating func reset() {
        min = Float.infinity
        max = -Float.infinity
        span = 0
#if DEBUG
        let string = String(describing: self)
        logger.debug("reset range \(string)")
#endif
    }

    init() {
        reset()
    }

    mutating func update(with value: Float) {
        min = .minimum(min, value)
        max = .maximum(max, value)
        span = max - min
#if DEBUG
        let string = String(describing: self)
        logger.debug("updated range \(string)")
#endif
    }

    func getNormalization(for value: Float, weightBySpan: Bool) -> Float {
        if span == 0 {
            return 0
        }
        var interpolation: Float = (value - min) / span
        if weightBySpan {
            interpolation *= span
        }
        return interpolation
    }

    mutating func updateAndGetNormalization(for value: Float, weightBySpan: Bool) -> Float {
        update(with: value)
        return getNormalization(for: value, weightBySpan: weightBySpan)
    }
}
