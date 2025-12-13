//
//  BookingView.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

import SwiftUI

struct BookingView: View {
    let flight: SimpleFlight
    @StateObject private var bookingViewModel = BookingViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var flightViewModel: FlightViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var hasConfirmedDetails = false
    @State private var showSuccessView = false
    @State private var currentStep = 0
    
    private let steps = ["Flight", "Passenger", "Payment", "Review"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressIndicator
                
                // Content based on current step
                ScrollView {
                    VStack(spacing: 24) {
                        switch currentStep {
                        case 0:
                            flightSummarySection
                        case 1:
                            passengerInfoSection
                        case 2:
                            paymentInfoSection
                        case 3:
                            reviewSection
                        default:
                            flightSummarySection
                        }
                        
                        // Error message
                        if !bookingViewModel.errorMessage.isEmpty {
                            Text(bookingViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .transition(.opacity)
                        }
                    }
                    .padding()
                }
                
                // Navigation buttons
                navigationButtons
            }
            .navigationTitle("Book Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSuccessView) {
                BookingSuccessView(
                    ticket: bookingViewModel.currentBooking,
                    onDismiss: {
                        dismiss()
                    }
                )
            }
            .onChange(of: bookingViewModel.bookingSuccess) { _, success in
                if success {
                    showSuccessView = true
                }
            }
            .onAppear {
                prefillUserData()
            }
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(0..<steps.count, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(index <= currentStep ? Color.purple : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                        
                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(index < currentStep ? Color.purple : Color.gray.opacity(0.3))
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Text(steps[currentStep])
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
        }
        .padding(.vertical)
        .background(Color.adaptiveSecondaryBackground)
    }
    
    // MARK: - Flight Summary Section (Step 0)
    private var flightSummarySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Flight Details")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Review your selected flight")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                // Outbound
                FlightSummary(
                    title: "Outbound Flight",
                    from: flight.outbound.firstSegment.departure.iataCode,
                    to: flight.outbound.lastSegment.arrival.iataCode,
                    departureTime: flightViewModel.formatTime(flight.outbound.firstSegment.departure.at),
                    arrivalTime: flightViewModel.formatTime(flight.outbound.lastSegment.arrival.at),
                    duration: flightViewModel.formatDuration(flight.outbound.duration),
                    date: formatFlightDate(flight.outbound.firstSegment.departure.at),
                    stops: flight.outbound.numberOfStops
                )
                
                // Return flight if exists
                if let returnFlight = flight.inbound {
                    FlightSummary(
                        title: "Return Flight",
                        from: returnFlight.firstSegment.departure.iataCode,
                        to: returnFlight.lastSegment.arrival.iataCode,
                        departureTime: flightViewModel.formatTime(returnFlight.firstSegment.departure.at),
                        arrivalTime: flightViewModel.formatTime(returnFlight.lastSegment.arrival.at),
                        duration: flightViewModel.formatDuration(returnFlight.duration),
                        date: formatFlightDate(returnFlight.firstSegment.departure.at),
                        stops: returnFlight.numberOfStops
                    )
                }
            }
            
            // Price summary
            VStack(spacing: 8) {
                HStack {
                    Text("Total Price")
                        .font(.headline)
                    Spacer()
                    Text(flightViewModel.formatPrice(flight.totalPrice, currency: flight.currency))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .background(Color.adaptiveSecondaryBackground)
            .cornerRadius(12)
            
            //checkbox
            VStack(spacing: 12) {
                Divider()
                
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            hasConfirmedDetails.toggle()
                        }
                    }) {
                        Image(systemName: hasConfirmedDetails ? "checkmark.square.fill" : "square")
                            .font(.title2)
                            .foregroundColor(hasConfirmedDetails ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("I confirm that all flight details are correct")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("Please review departure times, dates, and airports carefully")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(hasConfirmedDetails ? Color.green.opacity(0.1) : Color.adaptiveInputBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(hasConfirmedDetails ? Color.green : Color.adaptiveBorder, lineWidth: hasConfirmedDetails ? 2 : 0.5)
                )
            }
            
        }
    }
    
    // MARK: - Passenger Info Section (Step 1)
    
    private var passengerInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Passenger Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter passenger details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    IconTextField(
                        text: $bookingViewModel.firstName,
                        systemImageName: "person.fill",
                        placeholder: "First Name"
                    )
                    
                    IconTextField(
                        text: $bookingViewModel.lastName,
                        systemImageName: "person.fill",
                        placeholder: "Last Name"
                    )
                }
                
                IconTextField(
                    text: $bookingViewModel.email,
                    systemImageName: "envelope.fill",
                    placeholder: "Email Address"
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                IconTextField(
                    text: $bookingViewModel.phone,
                    systemImageName: "phone.fill",
                    placeholder: "Phone Number"
                )
                .keyboardType(.phonePad)
                
                HStack() {
                    Text("Date of Birth")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    DatePicker("", selection: $bookingViewModel.dateOfBirth, in: ...Calendar.current.date(byAdding: .year, value: -12, to: Date())!, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.adaptiveSecondaryBackground)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Payment Info Section (Step 2)
    
    private var paymentInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Payment Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your payment is secure")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                IconTextField(
                    text: $bookingViewModel.cardHolderName,
                    systemImageName: "person.text.rectangle",
                    placeholder: "Cardholder Name"
                )
                .autocapitalization(.words)
                
                HStack {
                    Image(systemName: bookingViewModel.selectedCardType.icon)
                        .foregroundColor(.secondary)
                        .frame(width: 16)
                    
                    TextField("Card Number", text: $bookingViewModel.cardNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: bookingViewModel.cardNumber) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count <= 16 {
                                bookingViewModel.cardNumber = bookingViewModel.formatCardNumber(filtered)
                                bookingViewModel.selectedCardType = bookingViewModel.detectCardType(filtered)
                            }
                        }
                }
                .padding(.vertical, 12)
                .padding(.leading, 16)
                .frame(height: 50)
                .background(Color.adaptiveInputBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.adaptiveBorder, lineWidth: 0.5)
                )
                
                HStack(spacing: 12) {
                    IconTextField(
                        text: $bookingViewModel.expiryDate,
                        systemImageName: "calendar",
                        placeholder: "MM/YY"
                    )
                    .keyboardType(.numberPad)
                    .onChange(of: bookingViewModel.expiryDate) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count != 4 {
                            bookingViewModel.expiryDate = bookingViewModel.formatExpiryDate(filtered)
                        }
                    }
                    
                    IconSecureField(
                        text: $bookingViewModel.cvv,
                        systemImageName: "lock.fill",
                        placeholder: "CVV"
                    )
                    .keyboardType(.numberPad)
                    .onChange(of: bookingViewModel.cvv) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count != 4 {
                            bookingViewModel.cvv = filtered
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Review Section (Step 3)
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Review & Confirm")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Review all details before booking")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                // Flight summary
                ReviewCard(title: "Flight") {
                    HStack {
                        Text("\(flight.outbound.firstSegment.departure.iataCode) → \(flight.outbound.lastSegment.arrival.iataCode)")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text(formatFlightDate(flight.outbound.firstSegment.departure.at))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let returnFlight = flight.inbound {
                        HStack {
                            Text("\(returnFlight.firstSegment.departure.iataCode) → \(returnFlight.lastSegment.arrival.iataCode)")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text(formatFlightDate(returnFlight.firstSegment.departure.at))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Passenger summary
                ReviewCard(title: "Passenger") {
                    HStack{
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(bookingViewModel.firstName) \(bookingViewModel.lastName)")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(bookingViewModel.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                
                // Payment summary
                ReviewCard(title: "Payment") {
                    HStack {
                        Text(bookingViewModel.selectedCardType.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("****\(bookingViewModel.cardNumber.suffix(4))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Total price
                VStack(spacing: 8) {
                    HStack {
                        Text("Total Amount")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text(flightViewModel.formatPrice(flight.totalPrice, currency: flight.currency))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        VStack(spacing: 12) {
            if currentStep < 3 {
                // Next button
                Button("Continue") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(canProceed ? Color.purple : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(!canProceed)
                .fontWeight(.semibold)
            } else {
                // Book button
                Button(action: {
                    guard let userId = authViewModel.currentUser?.id else { return }
                    Task {
                        await bookingViewModel.bookFlight(flight, userId: userId)
                    }
                }) {
                    HStack {
                        if bookingViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "creditcard.fill")
                        }
                        
                        Text(bookingViewModel.isLoading ? "Processing..." : "Confirm Booking")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(bookingViewModel.formIsValid ? Color.purple : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(!bookingViewModel.formIsValid || bookingViewModel.isLoading)
            }
            
            // Back button
            if currentStep > 0 {
                Button("Back") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.adaptiveSecondaryBackground)
                .foregroundColor(Color.adaptivePrimaryText)
                .cornerRadius(12)
                .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color.adaptiveBackground)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
    }
    
    // MARK: - Helper Properties
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return hasConfirmedDetails
        case 1:
            return !bookingViewModel.firstName.isEmpty &&
                   !bookingViewModel.lastName.isEmpty &&
                   !bookingViewModel.email.isEmpty &&
                   bookingViewModel.email.contains("@") &&
                   !bookingViewModel.phone.isEmpty
        case 2:
            return !bookingViewModel.cardNumber.isEmpty &&
                   bookingViewModel.cardNumber.replacingOccurrences(of: " ", with: "").count == 16 &&
                   !bookingViewModel.expiryDate.isEmpty &&
                   !bookingViewModel.cvv.isEmpty &&
                   !bookingViewModel.cardHolderName.isEmpty
        default:
            return true
        }
    }
    
    // MARK: - Helper Functions
    
    private func prefillUserData() {
        guard let user = authViewModel.currentUser else { return }
        bookingViewModel.prefillUserData(
            fullname: user.fullname,
            email: user.email,
            phone: user.phone,
            defaultCard: user.defaultCard
        )
    }
    
    private func formatFlightDate(_ isoString: String) -> String {
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

