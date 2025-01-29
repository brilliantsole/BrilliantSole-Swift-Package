//
//  BSQuaternion.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import Foundation
import simd

private let logger = getLogger(category: "BSQuaternion")

typealias BSQuaternion = simd_quatd
private let quaternionNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumIntegerDigits = 1
    nf.minimumFractionDigits = 3
    nf.maximumFractionDigits = 3
    nf.positivePrefix = " "
    nf.paddingCharacter = "0"
    nf.paddingPosition = .afterSuffix
    return nf
}()

public extension BSQuaternion {
    fileprivate var nf: NumberFormatter { quaternionNumberFormatter }
    var strings: [String] {
        [
            "w:\(nf.string(for: vector.w)!)",
            "x:\(nf.string(for: vector.x)!)",
            "y:\(nf.string(for: vector.y)!)",
            "z:\(nf.string(for: vector.z)!)",
        ]
    }

    var string: String {
        strings.joined(separator: isWatch ? "\n" : ", ")
    }

    var array: [Double] {
        [vector.x, vector.y, vector.z, vector.w]
    }
}

extension BSQuaternion {
    static func parse(_ data: Data, scalar: Float) -> Self? {
        let rawX = Int16.parse(data, at: 0)
        let rawY = Int16.parse(data, at: 2)
        let rawZ = Int16.parse(data, at: 4)
        let rawW = Int16.parse(data, at: 6)

        guard let rawX, let rawY, let rawZ, let rawW else { return nil }

        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)
        let w = Double(rawW)

        let quaternion: Self = .init(ix: x, iy: y, iz: z, r: w) * Double(scalar)

        logger.debug("parsed quaternion: \(quaternion.debugDescription)")

        return quaternion
    }
}
