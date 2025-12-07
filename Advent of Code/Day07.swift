//
//  Day07.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-07.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day7: AdventDay {

    enum Tile {
        case open
        case splitter
    }

    enum NodeType {
        case exit
        case splitter
        case start
    }

    class Node {
        let point: Point
        var type: NodeType
        var children: [Node] = []

        init(point: Point, type: NodeType) {
            self.point = point
            self.type = type
            self.children = []
        }
    }

    public var data: String

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        let (start, grid) = try parse()

        var tachyons: Set<Point> = [start]
        var tachyonsToAdd: Set<Point> = []
        var tachyonsToRemove: Set<Point> = []

        var level = start.y
        var splits = 0

        while level < grid.count - 1 {
            // Move tachyons down
            tachyons = Set(tachyons.map { Point(x: $0.x, y: $0.y + 1) })

            // Remove split tachyons and add their neighbors
            for tachyon in tachyons where grid[tachyon.y][tachyon.x] == .splitter {
                tachyonsToRemove.insert(tachyon)
                tachyonsToAdd.insert(Point(x: tachyon.x - 1, y: tachyon.y))
                tachyonsToAdd.insert(Point(x: tachyon.x + 1, y: tachyon.y))

                splits += 1
            }

            // Make the changes
            tachyons.subtract(tachyonsToRemove)
            tachyons.formUnion(tachyonsToAdd)

            tachyonsToRemove.removeAll(keepingCapacity: true)
            tachyonsToAdd.removeAll(keepingCapacity: true)

            level += 1
        }

        return splits
    }

    public func part2() async throws -> Any {
        let (start, grid) = try parse()

        let width = grid[0].count
        let height = grid.count

        // Find all of the nodes
        let startNode = Node(point: start, type: .start)

        var allNodes: [Point:Node] = [:]
        allNodes[start] = startNode

        for (y, row) in grid.enumerated() {
            for (x, value) in row.enumerated() where value == .splitter {
                let point = Point(x: x, y: y)
                allNodes[point] = Node(point: point, type: .splitter)
            }
        }

        for x in 0 ..< width {
            let point = Point(x: x, y: height - 1)
            allNodes[point] = Node(point: point, type: .exit)
        }

        // Draw the graph
        var nodesToVisit = [startNode]

        while !nodesToVisit.isEmpty {
            let currentNode = nodesToVisit.removeFirst()

            guard currentNode.children.isEmpty else { continue }

            switch currentNode.type {
            case .exit:
                break
            case .splitter:
                let lhs = Point(x: currentNode.point.x - 1, y: currentNode.point.y)
                let rhs = Point(x: currentNode.point.x + 1, y: currentNode.point.y)

                let lhsChild = findChild(point: lhs, nodes: allNodes)
                let rhsChild = findChild(point: rhs, nodes: allNodes)

                currentNode.children.append(lhsChild)
                currentNode.children.append(rhsChild)

                if lhsChild.type == .splitter {
                    nodesToVisit.append(lhsChild)
                }

                if rhsChild.type == .splitter {
                    nodesToVisit.append(rhsChild)
                }
            case .start:
                let point = Point(x: currentNode.point.x, y: currentNode.point.y + 1)

                let child = findChild(point: point, nodes: allNodes)
                currentNode.children.append(child)

                if child.type == .splitter {
                    nodesToVisit.append(child)
                }
            }
        }

        // Run the graph
        var cache: [Point:Int] = [:]
        return visit(node: startNode, cache: &cache)
    }

    func findChild(point: Point, nodes: [Point:Node]) -> Node {
        var currentPoint = point

        while true {
            if let child = nodes[currentPoint] {
                return child
            }

            currentPoint.y += 1
        }
    }

    func visit(node: Node, cache: inout [Point:Int]) -> Int {
        if let cached = cache[node.point] {
            return cached
        }

        switch node.type {
        case .exit:
            cache[node.point] = 1
            return 1
        case .splitter, .start:
            let result = node.children.reduce(0) { $0 + visit(node: $1, cache: &cache) }
            cache[node.point] = result

            return result
        }
    }

    func parse() throws -> (Point, [[Tile]]) {
        guard let startX = data.firstIndex(of: "S") else {
            throw AdventOfCodeError.parseError("Failed to find start position")
        }

        let start = Point(x: data.distance(from: data.startIndex, to: startX), y: 0)

        let grid = try grid.map { row in
            try row.map { value in
                switch value {
                case ".": Tile.open
                case "^": Tile.splitter
                case "S": Tile.open
                default: throw AdventOfCodeError.parseError("Unhandled title: \(value)")
                }
            }
        }

        return (start, grid)
    }
}
