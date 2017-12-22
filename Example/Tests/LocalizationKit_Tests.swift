//
//  LocalizationKit_Tests.swift
//  LocalizationKit_Tests
//
//  Created by Will Powell on 22/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import LocalizationKit

class LocalizationKit_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Localization.start(appKey: "407f3581-648e-4099-b761-e94136a6628d", live:false)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParser(){
        let str = Localization.parse(str:"Name*")
         XCTAssert(str == "Name")
        let str2 = Localization.parse(str:"Hello how are you !?>")
        XCTAssert(str2 == "Hellohowareyou")
    }
    
    func testLanguages(){
        let expectation = XCTestExpectation(description: "Get languages")
        Localization.availableLanguages { (languages) in
            XCTAssert(languages.count > 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
}
