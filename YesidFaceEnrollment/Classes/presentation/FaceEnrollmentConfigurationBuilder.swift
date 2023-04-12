//
//  FaceEnrollmentConfigurationBuilder.swift
//  YesidFaceEnrollment
//
//  Created by Emmanuel Mtera on 4/12/23.
//

import Foundation


public class FaceEnrollmentConfigurationBuilder {
    public init(){}
    private var userLicense = ""
    public func setUserLicense(userLicense: String) -> FaceEnrollmentConfigurationBuilder {
        self.userLicense = userLicense
        return self
    }
    
    func getUserLicense() -> String {
        return userLicense
    }
    
}
