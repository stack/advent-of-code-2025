//
//  Day01.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-01.
//

import Foundation

public struct Day1: AdventDay {

    public var data: String

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        var position = 50
        var hits = 0

        print("The dial starts by pointing at \(position)")

        for line in lines {
            let direction = line.first!
            let distance = Int(line.dropFirst())!

            switch direction {
            case "L": position -= distance
            case "R": position += distance
            default: fatalError("Unhandled direction \(direction)")
            }

            print("The dial is rotated \(line) to point at \(position)")

            if position.isMultiple(of: 100) {
                hits += 1
            }
        }

        return hits
    }

    public func part2() async throws -> Any {
        var position = 50
        var hits = 0

        print("The dial starts by pointing at \(position)")

        for line in lines {
            var nextPosition = position
            var localHits = 0

            let direction = line.first!
            let distance = Int(line.dropFirst())!

            switch direction {
            case "L":
                nextPosition -= distance

                while nextPosition < 0 {
                    nextPosition += 100
                    localHits += 1
                }

                if localHits > 0, position == 0 {
                    localHits -= 1
                } else if nextPosition == 0 {
                    localHits += 1
                }
            case "R":
                nextPosition += distance

                while nextPosition >= 100 {
                    nextPosition -= 100
                    localHits += 1
                }
            default: fatalError("Unhandled direction \(direction)")
            }

            print("Rotated from \(position) with \(line) to \(nextPosition)")

            if localHits > 0 {
                print("- 0 was clicked \(localHits) times")
            }

            position = nextPosition
            hits += localHits
        }

        return hits
    }
}
