//
//  FlightModel.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

import Foundation

// MARK: - Search Request/Response

struct FlightSearchRequest {
    let from: String        // "BTS"
    let to: String         // "LHR"
    let departureDate: String  // "2025-06-15"
    let returnDate: String?    // nil for direct
    let adults: Int        // 1
    let kids: Int
}

struct FlightSearchResponse: Codable {
    let data: [SimpleFlight]
}

// MARK: - Flight Models

struct SimpleFlight: Codable, Identifiable {
    let id: String
    let price: FlightPrice
    let itineraries: [SimpleItinerary]
    
    var totalPrice: String { price.total }
    var currency: String { price.currency }
    var outbound: SimpleItinerary { itineraries[0] }
    var inbound: SimpleItinerary? { itineraries.count > 1 ? itineraries[1] : nil }
    var isRoundTrip: Bool { itineraries.count > 1 }
}

struct FlightPrice: Codable {
    let total: String      // "245.67"
    let currency: String   // "EUR"
    
    var totalAsDouble: Double {
        Double(total) ?? 0.0
    }
    
    var formattedPrice: String {
        let value = totalAsDouble
        return String(format: "%.2f %@", value, currency)
    }
}

struct SimpleItinerary: Codable {
    let duration: String   // "PT2H15M"
    let segments: [SimpleSegment]
    
    var firstSegment: SimpleSegment { segments[0] }
    var lastSegment: SimpleSegment { segments[segments.count - 1] }
    var isDirectFlight: Bool { segments.count == 1 }
    var numberOfStops: Int { segments.count - 1 }
    
    // Computed properties for easier access
    var departureTime: String { firstSegment.departure.at }
    var arrivalTime: String { lastSegment.arrival.at }
    var departureAirport: String { firstSegment.departure.iataCode }
    var arrivalAirport: String { lastSegment.arrival.iataCode }
}

struct SimpleSegment: Codable {
    let departure: FlightPoint
    let arrival: FlightPoint
    let carrierCode: String  // "BA"
    let number: String       // "847"
    let duration: String     // "PT2H15M"
    
    var flightNumber: String {
        "\(carrierCode)\(number)"
    }
}

struct FlightPoint: Codable {
    let iataCode: String     // "BTS"
    let at: String          // "2025-06-15T14:30:00"
    
    var date: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: at)
    }
    
    var displayTime: String {
        guard let date = date else { return at }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    var displayDate: String {
        guard let date = date else { return at }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    var displayDateTime: String {
        guard let date = date else { return at }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Airports

struct AirportSearchResponse: Codable {
    let data: [SimpleAirport]
}

struct SimpleAirport: Codable, Identifiable {
    let id: String
    let name: String         // "London Heathrow"
    let iataCode: String     // "LHR"
    let address: AirportAddress
    
    var displayName: String { "\(name) (\(iataCode))" }
}

struct AirportAddress: Codable {
    let cityName: String?    // "London"
    let countryName: String? // "United Kingdom"
}

// MARK: - API Token

struct AmadeusToken: Codable {
    let accessToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}
