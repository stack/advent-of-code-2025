//
//  Day05.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-05.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day5: AdventDay {

    public var data: String

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        let (ranges, available) = parse()

        var freshCount = 0

        for value in available {
            for range in ranges {
                if range.contains(value) {
                    freshCount += 1
                    break
                }
            }
        }

        return freshCount
    }

    public func part2() async throws -> Any {
        let (ranges, _) = parse()

        return ranges.reduce(0) { $0 + ($1.upperBound - $1.lowerBound + 1) }
    }

    func parse() -> ([ClosedRange<Int>], [Int]) {
        var ranges: [ClosedRange<Int>] = []
        var available: [Int] = []
        var inRanges = true

        for line in self.lines {
            if line.isEmpty {
                inRanges = false
            } else if inRanges {
                let parts = line.components(separatedBy: "-")
                let range = Int(parts[0])!...Int(parts[1])!
                ranges.append(range)
            } else {
                let value = Int(line)!
                available.append(value)
            }
        }

        var condensedRanges: [ClosedRange<Int>] = ranges
        var continueCondensing: Bool = true

        while continueCondensing {
            continueCondensing = condense(&condensedRanges)
        }

        print("Condensed from \(ranges.count) to \(condensedRanges.count)")

        return (condensedRanges, available)
    }

    func condense(_ ranges: inout [ClosedRange<Int>]) -> Bool {
        for (lhsIndex, lhs) in ranges.enumerated() {
            for (rhsIndex, rhs) in ranges.enumerated() where lhsIndex < rhsIndex {
                if lhs.overlaps(rhs) {
                    let min = min(lhs.lowerBound, rhs.lowerBound)
                    let max = max(lhs.upperBound, rhs.upperBound)

                    ranges.remove(at: rhsIndex)
                    ranges.remove(at: lhsIndex)
                    ranges.append(min...max)

                    return true
                }
            }
        }

        return false
    }
}
