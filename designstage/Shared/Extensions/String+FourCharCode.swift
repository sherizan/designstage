//
//  String+FourCharCode.swift
//  Design Stage
//
//  Utility helpers for converting four-character strings to OSType values.
//

import Foundation
import CoreServices

extension String {
    /// Returns the four-character code representation of the string.
    /// - Note: The string must be exactly four UTF-16 code units long.
    var fourCharCode: OSType {
        precondition(self.utf16.count == 4, "String must be exactly four characters long")
        return self.utf16.reduce(0) { (result, scalar) -> OSType in
            (result << 8) + OSType(scalar)
        }
    }
}
