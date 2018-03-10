/*
 WorkaroundReminder.swift

 This source file is part of the Workspace open source project.
 https://github.com/SDGGiesbrecht/Workspace#workspace

 Copyright ©2017–2018 Jeremy David Giesbrecht and the Workspace project contributors.

 Soli Deo gloria.

 Licensed under the Apache Licence, Version 2.0.
 See http://www.apache.org/licenses/LICENSE-2.0 for licence information.
 */

import Foundation

import SDGCornerstone
import SDGCommandLine

struct WorkaroundReminder : Warning {

    static let noticeOnly = true

    static let name = UserFacingText<InterfaceLocalization, Void>({ (localization, _) in
        switch localization {
        case .englishCanada:
            return "Workaround Reminder"
        }
    })

    static let trigger = UserFacingText<InterfaceLocalization, Void>({ (localization, _) in
        switch localization {
        case .englishCanada:
            return "Workaround"
        }
    })

    static func message(for details: StrictString, in project: PackageRepository, output: inout Command.Output) throws -> UserFacingText<InterfaceLocalization, Void>? {

        if let versionCheck = details.scalars.firstNestingLevel(startingWith: "(".scalars, endingWith: ")".scalars) {
            var parameters = versionCheck.contents.contents.components(separatedBy: " ".scalars)
            if ¬parameters.isEmpty,
                let problemVersion = Version(String(StrictString(parameters.removeLast().contents))) {

                let dependency = parameters.map({ StrictString($0.contents) }).joined(separator: " ")

                if dependency == "Swift" {
                    var newDetails = details
                    let script: StrictString = "swift \u{2D}\u{2D}version"
                    newDetails.replaceSubrange(versionCheck.contents.range, with: "\(script) \(problemVersion.string)".scalars)
                    if try message(for: newDetails, in: project, output: &output) == nil {
                        return nil
                    }
                } else {
                    if let current = try currentVersion(of: dependency, for: project, output: &output) {
                        if current ≤ problemVersion {
                            return nil
                        }
                    }
                }
            }
        }

        return UserFacingText({ localization, _ in
            let label: StrictString
            switch localization {
            case .englishCanada:
                label = "Workaround: "
            }
            return label + details
        })
    }

    private static var dependencyVersionCache: [StrictString: Version?] = [:]
    private static func currentVersion(of dependency: StrictString, for project: PackageRepository, output: inout Command.Output) throws -> Version? {
        if let version = try project.dependencies(output: &output)[dependency] {
            return version
        } else {
            return cached(in: &dependencyVersionCache[dependency], {
                if let shellOutput = try? Shell.default.run(command: String(dependency).components(separatedBy: " "), silently: true),
                    let version = Version(firstIn: shellOutput) {
                    return version
                } else {
                    return nil
                }
            })
        }
    }
}