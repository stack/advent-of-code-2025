//
//  AdventOfCodeError.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-07.
//

import Foundation

enum AdventOfCodeError: Error {
    case parseError(String)
    case runError(String)
}
