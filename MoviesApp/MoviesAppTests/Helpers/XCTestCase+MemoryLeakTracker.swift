

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
         XCTAssertNil(instance,
                      "Instance of \(String(describing: instance)) should be nil. Potential memory leak detected",
                      file: file,
                      line: line)
        }
    }
}
