# yes:ID IOS Face Enrollment SDK

# Installation
You can install the YesidFaceEnrollment library using CocoaPods. Add the following line to your project's Podfile:

`pod 'YesidFaceEnrollment'`

Then run `pod install` command to install the library.

# Import the YesidFaceEnrollment module:

In your project's Swift file where you want to use the YesidFaceEnrollment library, add the following import statement:

```
import YesidFaceEnrollment
```

# Instantiate and present the FaceEnrollmentCameraUI view:

`Configure the SDK by passing the license or anyother configuration`

```
let configuration: FaceEnrollmentConfigurationBuilder = FaceEnrollmentConfigurationBuilder().setUserLicense(userLicense: "YOUR_LICENSE")

```
` Use the SDK by calling FaceEnrollmentCameraUI`
```
@main
struct iOSApp: App {
    var body: some Scene {
        WindowGroup {
                FaceEnrollmentCameraUI(configurationBuilder: configuration) { response in
                    print(response)
                }
        }
    }
}
```

# Handle FaceEnrollment responses:

When the FaceEnrollment process completes, the FaceEnrollmentCameraUI view will call the callback function you provided with the FaceEnrollment results. You can handle the results accordingly in your app.

