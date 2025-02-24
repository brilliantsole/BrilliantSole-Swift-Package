//
//  BSTfliteFile.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import Foundation

public typealias BSTfliteCaptureDelay = UInt16
public typealias BSTfliteThreshold = Float

public class BSTfliteFile: BSBaseFile {
    override public class var fileType: BSFileType { .tflite }

    public var modelName: String
    public var sensorTypes: BSTfliteSensorTypes
    public func getSensorTypes() -> [BSSensorType] {
        .init(sensorTypes.map { $0.sensorType })
    }

    public var task: BSTfliteTask
    public var sensorRate: BSSensorRate

    public static let MaxCaptureDelay: BSTfliteCaptureDelay = 5000
    public var maxCaptureDelay: BSTfliteCaptureDelay { Self.MaxCaptureDelay }
    public var captureDelay: BSTfliteCaptureDelay {
        didSet {
            captureDelay = min(captureDelay, Self.MaxCaptureDelay)
        }
    }

    public static let MaxThreshold: BSTfliteThreshold = 1.0
    public var maxThreshold: BSTfliteThreshold { Self.MaxThreshold }
    public var threshold: BSTfliteThreshold {
        didSet {
            threshold = min(threshold, Self.MaxThreshold)
        }
    }
    
    public var classes: [String]?

    public init(modelName: String = "", sensorTypes: BSTfliteSensorTypes = [.gyroscope, .linearAcceleration], task: BSTfliteTask = .classification, sensorRate: BSSensorRate = ._20ms, captureDelay: BSTfliteCaptureDelay = 0, threshold: BSTfliteThreshold = 0.0, classes: [String]? = nil) {
        self.modelName = modelName
        self.sensorTypes = sensorTypes
        self.task = task
        self.sensorRate = sensorRate
        self.captureDelay = captureDelay
        self.threshold = threshold
        self.classes = classes

        super.init()
    }

    public init(fileURL: URL, modelName: String, sensorTypes: BSTfliteSensorTypes, task: BSTfliteTask, sensorRate: BSSensorRate, captureDelay: BSTfliteCaptureDelay = 0, threshold: BSTfliteThreshold = 0.0, classes: [String]? = nil) {
        self.modelName = modelName
        self.sensorTypes = sensorTypes
        self.task = task
        self.sensorRate = sensorRate
        self.captureDelay = captureDelay
        self.threshold = threshold
        self.classes = classes

        super.init(fileURL: fileURL)
    }

    public init(fileName: String, bundle: Bundle = .main, modelName: String, sensorTypes: BSTfliteSensorTypes, task: BSTfliteTask, sensorRate: BSSensorRate, captureDelay: BSTfliteCaptureDelay = 0, threshold: BSTfliteThreshold = 0.0, classes: [String]?) {
        self.modelName = modelName
        self.sensorTypes = sensorTypes
        self.task = task
        self.sensorRate = sensorRate
        self.captureDelay = captureDelay
        self.threshold = threshold
        self.classes = classes

        super.init(fileName: fileName, bundle: bundle)
    }
}
