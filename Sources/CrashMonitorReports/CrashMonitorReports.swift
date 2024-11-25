//
//  CrashMonitorReports.swift
//  CrashMonitor
//
//  Created by CodingIran on 2024/11/21.
//

import CrashMonitorCore
import CrashMonitorObjC
import KSCrashFilters
import KSCrashRecording

// MARK: - Crash Reports Model

public extension CrashMonitor {
    struct CrashReports: Equatable {
        /// Crash report id (KSCrash id)
        public let id: Int64
        /// Report name
        public let name: String
        /// Crash date
        public let crashDate: Date?
        /// Raw value
        public let rawValue: [String: Any]
        /// Report Info
        public let info: CrashReports.Info?
        /// Apple fmt value
        public let appleFmtValue: String?

        public static func == (lhs: CrashMonitor.CrashReports, rhs: CrashMonitor.CrashReports) -> Bool {
            return lhs.id == rhs.id
        }

        public struct Info {
            public let id: String?
            public let version: String?
            public let type: String?
            public let timestamp: String?
            public let processName: String?

            init(id: String?, version: String?, type: String?, timestamp: String?, processName: String?) {
                self.id = id
                self.version = version
                self.type = type
                self.timestamp = timestamp
                self.processName = processName
            }

            init?(dict: [String: Any]?) {
                guard let dict else { return nil }
                let id = dict[CrashField.id.rawValue] as? String
                let version = dict[CrashField.version.rawValue] as? String
                let type = dict[CrashField.type.rawValue] as? String
                let timestamp = dict[CrashField.timestamp.rawValue] as? String
                let processName = dict[CrashField.processName.rawValue] as? String
                self.init(id: id, version: version, type: type, timestamp: timestamp, processName: processName)
            }
        }
    }
}

// MARK: - Fetch Crash Reports

public extension CrashMonitor {
    /// Fetch all crash reports
    /// - Parameters:
    ///   - appName: name of the app, If `nil` the default value is used: `CFBundleName` from Info.plist. defaults to nil
    ///   - reportsPath: path of reports, If `nil` the default directory is used: `Reports` within the installation directory. defaults to nil
    /// - Returns: [CrashMonitor.CrashReports]
    static func allReports(of appName: String? = nil, reportsPath: String? = nil) async throws -> [CrashMonitor.CrashReports] {
        let reportStoreConfiguration = CrashMonitor.ReportStoreConfiguration(reportsPath: reportsPath, appName: appName)
        return try await allReports(of: reportStoreConfiguration)
    }

    /// Fetch all crash reports
    /// - Parameter reportStoreConfiguration: CrashMonitor.ReportStoreConfiguration
    static func allReports(of reportStoreConfiguration: CrashMonitor.ReportStoreConfiguration) async throws -> [CrashMonitor.CrashReports] {
        let configuration = KSCrashRecording.CrashReportStoreConfiguration(reportStoreConfiguration)
        let crashReportStore = try KSCrashRecording.CrashReportStore(configuration: configuration)
        let reportIDs = crashReportStore.reportIDs.map { $0.int64Value }
        guard !reportIDs.isEmpty else { return [] }
        var reports: [CrashMonitor.CrashReports] = []
        for id in reportIDs {
            guard let report = crashReportStore.report(for: id) else {
                continue
            }
            let name = reportName(of: id, appName: reportStoreConfiguration.appName ?? "")
            let rawValue = report.value
            let infoDict = appleFmtFilter.infoReport(rawValue) as? [String: Any]
            let info = CrashReports.Info(dict: infoDict)
            var crashDate: Date?
            if let timestamp = info?.timestamp {
                crashDate = g_rfc3339DateFormatter.date(from: timestamp)
            }
            let appleFmtReport = try await appleFmtFilter.filterReport(report)
            let appleFmtValue = appleFmtReport?.value
            let crashReport = CrashMonitor.CrashReports(id: id, name: name, crashDate: crashDate, rawValue: rawValue, info: info, appleFmtValue: appleFmtValue)
            reports.append(crashReport)
        }
        return reports
    }

    /// Get Report name by id
    private static func reportName(of id: Int64, appName: String) -> String {
        String(format: "%@-report-%016llx", appName, id)
    }
}

// MARK: - Delete Crash Reports

public extension CrashMonitor {
    /// Delete all crash reports
    /// - Parameters:
    ///   - appName: name of the app, If `nil` the default value is used: `CFBundleName` from Info.plist. defaults to nil
    ///   - reportsPath: path of reports, If `nil` the default directory is used: `Reports` within the installation directory. defaults to nil
    static func deleteAllReports(of appName: String? = nil, reportsPath: String? = nil) throws {
        let reportStoreConfiguration = CrashMonitor.ReportStoreConfiguration(reportsPath: reportsPath, appName: appName)
        try deleteAllReports(of: reportStoreConfiguration)
    }

    /// Delete all crash reports
    /// - Parameter reportStoreConfiguration: CrashMonitor.ReportStoreConfiguration
    static func deleteAllReports(of reportStoreConfiguration: CrashMonitor.ReportStoreConfiguration) throws {
        let configuration = KSCrashRecording.CrashReportStoreConfiguration(reportStoreConfiguration)
        let crashReportStore = try KSCrashRecording.CrashReportStore(configuration: configuration)
        crashReportStore.deleteAllReports()
    }
}

private extension CrashMonitor {
    static let appleFmtFilter = KSCrashFilters.CrashReportFilterAppleFmt(reportStyle: .symbolicatedSideBySide)

    static let g_rfc3339DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
}

public extension KSCrashFilters.CrashReportFilterAppleFmt {
    /// Filter reports
    /// - Parameter reports: [CrashReportDictionary]
    /// - Returns: [CrashReportString]?
    func filterReports(_ reports: [CrashReportDictionary]) async throws -> [CrashReportString]? {
        try await withCheckedThrowingContinuation { continuation in
            self.filterReports(reports) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result as? [CrashReportString])
                }
            }
        }
    }

    /// Filter report
    /// - Parameter report: CrashReportDictionary
    /// - Returns: CrashReportString?
    func filterReport(_ report: CrashReportDictionary) async throws -> CrashReportString? {
        let result = try await filterReports([report])
        return result?.first
    }
}
