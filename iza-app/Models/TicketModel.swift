//
//  BookingModels.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

import Foundation

// MARK: - Passenger Info
struct PassengerInfo: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let dateOfBirth: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - Payment Info
struct PaymentInfo: Codable {
    let cardNumber: String // Only last 4 digits stored
    let cardType: CardType
    let cardHolderName: String
    let amount: Double
    let currency: String
    let paymentDate: Date
    
    var maskedCardNumber: String {
        "**** **** **** \(cardNumber)"
    }
}

// MARK: - Card Type
enum CardType: String, Codable, CaseIterable {
    case visa = "Visa"
    case mastercard = "Mastercard"
    case amex = "American Express"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .visa, .mastercard, .amex: return "creditcard.fill"
        case .other: return "creditcard"
        }
    }
}

// MARK: - Booked Ticket (simplified for now)
struct BookedTicket: Identifiable, Codable {
    let id: String
    let userId: String
    let bookingReference: String
    let flight: SimpleFlight
    let passengerInfo: PassengerInfo
    let paymentInfo: PaymentInfo
    let bookingDate: Date
    
    var totalPrice: Double {
        Double(flight.totalPrice) ?? 0.0
    }
}
