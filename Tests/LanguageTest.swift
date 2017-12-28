//
//  LocalizationLanguageTest.swift
//  LocalizationKit
//
//  Created by Will Powell on 28/12/2017.
//  Copyright © 2017 willpowell8. All rights reserved.
//

import XCTest
import LocalizationKit

class LanguageTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Localization.start(appKey: "407f3581-648e-4099-b761-e94136a6628d", live: false)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLanguageCode(){
        XCTAssert(Localization.language?.key == Localization.languageCode)
    }
    
    func testAvailableLanguages(){
        let expectation = XCTestExpectation(description: "Available Langauges")
        Localization.availableLanguages { (languages) in
            XCTAssert(languages.count > 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testChangeLanguage(){
        let expectation = XCTestExpectation(description: "Test Change Language")
        Localization.availableLanguages { (languages) in
            Localization.setLanguage(languages[0], {
                XCTAssert(Localization.language?.key == languages[0].key)
                expectation.fulfill()
            })
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testResetLanguage(){
        let expectation = XCTestExpectation(description: "Test Reset Language")
        Localization.resetToDeviceLanguage({ (language) in
            XCTAssert(Localization.language?.key == "en")
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
}
