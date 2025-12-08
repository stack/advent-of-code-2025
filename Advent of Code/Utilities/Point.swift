//
//  Point.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-04.
//  SPDX-License-Identifier: MIT
//

import Foundation
import simd

public typealias Point = SIMD2<Int>

public extension Point {

    var cardinalNeighbors: [Point] {
        [
            Point(x: x - 1, y: y),
            Point(x: x , y: y - 1),
            Point(x: x + 1, y:  y),
            Point(x: x, y:  y + 1)
        ]
    }

    var neighbors: [Point] {
        [
            Point(x: x - 1, y: y),
            Point(x: x - 1, y: y - 1),
            Point(x: x, y: y - 1),
            Point(x: x + 1, y: y - 1),
            Point(x: x + 1, y: y),
            Point(x: x + 1, y: y + 1),
            Point(x: x, y:  y + 1),
            Point(x: x - 1, y: y + 1),
        ]
    }
}
