//: Playground - noun: a place where people can play

import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import LocalizationKit

Localization.start(appKey: "407f3581-648e-4099-b761-e94136a6628d")
var langauge = Localization.get("Hello.Label", alternate: "Welcome")
