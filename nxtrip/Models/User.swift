//
//  User.swift
//  iza-app
//
//  Created by Lukáš Mader on 24/05/2025.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let fullname: String
    let email: String
    let phone: String
    let savedCards: [SavedCreditCard]
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
    
    var hasPhone: Bool {
        return !phone.isEmpty
    }
    
    var userId: String {
        return id ?? ""
    }
        
    var displayPhone: String {
        return phone.isEmpty ? "Not provided" : phone
    }
    
    var defaultCard: SavedCreditCard? {
        return savedCards.first { $0.isDefault } ?? savedCards.first
    }
        
    var hasCards: Bool {
        return !savedCards.isEmpty
    }
        
    var canAddMoreCards: Bool {
        return savedCards.count < 3
    }
}
