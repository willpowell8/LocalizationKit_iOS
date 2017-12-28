//
//  KeyParseTest.swift
//  LocalizationKit
//
//  Created by Will Powell on 28/12/2017.
//  Copyright © 2017 willpowell8. All rights reserved.
//

import XCTest
import LocalizationKit

class KeyParseTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseSuccess() {
        XCTAssert(Localization.parse(str: "com.test") == "com.test")
    }
    
    func testParseSpace() {
        XCTAssert(Localization.parse(str: "com. test") == "com.test")
    }
    
    func testParsePunctuation() {
        XCTAssert(Localization.parse(str: "com.#?/<>,test") == "com.test")
    }
    
}
