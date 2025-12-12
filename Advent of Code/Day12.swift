//
//  Day12.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-12.
//

import Foundation

public struct Day12: AdventDay {

    struct Shape {
        var width: Int
        var height: Int
        var points: Set<Point>

        init(points: Set<Point>) {
            self.points = points

            width = (points.map(\.x).max() ?? 0) + 1
            height = (points.map(\.y).max() ?? 0) + 1
        }
    }

    struct Tree {
        var width: Int
        var height: Int
        var counts: [Int]
    }

    public var data: String

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        let (shapes, trees) = parse()

        var count = 0

        for tree in trees {
            let treeArea = tree.width * tree.height
            let shapeArea = tree.counts.enumerated()
                .map {
                    $0.element * shapes[$0.offset].width * shapes[$0.offset].height
                }
                .reduce(0, +)

            if shapeArea <= treeArea {
                count += 1
            }
        }

        return count
    }

    public func part2() async throws -> Any {
        print("Part 2 Complete")
    }

    func parse() -> ([Shape], [Tree]) {
        var shapes: [Shape] = []
        var trees: [Tree] = []

        var shapeRow = 0
        var currentPoints: Set<Point> = []

        for line in lines {
            if line.firstMatch(of: /^\d+:/) != nil {
                currentPoints.removeAll()
                shapeRow = 0
            } else if line.isEmpty {
                shapes.append(Shape(points: currentPoints))

                currentPoints.removeAll()
                shapeRow = 0
            } else if line.firstMatch(of: /^\d+x\d+:/) != nil {
                let parts = line.components(separatedBy: ": ")
                let dimensions = parts[0].components(separatedBy: "x").map { Int($0)! }
                let indexes = parts[1].components(separatedBy: " ").map { Int($0)! }

                trees.append(Tree(width: dimensions[0], height: dimensions[1], counts: indexes))
            } else {
                let points = line
                    .split(separator: "")
                    .enumerated()
                    .compactMap {
                        $0.element == "#" ? Point(x: $0.offset, y: shapeRow) : nil
                    }

                currentPoints.formUnion(points)
                shapeRow += 1
            }
        }

        return (shapes, trees)
    }
}

