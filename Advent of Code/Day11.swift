//
//  Day11.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-11.
//  SPDX-License-Identifier: MIT
//

internal import Collections
import Foundation

public struct Day11: AdventDay {

    class Node {
        let name: String
        var children: [Node] = []
        var visited: Bool = false

        init(name: String) {
            self.name = name
        }
    }

    public var data: String
    public var useSampleData: Bool = false

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        let connections = connections

        var toVisit: [String] = ["you"]
        var outs: Int = 0

        while !toVisit.isEmpty {
            let current = toVisit.removeFirst()
            let children = connections[current, default: []]

            for child in children {
                if child == "out" {
                    outs += 1
                } else {
                    toVisit.append(child)
                }
            }
        }

        return outs
    }

    public func part2() async throws -> Any {
        // Build the connections and then a graph
        let connections = connections
        var nodes = connections.keys.reduce(into: [String:Node]()) { $0[$1] = Node(name: $1) }
        nodes["out"] = Node(name: "out")

        for (connection, children) in connections {
            guard let node = nodes[connection] else { continue }
            node.children = children.compactMap { nodes[$0] }
        }

        // Dump a graphviz description
        print("digraph {")
        print("  fft[color=\"red\"];")
        print("  dac[color=\"red\"];")
        for (connection, children) in connections {
            for child in children {
                print("  \(connection) -> \(child);")
            }
        }
        print("}")

        // Calculate the segments
        var cache: [String:Int] = [:]
        let svrToDac = dfs(current: "svr", target: "dac", nodes: nodes, cache: &cache)

        cache.removeAll(keepingCapacity: true)
        let svrToFft = dfs(current: "svr", target: "fft", nodes: nodes, cache: &cache)

        cache.removeAll(keepingCapacity: true)
        let dacToFft = dfs(current: "dac", target: "fft", nodes: nodes, cache: &cache)

        cache.removeAll(keepingCapacity: true)
        let fftToDac = dfs(current: "fft", target: "dac", nodes: nodes, cache: &cache)

        cache.removeAll(keepingCapacity: true)
        let dacToOut = dfs(current: "dac", target: "out", nodes: nodes, cache: &cache)

        cache.removeAll(keepingCapacity: true)
        let fftToOut = dfs(current: "fft", target: "out", nodes: nodes, cache: &cache)

        let svrDacFft = svrToDac * dacToFft * fftToOut
        let svrFftDac = svrToFft * fftToDac * dacToOut

        return svrDacFft + svrFftDac
    }

    func dfs(current: String, target: String, nodes: [String:Node], cache: inout [String:Int]) -> Int {
        if current == target {
            return 1
        }

        if let value = cache[current] {
            return value
        }

        guard let node = nodes[current] else {
            fatalError("Missing node")
        }

        node.visited = true

        var count = 0

        for child in node.children where !child.visited {
            count += dfs(current: child.name, target: target, nodes: nodes, cache: &cache)
        }

        node.visited = false
        cache[current] = count

        return count
    }

    var connections: [String:[String]] {
        var result: [String:[String]] = [:]

        for line in lines {
            var parts = line.components(separatedBy: " ")
            let id = parts.removeFirst().replacing(":", with: "")

            result[id, default: []].append(contentsOf: parts)
        }

        return result
    }
}
