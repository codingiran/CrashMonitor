//
//  CrashMonitor.swift
//  CrashMonitor
//
//  Created by iran.qiu on 2024/11/21.
//

import CrashMonitorObjC
import Foundation
import KSCrashFilters
import KSCrashInstallations
import KSCrashRecording

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.9)
#error("CrashMonitor doesn't support Swift versions below 5.9.")
#endif

/// Current CrashMonitor version 0.0.1. Necessary since SPM doesn't use dynamic libraries. Plus this will be more accurate.
let version = "0.0.1"

public enum CrashMonitor {}

public extension CrashMonitor {
    /// Install KSCrash
    /// - Parameters:
    ///   - appName: name of the app, If `nil` the default value is used: `CFBundleName` from Info.plist. defaults to nil
    ///   - installPath: install path, If `nil` the default directory is used: The default directory is "KSCrash" inside the default cache directory. defaults to nil
    ///   - reportsPath: path of reports, If `nil` the default directory is used: `Reports` within the installation directory. defaults to nil
    static func install(to appName: String? = nil, installPath: String? = nil, reportsPath: String? = nil) throws {
        let installation = CrashInstallationStandard.shared
        let config = KSCrashConfiguration()
        config.installPath = installPath
        config.monitors = [.machException, .signal, .cppException, .nsException]
        config.reportStoreConfiguration = reportStoreConfiguration(of: appName, reportsPath: reportsPath)
        try installation.install(with: config)
    }

    /// Get all reports
    /// - Parameters:
    ///   - appName: name of the app, If `nil` the default value is used: `CFBundleName` from Info.plist. defaults to nil
    ///   - reportsPath: path of reports, If `nil` the default directory is used: `Reports` within the installation directory. defaults to nil
    /// - Returns: [CrashReportString]?
    static func allAppleFmtReports(of appName: String? = nil, at reportsPath: String) async throws -> [CrashReportString]? {
        guard let allReports = allReports(of: appName, reportsPath: reportsPath) else { return nil }
        return try await withCheckedThrowingContinuation { continuation in
            let appleFmtFilter = CrashReportFilterAppleFmt(reportStyle: .symbolicatedSideBySide)
            appleFmtFilter.filterReports(allReports) { reports, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: reports as? [CrashReportString])
                }
            }
        }
    }

    /// Get report store configuration
    /// - Parameters:
    ///   - appName: name of the app, If `nil` the default value is used: `CFBundleName` from Info.plist. defaults to nil
    ///   - reportsPath: path of reports, If `nil` the default directory is used: `Reports` within the installation directory. defaults to nil
    ///   - maxReportCount: maximum number of reports, defaults to 20
    /// - Returns: CrashReportStoreConfiguration    
    private static func reportStoreConfiguration(of appName: String? = nil, reportsPath: String? = nil, maxReportCount: Int = 20) -> CrashReportStoreConfiguration {
        let config = CrashReportStoreConfiguration()
        config.reportsPath = reportsPath
        config.maxReportCount = maxReportCount
        config.appName = appName
        config.reportCleanupPolicy = .never
        return config
    }

    /// Get report store
    /// - Parameters:
    ///   - appName: name of the app, If `nil` the default value is used: `CFBundleName` from Info.plist. defaults to nil
    ///   - reportsPath: path of reports, If `nil` the default directory is used: `Reports` within the installation directory. defaults to nil
    /// - Returns: CrashReportStore?    
    private static func reportStore(of appName: String? = nil, reportsPath: String) -> CrashReportStore? {
        let config = reportStoreConfiguration(of: appName, reportsPath: reportsPath)
        guard let reportStore = try? CrashReportStore(configuration: config) else { return nil }
        return reportStore
    }

    /// Get all reports
    /// - Parameters:
    ///   - appName: name of the app, If `nil` the default value is used: `CFBundleName` from Info.plist. defaults to nil
    ///   - reportsPath: path of reports, If `nil` the default directory is used: `Reports` within the installation directory. defaults to nil
    /// - Returns: [CrashReportDictionary]? 
    private static func allReports(of appName: String? = nil, reportsPath: String) -> [CrashReportDictionary]? {
        guard let reportStore = reportStore(of: appName, reportsPath: reportsPath) else { return nil }
        return reportStore.allReports()
    }
}
