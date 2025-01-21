//
//  BSRange.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import OSLog

private let logger = getLogger(category: "BSRange")

public struct BSRange<T: BinaryFloatingPoint> {
    public private(set) var min: T = -.infinity
    public private(set) var max: T = .infinity
    public private(set) var span: T = 0

    public mutating func reset() {
        min = T.infinity
        max = -T.infinity
        span = 0
        let string = String(describing: self)
        logger.debug("reset range \(string)")
    }

    init() {
        reset()
    }

    mutating func update(with value: T) {
        min = .minimum(min, value)
        max = .maximum(max, value)
        span = max - min
        let string = String(describing: self)
        logger.debug("updated range \(string)")
    }

    func getNormalization(for value: T, weightBySpan: Bool) -> T {
        if span == 0 {
            return 0
        }
        var interpolation: T = (value - min) / span
        if weightBySpan {
            interpolation *= span
        }
        return interpolation
    }

    mutating func updateAndGetNormalization(for value: T, weightBySpan: Bool) -> T {
        update(with: value)
        return getNormalization(for: value, weightBySpan: weightBySpan)
    }
}
