//
//  AsyncQueue.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-09.
//

import Foundation
import Synchronization

final class AsyncQueue<T> {

    private let values: Mutex<[T]>

    init(values: [T]) {
        self.values = Mutex(values)
    }

    func pop() -> T? {
        values.withLock {
            guard !$0.isEmpty else { return nil }

            return $0.removeFirst()
        }
    }
}
