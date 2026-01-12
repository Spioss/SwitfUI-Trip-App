//
//  AirlineReviewModel.swift
//  nxtrip
//
//  Created by Lukáš Mader on 11/01/2026.
//

import Foundation
import FirebaseFirestore

// MARK: - Airline

struct Airline: Identifiable, Hashable {
    let code: String   // e.g. "BA"
    let name: String   // e.g. "British Airways"
    
    var id: String { code }
}

extension Airline {
    static let all: [Airline] = [
        Airline(code: "VY", name: "Vueling"),
        Airline(code: "FR", name: "Ryanair"),
        Airline(code: "BA", name: "British Airways"),
        Airline(code: "LH", name: "Lufthansa"),
        Airline(code: "DY", name: "Norwegian"),
        Airline(code: "U2", name: "easyJet"),
        Airline(code: "W6", name: "Wizz Air"),
        Airline(code: "OS", name: "Austrian Airlines"),
        Airline(code: "KL", name: "KLM"),
        Airline(code: "AF", name: "Air France"),
        Airline(code: "IB", name: "Iberia"),
        Airline(code: "TP", name: "TAP Portugal")
    ]
}

// MARK: - Airline Review

struct AirlineReview: Identifiable, Codable {
    @DocumentID var id: String?
    let airlineCode: String
    let airlineName: String
    let userId: String
    let userName: String
    let rating: Int          // 1-5
    let comment: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case airlineCode
        case airlineName
        case userId
        case userName
        case rating
        case comment
        case createdAt
    }
}
