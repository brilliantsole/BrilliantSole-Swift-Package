//
//  BSBarometer.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import Foundation

private let logger = getLogger(category: "BSBarometer")

typealias BSBarometer = Float

extension BSBarometer {
    static func parse(_ data: Data, scalar: Float) -> Self {
        var barometer: Float = .parse(from: data, at: 0)
        barometer *= scalar
        logger.debug("parsed barometer: \(barometer)")
        return barometer
    }
}
