/*
 BlockCommentSyntax.swift

 This source file is part of the Workspace open source project.
 https://github.com/SDGGiesbrecht/Workspace#workspace

 Copyright ©2017–2018 Jeremy David Giesbrecht and the Workspace project contributors.

 Soli Deo gloria.

 Licensed under the Apache Licence, Version 2.0.
 See http://www.apache.org/licenses/LICENSE-2.0 for licence information.
 */

import SDGCollections
import WSGeneralImports

internal struct BlockCommentSyntax {

    // MARK: - Initialization

    internal init(start: String, end: String, stylisticIndent: String? = nil) {
        self.start = start
        self.end = end
        self.stylisticIndent = stylisticIndent
    }

    // MARK: - Properties

    private let start: String
    private let end: String
    private let stylisticIndent: String?

    // MARK: - Output

    internal func comment(contents: String) -> String { // [_Exempt from Test Coverage_] [_Workaround: Until headers are testable._]

        let withEndToken = [contents, end].joinedAsLines()

        var lines = withEndToken.lines.map({ String($0.line) })

        lines = lines.map { (line: String) -> String in

            if let indent = stylisticIndent {
                if line.isWhitespace {
                    return line
                } else {
                    return indent + line
                }
            } else {
                return line
            }
        }

        lines = [start, lines.joinedAsLines()]

        return lines.joinedAsLines()
    }

    // MARK: - Parsing

    internal func startOfCommentExists(at location: String.ScalarView.Index, in string: String, countDocumentationMarkup: Bool = true) -> Bool {

        var index = location
        if ¬string.scalars.advance(&index, over: start.scalars) {
            return false
        } else { // [_Exempt from Test Coverage_] [_Workaround: Until headers are testable._]
             // [_Exempt from Test Coverage_] [_Workaround: Until headers are testable._]

            if countDocumentationMarkup {
                return true
            } else {
                // Make sure this isn’t documentation.

                if let nextCharacter = string.scalars[index...].first {

                    if nextCharacter ∈ CharacterSet.whitespacesAndNewlines {
                        return true
                    }
                }
                return false
            }
        }
    }

    internal func firstComment(in range: Range<String.ScalarView.Index>, of string: String) -> NestingLevel<String.ScalarView>? { // [_Exempt from Test Coverage_] [_Workaround: Until headers are testable._]
        return string.scalars.firstNestingLevel(startingWith: start.scalars, endingWith: end.scalars)
    }

    internal func contentsOfFirstComment(in range: Range<String.ScalarView.Index>, of string: String) -> String? { // [_Exempt from Test Coverage_] [_Workaround: Until headers are testable._]
        guard let range = firstComment(in: range, of: string)?.contents.range else {
            return nil
        }

        var lines = String(string[range]).lines.map({ String($0.line) })
        while let line = lines.first, line.isWhitespace {
            lines.removeFirst()
        }

        guard let first = lines.first else {
            return ""
        }
        lines.removeFirst()

        var index = first.scalars.startIndex
        first.scalars.advance(&index, over: RepetitionPattern(ConditionalPattern({ $0 ∈ CharacterSet.whitespaces })))
        let indent = first.scalars.distance(from: first.scalars.startIndex, to: index)

        var result = [first.scalars.suffix(from: index)]
        for line in lines {
            var indentIndex = line.scalars.startIndex
            line.scalars.advance(&indentIndex, over: RepetitionPattern(ConditionalPattern({ $0 ∈ CharacterSet.whitespaces }), count: 0 ... indent))
            result.append(line.scalars.suffix(from: indentIndex))
        }

        var strings = result.map({ String($0) })
        while let last = strings.last, last.isWhitespace {
            strings.removeLast()
        }

        return strings.joinedAsLines()
    }

    internal func contentsOfFirstComment(in string: String) -> String? { // [_Exempt from Test Coverage_] [_Workaround: Until headers are testable._]
        return contentsOfFirstComment(in: string.scalars.startIndex ..< string.scalars.endIndex, of: string)
    }
}