@testable import CrashMonitor
import XCTest

final class CrashMonitorTests: XCTestCase {
    func testExample() async throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

        let all = try await CrashMonitor.allAppleFmtReports(of: "PacketTunnel", at: "/Users/codingiran/Downloads/Reports")
        print(all ?? "nil")
    }
}
