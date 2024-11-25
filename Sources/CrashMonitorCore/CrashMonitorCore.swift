//
//  CrashMonitorCore.swift
//  CrashMonitor
//
//  Created by CodingIran on 2024/11/21.
//

import Foundation
import KSCrashRecording

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.9)
#error("CrashMonitor doesn't support Swift versions below 5.9.")
#endif

/// Current CrashMonitor version 0.0.2. Necessary since SPM doesn't use dynamic libraries. Plus this will be more accurate.
let version = "0.0.2"

public enum CrashMonitor {}

public extension CrashMonitor {
    /// Install configuration
    struct Installonfiguration {
        /// Install path
        public let installPath: String?
        /// Monitor types
        public let monitorTypes: CrashMonitor.CrashMonitorType
        /// Report store configuration
        public let reportStoreConfiguration: CrashMonitor.ReportStoreConfiguration
        /// User info
        public let userInfo: [String: Any]?

        public init(installPath: String?,
                    monitorTypes: CrashMonitor.CrashMonitorType,
                    reportStoreConfiguration: CrashMonitor.ReportStoreConfiguration,
                    userInfo: [String: Any]? = nil)
        {
            self.installPath = installPath
            self.monitorTypes = monitorTypes
            self.reportStoreConfiguration = reportStoreConfiguration
            self.userInfo = userInfo
        }
    }
}

public extension CrashMonitor {
    /// Report store configuration
    struct ReportStoreConfiguration {
        /// Reports path
        public let reportsPath: String?
        /// App name
        public let appName: String?
        /// Max report count
        public let maxReportCount: Int
        /// Cleanup policy
        public let cleanupPolicy: ReportCleanupPolicy

        public init(reportsPath: String? = nil,
                    appName: String? = nil,
                    maxReportCount: Int = 5,
                    cleanupPolicy: CrashMonitor.ReportCleanupPolicy = .always)
        {
            self.reportsPath = reportsPath
            self.appName = appName
            self.maxReportCount = maxReportCount
            self.cleanupPolicy = cleanupPolicy
        }

        public static let `default` = ReportStoreConfiguration()
    }
}

public extension CrashMonitor {
    /// Monitor types, align with KSCrashRecording.MonitorType
    struct CrashMonitorType: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /** Monitor Mach kernel exceptions. */
        public static let machException = CrashMonitorType(rawValue: 1 << 0)

        /** Monitor fatal signals. */
        public static let signal = CrashMonitorType(rawValue: 1 << 1)

        /** Monitor uncaught C++ exceptions. */
        public static let cppException = CrashMonitorType(rawValue: 1 << 2)

        /** Monitor uncaught Objective-C NSExceptions. */
        public static let nsException = CrashMonitorType(rawValue: 1 << 3)

        /** Detect deadlocks on the main thread. */
        public static let mainThreadDeadlock = CrashMonitorType(rawValue: 1 << 4)

        /** Monitor user-reported custom exceptions. */
        public static let userReported = CrashMonitorType(rawValue: 1 << 5)

        /** Track and inject system information. */
        public static let system = CrashMonitorType(rawValue: 1 << 6)

        /** Track and inject application state information. */
        public static let applicationState = CrashMonitorType(rawValue: 1 << 7)

        /** Track memory issues and last zombie NSException. */
        public static let zombie = CrashMonitorType(rawValue: 1 << 8)

        /** Monitor memory to detect OOMs at startup. */
        public static let memoryTermination = CrashMonitorType(rawValue: 1 << 9)

        /** Enable all monitoring options. */
        public static let all: CrashMonitorType = [.machException, .signal, .cppException, .nsException, .mainThreadDeadlock, .userReported, .system, .applicationState, .zombie, .memoryTermination]

        /** Fatal monitors track exceptions that lead to error termination of the process.. */
        public static let fatal: CrashMonitorType = [.machException, .signal, .cppException, .nsException, .mainThreadDeadlock]

        /** Enable experimental monitoring options. */
        public static let experimental: CrashMonitorType = [.mainThreadDeadlock]
    }
}

public extension CrashMonitor {
    /// Report cleanup policy, align with KSCrashRecording.CrashReportCleanupPolicy
    enum ReportCleanupPolicy {
        /// Never delete reports
        case never
        /// Delete reports on success
        case onSuccess
        /// Always delete reports
        case always
    }
}

// MARK: - Conversions Extensions for KSCrashRecording

public extension KSCrashRecording.CrashReportStoreConfiguration {
    convenience init(_ configuration: CrashMonitor.ReportStoreConfiguration) {
        self.init()
        self.reportsPath = configuration.reportsPath
        self.appName = configuration.appName
        self.maxReportCount = configuration.maxReportCount
        self.reportCleanupPolicy = KSCrashRecording.CrashReportCleanupPolicy(configuration.cleanupPolicy)
    }
}

public extension KSCrashRecording.KSCrashConfiguration {
    convenience init(_ configuration: CrashMonitor.Installonfiguration) {
        self.init()
        self.installPath = configuration.installPath
        self.monitors = KSCrashRecording.MonitorType(configuration.monitorTypes)
        self.userInfoJSON = configuration.userInfo
        self.reportStoreConfiguration = CrashReportStoreConfiguration(configuration.reportStoreConfiguration)
    }
}

public extension KSCrashRecording.CrashReportCleanupPolicy {
    init(_ policy: CrashMonitor.ReportCleanupPolicy) {
        switch policy {
        case .never:
            self = .never
        case .onSuccess:
            self = .onSuccess
        case .always:
            self = .always
        }
    }
}

public extension KSCrashRecording.MonitorType {
    init(_ monitorType: CrashMonitor.CrashMonitorType) {
        self.init(rawValue: monitorType.rawValue)
    }
}
