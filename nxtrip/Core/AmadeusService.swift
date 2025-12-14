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
    
    // 🔧 Debug mode - set to true to always use mock data
    private let forceMockData = false
    
    private init() {}
    
    // MARK: - Authentication
    
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
        self.tokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn - 60))
        
        return tokenResponse.accessToken
    }
    
    // MARK: - Search Airports
    
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
    
    // MARK: - Search Flights (with Mock Fallback)
    
    func searchFlights(request: FlightSearchRequest) async throws -> [SimpleFlight] {
        
        // Parse dates from string to Date for mock data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let departureDate = dateFormatter.date(from: request.departureDate) else {
            throw FlightError.invalidResponse
        }
        
        let returnDate = request.returnDate != nil ? dateFormatter.date(from: request.returnDate!) : nil
        
        // Force mock data if enabled
        if forceMockData {
            print("🎭 Using MOCK data (forced)")
            try? await Task.sleep(nanoseconds: 500_000_000) // Simulate API delay
            return MockFlightData.generateMockFlights(
                from: request.from,
                to: request.to,
                departureDate: departureDate,
                returnDate: returnDate,
                isRoundTrip: request.returnDate != nil,
                travelClass: request.travelClass
            )
        }
        
        // Try real API first
        do {
            return try await fetchRealFlights(request: request)
        } catch {
            print("⚠️ Amadeus API failed: \(error.localizedDescription)")
            print("🎭 Falling back to MOCK data")
            
            // Pass actual dates to mock data
            return MockFlightData.generateMockFlights(
                from: request.from,
                to: request.to,
                departureDate: departureDate,
                returnDate: returnDate,
                isRoundTrip: request.returnDate != nil,
                travelClass: request.travelClass
            )
        }
    }
    
    // MARK: - Fetch Real Flights from API
    
    private func fetchRealFlights(request: FlightSearchRequest) async throws -> [SimpleFlight] {
        let token = try await getToken()
        
        var components = URLComponents(string: "\(baseURL)/v2/shopping/flight-offers")!
        var queryItems = [
            URLQueryItem(name: "originLocationCode", value: request.from),
            URLQueryItem(name: "destinationLocationCode", value: request.to),
            URLQueryItem(name: "departureDate", value: request.departureDate),
            URLQueryItem(name: "adults", value: String(request.numberOfTickets)),
            URLQueryItem(name: "travelClass", value: request.travelClass.apiCode),
            URLQueryItem(name: "max", value: "10")
        ]
        
        if let returnDate = request.returnDate {
            queryItems.append(URLQueryItem(name: "returnDate", value: returnDate))
        }
        
        components.queryItems = queryItems
        
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 10 // ⏱️ Shorter timeout to fail fast
        
        print("🔍 Amadeus API Request: \(components.url?.absoluteString ?? "N/A")")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FlightError.networkError
        }
        
        print("📡 HTTP Status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ API returned error code: \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                print("Response: \(errorString.prefix(200))")
            }
            throw FlightError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let flightResponse = try decoder.decode(FlightSearchResponse.self, from: data)
        
        print("✅ Successfully fetched \(flightResponse.data.count) flights from API")
        
        return flightResponse.data
    }
}

// MARK: - Error Types

enum FlightError: Error {
    case noToken
    case invalidResponse
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .noToken: return "Auth Problem"
        case .invalidResponse: return "Invalid response from the server"
        case .networkError: return "Network problem"
        }
    }
}
