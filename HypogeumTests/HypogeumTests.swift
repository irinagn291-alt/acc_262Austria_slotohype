import XCTest
@testable import Hypogeum

/// Placeholder. Replace with the cases required by SPEC.md section 17.
final class HypogeumTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: HypogeumApp.self), "HypogeumApp")
    }
}
