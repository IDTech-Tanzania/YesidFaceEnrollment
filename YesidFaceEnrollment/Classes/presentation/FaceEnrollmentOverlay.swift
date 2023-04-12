//
//  FaceEnrollmentOverlay.swift
//  YesidFaceEnrollment
//
//  Created by Emmanuel Mtera on 4/12/23.
//

import SwiftUI



struct FaceEnrollmentOverlay: View {
    @ObservedObject var faceModel: FaceEnrollmentViewModel
    var body: some View {
        return ZStack {
            GeometryReader { geometry in
                Color.black.opacity(0.9)
                    .mask(
                        FaceEnrollmentMaskShape(
                            inset: UIEdgeInsets(top: geometry.size.height,
                                                left: geometry.size.width,
                                                bottom: geometry.size.height,
                                                right: geometry.size.width)
                        ).fill(style: FillStyle(eoFill: true)).aspectRatio(1, contentMode: .fill)
                    )
            }
            Markers(
            faceModel: faceModel)
        }
    }
}

