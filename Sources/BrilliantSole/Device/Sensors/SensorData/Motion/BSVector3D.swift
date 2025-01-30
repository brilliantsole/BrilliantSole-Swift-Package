//
//  BSVector3D.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import Foundation
import OSLog
import Spatial

public typealias BSVector3D = Vector3D

private let logger = getLogger(category: "BSVector3D")

private let vector3DNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumIntegerDigits = 2
    nf.minimumFractionDigits = 3
    nf.maximumFractionDigits = 3
    nf.positivePrefix = " "
    nf.paddingCharacter = "0"
    nf.paddingPosition = .afterSuffix
    return nf
}()

public extension BSVector3D {
    fileprivate var nf: NumberFormatter { vector3DNumberFormatter }
    var strings: [String] {
        [
            "x:\(nf.string(for: x)!)",
            "y:\(nf.string(for: y)!)",
            "z:\(nf.string(for: z)!)",
        ]
    }

    var string: String {
        strings.joined(separator: isWatch ? "\n" : ", ")
    }

    var array: [Double] {
        [x, y, z]
    }
}

extension BSVector3D {
    static func parse(_ data: Data, scalar: Float) -> Self? {
        let rawX = Int16.parse(data, at: 0)
        let rawY = Int16.parse(data, at: 2)
        let rawZ = Int16.parse(data, at: 4)

        guard let rawX, let rawY, let rawZ else {
            return nil
        }

        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)

        let vector: Self = .init(x: x, y: y, z: z).uniformlyScaled(by: Double(scalar))

        logger.debug("parsed vector: \(vector)")

        return vector
    }
}
