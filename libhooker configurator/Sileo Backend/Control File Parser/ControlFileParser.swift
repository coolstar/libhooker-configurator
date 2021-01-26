//
//  ControlFileParser.swift
//  Sileo
//
//  Created by CoolStar on 6/22/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

import Foundation

class ControlFileParser {
    enum Error: LocalizedError {
        case invalidStringData
        case invalidMultilineValue
        case expectedSeparator
    }

    private static let lineSeparator = "\n".utf8.first!
    private static let keyValueSeparator = ":".utf8.first!
    private static let space = " ".utf8.first!
    private static let tab = "\t".utf8.first!
    private static let regularMultilineKeys: Set = ["description"]
    private static let releaseMultilineKeys: Set = ["description", "md5sum", "sha1", "sha256", "sha512"]

    class func dictionary(controlFile: String, isReleaseFile: Bool) throws -> [String: String] {
        guard let controlData = controlFile.data(using: .utf8) else {
            throw Error.invalidStringData
        }
        return try dictionary(controlData: controlData, isReleaseFile: isReleaseFile)
    }

    class func dictionary(controlData: Data, isReleaseFile: Bool) throws -> [String: String] {
        let lineSeparator = self.lineSeparator
        let keyValueSeparator = self.keyValueSeparator
        let space = self.space
        let tab = self.tab
        let multilineKeys = isReleaseFile ? releaseMultilineKeys : regularMultilineKeys

        var dictionary: [String: String] = [:]
        var lastMultilineKey: String?

        var controlData = controlData
        if let endIndex = controlData.lastIndex(where: { $0 != lineSeparator }) {
            controlData = controlData[...endIndex]
        }

        var index = controlData.startIndex
        while index < controlData.endIndex {
            let lineEnd = controlData[index...].firstIndex(of: lineSeparator)?.advanced(by: 1) ?? controlData.endIndex
            defer { index = lineEnd }
            let lineData = controlData[index..<lineEnd]

            guard lineData.first != space && lineData.first != tab else {
                guard let lastMultilineKey = lastMultilineKey else { throw Error.invalidMultilineValue }
                let line = String(data: lineData, encoding: .utf8) ?? ""
                dictionary[lastMultilineKey, default: ""] += "\n\(line.trimmingLeadingWhitespace())"
                continue
            }
            guard let separatorIdx = lineData.firstIndex(of: keyValueSeparator)
                else { throw Error.expectedSeparator }

            guard let key = String(data: lineData[..<separatorIdx], encoding: .utf8)?.lowercased()
                else { throw Error.invalidStringData }
            lastMultilineKey = multilineKeys.contains(key) ? key : nil

            let rawValue = lineData[separatorIdx.advanced(by: 1)...]
            let value: String
            if let start = rawValue.firstIndex(where: { $0 != space && $0 != tab }),
                let end = rawValue.lastIndex(where: { $0 != space && $0 != tab && $0 != lineSeparator }) {
                guard let decoded = String(data: rawValue[start...end], encoding: .utf8) else { throw Error.invalidStringData }
                value = decoded
            } else {
                value = ""
            }
            dictionary[key] = value
        }

        return dictionary
    }
    
    class func authorName(string: String) -> String {
        guard let emailIndex = string.firstIndex(of: "<") else {
            return string.trimmingCharacters(in: .whitespaces)
        }
        return string[..<emailIndex].trimmingCharacters(in: .whitespaces)
    }
    
    class func authorEmail(string: String) -> String? {
        guard let emailIndex = string.firstIndex(of: "<") else {
            return nil
        }
        let email = string[emailIndex...]
        guard let emailLastIndex = email.firstIndex(of: ">") else {
            return nil
        }
        return String(email[..<emailLastIndex])
    }
}
