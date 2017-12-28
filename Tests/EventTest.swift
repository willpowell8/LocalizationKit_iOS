//
//  EventTest.swift
//  LocalizationKit
//
//  Created by Will Powell on 28/12/2017.
//  Copyright © 2017 willpowell8. All rights reserved.
//

import XCTest
import LocalizationKit

class EventTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHighlightEvent() {
        let event = Localization.highlightEvent(localizationKey: "com.general")
        XCTAssert(event.rawValue == "LOC_HIGHLIGHT_com.general")
    }
    
    func testUpdateEvent() {
        let event = Localization.localizationEvent(localizationKey: "com.general")
        XCTAssert(event.rawValue == "LOC_TEXT_com.general")
    }
    
}
