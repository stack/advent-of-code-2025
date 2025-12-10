//
//  Day09.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-09.
//  SPDX-License-Identifier: MIT
//

internal import Algorithms
import Foundation

public struct Day9: AdventDay {

    public var data: String
    public var useSampleData: Bool = false

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        let points = self.points

        var bestArea = 0

        for (lhsIndex, lhs) in points.dropLast().enumerated() {
            for rhsIndex in (lhsIndex + 1)..<points.count {
                let rhs = points[rhsIndex]

                let width = abs(lhs.x - rhs.x) + 1
                let height = abs(lhs.y - rhs.y) + 1
                let area = width * height

                if area > bestArea {
                    bestArea = area
                }
            }
        }

        return bestArea
    }

    public func part2() async throws -> Any {
        // Find all of the line segments
        let points = points
        let allPoints = points + [points.first!]

        var horizontalLines: [Int:[ClosedRange<Int>]] = [:] // Key is Y, Values are X ranges
        var verticalLines: [Int:[ClosedRange<Int>]] = [:] // Key is X, Values are Y ranges

        for (lhs, rhs) in allPoints.adjacentPairs() {
            if lhs.x == rhs.x { // Vertical line
                let minY = min(lhs.y, rhs.y)
                let maxY = max(lhs.y, rhs.y)

                verticalLines[lhs.x, default: []].append(minY...maxY)
            } else { // Horizontal line}
                let minX = min(lhs.x, rhs.x)
                let maxX = max(lhs.x, rhs.x)

                horizontalLines[lhs.y, default: []].append(minX...maxX)
            }
        }

        // Build a queue of pairs to check
        var pairs: [(Point, Point)] = []

        for (lhsIndex, lhs) in points.dropLast().enumerated() {
            for rhsIndex in (lhsIndex + 1)..<points.count {
                let rhs = points[rhsIndex]

                pairs.append((lhs, rhs))
            }
        }

        let queue = AsyncQueue(values: pairs)

        // Process data across all cores
        return await withTaskGroup { taskGroup in
            for index in 0 ..< ProcessInfo.processInfo.processorCount {
                taskGroup.addTask { await process(index: index, queue: queue, horizontalLines: horizontalLines, verticalLines: verticalLines) }
            }

            var bestArea = 0

            for await area in taskGroup {
               bestArea = max(bestArea, area)
            }

            return bestArea
        }
    }

    func process(index: Int, queue: AsyncQueue<(Point, Point)>, horizontalLines: [Int:[ClosedRange<Int>]], verticalLines: [Int:[ClosedRange<Int>]]) async -> Int {
        var bestArea = 0

        while true {
            guard let pair = await queue.pop() else {
                break
            }

            let lhs = pair.0
            let rhs = pair.1

            // Determine the area and see if it's plausible
            let width = abs(lhs.x - rhs.x) + 1
            let height = abs(lhs.y - rhs.y) + 1
            let area = width * height

            // Ensure the box has an inner dimension
            guard width > 2 else { continue }
            guard height > 2 else { continue }

            // Ensure this area is actually better
            guard area > bestArea else { continue }

            // Build the rectangle
            let minX = min(lhs.x, rhs.x)
            let minY = min(lhs.y, rhs.y)
            let maxX = max(lhs.x, rhs.x)
            let maxY = max(lhs.y, rhs.y)

            let xRange = (minX + 1)...(maxX - 1)
            let yRange = (minY + 1)...(maxY - 1)

            var hasIntersection = false

            // Do any horizontal lines intersect this box?
            if !hasIntersection {
                var y = minY + 1
                verticalLoop: while y < maxY {
                    for line in (horizontalLines[y] ?? []) {
                        if line.overlaps(xRange) {
                            hasIntersection = true
                            break verticalLoop
                        }
                    }

                    y += 1
                }
            }

            // Do any vertical lines intersect this box?
            if !hasIntersection {
                var x = minX + 1
                horizontalLoop: while x < maxX {
                    for line in (verticalLines[x] ?? []) {
                        if line.overlaps(yRange) {
                            hasIntersection = true
                            break horizontalLoop
                        }
                    }

                    x += 1
                }
            }

            // If there's an intersection, skip it
            guard !hasIntersection else { continue }

            print("BEST AREA \(index): \(area)")

            bestArea = area
        }

        return bestArea
    }

    var points: [Point] {
        lines.map { line in
            let parts = line.components(separatedBy: ",")
            return Point(x: Int(parts[0])!, y: Int(parts[1])!)
        }
    }
}
