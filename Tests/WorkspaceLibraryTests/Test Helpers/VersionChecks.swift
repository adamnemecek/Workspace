/*
 VersionChecks.swift

 This source file is part of the Workspace open source project.
 https://github.com/SDGGiesbrecht/Workspace#workspace

 Copyright ©2017–2018 Jeremy David Giesbrecht and the Workspace project contributors.

 Soli Deo gloria.

 Licensed under the Apache Licence, Version 2.0.
 See http://www.apache.org/licenses/LICENSE-2.0 for licence information.
 */

@testable import WSProofreading
@testable import WSDocumentation
@testable import WSInterface
import WSGeneralTestImports

func triggerVersionChecks() {
    _ = try? SwiftLint.default.execute(with: ["version"], output: Command.Output.mock)
}
