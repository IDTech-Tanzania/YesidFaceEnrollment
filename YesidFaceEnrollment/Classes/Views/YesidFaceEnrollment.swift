import SwiftUI
import Vision

public struct YesidFaceEnrollment: View {
    @EnvironmentObject var faceEnrollModel:FaceEnrollmentViewModel
    @EnvironmentObject var captureSession:FaceEnrollmentCaptureSession
    
    public init(){
        
    }
    
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public var body: some View {
        VStack(alignment:.leading,spacing: 10) {
            FullCameraView()
        }
        .clipped()
    }
    @ViewBuilder
    func MainCameraView() -> some View {
        CameraView(captureSession: self.captureSession.captureSession)
    }
    
    @ViewBuilder
    func FullCameraView() -> some View {
        ZStack(){
            MainCameraView()
            FaceEnrollmentUI(faceModel: faceEnrollModel)
        }
        .frame(maxWidth:self.screenWidth,maxHeight: self.screenHeight)
    }
    
}



