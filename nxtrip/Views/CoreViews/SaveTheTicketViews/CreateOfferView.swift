//
//  CreateOfferView.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

import SwiftUI

struct CreateOfferView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: SaveTheTicketViewModel
    @StateObject private var ticketViewModel = TicketViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedBooking: Booking?
    @State private var newPrice: String = ""
    @State private var selectedReason: SellReason = .illness
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Instructions
                    instructionsSection
                    
                    // Select booking
                    selectBookingSection
                    
                    if let booking = selectedBooking {
                        // Booking preview
                        selectedBookingPreview(booking: booking)
                        
                        // Price section
                        priceSection(booking: booking)
                        
                        // Reason section
                        reasonSection
                        
                        // Create button
                        createButton(booking: booking)
                    }
                }
                .padding()
            }
            .navigationTitle("Sell Your Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    Task {
                        await ticketViewModel.fetchUserTickets(userId: userId)
                    }
                }
            }
        }
    }
    
    // MARK: - Instructions Section
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("How it works")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                InstructionRow(number: "1", text: "Select your booked ticket")
                InstructionRow(number: "2", text: "Set a new price (must be lower)")
                InstructionRow(number: "3", text: "Choose reason for selling")
                InstructionRow(number: "4", text: "Create offer and wait for buyers")
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Select Booking Section
    
    private var selectBookingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Ticket to Sell")
                .font(.headline)
                .fontWeight(.semibold)
            
            if ticketViewModel.bookedTickets.isEmpty {
                emptyTicketsView
            } else {
                bookingsList
            }
        }
    }
    
    private var emptyTicketsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No tickets available")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Book a flight first to sell your tickets")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.adaptiveInputBackground)
        .cornerRadius(12)
    }
    
    private var bookingsList: some View {
        VStack(spacing: 12) {
            ForEach(ticketViewModel.bookedTickets) { booking in
                Button {
                    selectedBooking = booking
                    // Set initial price to 80% of original
                    let suggested = booking.totalPrice * 0.8
                    newPrice = String(format: "%.2f", suggested)
                } label: {
                    BookingSelectCard(
                        booking: booking,
                        isSelected: selectedBooking?.id == booking.id
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Selected Booking Preview
    
    private func selectedBookingPreview(booking: Booking) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Ticket")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                HStack {
                    Text(booking.flight.outbound.firstSegment.departure.iataCode)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.purple)
                    
                    Text(booking.flight.outbound.lastSegment.arrival.iataCode)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Original Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f €", booking.totalPrice))
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                }
                
                HStack {
                    Text("Ref: \(booking.bookingReference)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatDate(booking.flight.outbound.firstSegment.departure.at))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green, lineWidth: 2)
            )
        }
    }
    
    // MARK: - Price Section
    
    private func priceSection(booking: Booking) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Set New Price")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Price input
                HStack {
                    Image(systemName: "eurosign.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    TextField("Enter new price", text: $newPrice)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("EUR")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.adaptiveInputBackground)
                .cornerRadius(12)
                
                // Price comparison
                if let price = Double(newPrice), price > 0 {
                    priceComparison(original: booking.totalPrice, new: price)
                }
            }
        }
    }
    
    private func priceComparison(original: Double, new: Double) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Original Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f €", original))
                        .font(.headline)
                        .strikethrough()
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.purple)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Your Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f €", new))
                        .font(.headline)
                        .foregroundColor(new < original ? .green : .red)
                }
            }
            
            if new < original {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Savings: \(String(format: "%.2f €", original - new)) (\(Int(((original - new) / original) * 100))%)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    
                    Text("Price must be lower than original!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.adaptiveSecondaryBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Reason Section
    
    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reason for Selling")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(SellReason.allCases, id: \.self) { reason in
                    Button {
                        selectedReason = reason
                    } label: {
                        ReasonCard(
                            reason: reason,
                            isSelected: selectedReason == reason
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Create Button
    
    private func createButton(booking: Booking) -> some View {
        Button(action: {
            Task {
                await createOffer(booking: booking)
            }
        }) {
            HStack {
                if isCreating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
                
                Text(isCreating ? "Creating..." : "Create Offer")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(canCreate ? Color.purple : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!canCreate || isCreating)
    }
    
    // MARK: - Helper Properties
    
    private var canCreate: Bool {
        guard let booking = selectedBooking,
              let price = Double(newPrice),
              price > 0,
              price < booking.totalPrice else {
            return false
        }
        return true
    }
    
    // MARK: - Helper Functions
    
    private func createOffer(booking: Booking) async {
        guard let userId = authViewModel.currentUser?.id,
              let userName = authViewModel.currentUser?.fullname,
              let price = Double(newPrice) else {
            return
        }
        
        isCreating = true
        
        do {
            try await viewModel.createOffer(
                from: booking,
                userId: userId,
                userName: userName,
                newPrice: price,
                reason: selectedReason
            )
            
            dismiss()
        } catch {
            print("Failed to create offer: \(error)")
        }
        
        isCreating = false
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else {
            return isoString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        return outputFormatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

struct BookingSelectCard: View {
    let booking: Booking
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(booking.flight.outbound.firstSegment.departure.iataCode) → \(booking.flight.outbound.lastSegment.arrival.iataCode)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Ref: \(booking.bookingReference)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.2f €", booking.totalPrice))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(isSelected ? Color.green.opacity(0.1) : Color.adaptiveInputBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

struct ReasonCard: View {
    let reason: SellReason
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reason.icon)
                .font(.title3)
                .foregroundColor(colorForReason(reason.color))
            
            Text(reason.rawValue)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(isSelected ? Color.purple.opacity(0.1) : Color.adaptiveInputBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
        )
    }
    
    private func colorForReason(_ colorString: String) -> Color {
        switch colorString {
        case "red": return .red
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "gray": return .gray
        default: return .gray
        }
    }
}
