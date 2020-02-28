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
// Create user object (optional)
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
There are two types of tracking *ScreenView* and *SectionScreenView*. One should be used in favor of another depending on the media.   


#### Screen View
If a media (website) has one topic it can be tracked by using `UserReport.trackScreenView`.

#### Section Screen View
If a website has different sections, for instance, media has *Health*, *World news*, *Local news* and it should be tracked differenlty `UserReport.trackSectionScreenView(sectionId)` method should be used instead.  

#### Manual invocation
If `UserReport.trackSectionScreenView` or `UserReport.trackScreenView()` methods invoked by your code, automatic tracking should not be used. 

#### Example
```swift
class ViewController: UIViewController {
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Tracking screen view
        UserReport.trackScreenView()
    }
}
```

#### Automatic tracking
If you want to automatically measure screen views. Application's ViewControllers should be inherited from the `UserReportViewController` class.

```swift
class ViewController: UserReportViewController {
    ...
}
```

### Display mode
The survey can appear in two ways:

- `.alert` - show survey like an alert view (Default)
- `.fullScreen` - show survey in full-screen mode, like the modal view controller

To change the display mode, please specify following:

```swift
UserReport.setDisplayMode(.fullscreen)
```

### Change settings
To update the default rules for appear the survey use follow:
Though, it is recommended to pass `Settings` to configure method instead, use this method only when you want to change rules for already launched app
```swift
let settings = Settings()
settings.sessionScreensView = 5
settings.inviteAfterNSecondsInApp = 20

UserReport.updateSettings(settings)
```

### Mute
For the survey not to appear on important screens, you can use a variable `mute`.

```swift
UserReport.mute = true
```
> Do not forget to restore value back to `false`.


### Update user info
When changing user data, you should also send the updated data to the UserReport iOS SDK.

```swift
let user = User()
user.email = "new_example@email.com"

UserReport.updateUser(user)
```

### Session info
UserReport SDK stores the data on the count of screens viewed and the time the application is used. If necessary, you can get this data from a variable `session`. The session contains the following values:

- `screenView` - number of screens viewed in the current session
- `totalScreenView` - number of screens viewed in all session
- `sessionSeconds` - number of seconds spent in the application for current session
- `totalSecondsInApp` - number of seconds spent in the application for all time
- `localQuarantineDate` - date until the survey will not appear again
- `settings` - current settings for the survey appearance


```swift
// Session information about the running time of the application and screen views
let session = UserReport.session

// Get current settings for appear survey
let currentSetting = session?.settings
```

### Manually
If you decide to show the survey yourself, then you can use the following method:

```swift
UserReport.tryInvite()
```

### IDFA
SDK relies on IDFA. So make sure marking appropriate checkboxes when publishing your app.  

## License

UserReport iOS SDK is released under the Apache License 2.0. [See LICENSE](https://github.com/AudienceProject/userreport-ios-sdk/blob/master/LICENSE) for details.
