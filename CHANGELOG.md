# LocalizationKit
Here is a complete log of what has been changed in each version. Currently this library it iterating quickly to add features and functionality.
### 3.0.12 - remove warnings from build caused by characters.count
### 3.0.11 - added Carthage Support and restructured project
### 3.0.6 - fixes for inline editor for keyboard events
### 3.0.5 - added multiline inline editor
### 3.0.4 - fix warnings
### 3.0.2 - update to add the searchbar component
### 3.0.1 - update to socketio 2.0 for Swift 3
### 3.0.0 - update to socketio 2.0 for Swift 3
### 2.0.9 - update to change to main language object
### 2.0.6 - fix issue with UINavigationController initial set
### 2.0.4 - update to add get 639 language code get property
### 2.0.3 - update move to support IEFT language code sets
### 2.0.2 - update to persist selected langauge
when a user changes the language it saves the value
### 2.0.1 - addition of inline edit
update to add the ability to inline edit the localizations
### 1.1.8 - update to support date formatter
### 1.1.6 - update default language to build language and removed warnings
### 1.1.5 - update to add default language and show debug strings in UI
### 1.1.4 - update to add Localization.parse
### 1.1.3 - update to support function call on language load complete
### 1.1.2 - update of socket io library
### 1.1.1 - Support for MacOSX

### 1.1.0 - Get available languages
Now you can return the available languages that you have setup on the server.

### 1.0.12 - Added UIButton and UITextField support
#### UIButton support
By setting a Key on a UIButton it will now create a .Normal key in the web portal
#### UITextField support
By setting a localization key for a UITextField it will create a localization key in the web portal with .Placeholder so you can change it remotely
#### Other Updates
- Added print of portal URL when starting
- ATS fixes

### 1.0.11 - Added UIBarItem and UIBarButtonItem
Added more components for default support out of the box.

### 1.0.9 - Added CHANGELOG.md
Provided document for listing what has changed

### 1.0.8 - Added SPM support

### 1.0.7 - Added documentation
For a first pass of documentation of features and functions within the library

### 1.0.6 - Added String.localize function
Added ability to localize a string from anywhere using 
```ruby
let localizedGreeting = "Hello".localize
```
### 1.0.5 - Updated to TLS/SSL support
