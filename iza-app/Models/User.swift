//
//  User.swift
//  iza-app
//
//  Created by Lukáš Mader on 24/05/2025.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let phone: String?
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
    
    var hasPhone: Bool {
        return phone != nil && !phone!.isEmpty
    }
        
    var displayPhone: String {
        return phone ?? "Not provided"
    }
}
