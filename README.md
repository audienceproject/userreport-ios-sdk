![architecture overview](docs/UserReport.svg)

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/UserReport.svg)](https://cocoapods.org/pods/UserReport)
[![Platform](https://img.shields.io/cocoapods/p/UserReport.svg?style=flat)](http://cocoadocs.org/docsets/UserReport)
![Xcode 9.0](https://img.shields.io/badge/Xcode-9.0-blue.svg)
![iOS 9.0+](https://img.shields.io/badge/iOS-9.0%2B-blue.svg)
![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)
[![License](https://img.shields.io/cocoapods/l/UserReport.svg)](https://raw.githubusercontent.com/AudienceProject/userreport-ios-sdk/master/LICENSE)



## Requirements
- Xcode 9.0+
- iOS 9.0+

## Installation
UserReport iOS SDK can be installed in various ways.

### CocoaPods
[CocoaPods](https://cocoapods.org/) is a centralized dependency manager for
Objective-C and Swift. Go [here](https://guides.cocoapods.org/using/index.html)
to learn more.

1. Add the project to your [Podfile](https://guides.cocoapods.org/using/the-podfile.html).

    ```ruby
    use_frameworks!

    pod 'UserReport'
    ```
2. Run `pod install` and open the `.xcworkspace` file to launch Xcode.
3. Import the UserReport framework.

    ```swift
    import UserReport
    ```

### Manually
To install it manually drag the UserReport project into your app project in Xcode or add it as a git submodule.
In your project folder enter:
```bash
$ git submodule add git@github.com:AudienceProject/userreport-ios-sdk.git
```

## Usage
### Configure
Configure UserReport iOS SDK via `SAK_ID`, `MEDIA_ID` (You can find these values on media setting page) and information about user.

```swift
// Create user object
let user = User()
user.email = "example@email.com"

// You can also specify a email hash
user.emailMd5 = "MD5_EMAIL_HASH"
user.emailSha1 = "SHA1_EMAIL_HASH"
user.emailSha256 = "SHA256_EMAIL_HASH"

// Provide additional social network information
user.facebookId = "FACEBOOK_ID"

//It is also possible to override default rules when survey will appear;
//though, userSettings parameter is optional
let settings = Settings()
settings.sessionScreensView = 5
settings.inviteAfterNSecondsInApp = 20

// Configure
UserReport.configure(sakId: "YOUR_SAK_ID", mediaId: "YOU_MEDIA_ID", user: user, userSetting: setting)

```
### Screen tracking
#### Manual
To manually measure the screen view, use the method `trackScreen()`.

```swift
class ViewController: UIViewController {
	override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Tracking screen view
        UserReport.shared?.trackScreen()
    }
}
```

#### Automatic
If you want to automatically measure views as screens using the `UserReportViewController` class.

```swift
class ViewController: UserReportViewController {
	...
}
```

### Display mode
The survey can be appear in two ways:

- `.alert` - show survey like an alert view (Default)
- `.fullScreen` - show survey in full screen mode, like the modal view controller

To change the display mode, please specify following:

```swift
UserReport.shared?.displayMode = .fullscreen
```

### Change settings
To update the default rules for appear the survey use follow:
Though, it is recommended to pass `Settings` to configure method instead, use this method only when you want to change rules for already launched app
```swift
let settings = Settings()
settings.sessionScreensView = 5
settings.inviteAfterNSecondsInApp = 20

UserReport.shared?.updateSettings(settings)
```

### Mute
In order for the survey not to be appear on important screens, you can use a variable `mute`.

```swift
UserReport.shared?.mute = true
```
> Don't forget to return back to `false`.


### Update user info
When changing user data, you should also send the updated data to the UserRecord iOS SDK.

```swift
let user = User()
user.email = "new_example@email.com"

UserReport.shared?.updateUser(user)
```

### Session info
UserReport SDK stores the data on the count of screens viewed and the time the application is used. If necessary, you can get this data from a variable `session`. The session contains the following values:

- `screenView` - number of screen viewed in current session
- `totalScreenView` - number of screen viewed in all session
- `sessionSeconds` - number of seconds spent in the application for current session
- `totalSecondsInApp` - number of seconds spent in the application for all time
- `localQuarantineDate` - date until the survey will not appear again
- `settings` - current settings for appear the survey


```swift
// Session information about the running time of the application and screen views
let session = UserReport.shared?.session

// Get current settings for appear survey
let currentSetting = session?.settings
```

### Manually
If you decide to show the survey yourself, then you can use the following method:

```swift
UserReport.shared?.tryInvite()
```
## License

UserReport iOS SDK is released under the Apache License 2.0. [See LICENSE](https://github.com/AudienceProject/userreport-ios-sdk/blob/master/LICENSE) for details.
