//
//  LocalStorageTest.swift
//  LocalizationKit
//
//  Created by Will Powell on 28/12/2017.
//  Copyright © 2017 willpowell8. All rights reserved.
//

import XCTest
import LocalizationKit

class LocalStorageTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Localization.start(appKey: "407f3581-648e-4099-b761-e94136a6628d", live: false)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        let translation:[String:String] = ["testCode":"EXAMPLE"]
        Localization.saveLanguageToDisk(code: "xxx", translation: translation)
        Localization.loadLanguageFromDisk(code: "xxx")
        let key = Localization.get("testCode", alternate: "")
        XCTAssert(key == "EXAMPLE")
    }
    
}
