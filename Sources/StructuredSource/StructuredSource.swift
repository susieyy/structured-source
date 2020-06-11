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

private let regex = NSRegularExpression("[\\r\\n\u{2028}\u{2029}]")

public struct StructuredSource {
    public var source: String
    public var indice: [Int]
    public var count: Int

    public init(_ source: String) {
        self.source = source
        self.indice = [ 0 ]
        let characters: [Character] = Array(source)
        let length = characters.count
        self.count = length

        regex.matches(in: source, options: [], range: NSRange(location: 0, length: source.count)).forEach { (match: NSTextCheckingResult) in
            var index = match.range.lowerBound
            let next = index + 1

            if length > next &&
                characters[index].isNewline && //  == 0x0D  /* '\r' */ &&
                characters[next].isNewline { // == 0x0A  /* '\n' */ {
                index += 1
            }
            // If there's a last line terminator, we push it to the indice.
            // So use < instead of <=.
            if length < next {
                return
            }
            indice.append(next)
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
