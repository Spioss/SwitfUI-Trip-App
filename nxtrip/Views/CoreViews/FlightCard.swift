//
//  FlightCard.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

import SwiftUI

struct FlightCard: View {
    let flight: SimpleFlight
    let numberOfTickets: Int
    @EnvironmentObject var viewModel: FlightViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with price
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.formatPrice(flight.totalPrice, currency: flight.currency, numberOfTickets: numberOfTickets))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    if numberOfTickets > 1 {
                        Text("\(viewModel.formatPrice(flight.totalPrice, currency: flight.currency, numberOfTickets: 1)) × \(numberOfTickets)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(flight.outbound.firstSegment.carrierCode)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Main flight info
            HStack(alignment: .center, spacing: 20) {
                // Departure
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.outbound.firstSegment.departure.iataCode)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(getCityName(flight.outbound.firstSegment.departure.iataCode))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    VStack(alignment: .leading, spacing: 0){
                        Text(formatFlightDate(flight.outbound.firstSegment.departure.at))
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(viewModel.formatTime(flight.outbound.firstSegment.departure.at))
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                Spacer()
                
                // Flight path with duration
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "airplane")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !flight.outbound.isDirectFlight {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 4, height: 4)
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)
                        .frame(maxWidth: 60)
                    
                    Text(viewModel.formatDuration(flight.outbound.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrival
                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.outbound.lastSegment.arrival.iataCode)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(getCityName(flight.outbound.lastSegment.arrival.iataCode))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    VStack(alignment: .trailing, spacing: 0){
                        Text(formatFlightDate(flight.outbound.lastSegment.arrival.at))
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(viewModel.formatTime(flight.outbound.lastSegment.arrival.at))
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            // Return flight (ak existuje)
            if let returnFlight = flight.inbound {
                Divider()
                    .padding(.horizontal, 20)
                
                HStack(alignment: .center, spacing: 20) {
                    // Return Departure
                    VStack(alignment: .leading, spacing: 4) {
                        Text(returnFlight.firstSegment.departure.iataCode)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(getCityName(returnFlight.firstSegment.departure.iataCode))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading, spacing: 0){
                            Text(formatFlightDate(returnFlight.firstSegment.departure.at))
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(viewModel.formatTime(returnFlight.firstSegment.departure.at))
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer()
                    
                    // Return Flight path
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "airplane")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if !returnFlight.isDirectFlight {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                            .frame(maxWidth: 60)
                        
                        Text(viewModel.formatDuration(returnFlight.duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Return Arrival
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(returnFlight.lastSegment.arrival.iataCode)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(getCityName(returnFlight.lastSegment.arrival.iataCode))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        VStack(alignment: .trailing, spacing: 0){
                            Text(formatFlightDate(returnFlight.lastSegment.arrival.at))
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(viewModel.formatTime(returnFlight.lastSegment.arrival.at))
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            // Bottom section
            if !flight.outbound.isDirectFlight || (flight.inbound != nil && !flight.inbound!.isDirectFlight) {
                VStack(spacing: 4) {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    HStack {
                        if !flight.outbound.isDirectFlight {
                            Label("\(flight.outbound.numberOfStops) transfer", systemImage: "arrow.triangle.swap")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                        
                        if let returnFlight = flight.inbound, !returnFlight.isDirectFlight {
                            Label("\(returnFlight.numberOfStops) transfer", systemImage: "arrow.triangle.swap")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
            }
        }
        .background(Color.adaptiveInputBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Helper functions
    
    private func formatFlightDate(_ isoString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let date = inputFormatter.date(from: isoString) else {
            // Regex fallback
            if let dateMatch = isoString.range(of: #"(\d{4}-\d{2}-\d{2})"#, options: .regularExpression) {
                let dateString = String(isoString[dateMatch])
                let parts = dateString.split(separator: "-")
                if parts.count == 3 {
                    return "\(parts[2]).\(parts[1])."
                }
            }
            return isoString
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    
    private func getCityName(_ iataCode: String) -> String {
        // Most common airports, for some reason AmedeusAPI doesnt show most of these airport, idk why
        let airportNames = [
            "BTS": "Bratislava",
            "VIE": "Vienna",
            "PRG": "Prague",
            "LHR": "London",
            "LGW": "London",
            "STN": "London",
            "CDG": "Paris",
            "ORY": "Paris",
            "FRA": "Frankfurt",
            "MUC": "Munich",
            "FCO": "Rome",
            "MXP": "Milan",
            "MAD": "Madrid",
            "BCN": "Barcelona",
            "AMS": "Amsterdam",
            "ZUR": "Zurich",
            "GVA": "Geneva",
            "DUB": "Dublin",
            "CGN": "Cologne",
            "HAM": "Hamburg",
            "TXL": "Berlin",
            "BER": "Berlin",
            "WAW": "Warsaw",
            "KRK": "Krakow",
            "BUD": "Budapest",
            "OTP": "Bucharest",
            "SOF": "Sofia",
            "ATH": "Athens",
            "IST": "Istanbul",
            "CAI": "Cairo",
            "JFK": "New York",
            "LAX": "Los Angeles",
            "DXB": "Dubai",
            "DOH": "Doha",
            "SIN": "Singapore",
            "NRT": "Tokyo",
            "HND": "Tokyo",
            "ICN": "Seoul",
            "PEK": "Beijing",
            "SYD": "Sydney",
            "MEL": "Melbourne"
        ]
        
        return airportNames[iataCode] ?? iataCode
    }
}
