//
//  LocalizationNetworkTest.swift
//  LocalizationKit
//
//  Created by Will Powell on 28/12/2017.
//  Copyright © 2017 willpowell8. All rights reserved.
//

import XCTest
import LocalizationKit

class NetworkTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Localization.start(appKey: "407f3581-648e-4099-b761-e94136a6628d", live: false)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAvailableLanguagesPerformance() {
        self.measure {
            Localization.availableLanguages({ (languages) in
                self.stopMeasuring()
            })
        }
    }
    
    func testChangeLanguagesPerformance() {
        self.measure {
            Localization.availableLanguages { (languages) in
                Localization.setLanguage(languages[0], {
                    Localization.setLanguage(languages[1], {
                        self.stopMeasuring()
                    })
                })
            }
        }
    }
}
