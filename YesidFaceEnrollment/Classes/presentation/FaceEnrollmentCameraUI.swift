//
//  FaceEnrollmentCameraUI.swift
//  YesidFaceEnrollment
//
//  Created by Emmanuel Mtera on 4/12/23.
//

import SwiftUI
import Combine

// MARK: The FaceEnrollmentAppDelegate
class FaceEnrollmentAppDelegate: UIResponder, UIApplicationDelegate {
    let viewModel: FaceEnrollmentViewModel = FaceEnrollmentViewModel()
    private var cancellables = [AnyCancellable]()
    let captureSession = FaceEnrollmentCaptureSession()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        captureSession.$sampleBuffer
            .subscribe(viewModel.subject).store(in: &cancellables)
        return true
    }
}

// MARK: FaceEnrollment MainApp
public struct FaceEnrollmentCameraUI: View {
    var configurationBuilder: FaceEnrollmentConfigurationBuilder
    var onResults: (FaceEnrollmentResults) -> Void
    @UIApplicationDelegateAdaptor(FaceEnrollmentAppDelegate.self) private var FaceEnrollmentDelegate
    public init(configurationBuilder:FaceEnrollmentConfigurationBuilder, onResults:@escaping (FaceEnrollmentResults) -> Void){
        self.configurationBuilder = configurationBuilder
        self.onResults = onResults
    }
    public var body: some View {
        return FaceEnrollmentMainCameraUI(configurationBuilder: configurationBuilder, onResults: onResults, FaceEnrollmentDelegate:FaceEnrollmentDelegate)
    }
}

// MARK: The Public FaceEnrollmentMainCameraUI
// Takes in FaceEnrollmentConfigurationBuilder and onResults callback which return FaceEnrollmentResponse
private struct FaceEnrollmentMainCameraUI: View {
    var configurationBuilder: FaceEnrollmentConfigurationBuilder
    var onResults: (FaceEnrollmentResults) -> Void
    @State private var FaceEnrollmentDelegate: FaceEnrollmentAppDelegate = FaceEnrollmentAppDelegate()
    init(configurationBuilder:FaceEnrollmentConfigurationBuilder, onResults:@escaping (FaceEnrollmentResults) -> Void, FaceEnrollmentDelegate: FaceEnrollmentAppDelegate){
        self.configurationBuilder = configurationBuilder
        self.onResults = onResults
        self.FaceEnrollmentDelegate = FaceEnrollmentDelegate
    }
    var body: some View {
        return _FaceEnrollmentCameraUI(
        configurationBuilder: configurationBuilder, onResults: onResults)
        .environmentObject(FaceEnrollmentDelegate.viewModel)
        .environmentObject(FaceEnrollmentDelegate.captureSession)
    }
}

// MARK: The Private _FaceEnrollmentCameraUI
private struct _FaceEnrollmentCameraUI: View {
    var configurationBuilder: FaceEnrollmentConfigurationBuilder = FaceEnrollmentConfigurationBuilder()
    var onResults: (FaceEnrollmentResults) -> Void = {_ in }
    @EnvironmentObject private var viewModel:FaceEnrollmentViewModel
    @EnvironmentObject private var captureSession: FaceEnrollmentCaptureSession
    
    public init(configurationBuilder:FaceEnrollmentConfigurationBuilder, onResults:@escaping (FaceEnrollmentResults) -> Void){
        self.configurationBuilder = configurationBuilder
        self.onResults = onResults
    }
    
    public var body: some View {
        return ZStack(alignment:.bottom){
            IOSCameraView()
            SimpleProgressView()
            InstructionText()
        }
    }
    
    @ViewBuilder
    private func IOSCameraView() -> some View {
        if #available(iOS 14.0, *) {
            ZStack{
                CameraView(captureSession: self.captureSession.captureSession)
                cameraOverlay()
            }.onDisappear(){
                self.captureSession.stop()
            }
            .onAppear(){
                self.captureSession.start()
            }.onChange(of: self.captureSession.sampleBuffer, perform: { _ in
                //self.viewModel.performFaceEnrollment()
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    @ViewBuilder
    private func cameraOverlay() -> some View {
        FaceEnrollmentOverlay(faceModel: self.viewModel)
    }

    
    @ViewBuilder
    private func SimpleProgressView() -> some View {
        if #available(iOS 14.0, *) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        } else {
            ActivityIndicator(style: .medium)
        }
    }

    
    @ViewBuilder
    private func InstructionText() -> some View {
        Text(self.viewModel.direction)
            .foregroundColor(Color.white)
            .padding()
    }
}

// MARK: The ProgressView to support older ios verions
private struct ActivityIndicator: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        UIViewType(style: style)
    }

    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        uiView.style = style
        uiView.hidesWhenStopped = true
        uiView.startAnimating()
    }
}

// MARK: USAGE
/*
 FaceEnrollmentCameraUI(
     configurationBuilder: FaceEnrollmentConfigurationBuilder()
         .setUserLicense(userLicense: "1234"),
     onResults: {FaceEnrollmentResults in print(FaceEnrollmentResults)}
 )
 */
