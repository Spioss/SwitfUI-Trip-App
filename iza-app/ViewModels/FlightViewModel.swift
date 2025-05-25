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
            return
        }
        
        do {
            airports = try await service.searchAirports(keyword: keyword)
        } catch {
            errorMessage = "Chyba pri hľadaní letísk: \(error.localizedDescription)"
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
        
        let request = FlightSearchRequest(
            from: from,
            to: to,
            departureDate: formatDate(departureDate),
            returnDate: isRoundTrip ? formatDate(returnDate) : nil,
            adults: adults
        )
        
        do {
            flights = try await service.searchFlights(request: request)
            if flights.isEmpty {
                errorMessage = "Žiadne lety nenájdené"
            }
        } catch {
            errorMessage = "Chyba pri hľadaní letov: \(error.localizedDescription)"
            flights = []
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
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return isoString }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }
    
    func formatDuration(_ duration: String) -> String {
        // PT2H15M -> 2h 15m
        let clean = duration.replacingOccurrences(of: "PT", with: "")
        let parts = clean.components(separatedBy: CharacterSet(charactersIn: "HM"))
        
        var result = ""
        if let hours = Int(parts[0]) {
            result += "\(hours)h"
        }
        if parts.count > 1, let minutes = Int(parts[1]) {
            result += " \(minutes)m"
        }
        
        return result
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
    }
}
