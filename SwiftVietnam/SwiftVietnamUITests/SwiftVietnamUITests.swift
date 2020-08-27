//
//  Created by An Tran.
//

import XCTest

class SwiftVietnamUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // UI tests must launch the application that they test.
        app = XCUIApplication()
        app.launch()
    }


    func testHappyFlow() {
        // wait a little bit to load the remote RSS feed
        sleep(3)

        // Assert that the feed is loaded successfully
        XCTAssertTrue(app.tables.buttons["Bản tin Swift Việt Nam #12"].exists)
        XCTAssertTrue(app.tables.buttons["Bản tin Swift Việt Nam #11"].exists)
        XCTAssertTrue(app.tables.buttons["Bản tin Swift Việt Nam #10"].exists)
    }
}
