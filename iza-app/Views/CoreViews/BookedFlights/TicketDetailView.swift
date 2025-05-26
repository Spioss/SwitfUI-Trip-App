
//
//  TicketDetailView.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//

import SwiftUI

struct TicketDetailView: View {
    let ticket: BookedTicket
    @EnvironmentObject var viewModel: TicketViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Header
                    statusHeaderSection
                    
                    // Boarding Pass Style Card
                    boardingPassCard
                    
                    // Flight Details
                    flightDetailsSection
                    
                    // Passenger Info
                    passengerInfoSection
                    
                    // Payment Info
                    paymentInfoSection
                    
                    // Important Information
                    importantInfoSection
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding()
            }
            .navigationTitle("Flight Details")
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
    
    // MARK: - Status Header
    private var statusHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Flight Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: flightStatus.icon)
                            .font(.subheadline)
                        Text(flightStatus.text)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(flightStatus.color)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Departure")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(viewModel.formatFlightDate(ticket.flight.outbound.firstSegment.departure.at))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(viewModel.formatTime(ticket.flight.outbound.firstSegment.departure.at))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding()
            .background(flightStatus.color.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Boarding Pass Card
    private var boardingPassCard: some View {
        VStack(spacing: 0) {
            // Top section
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("BOARDING PASS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(ticket.bookingReference)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("PASSENGER")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(ticket.passengerInfo.fullName.uppercased())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Flight route section
            HStack(alignment: .center, spacing: 20) {
                // From
                VStack(spacing: 4) {
                    Text(ticket.flight.outbound.firstSegment.departure.iataCode)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.purple)
                    
                    Text(viewModel.formatTime(ticket.flight.outbound.firstSegment.departure.at))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "airplane")
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    // Dashed line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 80, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(.secondary.opacity(0.5))
                    .frame(height: 2)
                }
                
                Spacer()
                
                // To
                VStack(spacing: 4) {
                    Text(ticket.flight.outbound.lastSegment.arrival.iataCode)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.purple)
                    
                    Text(viewModel.formatTime(ticket.flight.outbound.lastSegment.arrival.at))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .background(Color.adaptiveInputBackground)
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Flight Details Section
    private var flightDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Flight Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DetailRow(label: "Flight", value: "\(ticket.flight.outbound.firstSegment.carrierCode) \(ticket.flight.outbound.firstSegment.number)")
                DetailRow(label: "Route", value: "\(ticket.flight.outbound.firstSegment.departure.iataCode) → \(ticket.flight.outbound.lastSegment.arrival.iataCode)")
                DetailRow(label: "Date", value: viewModel.formatFlightDate(ticket.flight.outbound.firstSegment.departure.at))
                DetailRow(label: "Departure", value: viewModel.formatTime(ticket.flight.outbound.firstSegment.departure.at))
                DetailRow(label: "Arrival", value: viewModel.formatTime(ticket.flight.outbound.lastSegment.arrival.at))
                
                if let returnFlight = ticket.flight.inbound {
                    Divider()
                    Text("Return Flight")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    
                    DetailRow(label: "Flight", value: "\(returnFlight.firstSegment.carrierCode) \(returnFlight.firstSegment.number)")
                    DetailRow(label: "Route", value: "\(returnFlight.firstSegment.departure.iataCode) → \(returnFlight.lastSegment.arrival.iataCode)")
                    DetailRow(label: "Date", value: viewModel.formatFlightDate(returnFlight.firstSegment.departure.at))
                    DetailRow(label: "Departure", value: viewModel.formatTime(returnFlight.firstSegment.departure.at))
                    DetailRow(label: "Arrival", value: viewModel.formatTime(returnFlight.lastSegment.arrival.at))
                }
            }
            .padding()
            .background(Color.adaptiveInputBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Passenger Info Section
    private var passengerInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Passenger Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DetailRow(label: "Name", value: ticket.passengerInfo.fullName)
                DetailRow(label: "Email", value: ticket.passengerInfo.email)
                DetailRow(label: "Phone", value: ticket.passengerInfo.phone)
                DetailRow(label: "Date of Birth", value: formatDateOfBirth(ticket.passengerInfo.dateOfBirth))
            }
            .padding()
            .background(Color.adaptiveInputBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Payment Info Section
    private var paymentInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DetailRow(label: "Total Amount", value: "\(Int(ticket.totalPrice)) \(ticket.flight.currency)", valueColor: .green)
                DetailRow(label: "Payment Method", value: ticket.paymentInfo.cardType.rawValue)
                DetailRow(label: "Card", value: ticket.paymentInfo.maskedCardNumber)
                DetailRow(label: "Payment Date", value: formatPaymentDate(ticket.paymentInfo.paymentDate))
            }
            .padding()
            .background(Color.adaptiveInputBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Important Info Section
    private var importantInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Important Information")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ImportantInfoRow(icon: "clock", text: "Arrive at airport 2 hours before departure")
                ImportantInfoRow(icon: "doc.text", text: "Bring valid passport or ID document")
                ImportantInfoRow(icon: "suitcase", text: "Check baggage restrictions with airline")
                ImportantInfoRow(icon: "qrcode", text: "Save booking reference for check-in")
                
                if flightStatus == .soon {
                    ImportantInfoRow(icon: "exclamationmark.triangle.fill", text: "Online check-in is available now", color: .orange)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if flightStatus == .soon {
                Button(action: {
                    // Handle check-in action
                    print("Check-in tapped")
                }) {
                    HStack {
                        Image(systemName: "airplane.departure")
                        Text("Check-in Online")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            Button(action: {
                copyTicketDetails()
            }) {
                HStack {
                    Image(systemName: "doc.on.clipboard")
                    Text("Copy Ticket Details")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: {
                // Handle add to calendar
                print("Add to calendar tapped")
            }) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Add to Calendar")
                        .fontWeight(.semibold)
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
    
    // MARK: - Computed Properties
    private var flightStatus: FlightStatus {
        viewModel.getFlightStatus(ticket.flight.outbound.firstSegment.departure.at)
    }
    
    // MARK: - Helper Functions
    private func formatDateOfBirth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatPaymentDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func copyTicketDetails() {
        let ticketText = """
        ✈️ Flight Booking Details
        
        Booking Reference: \(ticket.bookingReference)
        Passenger: \(ticket.passengerInfo.fullName)
        
        Outbound Flight:
        \(ticket.flight.outbound.firstSegment.departure.iataCode) → \(ticket.flight.outbound.lastSegment.arrival.iataCode)
        Date: \(viewModel.formatFlightDate(ticket.flight.outbound.firstSegment.departure.at))
        Departure: \(viewModel.formatTime(ticket.flight.outbound.firstSegment.departure.at))
        Arrival: \(viewModel.formatTime(ticket.flight.outbound.lastSegment.arrival.at))
        
        \(ticket.flight.inbound != nil ? """
        Return Flight:
        \(ticket.flight.inbound!.firstSegment.departure.iataCode) → \(ticket.flight.inbound!.lastSegment.arrival.iataCode)
        Date: \(viewModel.formatFlightDate(ticket.flight.inbound!.firstSegment.departure.at))
        Departure: \(viewModel.formatTime(ticket.flight.inbound!.firstSegment.departure.at))
        Arrival: \(viewModel.formatTime(ticket.flight.inbound!.lastSegment.arrival.at))
        
        """ : "")Total: \(Int(ticket.totalPrice)) \(ticket.flight.currency)
        
        Have a great flight! 🌍
        """
        
        UIPasteboard.general.string = ticketText
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let label: String
    let value: String
    let valueColor: Color
    
    init(label: String, value: String, valueColor: Color = .primary) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Important Info Row Component
struct ImportantInfoRow: View {
    let icon: String
    let text: String
    let color: Color
    
    init(icon: String, text: String, color: Color = .secondary) {
        self.icon = icon
        self.text = text
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(color)
        }
    }
}
