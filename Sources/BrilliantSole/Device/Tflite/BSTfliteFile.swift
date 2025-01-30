//
//  BSTfliteFile.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

public typealias BSTfliteCaptureDelay = UInt16
public typealias BSTfliteThreshold = Float

public class BSTfliteFile: BSBaseFile {
    override public class var fileType: BSFileType { .tflite }

    public let tfliteName: String
    public let sensorTypes: Set<BSTfliteSensorType>
    public func getSensorTypes() -> Set<BSSensorType> {
        .init(sensorTypes.map { $0.sensorType })
    }

    public let task: BSTfliteTask
    public let sensorRate: BSSensorRate

    public static let maxCaptureDelay: BSTfliteCaptureDelay = 5000
    public var captureDelay: BSTfliteCaptureDelay {
        didSet {
            captureDelay = min(captureDelay, Self.maxCaptureDelay)
        }
    }

    public static let maxThreshold: BSTfliteThreshold = 1.0
    public var threshold: BSTfliteThreshold {
        didSet {
            threshold = min(threshold, Self.maxThreshold)
        }
    }

    public let classes: [String]?

    public init(fileName: String, modelName: String, sensorTypes: BSTfliteSensorTypes, task: BSTfliteTask, sensorRate: BSSensorRate, captureDelay: BSTfliteCaptureDelay = 0, threshold: BSTfliteThreshold = 0.0, classes: [String]?) {
        self.tfliteName = modelName
        self.sensorTypes = sensorTypes
        self.task = task
        self.sensorRate = sensorRate
        self.captureDelay = captureDelay
        self.threshold = threshold
        self.classes = classes

        super.init(fileName: fileName)
    }
}
