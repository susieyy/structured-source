import Foundation

// https://github.com/Constellation/structured-source/blob/master/src/structured-source.js

public class StructuredSource {
    public struct Position {
        public var line: Int
        public var column: Int
    }
    public struct Location {
        public var start: Position
        public var end: Position
    }

    public var source: String
    public var indice: [Int]

    public init(source: String) {
        self.source = source
        self.indice = [ 0 ]
        let regexp = Re("/[\r\n\u{2028}\u{2029}]/g")
        let length = source.count
        regexp.lastIndex = 0
        while true {
            guard let result = regexp.exec(source) else { break }
            var index = result.index
            if source.charCodeAt(index: index) == 0x0D  /* '\r' */ &&
                source.charCodeAt(index: index + 1) == 0x0A  /* '\n' */ {
                index += 1
            }
            let nextIndex = index + 1
            // If there's a last line terminator, we push it to the indice.
            // So use < instead of <=.
            if length < nextIndex {
                break
            }
            indice.append(nextIndex)
            regexp.lastIndex = nextIndex
        }
    }

    public var lin: Int {
        indice.count
    }

    public func locationToRange(loc: Location) -> Range<Int> {
        positionToIndex(pos: loc.start)..<positionToIndex(pos: loc.end)
    }

    public func rangeToLocation(range: Range<Int>) -> Location {
        Location(start: indexToPosition(index: range.startIndex), end: indexToPosition(index: range.endIndex))
    }

    public func positionToIndex(pos: Position) -> Int {
        // Line number starts with 1.
        // Column number starts with 0.
        let start = self.indice[pos.line - 1]
        return start + pos.column
    }

    public func indexToPosition(index: Int) -> Position {
        let startLine = upperBound(indice, index)
        return Position(line: startLine, column: index - indice[startLine - 1])
    }

}

func upperBound<T: Comparable>(_ array: [T], _ value: T) -> Int {
    array.filter({ $0 <= value }).count
}

extension String {
    public func charAt(index: Int) -> String {
        return String(Array(self)[index])
    }

    public func charCodeAt(index: Int) -> Int {
        return Int((self as NSString).character(at: index))
    }
}
