//
//  Day02.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-02.
//  SPDX-License-Identifier: MIT
//

internal import Algorithms
import Foundation

public struct Day2: AdventDay {

    public var data: String

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        var invalidIDs: [Int] = []

        for range in ranges {
            print("\(range):")

            for id in range {
                let idString = String(id)

                // Invalid IDs must have an even number of digits
                guard idString.count.isMultiple(of: 2) else { continue }

                // Split the string in half
                let splitIndex = idString.index(idString.startIndex, offsetBy: idString.count / 2)
                let lhs = idString[..<splitIndex]
                let rhs = idString[splitIndex...]

                if lhs == rhs {
                    print("- INVALID: \(idString)")
                    invalidIDs.append(id)
                }
            }
        }

        return invalidIDs.reduce(0, +)
    }

    public func part2() async throws -> Any {
        let result = await withTaskGroup{ taskGroup in
            for range in ranges {
                taskGroup.addTask { await findInvalid(in: range) }
            }

            var result = 0

            for await invalid in taskGroup {
               result += invalid
            }

            return result
        }

        return result
    }

    func findInvalid(in range: ClosedRange<Int>) async-> Int {
        var invalidIDs: [Int] = []

        print("\(range):")

        for id in range {
            let idString = String(id)

            guard idString.count > 1 else { continue }

            let largestSplit = idString.count / 2

            for chunkSize in 1...largestSplit {
                let chunks = idString.chunks(ofCount: chunkSize)
                let first = chunks.first!

                if chunks.dropFirst().allSatisfy({ $0 == first }) {
                    print("- \(range): \(idString)")
                    invalidIDs.append(id)
                    break
                }
            }
        }

        return invalidIDs.reduce(0, +)
    }

    var ranges: [ClosedRange<Int>] {
        lines.first!.components(separatedBy: ",").map { rangeString in
            let parts = rangeString.components(separatedBy: "-")
            let lhs = Int(parts[0])!
            let rhs = Int(parts[1])!

            return lhs...rhs
        }
    }
}
