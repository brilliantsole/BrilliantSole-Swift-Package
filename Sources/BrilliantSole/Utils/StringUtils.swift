//
//  StringUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation
import OSLog
import UkatonMacros

public func camelCaseToSpaces(_ inputString: String) -> String {
    let regex = try! NSRegularExpression(pattern: "([a-z])([A-Z])", options: [])
    let range = NSRange(location: 0, length: inputString.utf16.count)
    let spacedString = regex.stringByReplacingMatches(in: inputString, options: [], range: range, withTemplate: "$1 $2")
    return spacedString.lowercased()
}

public func spacesToCamelCase(_ inputString: String) -> String {
    let words = inputString.components(separatedBy: CharacterSet.whitespaces)
    let camelCaseString = words.enumerated().map { index, word in
        index == 0 ? word.lowercased() : word.prefix(1).uppercased() + word.dropFirst().lowercased()
    }.joined()
    return camelCaseString
}

@StaticLogger(disabled: true)
final class BSStringUtils {
    static func getString(from data: Data, includesLength: Bool = false) -> String? {
        var offset = 0
        var stringLength = data.count

        if includesLength {
            guard !data.isEmpty else { return nil }
            stringLength = Int(data[data.startIndex + offset])
            offset += 1
        }

        guard offset + stringLength <= data.count else {
            logger?.error("Invalid string length")
            return nil
        }

        guard let parsedString = String(data: data.subdata(in: data.startIndex + offset ..< data.startIndex + offset + stringLength), encoding: .utf8) else {
            return nil
        }
        logger?.debug("parsed string: \(parsedString)")
        return parsedString
    }

    static func toBytes(_ string: String, includeLength: Bool = false) -> Data {
        var data = Data()
        let utf8Data = string.data(using: .utf8) ?? Data()

        if includeLength {
            data.append(UInt8(utf8Data.count))
        }

        data.append(utf8Data)
        return data
    }
}
