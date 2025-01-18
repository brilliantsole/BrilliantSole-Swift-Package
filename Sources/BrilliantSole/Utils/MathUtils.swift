//
//  MathUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import simd
import Spatial

// MARK: - Interpolation

public typealias InterpolationParameter = Double

public protocol Interpolatable {
    static func *(lhs: Self, rhs: InterpolationParameter) -> Self
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Float: Interpolatable {
    public static func *(lhs: Float, rhs: InterpolationParameter) -> Float {
        lhs * Float(rhs)
    }
}

extension Double: Interpolatable {}
extension Vector3D: Interpolatable {}

extension simd_float3: Interpolatable {
    public static func *(lhs: SIMD3<Scalar>, rhs: InterpolationParameter) -> SIMD3<Scalar> {
        lhs * Float(rhs)
    }
}

public func interpolate<T: Interpolatable>(from start: T, to end: T, with parameter: InterpolationParameter) -> T {
    start * (1.0 - parameter) + end * parameter
}

public extension Interpolatable {
    mutating func interpolate(to value: Self, with parameter: InterpolationParameter) {
        self = BrilliantSole.interpolate(from: self, to: value, with: parameter)
    }
}

// MARK: - GetInterpolation

public func clamp<T: Comparable>(_ value: T, min lower: T, max upper: T) -> T {
    if value < lower {
        return lower
    }
    else if value > upper {
        return upper
    }
    else {
        return value
    }
}

public protocol GetInterpolatable: Comparable {
    static func /(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
}

extension Float: GetInterpolatable {}
extension Double: GetInterpolatable {}

public func getInterpolation<T: GetInterpolatable>(of value: T, between from: T, and to: T, clampValue: Bool) -> T {
    let lower = min(from, to)
    let upper = max(from, to)
    let _value = clampValue ? clamp(value, min: lower, max: upper) : value
    return (_value - lower) / (upper - lower)
}

public extension GetInterpolatable {
    func getInterpolation(between from: Self, and to: Self, clampValue: Bool) -> Self {
        BrilliantSole.getInterpolation(of: self, between: from, and: to, clampValue: clampValue)
    }
}
