//
//  CrashMonitorInstall.swift
//  CrashMonitor
//
//  Created by CodingIran on 2024/11/21.
//

import CrashMonitorCore
import KSCrashInstallations
import KSCrashRecording

// MARK: - Install KSCrash

public extension CrashMonitor {
    /// Install KSCrash
    /// - Parameters:
    ///   - appName: name of the app, If `nil` the default value is used: `CFBundleName` from Info.plist. defaults to nil
    ///   - installPath: install path, If `nil` the default directory is used: The default directory is "KSCrash" inside the default cache directory. defaults to nil
    ///   - monitorTypes: monitor types, defaults to .machException, .signal, .cppException, .nsException
    ///   - reportsPath: path of reports, If `nil` the default directory is used: `Reports` within the installation directory. defaults to nil
    ///   - maxReportCount: The maximum number of crash reports allowed on disk before old ones get deleted. defaults to 20
    ///   - cleanupPolicy: What to do after sending reports. defaults to .never
    static func install(to appName: String? = nil,
                        installPath: String? = nil,
                        monitorTypes: CrashMonitorType = [.machException, .signal, .cppException, .nsException],
                        reportsPath: String? = nil,
                        maxReportCount: Int = 20,
                        cleanupPolicy: ReportCleanupPolicy = .never) throws
    {
        let reportStoreConfiguration = CrashMonitor.ReportStoreConfiguration(reportsPath: reportsPath, appName: appName, maxReportCount: maxReportCount, cleanupPolicy: cleanupPolicy)
        let installConfiguration = CrashMonitor.Installonfiguration(installPath: installPath, monitorTypes: monitorTypes, reportStoreConfiguration: reportStoreConfiguration)
        try install(installConfiguration)
    }

    /// Install KSCrash
    /// - Parameter configuration: KSCrashInstallationConfiguration
    static func install(_ configuration: CrashMonitor.Installonfiguration) throws {
        let installation = KSCrashInstallations.CrashInstallationStandard.shared
        let ksConfiguration = KSCrashRecording.KSCrashConfiguration(configuration)
        try installation.install(with: ksConfiguration)
    }
}
