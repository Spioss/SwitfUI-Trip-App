//
//  SoldTicketInfoView.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

import SwiftUI

// Simple info view for sold tickets (non-interactive)
struct SoldTicketInfoView: View {
    let ticket: BookedTicket
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)
                    
                    // Sold icon
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "arrow.triangle.swap")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                        
                        Text("Ticket Sold")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        Text("This ticket was successfully sold via SaveTheTicket")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Original booking info
                    VStack(spacing: 20) {
                        infoCard(
                            title: "Original Booking",
                            items: [
                                ("Reference", ticket.bookingReference),
                                ("Route", "\(ticket.flight.outbound.firstSegment.departure.iataCode) → \(ticket.flight.outbound.lastSegment.arrival.iataCode)"),
                                ("Class", ticket.travelClass.rawValue),
                                ("Tickets", "\(ticket.numberOfTickets)")
                            ]
                        )
                        
                        infoCard(
                            title: "Payment",
                            items: [
                                ("Original Price", ticket.formattedPrice),
                                ("Status", "Refunded to new owner")
                            ]
                        )
                        
                        // Info message
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Important Information")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRowSold(
                                    icon: "checkmark.circle",
                                    text: "This ticket was transferred to a new passenger",
                                    color: .green
                                )
                                InfoRowSold(
                                    icon: "person.fill",
                                    text: "The new owner now has full access to this booking",
                                    color: .blue
                                )
                                InfoRowSold(
                                    icon: "lock.fill",
                                    text: "You can no longer modify or use this ticket",
                                    color: .orange
                                )
                                InfoRowSold(
                                    icon: "dollarsign.circle",
                                    text: "Payment was processed through SaveTheTicket",
                                    color: .green
                                )
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Sold Ticket Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Info Card Component
    
    private func infoCard(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                ForEach(items, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(item.1)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Info Row Component

struct InfoRowSold: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}
