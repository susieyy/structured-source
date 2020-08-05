import Foundation

// MARK: - ./Resources/ Workaround
// URL of the directory containing non-code, test resource files.
//
// It is required that a directory named "Resources" be contained immediately below the test target.
// Root
//   Package.swift
//   Tests
//     (target)
//       Resources
//
fileprivate let _resources: URL = {
    func packageRoot(of file: String) -> URL? {
        func isPackageRoot(_ url: URL) -> Bool {
            let filename = url.appendingPathComponent("Package.swift", isDirectory: false)
            return FileManager.default.fileExists(atPath: filename.path)
        }

        var url = URL(fileURLWithPath: file, isDirectory: false)
        repeat {
            url = url.deletingLastPathComponent()
            if url.pathComponents.count <= 1 {
                return nil
            }
        } while !isPackageRoot(url)
        return url
    }

    guard let root = packageRoot(of: #file) else {
        fatalError("\(#file) must be contained in a Swift Package Manager project.")
    }
    let fileComponents = URL(fileURLWithPath: #file, isDirectory: false).pathComponents
    let rootComponenets = root.pathComponents
    let trailingComponents = Array(fileComponents.dropFirst(rootComponenets.count))
    let resourceComponents = rootComponenets + trailingComponents[0...1] + ["Resources"]
    return URL(fileURLWithPath: resourceComponents.joined(separator: "/"), isDirectory: true)
}()

extension URL {
    public init(forResource name: String, type: String) {
        let url = _resources.appendingPathComponent("\(name).\(type)", isDirectory: false)
        self = url
    }
}
