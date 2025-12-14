//
//  TicketCard.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//

import SwiftUI

struct TicketCard: View {
    let ticket: BookedTicket
    @EnvironmentObject var viewModel: TicketViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with booking reference and status
            ticketHeader
            
            // Flight details
            flightDetails
            
            // Bottom info
            ticketFooter
        }
        .background(Color.adaptiveInputBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(statusColor.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Header
    private var ticketHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Booking Reference")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(ticket.bookingReference)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.purple)
                
                HStack(spacing: 4) {
                    Image(systemName: ticket.travelClass.icon)
                        .font(.caption2)
                    Text(ticket.travelClass.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ticket.travelClass.color)
                    .cornerRadius(6)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: flightStatus.icon)
                        .font(.caption)
                    Text(flightStatus.text)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(flightStatus.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(flightStatus.color.opacity(0.1))
                .cornerRadius(8)
                
                Text(viewModel.formatFlightDate(ticket.flight.outbound.firstSegment.departure.at))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if ticket.numberOfTickets > 1 {
                    HStack(spacing: 4) {
                    Image(systemName: "ticket.fill")
                        .font(.caption2)
                    Text("\(ticket.numberOfTickets) tickets")
                        .font(.caption)
                        .fontWeight(.medium)
                 }
                .foregroundColor(.purple)
               }
            
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Flight Details
    private var flightDetails: some View {
        VStack(spacing: 16) {
            // Outbound flight
            FlightRoute(
                from: ticket.flight.outbound.firstSegment.departure.iataCode,
                to: ticket.flight.outbound.lastSegment.arrival.iataCode,
                departureTime: viewModel.formatTime(ticket.flight.outbound.firstSegment.departure.at),
                arrivalTime: viewModel.formatTime(ticket.flight.outbound.lastSegment.arrival.at),
                date: viewModel.formatFlightDate(ticket.flight.outbound.firstSegment.departure.at),
                isReturn: false
            )
            
            // Return flight if exists
            if let returnFlight = ticket.flight.inbound {
                Divider()
                    .padding(.horizontal, 20)
                
                FlightRoute(
                    from: returnFlight.firstSegment.departure.iataCode,
                    to: returnFlight.lastSegment.arrival.iataCode,
                    departureTime: viewModel.formatTime(returnFlight.firstSegment.departure.at),
                    arrivalTime: viewModel.formatTime(returnFlight.lastSegment.arrival.at),
                    date: viewModel.formatFlightDate(returnFlight.firstSegment.departure.at),
                    isReturn: true
                )
            }
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Footer
    private var ticketFooter: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Passenger")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(ticket.passengerInfo.fullName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Total Paid")
                    .font(.caption)
                    .foregroundColor(.secondary)
                            
                VStack(alignment: .trailing, spacing: 2) {
                Text(ticket.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                                
                // breakdown if multiple tickets
                if ticket.numberOfTickets > 1 {
                    Text("\(ticket.formattedPricePerTicket) × \(ticket.numberOfTickets)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .padding(.top, 16)
        .background(Color.adaptiveSecondaryBackground.opacity(0.5))
        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
    }
    
    // MARK: - Computed Properties
    private var flightStatus: FlightStatus {
        viewModel.getFlightStatus(ticket.flight.outbound.firstSegment.departure.at)
    }
    
    private var statusColor: Color {
        flightStatus.color
    }
}

// MARK: - Flight Route Component
struct FlightRoute: View {
    let from: String
    let to: String
    let departureTime: String
    let arrivalTime: String
    let date: String
    let isReturn: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(isReturn ? "Return" : "Outbound")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            HStack(alignment: .center, spacing: 20) {
                // Departure
                VStack(alignment: .leading, spacing: 4) {
                    Text(from)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(departureTime)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Flight path
                VStack(spacing: 4) {
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundColor(.purple)
                    
                    Rectangle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(height: 2)
                        .frame(width: 60)
                }
                
                Spacer()
                
                // Arrival
                VStack(alignment: .trailing, spacing: 4) {
                    Text(to)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(arrivalTime)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorners(radius: radius, corners: corners))
    }
}
