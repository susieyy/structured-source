import Foundation

// https://github.com/Constellation/structured-source/blob/master/src/structured-source.js

public struct OutOfRangeError: Error, Equatable { }

public struct Position: Equatable, Encodable {
    public var line: Int
    public var column: Int
    public init(line: Int, column: Int) {
        assert(line > 0, "Line should be more than 0")
        assert(column >= 0, "column should be greater than 0")
        self.line = line
        self.column = column
    }
}

public struct Location: Equatable, Encodable {
    public var start: Position
    public var end: Position
    public init(start: Position, end: Position) {
        self.start = start
        self.end = end
    }
}

private let regex = NSRegularExpression("[\\r\\n\u{2028}\u{2029}]")

public struct StructuredSource {
    public struct Line {
        public var text: String
        public var range: Range<Int>
        public var newLine: Character?
    }
    public var source: String
    public var indice: [Int] { indiceAndNewLine.map { $0.0 }  }
    public var count: Int
    private var indiceAndNewLine: [(Int, Character)]
    private var characters: [Character]

    public init(_ source: String) {
        self.source = source
        self.characters = Array(source)
        let length = characters.count
        self.count = length

        self.indiceAndNewLine = [(0, Character("\n"))] + characters.enumerated().filter { $0.1.isNewline }.map { ($0.offset + 1, $0.element) }

//        regex.matches(in: source, options: [], range: NSRange(location: 0, length: source.count)).forEach { (match: NSTextCheckingResult) in
//            var index = match.range.lowerBound
//            let next = index + 1
//
//            print(characters[index])
//            if length > next &&
//                characters[index].isNewline && //  == 0x0D  /* '\r' */ &&
//                characters[next].isNewline { // == 0x0A  /* '\n' */ {
//                index += 1
//            }
//            // If there's a last line terminator, we push it to the indice.
//            // So use < instead of <=.
//            if length < next {
//                return
//            }
//            indice.append(next)
//        }
    }

    public var line: Int {
        indice.count
    }

    public var lines: [Line] {
        indiceAndNewLine.enumerated().map {
            let next = $0.offset + 1
            let nextElement = indiceAndNewLine.count > next ? indiceAndNewLine[next] : nil
            let start = $0.element.0
            let end = (nextElement?.0 ?? (source.count + 1)) - 1
            let text = String(characters[start..<end])
            return Line(text: text, range: start..<end, newLine: nextElement?.1)
        }
    }

    public func slice(_ range: Range<Int>) -> String {
        String(characters[range])
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
        let start = indiceAndNewLine[index].0
        return .success(start + pos.column)
    }

    public func indexToPosition(_ index: Int) -> Position {
        let startLine = upperBound(indiceAndNewLine, index)
        return Position(line: startLine, column: index - indiceAndNewLine[startLine - 1].0)
    }
}

func upperBound<T: Comparable>(_ array: [(T, Character)], _ value: T) -> Int {
    array.filter({ $0.0 <= value }).count
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
