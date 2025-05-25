//
//  AmadeusService.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

// API HANDLE
import Foundation

class AmadeusService: ObservableObject {
    static let shared = AmadeusService()
    

    private let baseURL = "https://test.api.amadeus.com"
    
    private var accessToken: String?
    private var tokenExpiry: Date?
    
    private init() {}
    
    // Authetication
    private func getToken() async throws -> String {
        if let token = accessToken, let expiry = tokenExpiry, expiry > Date() {
            return token
        }
        
        let url = URL(string: "\(baseURL)/v1/security/oauth2/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=client_credentials&client_id=\(apiKey)&client_secret=\(apiSecret)"
        request.httpBody = body.data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let tokenResponse = try JSONDecoder().decode(AmadeusToken.self, from: data)
        
        self.accessToken = tokenResponse.accessToken
        self.tokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn - 60)) // 1 minúta pred expirovaním
        
        return tokenResponse.accessToken
    }
    
    // searchAirports
    func searchAirports(keyword: String) async throws -> [SimpleAirport] {
        let token = try await getToken()
        
        var components = URLComponents(string: "\(baseURL)/v1/reference-data/locations")!
        components.queryItems = [
            URLQueryItem(name: "subType", value: "AIRPORT"),
            URLQueryItem(name: "keyword", value: keyword),
            URLQueryItem(name: "page[limit]", value: "10"),
            URLQueryItem(name: "sort", value: "analytics.travelers.score")
        ]
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AirportSearchResponse.self, from: data)
        
        return response.data
    }
    
    // searchFlights
    func searchFlights(request: FlightSearchRequest) async throws -> [SimpleFlight] {
        let token = try await getToken()
        
        var components = URLComponents(string: "\(baseURL)/v2/shopping/flight-offers")!
        var queryItems = [
            URLQueryItem(name: "originLocationCode", value: request.from),
            URLQueryItem(name: "destinationLocationCode", value: request.to),
            URLQueryItem(name: "departureDate", value: request.departureDate),
            URLQueryItem(name: "adults", value: String(request.adults)),
            URLQueryItem(name: "max", value: "10") // Maximálne 10 výsledkov
        ]
        
        if let returnDate = request.returnDate {
            queryItems.append(URLQueryItem(name: "returnDate", value: returnDate))
        }
        
        components.queryItems = queryItems
        
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let response = try JSONDecoder().decode(FlightSearchResponse.self, from: data)
        
        return response.data
    }
}

// enum type for errors
enum FlightError: Error {
    case noToken
    case invalidResponse
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .noToken: return "Problém s autentifikáciou"
        case .invalidResponse: return "Neplatná odpoveď zo servera"
        case .networkError: return "Problém so sieťou"
        }
    }
}
