//
//  ActionButtonsView.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//

import SwiftUI

struct ActionButtonsView: View {
    let ticket: BookedTicket?
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                copyBookingDetailsToClipboard()
            }) {
                HStack {
                    Image(systemName: "doc.on.clipboard")
                    Text("Copy Booking Details")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: {
                print("Add to calendar tapped")
            }) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Add to Calendar")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.adaptiveSecondaryBackground)
                .foregroundColor(Color.adaptivePrimaryText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.adaptiveBorder, lineWidth: 1)
                )
            }
        }
    }
    
    private func copyBookingDetailsToClipboard() {
        guard let ticket = ticket else { return }
        
        let shareText = """
        ✈️ Flight Booking Confirmed!
        
        Booking Reference: \(ticket.bookingReference)
        Passenger: \(ticket.passengerInfo.fullName)
        
        Outbound: \(ticket.flight.outbound.firstSegment.departure.iataCode) → \(ticket.flight.outbound.lastSegment.arrival.iataCode)
        Date: \(formatDate(ticket.flight.outbound.firstSegment.departure.at))
        
        \(ticket.flight.inbound != nil ? "Return: \(ticket.flight.inbound!.firstSegment.departure.iataCode) → \(ticket.flight.inbound!.lastSegment.arrival.iataCode)\nDate: \(formatDate(ticket.flight.inbound!.firstSegment.departure.at))\n" : "")Total: \(Int(ticket.totalPrice)) \(ticket.flight.currency)
        
        Safe travels! 🌍
        """
        
        UIPasteboard.general.string = shareText
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        print("✅ Booking details copied to clipboard!")
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
