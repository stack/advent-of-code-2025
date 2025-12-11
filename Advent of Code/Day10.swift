//
//  Day10.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-10.
//  SPDX-License-Identifier: MIT
//

import Accelerate
import Foundation
internal import Subprocess
import System

public struct Day10: AdventDay {

    typealias Lights = [Bool]
    typealias Joltages = [Int]

    struct Machine {
        var lights: Lights
        var buttons: [[Int]]
        var joltages: Joltages
    }

    public var data: String
    public var useSampleData: Bool = false

    public init(data: String) {
        self.data = data
    }

    public func part1() async throws -> Any {
        try machines
            .map { try findPattern(for: $0) }
            .reduce(0, +)
    }

    public func part2() async throws -> Any {
        var total = 0

        for machine in machines {
            let result = try await findJoltages(for: machine)
            total += result
        }

        return total
    }

    func findJoltages(for machine: Machine) async throws -> Int {
        // Open the file for writing
        let outputFile = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).smt")
        FileManager.default.createFile(atPath: outputFile.path(percentEncoded: false), contents: nil)

        defer {
            try? FileManager.default.removeItem(at: outputFile)
        }

        let file = try FileHandle(forWritingTo: outputFile)

        defer {
            try? file.close()
        }

        // Write the header of the file
        try file.writeLine("(set-option :produce-models true)")
        try file.writeLine("(set-logic QF_LIA)")
        try file.writeLine()

        // Write the variables
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        for column in (0 ..< machine.buttons.count) {
            let alphaIndex = alphabet.index(alphabet.startIndex, offsetBy: column)
            try file.writeLine("(declare-fun \(alphabet[alphaIndex]) () Int)")
        }

        try file.writeLine()

        // Write the assertions
        let columnLength = machine.joltages.count

        for column in (0 ..< columnLength) {
            let values = machine.buttons.enumerated().map { buttonIndex, button in
                let alphaIndex = alphabet.index(alphabet.startIndex, offsetBy: buttonIndex)
                let value = button.contains(column) ? 1 : 0

                return "(* \(value) \(alphabet[alphaIndex]))"
            }

            let adds = "(+ \(values.joined(separator: " ")))"
            let equals = "(= \(adds) \(machine.joltages[column]))"
            let assert = "(assert \(equals))"

            try file.writeLine(assert)
        }

        try file.writeLine()

        // Write the positive assertions
        for column in (0 ..< machine.buttons.count) {
            let alphaIndex = alphabet.index(alphabet.startIndex, offsetBy: column)
            try file.writeLine("(assert (>= \(alphabet[alphaIndex]) 0))")
        }

        try file.writeLine()

        // Write the minimize line
        let letters = (0 ..< machine.buttons.count).map { index in
            let alphaIndex = alphabet.index(alphabet.startIndex, offsetBy: index)
            return String(alphabet[alphaIndex])
        }
        .joined(separator: " ")

        try file.writeLine("(minimize (+ \(letters)))")
        try file.writeLine()

        // Write the outro
        try file.writeLine("(check-sat)")
        try file.writeLine("(get-model)")
        try file.writeLine("(get-objectives)")

        try file.close()

        // Run Z3
        let arguments = [outputFile.path(percentEncoded: false)]
        var result: Int? = nil

        _ = try await run(.path("/opt/homebrew/bin/z3"), arguments: Arguments(arguments)) { _, stdout in
            var inObjectives = false

            for try await line in stdout.lines() {
                if inObjectives {
                    let parts = line.trimmingCharacters(in: .whitespacesAndNewlines).replacing(")", with: "").components(separatedBy: " ")

                    if let valueString = parts.last, let value = Int(valueString) {
                        result = value
                    }

                    inObjectives = false
                } else if line.hasPrefix("(objectives") {
                    inObjectives = true
                }
            }
        }

        try? FileManager.default.removeItem(at: outputFile)

        guard let result else {
            throw AdventOfCodeError.runError("Did not get the objective value")
        }

        return result
    }

    func findPattern(for machine: Machine) throws -> Int {
        let solver = AStarSolver<Lights> { current, neighbor, costSoFar in
            (costSoFar ?? 0) + 1
        } neighbors: { current in
            machine.buttons.map { button in
                var next = current

                for pressIndex in button {
                    next[pressIndex].toggle()
                }

                return next
            }
        }

        let start = Lights(repeating: false, count: machine.lights.count)
        let target = machine.lights
        let path = try solver.solve(start: start, target: target)

        return path.count - 1
    }

    var machines: [Machine] {
        lines.map { line in
            var parts = line.components(separatedBy: " ")
            let lightsString = parts.removeFirst()
            var joltagesString = parts.removeLast()

            let lights = lightsString.compactMap {
                switch $0 {
                case ".": false
                case "#": true
                default: nil
                }
            }

            joltagesString.removeFirst()
            joltagesString.removeLast()

            let joltages = joltagesString
                .components(separatedBy: ",")
                .map { Int($0)! }

            let buttons = parts.map {
                var value = $0
                value.removeFirst()
                value.removeLast()

                return value.components(separatedBy: ",").map { Int($0)! }
            }

            return Machine(
                lights: lights,
                buttons: buttons,
                joltages: joltages
            )
        }
    }
}

extension Day10.Lights {

    var description: String {
        self.map { $0 ? "#" : "." }.joined()
    }
}

extension FileHandle {

    func write(_ string: String) throws {
        let data =  string.data(using: .utf8)!
        try self.write(contentsOf: data)
    }

    func writeLine() throws {
        try write("\n")
    }

    func writeLine(_ string: String) throws {
        try write(string)
        try write("\n")
    }
}
