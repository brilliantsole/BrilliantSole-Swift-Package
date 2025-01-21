//
//  BSCenterOfPressureRange.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import OSLog
import simd

private let logger = getLogger(category: "BSRange")

public typealias BSCenterOfPressure = simd_double2

struct BSCenterOfPressureRange<T: BinaryFloatingPoint> {
    var x: BSRange<T> = .init()
    var y: BSRange<T> = .init()

    mutating func reset() {
        x.reset()
        y.reset()
    }

    mutating func update(with value: BSCenterOfPressure) {
        x.update(with: T(value.x))
        y.update(with: T(value.y))
        let string = String(describing: self)
        logger.debug("updated to \(string)")
    }

    func getNormalization(for value: BSCenterOfPressure) -> BSCenterOfPressure {
        .init(
            x: Double(x.getNormalization(for: T(value.x), weightBySpan: false)),
            y: Double(y.getNormalization(for: T(value.y), weightBySpan: false))
        )
    }
}
