import SwiftUI
import Foundation
import Vision
import UIKit
import Combine
import AVFoundation

public class FaceEnrollmentViewModel: NSObject, ObservableObject {
    
    private var apiEndpoint = "https://faceapi.regulaforensics.com/api/match"
    
    @Published public var faceMatchResults = Result()
    
    @Published public var isLoading = false
    
    @Published var isloading = false
    
    @Published public var isResultSet:Bool = false
    
    @Published public var direction:String = ""
    
    @Published public var startFaceEnrollment:Bool = true
    
    @Published public var enrollmentProgress:Int = 0
    
    @Published var faceCaptureQuality: Float = 0.0
    @Published var capturePhoto:Bool = false
    
    @Published var boundingBox = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    
    @Published var landmarks: VNFaceLandmarks2D?

    @Published var directions = ["left","top-left","bottom-left","right","top-right","bottom-right","up","down","straight"]
    @Published public var enrolledFaces = [String: UIImage]()
    
    @Published var yaw: Float = 0
    @Published var roll: Float = 0
    @Published var pitch: Float = 0
    
    private var sampleBuffer: CMSampleBuffer?
    
    public let subject = PassthroughSubject<CMSampleBuffer?, Never>()
    var cancellables = [AnyCancellable]()
    
    public override init() {
        super.init()
        subject.sink { sampleBuffer in
            self.sampleBuffer = sampleBuffer
            do {
                guard let sampleBuffer = sampleBuffer else {
                    return
                }
                try self.detect(sampleBuffer: sampleBuffer)
            } catch {
                print("Error has been thrown")
            }
            
        }.store(in: &cancellables)
    }
    
    
    func detect(sampleBuffer: CMSampleBuffer) throws {
        let handler = VNSequenceRequestHandler()
        
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest { (req, err) in
            self.handleRequests(request: req, error: nil)
        }
        faceLandmarksRequest.revision = VNDetectFaceLandmarksRequestRevision3
        
        let faceCaptureQualityRequest = VNDetectFaceCaptureQualityRequest{ (req, err) in
            self.handleRequests(request: req, error: nil)
        }
        let faceRectanglesRequest = VNDetectFaceRectanglesRequest{ (req, err) in
            self.handleRequests(request: req, error: nil)
        }
        DispatchQueue.global().async {
            do {
                if #available(iOS 14.0, *) {
                    try handler.perform([faceLandmarksRequest, faceCaptureQualityRequest, faceRectanglesRequest], on: sampleBuffer, orientation: .left)
                } else {

                }
            } catch {
                // don't do anything
            }
        }
        
    }
    
    func handleRequests(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if(self.startFaceEnrollment){
            guard
                let imageBuffer = self.sampleBuffer,
                let results = request.results as? [VNFaceObservation],
                let result = results.first else { return }
            
            self.boundingBox = result.boundingBox
            
                if #available(iOS 15.0, *) {
                    if let yaw = result.yaw,
                       let pitch = result.pitch,
                       let roll = result.roll {
                        self.yaw = yaw.floatValue
                        self.pitch = pitch.floatValue
                        self.roll = roll.floatValue
                    }
                } else {
                    // Fallback on earlier versions
                }
            
            if let landmarks = result.landmarks {
                self.landmarks = landmarks
            }
            
            if let captureQuality = result.faceCaptureQuality {
                self.faceCaptureQuality = captureQuality
            }
            let roundedYaw = round(self.yaw * 100) / 100
            let roundedPitch = round(self.pitch * 100) / 100
            let roundedRoll = round(self.roll * 100) / 100
                
//                print("Yaw: \(roundedYaw), Pitch: \(roundedPitch), Roll: \(roundedRoll)")
            
                if(self.enrollmentProgress==0){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if(self.checkFaceBoundsCenter(boundingBox: self.boundingBox)){
                            self.updateEnrollmentProgress(currentProgress: 10)
                        }
                    }
                }
                if(self.enrollmentProgress >= 10 && self.enrollmentProgress != 100){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.checkFaceDirection(yaw: roundedYaw, pitch: roundedPitch, roll: roundedRoll,result,from:imageBuffer)
                    }
                }
            }
        }
    }
    
    public func clearData(){
        DispatchQueue.main.async {
            self.enrollmentProgress = 0
            self.sampleBuffer = nil
            self.enrolledFaces = [String: UIImage]()
            self.isResultSet = false
            self.direction = ""
        }
    }
    
    
    private func sendFaceDirection(direction:String){
        self.direction = direction
    }
    
    private func updateEnrollmentProgress(currentProgress:Int){
        self.enrollmentProgress = currentProgress
    }
    
    private func checkFaceDirection(yaw:Float,pitch:Float,roll:Float,_ observation: VNFaceObservation, from buffer: CMSampleBuffer){
        /*
         This portion of logic checks to see if the face is looking left
         */
        if(checkFaceLeft(yaw: yaw, pitch: pitch, roll: roll)){
            if(!self.enrolledFaces.keys.contains(self.directions[0])){
                self.capturePhoto = true
                self.performFaceEnrollment(observation, from: buffer, direction: self.directions[0])
            }
        }
        /*
         This portion of logic checks to see if the face is looking top-left
         */
        if(checkFaceTopLeft(yaw: yaw, pitch: pitch, roll: roll)){
            if(!self.enrolledFaces.keys.contains(self.directions[1])){
                self.capturePhoto = true
                self.performFaceEnrollment(observation, from: buffer, direction: self.directions[1])
            }
        }
        /*
         This portion of logic checks to see if the face is looking bottom-left
         */
        if(checkFaceBottomLeft(yaw: yaw, pitch: pitch, roll: roll)){
            if(!self.enrolledFaces.keys.contains(self.directions[2])){
                self.capturePhoto = true
                self.performFaceEnrollment(observation, from: buffer, direction: self.directions[2])
            }
        }
        /*
         This portion of logic checks to see if the face is looking right
         */
        if(checkFaceRight(yaw: yaw, pitch: pitch, roll: roll)){
            if(!self.enrolledFaces.keys.contains(self.directions[3])){
                self.capturePhoto = true
                self.performFaceEnrollment(observation, from: buffer, direction: self.directions[3])
            }
        }
        /*
         This portion of logic checks to see if the face is looking top-right
         */
        if(checkFaceTopRight(yaw: yaw, pitch: pitch, roll: roll)){
            if(!self.enrolledFaces.keys.contains(self.directions[4])){
                self.capturePhoto = true
                self.performFaceEnrollment(observation, from: buffer, direction: self.directions[4])
            }
        }
        /*
         This portion of logic checks to see if the face is looking bottom-right
         */
        if(checkFaceBottomRight(yaw: yaw, pitch: pitch, roll: roll)){
            if(!self.enrolledFaces.keys.contains(self.directions[5])){
                self.capturePhoto = true
                self.performFaceEnrollment(observation, from: buffer, direction: self.directions[5])
            }
        }
        /*
         This portion of logic checks to see if the face is looking up
         */
        if(checkFaceUp(yaw: yaw, pitch: pitch, roll: roll)){
            if(!self.enrolledFaces.keys.contains(self.directions[6])){
                self.capturePhoto = true
                self.performFaceEnrollment(observation, from: buffer, direction: self.directions[6])
            }
        }
        /*
         This portion of logic checks to see if the face is looking down
         */
        if(checkFaceDown(yaw: yaw, pitch: pitch, roll: roll)){
            if(!self.enrolledFaces.keys.contains(self.directions[7])){
                self.capturePhoto = true
                self.performFaceEnrollment(observation, from: buffer, direction: self.directions[7])
            }
        }
        /*
         This portion of logic checks to see if the face is looking straight
         */
        if(checkFaceStraight(yaw: yaw, pitch: pitch, roll: roll)){
            if(!self.enrolledFaces.keys.contains(self.directions[8])){
                self.capturePhoto = true
                self.performFaceEnrollment(observation, from: buffer, direction: self.directions[8])
            }
        }

        // check to see if enrollment progress is 90 then display direction that is missing
        if(self.enrollmentProgress == 90){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.checkMissingDirection()
            }
        }
        
    }

    private func checkMissingDirection(){
        var missingDirection = [String]()
        for direction in self.directions{
            if(!self.enrolledFaces.keys.contains(direction)){
                missingDirection.append(direction)
            }
        }
        if let lastDirection = missingDirection.first {
            self.sendFaceDirection(direction: lastDirection)
        }
        
    }
    
    private func checkFaceLeft(yaw:Float,pitch:Float,roll:Float)->Bool{
        if(yaw>0.2&&(pitch < 0.15||pitch > -0.35)){
            return true
        }
        return false
    }
    private func checkFaceBottomLeft(yaw:Float,pitch:Float,roll:Float)->Bool{
        if(yaw>0.2&&pitch>0.15){
            return true
        }
        return false
    }
    
    private func checkFaceTopLeft(yaw:Float,pitch:Float,roll:Float)->Bool{
        if(yaw > 0.1&&pitch < -0.15){
            return true
        }
        return false
    }
    
    private func checkFaceRight(yaw:Float,pitch:Float,roll:Float)->Bool{
        if(yaw < -0.4&&(pitch < 0.15||pitch > -0.35)){
            return true
        }
        return false
    }
    
    private func checkFaceBottomRight(yaw:Float,pitch:Float,roll:Float)->Bool{
        if(yaw < -0.2&&pitch>0.15){
            return true
        }
        return false
    }
    
    private func checkFaceTopRight(yaw:Float,pitch:Float,roll:Float)->Bool{
        if(yaw < -0.1&&pitch < -0.15){
            return true
        }
        return false
    }
    private func checkFaceUp(yaw:Float,pitch:Float,roll:Float)->Bool{
        if(pitch < -0.20&&roll>2.5&&yaw > -0.2){
            return true
        }
        return false
    }
    
    private func checkFaceDown(yaw:Float,pitch:Float,roll:Float)->Bool{
        if(pitch>0.15&&yaw<0.2&&yaw > -0.2){
            return true
        }
        return false
    }
    
    private func checkFaceStraight(yaw:Float,pitch:Float,roll:Float)->Bool{
        if(pitch<0.15&&pitch > -0.20&&yaw<0.2&&yaw > -0.2){
            return true
        }
        return false
    }
    
    private func checkFaceBoundsCenter(boundingBox: CGRect)->Bool{
        // check if boundingBox is at the center of the screen
        let centerX = boundingBox.origin.x + boundingBox.size.width/2
        let centerY = boundingBox.origin.y + boundingBox.size.height/2
        if centerX > 0.4 && centerX < 0.6 && centerY > 0.4 && centerY < 0.6 {
            return true
        }
        return false
    }
    
    private func performFaceEnrollment(_ observation: VNFaceObservation, from buffer: CMSampleBuffer, direction:String) {
        let imageBuffer = CMSampleBufferGetImageBuffer(buffer)
        // create UIImage from imageBuffer
        let ciImage = CIImage(cvPixelBuffer: imageBuffer!)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let uiImage = UIImage(cgImage: cgImage!).fixedOrientation().imageRotatedByDegrees(degrees: 90)
        // add the image and direction to the dictionary
        self.enrolledFaces[direction] = uiImage
        self.capturePhoto=false
        self.updateEnrollmentProgress(currentProgress: self.enrollmentProgress+10)
    }
    
    private func convertImageToBase64String(img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.2)?.base64EncodedString() ?? ""
    }
    
    public func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }
    
}
