//
//  FlightViewModel.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

import Foundation
import SwiftUI

@MainActor
class FlightViewModel: ObservableObject {
    @Published var flights: [SimpleFlight] = []
    @Published var airports: [SimpleAirport] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var searchStatus = "Ready to search"
    
    // Form
    @Published var fromAirport: SimpleAirport?
    @Published var toAirport: SimpleAirport?
    @Published var departureDate = Date()
    @Published var returnDate = Date().addingTimeInterval(7*24*3600)
    @Published var isRoundTrip = false
    @Published var adults = 1
    @Published var kids = 1
    
    private let service = AmadeusService.shared
    
    // MARK: - Search Airports
    
    func searchAirports(keyword: String) async {
        guard !keyword.isEmpty else {
            airports = []
            searchStatus = "Empty search"
            return
        }
        
        // 2 chars needed
        guard keyword.count >= 2 else {
            searchStatus = "Need at least 2 characters"
            return
        }
        
        searchStatus = "Searching airports for: '\(keyword)'"
        
        do {
            let foundAirports = try await service.searchAirports(keyword: keyword)
            airports = foundAirports
            
            if foundAirports.isEmpty {
                searchStatus = "No airports found for '\(keyword)'"
                errorMessage = "No airports found for '\(keyword)'. Try another expression."
            } else {
                searchStatus = "Found \(foundAirports.count) airports"
                errorMessage = ""
            }
            
        } catch {
            searchStatus = "Airport search failed"
            errorMessage = "Error finding airports: \(error.localizedDescription)"
            airports = []
        }
    }
    
    // MARK: - Search Flights
    
    func searchFlights() async {
        guard let from = fromAirport?.iataCode,
              let to = toAirport?.iataCode else {
            errorMessage = "Select airports"
            return
        }
        
        isLoading = true
        searchStatus = "Searching flights from \(from) to \(to)"
        
        let request = FlightSearchRequest(
            from: from,
            to: to,
            departureDate: formatDate(departureDate),
            returnDate: isRoundTrip ? formatDate(returnDate) : nil,
            adults: adults,
            kids: kids
        )
    
        
        do {
            let foundFlights = try await service.searchFlights(request: request)
            flights = foundFlights
            
            if foundFlights.isEmpty {
                errorMessage = "No flights found for the specified criteria"
                searchStatus = "No flights found"
            } else {
                errorMessage = ""
                searchStatus = "Found \(foundFlights.count) flights"
            }
            
        } catch {
            errorMessage = "Flight search error: \(error.localizedDescription)"
            flights = []
            searchStatus = "Flight search failed"
        }
        
        isLoading = false
    }
    
    // MARK: - Helping Functions
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func formatTime(_ isoString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.timeZone = TimeZone(identifier: "UTC") // API returns UTC
    
        guard let date = inputFormatter.date(from: isoString) else {
            if let timeMatch = isoString.range(of: #"T(\d{2}:\d{2})"#, options: .regularExpression) {
                let timeString = String(isoString[timeMatch]).replacingOccurrences(of: "T", with: "")
                return timeString
            }
            return isoString
        }
        
        // local time convert
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.current
        
        let formattedTime = outputFormatter.string(from: date)
        return formattedTime
    }
    
    func formatDuration(_ duration: String) -> String {
        // PT2H15M -> 2h 15m
        // PT45M -> 45m
        // PT1H -> 1h
        let clean = duration.replacingOccurrences(of: "PT", with: "")
        
        // Regex
        var result = ""
        
        // hours
        if let hoursRange = clean.range(of: #"(\d+)H"#, options: .regularExpression) {
            let hoursString = String(clean[hoursRange]).replacingOccurrences(of: "H", with: "")
            if let hours = Int(hoursString) {
                result += "\(hours)h"
            }
        }
        
        // minutes
        if let minutesRange = clean.range(of: #"(\d+)M"#, options: .regularExpression) {
            let minutesString = String(clean[minutesRange]).replacingOccurrences(of: "M", with: "")
            if let minutes = Int(minutesString) {
                if !result.isEmpty { result += " " }
                result += "\(minutes)m"
            }
        }
        
        let finalResult = result.isEmpty ? duration : result
        return finalResult
    }
    
    func formatPrice(_ price: String, currency: String) -> String {
        guard let amount = Double(price) else { return "\(price) \(currency)" }
        return String(format: "%.0f %@", amount, currency)
    }
    
    // MARK: - Actions
    
    func swapAirports() {
        let temp = fromAirport
        fromAirport = toAirport
        toAirport = temp
    }
    
    func clearSearch() {
        flights = []
        fromAirport = nil
        toAirport = nil
        errorMessage = ""
        searchStatus = "Search cleared"
    }
    
    // MARK: - Helper for better airport suggestions
    
    func getPopularAirports() -> [String] {
        // popular airports
        return [
            "Bratislava", "BTS",
            "Vienna", "VIE",
            "Prague", "PRG",
            "London", "LHR",
            "Paris", "CDG",
            "Frankfurt", "FRA",
            "Munich", "MUC",
            "Rome", "FCO",
            "Madrid", "MAD",
            "Barcelona", "BCN",
            "Amsterdam", "AMS",
            "Zurich", "ZUR",
            "Milan", "MXP",
            "Berlin", "BER",
            "Warsaw", "WAW",
            "Budapest", "BUD", 
            "Istanbul", "IST",
            "Dubai", "DXB"
        ]
    }
}
