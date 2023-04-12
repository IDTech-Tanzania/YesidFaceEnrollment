//
//  Markers.swift
//  YesidFaceEnrollment
//
//  Created by Emmanuel Mtera on 4/12/23.
//

import SwiftUI

struct Marker: View {
    @State var trim: Double
    @State var angle: Double
    @Binding var direction: String
    @ObservedObject var faceModel: FaceEnrollmentViewModel

    var body: some View {
        Circle()
            .trim(from: 0.0, to: trim)
            .stroke(style: StrokeStyle(lineWidth: 15.0, lineCap: .butt,dash: [2, 15]))
            .foregroundColor(enrolledColor)
            .rotationEffect(Angle(degrees: angle))
            .animation(.easeInOut(duration: 0.3))

    }

    var enrolledColor: Color {
        if faceModel.enrolledFaces.keys.contains(direction) {
            return .blue
        } else {
            return .white
        }
    }
}


struct Markers: View {
    @ObservedObject var faceModel: FaceEnrollmentViewModel
    @State var directions = ["up", "top-right", "right", "bottom-right", "down", "bottom-left", "left", "top-left"]
    
    var trimAngles: [(trim: Double, angle: Double)] = [
        (trim: 0.18, angle: 240),
        (trim: 0.10, angle: 305),
        (trim: 0.12, angle: 341),
        (trim: 0.10, angle: 24),
        (trim: 0.18, angle: 60),
        (trim: 0.10, angle: 124),
        (trim: 0.12, angle: 160),
        (trim: 0.10, angle: 204),
    ]
    
    var body: some View {
        ZStack {
            ForEach(Array(zip(directions, trimAngles)), id: \.0) { (direction, trimAngle) in
                Marker(trim: trimAngle.trim, angle: trimAngle.angle, direction: $directions[self.indexOf(direction)], faceModel: faceModel)
            }
        }
        .frame(width:270,height: 270)
    }
    
    func indexOf(_ direction: String) -> Int {
        return directions.firstIndex(of: direction)!
    }
}
