//
//  Day06.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-06.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day6: AdventDay {

    enum Operation {
        case add
        case multiply

        static func parse(_ value: String) -> Self? {
            switch value {
            case "+": return .add
            case "*": return .multiply
            default: return nil
            }
        }
    }

    public var data: String

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        var numbers: [[Int]] = []
        var operations: [Operation] = []
        var results: [Int] = []

        for line in lines {
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)

            if Int(parts[0]) == nil {
                operations = parts.map {
                    switch $0 {
                    case "+": .add
                    case "*": .multiply
                    default: fatalError("Unhandled operation: \($0)")
                    }
                }
            } else {
                numbers.append(parts.map { Int($0)! })
            }
        }

        for (index, operation) in operations.enumerated() {
            let values = numbers.map { $0[index] }

            switch operation {
            case .add: results.append(values.reduce(0, +))
            case .multiply: results.append(values.reduce(1, *))
            }
        }

        return results.reduce(0, +)
    }

    public func part2() async throws -> Any {
        var grid = grid
        let operationsRow = grid.removeLast()

        var skipNext: Bool = false
        var values: [Int] = []
        var results: [Int] = []

        for index in (0 ..< operationsRow.count).reversed() {
            guard !skipNext else {
                skipNext = false
                continue
            }

            let value = grid
                .map { $0[index] }
                .joined(separator: "")
                .trimmingCharacters(in: .whitespaces)

            values.append(Int(value)!)

            if let operation = Operation.parse(operationsRow[index]) {
                print("\(values) \(operation)")

                let result = switch operation {
                case .add: values.reduce(0, +)
                case .multiply: values.reduce(1, *)
                }

                results.append(result)

                skipNext = true
                values.removeAll(keepingCapacity: true)
            }
        }

        return results.reduce(0, +)
    }
}


