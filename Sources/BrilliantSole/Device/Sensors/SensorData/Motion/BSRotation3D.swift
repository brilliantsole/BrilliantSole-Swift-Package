//
//  BSRotation3D.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import Foundation
import Spatial

private let logger = getLogger(category: "BSRotation3D", disabled: true)

public typealias BSRotation3D = Rotation3D

private let rotation3DNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumIntegerDigits = 1
    nf.minimumFractionDigits = 4
    nf.maximumFractionDigits = 4
    nf.positivePrefix = " "
    nf.paddingCharacter = "0"
    nf.paddingPosition = .afterSuffix
    return nf
}()

public extension BSRotation3D {
    fileprivate var nf: NumberFormatter { rotation3DNumberFormatter }
    var strings: [String] {
        let angles = eulerAngles(order: .zxy).angles
        return [
            "y:\(nf.string(for: angles.x)!)",
            "p:\(nf.string(for: angles.y)!)",
            "r:\(nf.string(for: angles.z)!)",
        ]
    }

    var string: String {
        strings.joined(separator: isWatch ? "\n" : ", ")
    }

    var array: [Double] {
        let angles = eulerAngles(order: .zxy).angles
        return [angles.x, angles.y, angles.z]
    }
}

extension BSRotation3D {
    static func parse(_ data: Data, scalar: Float, sensorType: BSSensorType) -> Self? {
        let rawX = Int16.parse(data, at: 0)
        let rawY = Int16.parse(data, at: 2)
        let rawZ = Int16.parse(data, at: 4)

        guard let rawX, let rawY, let rawZ else { return nil }

        let x = Double(rawX) * Double(scalar)
        let y = Double(rawY) * Double(scalar)
        let z = Double(rawZ) * Double(scalar)

        let pitchDegrees: Double
        let yawDegrees: Double
        let rollDegrees = z

        switch sensorType {
        case .orientation:
            pitchDegrees = -y
            yawDegrees = -x
//        case .gyroscope:
//            pitchDegrees = x
//            yawDegrees = y
        default:
            fatalError("uncaught sensorType \(sensorType.name)")
        }

        let pitch: Angle2D = .init(degrees: pitchDegrees)
        let yaw: Angle2D = .init(degrees: yawDegrees)
        let roll: Angle2D = .init(degrees: rollDegrees)

        let rotation: Self = .init(eulerAngles: .init(x: pitch, y: yaw, z: roll, order: .zxy))

        logger?.debug("parsed rotation: \(rotation)")

        return rotation
    }
}
