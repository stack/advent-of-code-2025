//
//  Math.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-03.
//

import Foundation

func pow(_ base: Int, _ exp: Int) -> Int {
    var value = 1

    for _ in (0 ..< exp) {
        value *= base
    }

    return value
}
