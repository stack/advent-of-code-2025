//
//  Day08.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-08.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day8: AdventDay {

    struct Pair {
        var lhs: Point3D
        var rhs: Point3D
        var distance: Double
    }

    public var data: String

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        let allPoints = points
        let allPairs = makePairs(from: allPoints)
        let maxConnections = useSampleData ? 10 : 1000

        return connect(pairs: allPairs, maxConnections: maxConnections)
    }

    public func part2() async throws -> Any {
        let allPoints = points
        let allPairs = makePairs(from: allPoints)

        return connectAll(pairs: allPairs, totalPoints: allPoints.count)
    }

    var points: [Point3D] {
        lines.map { line in
            let parts = line.components(separatedBy: ",").map { Int($0)! }
            return Point3D(x: parts[0], y: parts[1], z: parts[2])
        }
    }

    func connect(pairs: [Pair], maxConnections: Int) -> Int {
        let sortedPairs = pairs.sorted { $0.distance < $1.distance }

        var circuits: [Set<Point3D>] = []
        for index in 0 ..< maxConnections {
            let pair = sortedPairs[index]

            let matchingIndices = circuits.indices(where: { $0.contains(pair.lhs) || $0.contains(pair.rhs) })

            if matchingIndices.isEmpty {
                var circuit: Set<Point3D> = []
                circuit.insert(pair.lhs)
                circuit.insert(pair.rhs)

                circuits.append(circuit)
            } else {
                var newCircuit: Set<Point3D> = circuits[matchingIndices].reduce(into: Set<Point3D>()) { $0.formUnion($1) }
                newCircuit.insert(pair.lhs)
                newCircuit.insert(pair.rhs)

                circuits.removeSubranges(matchingIndices)
                circuits.append(newCircuit)
            }
        }

        let sortedCircuits = circuits.sorted(by: { $0.count > $1.count })

        return sortedCircuits[..<3].reduce(1) { $0 * $1.count }
    }

    func connectAll(pairs: [Pair], totalPoints: Int) -> Int {
        let sortedPairs = pairs.sorted { $0.distance < $1.distance }

        var circuits: [Set<Point3D>] = []
        for pair in sortedPairs {
            let matchingIndices = circuits.indices(where: { $0.contains(pair.lhs) || $0.contains(pair.rhs) })

            if matchingIndices.isEmpty {
                var circuit: Set<Point3D> = []
                circuit.insert(pair.lhs)
                circuit.insert(pair.rhs)

                circuits.append(circuit)
            } else {
                var newCircuit: Set<Point3D> = circuits[matchingIndices].reduce(into: Set<Point3D>()) { $0.formUnion($1) }
                newCircuit.insert(pair.lhs)
                newCircuit.insert(pair.rhs)

                circuits.removeSubranges(matchingIndices)
                circuits.append(newCircuit)
            }

            if circuits.count == 1 && circuits[0].count == totalPoints {
                return pair.lhs.x * pair.rhs.x
            }
        }

        return -1
    }

    func makePairs(from points: [Point3D]) -> [Pair] {
        var allPairs: [Pair] = []

        for (lhsIndex, lhs) in points.dropLast().enumerated() {
            for rhsIndex in (lhsIndex + 1) ..< points.count {
                let rhs = points[rhsIndex]

                let pair = Pair(lhs: lhs, rhs: rhs, distance: lhs.distance(to: rhs))
                allPairs.append(pair)
            }
        }

        return allPairs
    }
}
