//
//  FlightViewModel.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

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
    // Výsledky
    @Published var flights: [SimpleFlight] = []
    @Published var airports: [SimpleAirport] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var searchStatus = "Ready to search" // Nový status pre debug
    
    // Formulár
    @Published var fromAirport: SimpleAirport?
    @Published var toAirport: SimpleAirport?
    @Published var departureDate = Date()
    @Published var returnDate = Date().addingTimeInterval(7*24*3600) // +7 dní
    @Published var isRoundTrip = false
    @Published var adults = 1
    
    private let service = AmadeusService.shared
    
    // MARK: - Search Airports
    
    func searchAirports(keyword: String) async {
        guard !keyword.isEmpty else {
            airports = []
            searchStatus = "Empty search"
            return
        }
        
        // Minimálne 2 znaky pre vyhľadávanie
        guard keyword.count >= 2 else {
            searchStatus = "Need at least 2 characters"
            return
        }
        
        searchStatus = "Searching airports for: '\(keyword)'"
        
        do {
            let foundAirports = try await service.searchAirports(keyword: keyword)
            
            // DEBUG: Vypíšme prvé 3 letiská pre kontrolu
            if !foundAirports.isEmpty {
                print("🛫 AIRPORTS API RESPONSE (first 3):")
                for (index, airport) in foundAirports.prefix(3).enumerated() {
                    print("  [\(index + 1)] \(airport.id)")
                    print("      Name: \(airport.name)")
                    print("      IATA: \(airport.iataCode)")
                    print("      City: \(airport.address.cityName ?? "N/A")")
                    print("      Country: \(airport.address.countryName ?? "N/A")")
                    print("      ---")
                }
                print("Total found: \(foundAirports.count) airports\n")
            }
            
            airports = foundAirports
            
            if foundAirports.isEmpty {
                searchStatus = "No airports found for '\(keyword)'"
                errorMessage = "Žiadne letiská nenájdené pre '\(keyword)'. Skúste iný výraz."
            } else {
                searchStatus = "Found \(foundAirports.count) airports"
                errorMessage = "" // Vyčistíme chybu ak sa nájdu výsledky
            }
            
        } catch {
            searchStatus = "Airport search failed"
            errorMessage = "Chyba pri hľadaní letísk: \(error.localizedDescription)"
            airports = []
            print("❌ AIRPORT SEARCH ERROR: \(error)")
        }
    }
    
    // MARK: - Search Flights
    
    func searchFlights() async {
        guard let from = fromAirport?.iataCode,
              let to = toAirport?.iataCode else {
            errorMessage = "Vyber letiská"
            return
        }
        
        isLoading = true
        searchStatus = "Searching flights from \(from) to \(to)"
        
        let request = FlightSearchRequest(
            from: from,
            to: to,
            departureDate: formatDate(departureDate),
            returnDate: isRoundTrip ? formatDate(returnDate) : nil,
            adults: adults
        )
        
        // DEBUG: Vypíšme request
        print("🔍 FLIGHT SEARCH REQUEST:")
        print("  From: \(request.from)")
        print("  To: \(request.to)")
        print("  Departure: \(request.departureDate)")
        print("  Return: \(request.returnDate ?? "nil")")
        print("  Adults: \(request.adults)")
        
        do {
            let foundFlights = try await service.searchFlights(request: request)
            
            // DEBUG: Vypíšme prvý let pre kontrolu
            if let firstFlight = foundFlights.first {
                print("✈️ FLIGHTS API RESPONSE (first flight):")
                print("  Flight ID: \(firstFlight.id)")
                print("  Price: \(firstFlight.price.total) \(firstFlight.price.currency)")
                print("  Itineraries count: \(firstFlight.itineraries.count)")
                
                if let outbound = firstFlight.itineraries.first {
                    print("  OUTBOUND:")
                    print("    Duration: \(outbound.duration)")
                    print("    Segments: \(outbound.segments.count)")
                    
                    if let firstSegment = outbound.segments.first {
                        print("    First Segment:")
                        print("      Departure: \(firstSegment.departure.iataCode) at \(firstSegment.departure.at)")
                        print("      Arrival: \(firstSegment.arrival.iataCode) at \(firstSegment.arrival.at)")
                        print("      Carrier: \(firstSegment.carrierCode)\(firstSegment.number)")
                        print("      Duration: \(firstSegment.duration)")
                    }
                }
                print("Total flights found: \(foundFlights.count)\n")
            }
            
            flights = foundFlights
            
            if foundFlights.isEmpty {
                errorMessage = "Žiadne lety nenájdené pre zadané kritériá"
                searchStatus = "No flights found"
            } else {
                errorMessage = ""
                searchStatus = "Found \(foundFlights.count) flights"
            }
            
        } catch {
            errorMessage = "Chyba pri hľadaní letov: \(error.localizedDescription)"
            flights = []
            searchStatus = "Flight search failed"
            print("❌ FLIGHT SEARCH ERROR: \(error)")
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
        // Jednoduchšie a spoľahlivejšie parsovanie
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.timeZone = TimeZone(identifier: "UTC") // API pravdepodobne vracia UTC
        
        // Skúsime parsovať
        guard let date = inputFormatter.date(from: isoString) else {
            print("⚠️ Cannot parse time: \(isoString)")
            // Ako fallback, skúsime extrahovať čas regex-om
            if let timeMatch = isoString.range(of: #"T(\d{2}:\d{2})"#, options: .regularExpression) {
                let timeString = String(isoString[timeMatch]).replacingOccurrences(of: "T", with: "")
                print("   -> Extracted time as fallback: \(timeString)")
                return timeString
            }
            return isoString
        }
        
        // Skonvertujeme na lokálny čas
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.current
        
        let formattedTime = outputFormatter.string(from: date)
        print("✅ Parsed time: \(isoString) -> \(formattedTime)")
        return formattedTime
    }
    
    func formatDuration(_ duration: String) -> String {
        // PT2H15M -> 2h 15m
        // PT45M -> 45m
        // PT1H -> 1h
        
        print("🕐 Parsing duration: \(duration)")
        
        let clean = duration.replacingOccurrences(of: "PT", with: "")
        
        // Regex na parsovanie hodin a minút
        var result = ""
        
        // Hľadáme hodiny (číslice pred H)
        if let hoursRange = clean.range(of: #"(\d+)H"#, options: .regularExpression) {
            let hoursString = String(clean[hoursRange]).replacingOccurrences(of: "H", with: "")
            if let hours = Int(hoursString) {
                result += "\(hours)h"
            }
        }
        
        // Hľadáme minúty (číslice pred M)
        if let minutesRange = clean.range(of: #"(\d+)M"#, options: .regularExpression) {
            let minutesString = String(clean[minutesRange]).replacingOccurrences(of: "M", with: "")
            if let minutes = Int(minutesString) {
                if !result.isEmpty { result += " " }
                result += "\(minutes)m"
            }
        }
        
        let finalResult = result.isEmpty ? duration : result
        print("   -> Formatted as: \(finalResult)")
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
        // Populárne letiská pre SK/CZ/EU región
        return [
            "Bratislava", "BTS", "Vienna", "VIE", "Prague", "PRG",
            "London", "LHR", "Paris", "CDG", "Frankfurt", "FRA",
            "Munich", "MUC", "Rome", "FCO", "Madrid", "MAD",
            "Barcelona", "BCN", "Amsterdam", "AMS", "Zurich", "ZUR",
            "Milan", "MXP", "Berlin", "BER", "Warsaw", "WAW",
            "Budapest", "BUD", "Istanbul", "IST", "Dubai", "DXB"
        ]
    }
}
