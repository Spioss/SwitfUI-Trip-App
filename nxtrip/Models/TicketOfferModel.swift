//
//  TicketOfferModel.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

import Foundation
import FirebaseFirestore

// MARK: - Ticket Offer Model
struct TicketOffer: Identifiable, Codable {
    @DocumentID var id: String?
    let sellerId: String
    let sellerName: String
    let bookingRef: String
    let fromCode: String
    let fromCity: String
    let toCode: String
    let toCity: String
    let date: String // "Dec 13, 2025"
    let departureTime: String // "10:35"
    let airline: String // "Vueling"
    let flightNumber: String // "8715"
    let seat: String // "ECONOMY"
    let isInternational: Bool
    let priceOriginal: Double // 109.22
    let priceCurrent: Double // 80
    let discountPercent: Int // 0-100
    let reason: String // "illness", "work", etc.
    let timeAgo: String // "Just now"
    let createdAt: Date
    let isActive: Bool
    
    // Custom CodingKeys to match Firestore field names
    enum CodingKeys: String, CodingKey {
        case id
        case sellerId = "sellerUid"
        case sellerName = "sellerName"
        case bookingRef = "bookingRef"
        case fromCode = "fromCode"
        case fromCity = "fromCity"
        case toCode = "toCode"
        case toCity = "toCity"
        case date
        case departureTime = "departureTime"
        case airline
        case flightNumber = "flightNumber"
        case seat
        case isInternational = "international"
        case priceOriginal = "priceOriginal"
        case priceCurrent = "priceCurrent"
        case discountPercent = "discountPercent"
        case reason
        case timeAgo = "timeAgo"
        case createdAt = "createdAt"
        case isActive = "isActive"
    }
    
    // Computed properties
    var savings: Double {
        priceOriginal - priceCurrent
    }
    
    var formattedOriginalPrice: String {
        String(format: "%.2f €", priceOriginal)
    }
    
    var formattedCurrentPrice: String {
        String(format: "%.2f €", priceCurrent)
    }
    
    var formattedSavings: String {
        String(format: "%.2f €", savings)
    }
    
    var route: String {
        "\(fromCode) → \(toCode)"
    }
    
    var routeWithCities: String {
        "\(fromCity) → \(toCity)"
    }
    
    var fullFlightInfo: String {
        "\(airline) \(flightNumber)"
    }
    
    var isValidOffer: Bool {
        priceCurrent < priceOriginal && priceCurrent > 0
    }

}

// MARK: - Reason enum for selling
enum SellReason: String, Codable, CaseIterable {
    case illness = "Illness"
    case work = "Work commitment"
    case emergency = "Family emergency"
    case schedule = "Schedule change"
    case other = "Other reason"
    
    var icon: String {
        switch self {
        case .illness:
            return "cross.case.fill"
        case .work:
            return "briefcase.fill"
        case .emergency:
            return "exclamationmark.triangle.fill"
        case .schedule:
            return "calendar.badge.clock"
        case .other:
            return "questionmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .illness:
            return "red"
        case .work:
            return "blue"
        case .emergency:
            return "orange"
        case .schedule:
            return "purple"
        case .other:
            return "gray"
        }
    }
}
