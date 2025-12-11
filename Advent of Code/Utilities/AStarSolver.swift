//
//  AStarSolver.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-10.
//

import Foundation

enum AStarSolverError: Error {
    case noSolutionFound
}

struct AStarSolver<T: Hashable> {

    var cost: (T, T, Int?) -> Int
    var heuristic: ((T, T) -> Int)? = nil
    var neighbors: (T) -> [T]

    func solve(start: T, target: T) throws -> [T] {
        var frontier = PriorityQueue<T>()
        frontier.push(start, priority: 0)

        var cameFrom: [T:T] = [:]
        var costSoFar: [T:Int] = [start:0]

        while true {
            guard let current = frontier.pop() else {
                throw AStarSolverError.noSolutionFound
            }

            if current == target {
                break
            }

            for neighbor in neighbors(current) {
                let newCost = cost(current, neighbor, costSoFar[current])

                if newCost < costSoFar[neighbor, default: .max] {
                    costSoFar[neighbor] = newCost

                    let priority = newCost + (heuristic?(current, neighbor) ?? 0)
                    frontier.push(neighbor, priority: priority)

                    cameFrom[neighbor] = current
                }
            }
        }

        var path: [T] = []
        var current = target

        while true {
            guard let previous = cameFrom[current] else {
                break
            }

            path.insert(current, at: 0)
            current = previous
        }

        path.insert(current, at: 0)

        return path
    }
}
