//
//  CreditCardModel.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//

import Foundation

// Saved Credit Card
struct SavedCreditCard: Identifiable, Codable {
    let id: String
    let cardHolderName: String
    let last4Digits: String
    let expiryMonth: String
    let expiryYear: String
    let cardType: CardType
    let isDefault: Bool            // if its a Primary card
    let nickname: String?          // Optional nickname like "Personal Card"
    
    var maskedNumber: String {
        "**** **** **** \(last4Digits)"
    }
    
    var expiryDate: String {
        "\(expiryMonth)/\(expiryYear)"
    }
    
    var displayName: String {
        if let nickname = nickname, !nickname.isEmpty {
            return nickname
        }
        return "\(cardType.rawValue) •••• \(last4Digits)"
    }
    
    init(id: String = UUID().uuidString, cardHolderName: String, last4Digits: String, expiryMonth: String, expiryYear: String, cardType: CardType, isDefault: Bool = false, nickname: String? = nil) {
        self.id = id
        self.cardHolderName = cardHolderName
        self.last4Digits = last4Digits
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cardType = cardType
        self.isDefault = isDefault
        self.nickname = nickname
    }
}

// MARK: - Updated User Model
struct UpdatedUser: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let phone: String?
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
        return phone != nil && !phone!.isEmpty
    }
    
    var displayPhone: String {
        return phone ?? "Not provided"
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
