/*
 ValidateTestCoverage.swift

 This source file is part of the Workspace open source project.
 https://github.com/SDGGiesbrecht/Workspace#workspace

 Copyright ©2017–2018 Jeremy David Giesbrecht and the Workspace project contributors.

 Soli Deo gloria.

 Licensed under the Apache Licence, Version 2.0.
 See http://www.apache.org/licenses/LICENSE-2.0 for licence information.
 */

import SDGLogic
import SDGCollections
import WSGeneralImports

import WSProject

extension Workspace.Validate {

    enum TestCoverage {

        private static let name = UserFacing<StrictString, InterfaceLocalization>({ localization in
            switch localization {
            case .englishCanada:
                return "test‐coverage"
            }
        })

        private static let description = UserFacing<StrictString, InterfaceLocalization>({ localization in
            switch localization {
            case .englishCanada:
                return "validates test coverage, checking that every code path is reached by the project’s tests."
            }
        })

        static let command = Command(name: name, description: description, directArguments: [], options: [ContinuousIntegration.Job.option], execution: { (_, options: Options, output: Command.Output) throws in

            try Build.validate(job: options.job, against: Tests.coverageJobs, for: options.project, output: output)

            var validationStatus = ValidationStatus()

            #if os(Linux)
            validationStatus.failStep(message: UserFacing<StrictString, InterfaceLocalization>({ localization in
                switch localization {
                case .englishCanada:
                    return "Test coverage validation requires Xcode, which is unavailable on Linux."
                }
            }))
            #endif

            try executeAsStep(options: options, validationStatus: &validationStatus, output: output)

            try validationStatus.reportOutcome(projectName: try options.project.projectName(), output: output)
        })

        static func executeAsStep(options: Options, validationStatus: inout ValidationStatus, output: Command.Output) throws {

            for job in ContinuousIntegration.Job.cases
                where try options.job.includes(job: job) ∧ (try Build.job(job, isRelevantTo: options.project, andAvailableJobs: Tests.coverageJobs, output: output)) {
                    try autoreleasepool {

                        if try options.project.configuration().continuousIntegration.skipSimulatorOutsideContinuousIntegration,
                            options.job == nil, // Not in continuous integration.
                            job ∈ Tests.simulatorJobs {
                            // [_Exempt from Test Coverage_] Tested separately.
                            return // and continue loop.
                        }

                        if BuildConfiguration.current == .debug,
                            job ∈ Tests.simulatorJobs,
                            ProcessInfo.processInfo.environment["SIMULATOR_UNAVAILABLE_FOR_TESTING"] ≠ nil { // Simulators are not available to all CI jobs and must be tested separately.
                            return // and continue loop.
                        }

                        try Tests.test(options.project, on: job, validationStatus: &validationStatus, output: output)
                        try Tests.validateCodeCoverage(for: options.project, on: job, validationStatus: &validationStatus, output: output)
                    }
            }
        }
    }
}