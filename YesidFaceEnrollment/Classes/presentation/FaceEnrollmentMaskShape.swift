//
//  FaceEnrollShape.swift
//  yesid
//
//  Created by Aim Group on 28/09/2022.
//

import SwiftUI
import Foundation

struct FaceEnrollmentMaskShape : Shape {
    var inset : UIEdgeInsets
    func path(in rect: CGRect) -> Path {
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: CGRect(x: rect.midX - 125, y: rect.midY - 125, width: 250, height: 250)))
        return shape
    }
}

