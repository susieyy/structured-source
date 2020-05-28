import Foundation

// https://github.com/Constellation/structured-source/blob/master/src/structured-source.js

public struct OutOfRangeError: Error, Equatable { }

public struct Position: Equatable {
    public var line: Int
    public var column: Int
    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

public struct Location: Equatable {
    public var start: Position
    public var end: Position
    public init(start: Position, end: Position) {
        self.start = start
        self.end = end
    }
}

public class StructuredSource {
    public var source: String
    public var indice: [Int]

    public init(_ source: String) {
        self.source = source
        self.indice = [ 0 ]
        let regexp = Re("[\\r\\n\u{2028}\u{2029}]", "g")
        let length = (source as NSString).length
        regexp.lastIndex = 0
        while true {
            guard let result = regexp.exec(source) else { break }
            var index = result.index
            let next = index + 1
            if // Array(source).indices.contains(next) &&
                source.charCodeAt(index: index) == 0x0D  /* '\r' */ &&
                source.charCodeAt(index: next) == 0x0A  /* '\n' */ {
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

    public var line: Int {
        indice.count
    }

    public func locationToRange(_ loc: Location) -> Result<Range<Int>, OutOfRangeError> {
        guard case .success(let posStart) = positionToIndex(loc.start) else { return .failure(OutOfRangeError()) }
        guard case .success(let posEnd) = positionToIndex(loc.end) else { return .failure(OutOfRangeError()) }
        return .success(posStart..<posEnd)
    }

    public func rangeToLocation(_ range: Range<Int>) -> Location {
        Location(start: indexToPosition(range.startIndex), end: indexToPosition(range.endIndex))
    }

    public func positionToIndex(_ pos: Position) -> Result<Int, OutOfRangeError> {
        // Line number starts with 1.
        // Column number starts with 0.
        let index = pos.line - 1
        guard indice.indices.contains(index) else { return .failure(OutOfRangeError()) }
        let start = indice[index]
        return .success(start + pos.column)
    }

    public func indexToPosition(_ index: Int) -> Position {
        let startLine = upperBound(indice, index)
        return Position(line: startLine, column: index - indice[startLine - 1])
    }
}

func upperBound<T: Comparable>(_ array: [T], _ value: T) -> Int {
    array.filter({ $0 <= value }).count
}

extension String {
    func charAt(index: Int) -> String {
        return String(Array(self)[index])
    }

    func charCodeAt(index: Int) -> Int {
        return Int((self as NSString).character(at: index))
    }
}
