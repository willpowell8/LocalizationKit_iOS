![alt text](https://raw.githubusercontent.com/willpowell8/LocalizationKit_iOS/master/page/LocalizationLogo.png "iOS Localization Logo")
# LocalizationKit
[![Version](https://img.shields.io/cocoapods/v/LocalizationKit.svg?style=flat)](http://cocoapods.org/pods/LocalizationKit)
[![License](https://img.shields.io/cocoapods/l/LocalizationKit.svg?style=flat)](http://cocoapods.org/pods/LocalizationKit)
[![Platform](https://img.shields.io/cocoapods/p/LocalizationKit.svg?style=flat)](http://cocoapods.org/pods/LocalizationKit)

Localization kit is a powerful to localize texts and translation management tool. I am a developer and invariably I get the questions 'Can you just change this text?' or 'Can you add another language?' I have designed this framework so you can manage these translations and texts without having to recompile, resubmit and without the need to use developers. Essentially take out all of the pain.
![alt text](https://raw.githubusercontent.com/willpowell8/LocalizationKit_iOS/master/page/Localization.gif "Realtime iOS Localize your app")

## How does it work
Localization Kit quickly and easily integrates into your app using Cocoapods. Then it connects to services from [LocalizationKit.com](http://www.localizationkit.com/app/) which are free to use and manage. Then as you create items in your iOS app the text keys become available instantly in the online web UI. From there you can change the text and it is reflected within app in realtime (as you type any key).

## Installation

LocalizationKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:
```ruby
pod "LocalizationKit"
```

Then go to https://www.localizationkit.com/app/ and create a new app on the left handside using your name. Then take the code generated currently in the url after #/app/...KEY HERE...

Then put the following into your app delegate:

At the top:
```swift
import LocalizationKit
```
and in the didFinishLaunchingWithOptions the following with your key:
```swift
Localization.start(appKey: "[[KEY]]")
```

### Enabling Live Update
One of the most powerful features of LocalizationKit is the capability to edit the text in realtime on the device. You can start the live service in the following ways:
#### At Initialization
```swift
Localization.start(appKey: "bed920eb-9802-4a2c-a8c0-69194729d69d", live: true)
```

#### From within Settings Bundle
Make sure you create a settings bundle with boolean object named live_localization
```swift
Localization.start(appKey: "bed920eb-9802-4a2c-a8c0-69194729d69d", useSettings: true)
```
#### Toggle it within app
```swift
Localization.liveEnabled = true
```

### Enabling Inline Edits
As part of the application you can enable the inline editing of the localizations using long press on fields.
![alt text](https://raw.githubusercontent.com/willpowell8/LocalizationKit_iOS/master/page/LocalizationKit-Inline.png "Inline Localization Editor")
Elements supporting Inline Edit: UILabel, UIButton
#### Toggle it within app
```swift
Localization.allowInlineEdit = true
```

## Using Interface Builder
Localization kit has support for Xcode UI development. The process is as simple as:
- install the cocoapod
- open storyboard or xib file
- select component eg UILabel or drag on standard component UILabel
- open attribute selector
- set a Localize Key
- run app and the key will be available online

![alt text](https://raw.githubusercontent.com/willpowell8/LocalizationKit_iOS/master/page/iOS_Localization_IBInspector_Xcode_1_1.png "Quick and Easy localization using interface builder")

### Supported Components
- UILabel
- UINavigatioNitem
- String
- UIBarItem
- UIBarButtonItem
- UITextField
- UIButton
- DateFormatter

## Using from Code
There are several ways of using the localization system from code without using storyboard or interface builder. The first is from any string you can call the .localize to call the localized string for it. This does not give you the live updates of the text but provides you with the text at the moment you call it.
```swift
let localizedGreeting = "Hello".localize
```
This will create a localization key of String.*Your String* (which has dots replacing the spaces). For example 'Select Languages' would become String.Select.Languages. These texts will similarly be made available for you to localize within the web UI.
```swift
let resultText = Localization.get("Localization.Key", alternate: "default label text")
```
## Localization Keys
Localization Keys are the unique identifiers that allow you to assign localization to the correct part within your app. You can use any string as a device identifier, however the application has some features to make live easier if you use dot separation methodology: ie. Product.Details.Label

## Caching
LocalizationKit internalizes the caching of the localizations and translations that you have translated. Currently once a languages is loaded from the server it is stored locally for offline and subsequent use. It is updated everytime the app is reopened where by the local version is first loaded and then replaced by the server version.

TO DO - add a build phase script that can pull first version of the 

## Other Functions

#### Set language
```swift
Localization.setLanguage("de")
```

#### Get Available Languages
```swift
Localization.availableLanguages { (languages) in
// Languages is an array of [Language] which has properties localizedName and key
}
```

#### Reset to device language
```swift
Localization.resetToDeviceLanguage()
```

#### Show debug Strings
```swift
Localization.ifEmptyShowKey = true
```

#### Set Default Language
The default language is the language that you have built the application in and will be used for passing to the backend for showing strings and data.
```swift
Localization.defaultLanguageCode = "en"
```


## Events
If you enable the live update process then you will be able to listen to localization events. These events are:

- **LocalizationEvent**  - this is when a text is updated. 
```swift
Localization.localizationEvent(localizationKey: String)
```
- **Highlight Event** - this is when a user has clicked the highlight button in the web UI.
```swift
Localization.highlightEvent(localizationKey: String)
```

#### Example Listening To An Event

```swift
NotificationCenter.default.addObserver(self, selector: #selector(localizationHighlight), name: Localization.highlightEvent(localizationKey: LocalizeKey!), object: nil)
```

#### Example Date Formatter
Date format as it is a single call it does adhere to the live updates. Note the dateFormat String must be set before the Localization Key
```swift
let d = DateFormatter()
d.dateFormat = "dd MMM yyyy"
d.LocalizeKey = "General.DateFormatter"
let dStr = d.string(from: Date())
print(dStr)
```


## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Will Powell - [LinkedIn](https://www.linkedin.com/in/willpowelluk) | [Blog](http://www.willpowell.co.uk)

## License

LocalizationKit is available under the MIT license. See the LICENSE file for more info.
