//
//  MainApp.swift
//  YesidFaceEnrollment_Example
//
//  Created by Emmanuel Mtera on 3/8/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import UIKit
import YesidFaceEnrollment

struct MainApp: View {
    @State var appDelegate: AppDelegate = AppDelegate()
    var body: some View {
        FaceEnrollmentScreen()
            .environmentObject(appDelegate.faceEnrollModel)
            .environmentObject(appDelegate.faceEnrollCaptureSession)
    }
}

struct FaceEnrollmentScreen: View {
    @EnvironmentObject var faceEnrollModel: FaceEnrollmentViewModel
    @EnvironmentObject var faceEnrollCaptureSession: FaceEnrollmentCaptureSession
    var body: some View {
        VStack {
            ZStack {
                ScrollView{
                    VStack(alignment: .leading, spacing: 1) {
                        EnrollmentCameraView()
                        ImageResultView()
                    }
                    .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity,alignment: .topLeading)
                    .padding(.horizontal, 10.0)
                }
            }
        }
        .clipped()
        
    }
    
    
    @ViewBuilder
    func EnrollmentCameraView()-> some View{
        if(self.faceEnrollModel.enrollmentProgress != 100){
            HStack{
                ZStack {
                    YesidFaceEnrollment()
                        .cornerRadius(6)
                        .onDisappear(){
                            self.faceEnrollCaptureSession.stop()
                        }
                        .onAppear(){
                            self.faceEnrollCaptureSession.start()
                        }
                }
            }
            .cornerRadius(6)
            .padding(.vertical,10)
            .frame(maxWidth:.infinity)
            .frame(height:UIScreen.screenHeight)
            HStack(alignment: .center, spacing: 1) {
                Circle()
                    .frame(width:24,height: 24)
                    .foregroundColor(Color.white)
                    .padding(6)
                    .overlay(
                        Text("\(self.faceEnrollModel.enrollmentProgress)%")
                            .font(Font.custom("Inter-Bold", size: 8))
                            .frame(width: 24, height: 24, alignment: .center)
                    )
                    .shadow(radius: 5)
                if(self.faceEnrollModel.direction != ""){
                    Text("Look \(self.faceEnrollModel.direction)")
                        .font(Font.custom("Inter-SemiBold", size: 14))
                        .foregroundColor(.black)
                }else{
                    Text("Scanning")
                        .font(Font.custom("Inter-SemiBold", size: 14))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth:.infinity)
            .offset(y:0)
            
        }
    }
    
    @ViewBuilder
    func ImageResultView() -> some View {
        if(self.faceEnrollModel.enrollmentProgress == 100){
            VStack {
                ZStack{
                    Image(uiImage: self.faceEnrollModel.enrolledFaces["straight"]!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height:UIScreen.screenHeight/2)
                        .clipShape(Rectangle())
                        .cornerRadius(6)
                        .onAppear(){
                            DispatchQueue.main.async {
                                self.faceEnrollCaptureSession.stop()
                            }
                            
                        }
                    RecaptureButton(
                        action: {
                            self.faceEnrollModel.clearData()
                            self.faceEnrollCaptureSession.start()
                        })
                    .frame(maxWidth: .infinity, maxHeight: 459.0, alignment: .bottom)
                    .offset(x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 25.0)
                }
                .padding(.vertical,20)
                EnrollmentCompletedScanView()
                    .padding(.vertical,10)
            }
        }
    }
    
    
    @ViewBuilder
    func EnrollmentCompletedScanView()-> some View{
        if(self.faceEnrollModel.enrollmentProgress==100){
            CompleteFaceScanView()
                .environmentObject(faceEnrollModel)
        }
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}


struct RecaptureButton: View {
    @State var action:()->Void = {}
    var body: some View {
        Button(
            action:{
                action()
            }){
                HStack(){
                    Text("Recapture")
                }
            }
            .padding(.all, 16.0)
            .frame(height: 50.0)
            .cornerRadius(24)
            .shadow(radius: 5)
    }
}


struct CompleteFaceScanView: View {
    @EnvironmentObject var faceEnrollModel:FaceEnrollmentViewModel
    @State var hideTitle:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            ScrollView(.horizontal){
                HStack(alignment: .center, spacing: 10) {
                    ForEach(faceEnrollModel.enrolledFaces.keys.sorted(), id: \.self) { key in
                        ScannedFaceContainerView(
                        image: faceEnrollModel.enrolledFaces[key]!)
                    }
                }
                .frame(maxWidth:.infinity, maxHeight: 110.8)
            }
        }
    }
}

struct ScannedFaceContainerView: View {
    @State var image:UIImage = UIImage()
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 110.8, height: 110.8, alignment: .center)
            .cornerRadius(6)
    }
}
