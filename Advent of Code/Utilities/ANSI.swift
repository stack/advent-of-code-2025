//
//  ANSI.swift
//  Advent of Code 2025
//
//  Created by Stephen H. Gerstacker on 2025-12-03.
//  SPDX-License-Identifier: MIT
//

import Foundation

enum AnsiColor {

    case black
    case red
    case green
    case yellow
    case blue
    case purple
    case cyan
    case white

    var code: Int {
        switch self {
        case .black: 0
        case .red: 1
        case .green: 2
        case .yellow: 3
        case .blue: 4
        case .purple: 5
        case .cyan: 6
        case .white: 7
        }
    }
}

enum AnsiCommand {

    static let reset = "0".ansi
    static let bold = "1".ansi
    static let italic = "3".ansi
    static let underline = "4".ansi

    static func foregroundColor(_ color: AnsiColor) -> String {
        "3\(color.code)".ansi
    }

    static func backgroundColor(_ color: AnsiColor) -> String {
        "4\(color.code)".ansi
    }
}

extension String {

    var ansi: String {
        "\u{001B}[" + self + "m"
    }

    func applying(background: AnsiColor) -> Self {
        AnsiCommand.backgroundColor(background) + self + AnsiCommand.reset
    }

    func applying(color: AnsiColor) -> Self {
        AnsiCommand.foregroundColor(color) + self + AnsiCommand.reset
    }

    var bold: Self {
        AnsiCommand.bold + self + AnsiCommand.reset
    }

    var italic: Self {
        AnsiCommand.italic + self + AnsiCommand.reset
    }

    var underline: Self {
        AnsiCommand.underline + self + AnsiCommand.reset
    }
}
