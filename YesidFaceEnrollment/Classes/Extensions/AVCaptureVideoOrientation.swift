//
//  AVCaptureVideoOrientation.swift
//  object-detection
//
//  Created by Aim Group on 19/09/2022.
//
import AVFoundation
import Foundation
import UIKit

extension AVCaptureVideoOrientation {
    
    static func from(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch (deviceOrientation) {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
}
