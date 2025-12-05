//
//  Day04.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-04.
//  SPDX-License-Identifier: MIT
//

import Foundation
import simd

public struct Day4: AdventDay {

    struct Warehouse {

        var rolls: Set<Point> = []
        var width: Int = 0
        var height: Int = 0

        var accessible: Set<Point> {
            var accessible: Set<Point> = []

            for roll in rolls {
                let neighbors = rolls.intersection(roll.neighbors)

                if neighbors.count < 4 {
                    accessible.insert(roll)
                }
            }

            return accessible
        }

        mutating func parse(lines: [String]) {
            for (y, line) in lines.enumerated() {
                for (x, value) in line.enumerated() where value == "@" {
                    rolls.insert(Point(x: x, y: y))
                }

                width = line.count
                height = y + 1
            }
        }

        mutating func prune() -> Set<Point> {
            let toRemove = accessible
            rolls.subtract(toRemove)

            return toRemove
        }

        func printFloor() {
            var lines: [String] = []

            for y in 0 ..< height {
                var line = ""

                for x in 0 ..< width {
                    let point = Point(x: x, y: y)

                    line.append(rolls.contains(point) ? "@" : ".")
                }

                lines.append(line)
            }

            let block = lines.joined(separator: "\n")
            print(block)
        }
    }

    public var data: String

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        var warehouse = Warehouse()
        warehouse.parse(lines: lines)

        return warehouse.accessible.count
    }

    public func part2() async throws -> Any {
        var warehouse = Warehouse()
        warehouse.parse(lines: lines)

        var totalRemoved = 0

        while true {
            let removed = warehouse.prune().count

            guard removed != 0 else {
                break
            }

            print("Removed \(removed)")
            totalRemoved += removed
        }

        warehouse.printFloor()

        return totalRemoved
    }
}
