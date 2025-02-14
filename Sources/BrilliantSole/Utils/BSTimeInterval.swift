//
//  BSTimeInterval.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/14/25.
//

import Foundation

public typealias BSTimeInterval = TimeInterval

private let timeIntervalNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.usesSignificantDigits = true
    nf.alwaysShowsDecimalSeparator = true
    nf.minimumIntegerDigits = 1
    nf.minimumSignificantDigits = 2
    nf.maximumSignificantDigits = 3
    return nf
}()

func timeIntervalString(interval: BSTimeInterval) -> String? {
    guard var string = timeIntervalNumberFormatter.string(for: interval * 1000) else {
        return nil
    }
    return string.padding(toLength: 5, withPad: "0", startingAt: 0)
}
