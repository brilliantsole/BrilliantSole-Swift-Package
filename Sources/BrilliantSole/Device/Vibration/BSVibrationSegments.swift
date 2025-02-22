//
//  BSVibrationSegments.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/18/25.
//

import Foundation

public typealias BSVibrationSegments = [any BSVibrationSegment]

public protocol BSVibrationSegmentsProtocol {
    var data: Data { get }
    static var type: BSVibrationType { get }
    var type: BSVibrationType { get }
    var maxLength: Int { get }
}

public extension BSVibrationSegmentsProtocol {
    var maxLength: Int { type.maxSegmentsLength }
    var type: BSVibrationType { Self.type }
}

extension Array: BSVibrationSegmentsProtocol where Element: BSVibrationSegment {
    public var data: Data { .init() }
    public static var type: BSVibrationType { Element.type }
    func getMaxLengthPrefix() -> Self {
        guard count <= maxLength else {
            return .init(prefix(maxLength))
        }
        return self
    }
}
