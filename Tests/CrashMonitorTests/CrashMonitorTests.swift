@testable import CrashMonitorCore
@testable import CrashMonitorReports
import XCTest

final class CrashMonitorTests: XCTestCase {
    func testExample() async throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        let all = try await CrashMonitor.allReports(of: "PacketTunnel", reportsPath: "/Users/codingiran/Downloads/Reports")
        debugPrint(all)
    }
}
