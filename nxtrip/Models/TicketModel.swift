//
//  TicketModel.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

import Foundation
import FirebaseFirestore

// MARK: - Main Booking Model (renamed from BookedTicket)
struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let bookingReference: String
    let bookingDate: Date
    let flight: SimpleFlight
    let passengerInfo: PassengerInfo
    let paymentInfo: PaymentInfo
    let status: String  // "pending", "confirmed", "cancelled"
    let numberOfTickets: Int  //
    let travelClass: TravelClass  //
    
    // Computed properties for backward compatibility
    var totalPrice: Double {
        flight.totalPriceForTickets(numberOfTickets)
    }
    
    var formattedPrice: String {
        flight.formattedTotalPrice(numberOfTickets: numberOfTickets)
    }
    
    var pricePerTicket: Double {
        flight.price.totalAsDouble
    }
    
    var formattedPricePerTicket: String {
        String(format: "%.2f %@", pricePerTicket, flight.currency)
    }
}

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
    let amount: Double
    let cardHolderName: String
    let cardNumber: String      // Last 4 digits only "2346"
    let cardType: String        // "Visa", "Mastercard", "Other"
    let currency: String        // "EUR"
    let paymentDate: Date
    
    var maskedCardNumber: String {
        "**** **** **** \(cardNumber)"
    }
    
    var cardTypeEnum: CardType {
        CardType(rawValue: cardType) ?? .other
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

// MARK: - Type Alias for backward compatibility
typealias BookedTicket = Booking
