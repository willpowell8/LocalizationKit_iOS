# LocalizationKit
Here is a complete log of what has been changed in each version. Currently this library it iterating quickly to add features and functionality.
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
