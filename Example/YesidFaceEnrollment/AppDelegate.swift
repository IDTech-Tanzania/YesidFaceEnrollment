import SwiftUI
import Combine
import YesidFaceEnrollment


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let faceEnrollModel = FaceEnrollmentViewModel()
    let faceEnrollCaptureSession = FaceEnrollmentCaptureSession()
   
    var cancellables = [AnyCancellable]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        faceEnrollCaptureSession.$sampleBuffer
            .subscribe(faceEnrollModel.subject).store(in: &cancellables)
        return true
    }
}

@main
struct YesIDApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            MainApp(appDelegate:appDelegate)
        }
    }
}
