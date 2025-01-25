//
//  BSTfliteFile.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

typealias BSTfliteCaptureDelay = UInt16
typealias BSTfliteThreshold = Float

class BSTfliteFile: BSBaseFile {
    override class var fileType: BSFileType { .tflite }

    let tfliteName: String
    let sensorTypes: Set<BSTfliteSensorType>
    func getSensorTypes() -> Set<BSSensorType> {
        .init(sensorTypes.map { $0.sensorType })
    }

    let task: BSTfliteTask
    let sensorRate: BSSensorRate

    static let maxCaptureDelay: BSTfliteCaptureDelay = 5000
    var captureDelay: BSTfliteCaptureDelay {
        didSet {
            captureDelay = min(captureDelay, Self.maxCaptureDelay)
        }
    }

    static let maxThreshold: BSTfliteThreshold = 1.0
    var threshold: BSTfliteThreshold {
        didSet {
            threshold = min(threshold, Self.maxThreshold)
        }
    }

    let classes: [String]?

    init(fileName: String, modelName: String, sensorTypes: BSTfliteSensorTypes, task: BSTfliteTask, sensorRate: BSSensorRate, captureDelay: BSTfliteCaptureDelay = 0, threshold: BSTfliteThreshold = 0.0, classes: [String]?) {
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
