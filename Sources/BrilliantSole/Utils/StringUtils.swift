//
//  StringUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

import Foundation

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
