//
//  Day03.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-03.
//  SPDX-License-Identifier: MIT
//

import Foundation
import Utilities

public struct Day3: AdventDay {

    public var data: String

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        await findJoltages(count: 2)
    }

    public func part2() async throws -> Any {
        await findJoltages(count: 12)
    }

    var banks: [[Int]] {
        lines.map {
            $0.split(separator: "").map { Int($0)! }
        }
    }

    func findJoltage(bank: [Int], startIndex: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }

        let endIndex = bank.count - count
        let startRange = startIndex...endIndex

        var highest = -1
        var highestTotal = 0

        for index in startRange {
            let value = bank[index]

            guard value > highest else { continue }

            highest = value
            let rest = findJoltage(bank: bank, startIndex: index + 1, count: count - 1)

            highestTotal = (highest * pow(10, count - 1)) + rest
        }

        return highestTotal
    }

    func findJoltages(count: Int) async -> Int {
        await withTaskGroup { taskGroup in
            for bank in banks {
                taskGroup.addTask {
                    let value = findJoltage(bank: bank, startIndex: 0, count: count)

                    let bankString = bank.map { String($0) }.joined()
                    print("\(bankString) = \(value)")

                    return value
                }
            }

            var total = 0

            for await result in taskGroup {
                total += result
            }

            return total
        }
    }
}
