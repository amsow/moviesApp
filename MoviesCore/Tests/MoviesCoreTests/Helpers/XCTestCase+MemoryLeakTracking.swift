

import XCTest

extension XCTestCase {
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Memory leak detected! Instance \(String(describing: instance)) should have been deallocated", file: file, line: line)
        }
    }
}
