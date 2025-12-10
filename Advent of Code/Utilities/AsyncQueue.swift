//
//  AsyncQueue.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-09.
//

import Foundation

actor AsyncQueue<T> {

    var values: [T]

    init(values: [T]) {
        self.values = values
    }

    func pop() -> T? {
        guard !values.isEmpty else { return nil }

        return values.removeFirst()
    }
}
