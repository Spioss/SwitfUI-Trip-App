//
//  BookingDetailsCard.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//

import SwiftUI

struct BookingDetailsCard: View {
    let ticket: BookedTicket
    
    var body: some View {
        VStack(spacing: 20) {
            // Booking Reference
            BookingReferenceCard(reference: ticket.bookingReference)
            
            // Flight Details
            FlightDetailsCard(flight: ticket.flight)
            
            // Passenger Info
            PassengerInfoCard(passenger: ticket.passengerInfo)
            
            // Payment Summary
            PaymentSummaryCard(payment: ticket.paymentInfo, total: ticket.totalPrice, currency: ticket.flight.currency)
            
            // Important Info
            ImportantInfoCard()
        }
    }
}

// MARK: - Individual Cards

struct BookingReferenceCard: View {
    let reference: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Booking Reference")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(reference)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.purple)
                .padding()
                .background(Color.adaptiveSecondaryBackground)
                .cornerRadius(12)
        }
    }
}

struct FlightDetailsCard: View {
    let flight: SimpleFlight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Flight Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Outbound flight
                FlightRowComponent(
                    from: flight.outbound.firstSegment.departure.iataCode,
                    to: flight.outbound.lastSegment.arrival.iataCode,
                    date: formatDate(flight.outbound.firstSegment.departure.at)
                )
                
                // Return flight if exists
                if let returnFlight = flight.inbound {
                    Divider()
                    
                    FlightRowComponent(
                        from: returnFlight.firstSegment.departure.iataCode,
                        to: returnFlight.lastSegment.arrival.iataCode,
                        date: formatDate(returnFlight.firstSegment.departure.at)
                    )
                }
            }
        }
        .padding()
        .background(Color.adaptiveInputBackground)
        .cornerRadius(12)
    }
    
    private func formatDate(_ isoString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let date = inputFormatter.date(from: isoString) else {
            return isoString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        return outputFormatter.string(from: date)
    }
}

struct FlightRowComponent: View {
    let from: String
    let to: String
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(from)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(to)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "airplane")
                .font(.title3)
                .foregroundColor(.purple)
        }
    }
}

struct PassengerInfoCard: View {
    let passenger: PassengerInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Passenger")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(passenger.fullName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(passenger.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(passenger.phone)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(getInitials(from: passenger.fullName))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.purple)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.adaptiveInputBackground)
        .cornerRadius(12)
    }
    
    private func getInitials(from fullName: String) -> String {
        let nameParts = fullName.split(separator: " ")
        let initials = nameParts.compactMap { $0.first }.map { String($0).uppercased() }
        return initials.joined()
    }
}

struct PaymentSummaryCard: View {
    let payment: PaymentInfo
    let total: Double
    let currency: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Paid")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(total)) \(currency)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(payment.cardType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(payment.maskedCardNumber)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color.adaptiveInputBackground)
        .cornerRadius(12)
    }
}

struct ImportantInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Important Information")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("• Please arrive at the airport at least 2 hours before departure")
                Text("• Bring a valid passport or ID document")
                Text("• Check baggage restrictions with your airline")
                Text("• Save your booking reference for check-in")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}
