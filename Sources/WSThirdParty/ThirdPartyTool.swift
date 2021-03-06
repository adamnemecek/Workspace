/*
 ThirdPartyTool.swift

 This source file is part of the Workspace open source project.
 https://github.com/SDGGiesbrecht/Workspace#workspace

 Copyright ©2017–2018 Jeremy David Giesbrecht and the Workspace project contributors.

 Soli Deo gloria.

 Licensed under the Apache Licence, Version 2.0.
 See http://www.apache.org/licenses/LICENSE-2.0 for licence information.
 */

import WSGeneralImports

import SDGExternalProcess

open class ThirdPartyTool {

    // MARK: - Static Properties

    private static let toolsCache = FileManager.default.url(in: .cache, at: "Tools")

    // MARK: - Initialization

    public init(command: StrictString, repositoryURL: URL, version: Version, versionCheck: [StrictString]) { // @exempt(from: tests) False positive with Xcode 9.3.
        self.command = command
        self.repositoryURL = repositoryURL
        self.version = version
        self.versionCheck = versionCheck
    }

    // MARK: - Properties

    private let command: StrictString
    private let repositoryURL: URL
    private let version: Version
    private let versionCheck: [StrictString]

    // MARK: - Execution

    public final func execute(with arguments: [StrictString], output: Command.Output) throws {
        try executeInCompatibilityMode(with: arguments.map({ String($0) }), output: output)
    }

    public final func executeInCompatibilityMode(with arguments: [String], output: Command.Output) throws {
        if let systemVersionString = try? Shell.default.run(command: ([String(command)] + versionCheck.map({ String($0) }))),
            let systemVersion = Version(firstIn: systemVersionString),
            systemVersion == version {
            // @exempt(from: tests) Reachability differs from device to device.

            output.print("")
            try Shell.default.run(command: [String(command)] + arguments, reportProgress: { output.print($0) })
            output.print("")
            return
        }
        // @exempt(from: tests) Reachability differs from device to device.
        try type(of: self).execute(command: command, version: version, with: arguments, versionCheck: versionCheck, repositoryURL: repositoryURL, cacheDirectory: ThirdPartyTool.toolsCache.appendingPathComponent(repositoryURL.lastPathComponent), output: output)
    }

    open class func execute(command: StrictString, version: Version, with arguments: [String], versionCheck: [StrictString], repositoryURL: URL, cacheDirectory: URL, output: Command.Output) throws {
        primitiveMethod()
    }
}
