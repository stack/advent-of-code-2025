//
//  Point3D.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-08.
//  SPDX-License-Identifier: MIT
//

import Foundation
import simd

public typealias Point3D = SIMD3<Int>

public extension Point3D {

    func distance(to other: Point3D) -> Double {
        let x2 = (x - other.x) * (x - other.x)
        let y2 = (y - other.y) * (y - other.y)
        let z2 = (z - other.z) * (z - other.z)

        return sqrt(Double(x2 + y2 + z2))
    }
}
