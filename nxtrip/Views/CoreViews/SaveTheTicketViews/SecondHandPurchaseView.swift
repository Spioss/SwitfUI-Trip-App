//
//  SecondHandPurchaseView.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

import SwiftUI

struct SecondHandPurchaseView: View {
    let offer: TicketOffer
    let originalBookingId: String
    
    @StateObject private var purchaseViewModel = SecondHandPurchaseViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var showSuccessView = false
    
    private let steps = ["Offer", "Passenger", "Payment", "Review"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressIndicator
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch currentStep {
                        case 0:
                            offerSummarySection
                        case 1:
                            passengerInfoSection
                        case 2:
                            paymentInfoSection
                        case 3:
                            reviewSection
                        default:
                            offerSummarySection
                        }
                        
                        if !purchaseViewModel.errorMessage.isEmpty {
                            Text(purchaseViewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .transition(.opacity)
                        }
                    }
                    .padding()
                }
                
                navigationButtons
            }
            .navigationTitle("Buy Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSuccessView) {
                SecondHandSuccessView(
                    booking: purchaseViewModel.currentPurchase,
                    offer: offer,
                    onDismiss: {
                        dismiss()
                    }
                )
            }
            .onChange(of: purchaseViewModel.purchaseSuccess) { _, success in
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
                            .fill(index <= currentStep ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                        
                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(index < currentStep ? Color.green : Color.gray.opacity(0.3))
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Text(steps[currentStep])
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(.vertical)
        .background(Color.adaptiveSecondaryBackground)
    }
    
    // MARK: - Offer Summary Section
    
    private var offerSummarySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Second-Hand Offer")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Review the offer details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Offer card
            VStack(spacing: 16) {
                // Route
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text(offer.fromCode)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.green)
                        Text(offer.fromCity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "airplane")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(offer.toCode)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.green)
                        Text(offer.toCity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Flight details
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(offer.date)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Departure")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(offer.departureTime)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Airline")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(offer.fullFlightInfo)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Class")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(offer.seat)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color.adaptiveSecondaryBackground)
                .cornerRadius(12)
            }
            .padding()
            .background(Color.adaptiveInputBackground)
            .cornerRadius(16)
            
            // Price comparison
            priceComparisonCard
            
            // Seller info
            VStack(alignment: .leading, spacing: 12) {
                Text("Seller Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack {
                    Text(getInitials(from: offer.sellerName))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.green)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(offer.sellerName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Posted \(offer.timeAgo)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.adaptiveSecondaryBackground)
                .cornerRadius(12)
            }
        }
    }
    
    private var priceComparisonCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Price Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Original Price")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(offer.formattedOriginalPrice)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .strikethrough()
                }
                
                HStack {
                    Text("You Save")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(offer.formattedSavings + " (\(offer.discountPercent)%)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                Divider()
                
                HStack {
                    Text("Total to Pay")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text(offer.formattedCurrentPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Passenger Info Section
    
    private var passengerInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your passenger details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    IconTextField(
                        text: $purchaseViewModel.firstName,
                        systemImageName: "person.fill",
                        placeholder: "First Name"
                    )
                    
                    IconTextField(
                        text: $purchaseViewModel.lastName,
                        systemImageName: "person.fill",
                        placeholder: "Last Name"
                    )
                }
                
                IconTextField(
                    text: $purchaseViewModel.email,
                    systemImageName: "envelope.fill",
                    placeholder: "Email Address"
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                IconTextField(
                    text: $purchaseViewModel.phone,
                    systemImageName: "phone.fill",
                    placeholder: "Phone Number"
                )
                .keyboardType(.phonePad)
                
                HStack {
                    Text("Date of Birth")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    DatePicker("", selection: $purchaseViewModel.dateOfBirth, in: ...Calendar.current.date(byAdding: .year, value: -12, to: Date())!, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.adaptiveSecondaryBackground)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Payment Info Section
    
    private var paymentInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Payment Method")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your payment is secure")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                IconTextField(
                    text: $purchaseViewModel.cardHolderName,
                    systemImageName: "person.text.rectangle",
                    placeholder: "Cardholder Name"
                )
                .autocapitalization(.words)
                
                HStack {
                    Image(systemName: purchaseViewModel.selectedCardType.icon)
                        .foregroundColor(.secondary)
                        .frame(width: 16)
                    
                    TextField("Card Number", text: $purchaseViewModel.cardNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: purchaseViewModel.cardNumber) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count <= 16 {
                                purchaseViewModel.cardNumber = purchaseViewModel.formatCardNumber(filtered)
                                purchaseViewModel.selectedCardType = purchaseViewModel.detectCardType(filtered)
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
                        text: $purchaseViewModel.expiryDate,
                        systemImageName: "calendar",
                        placeholder: "MM/YY"
                    )
                    .keyboardType(.numberPad)
                    .onChange(of: purchaseViewModel.expiryDate) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count <= 4 {
                            purchaseViewModel.expiryDate = purchaseViewModel.formatExpiryDate(filtered)
                        }
                    }
                    
                    IconSecureField(
                        text: $purchaseViewModel.cvv,
                        systemImageName: "lock.fill",
                        placeholder: "CVV"
                    )
                    .keyboardType(.numberPad)
                    .onChange(of: purchaseViewModel.cvv) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count <= 4 {
                            purchaseViewModel.cvv = filtered
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Review Section
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Review & Confirm")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Review all details before purchase")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                // Flight summary
                ReviewCard(title: "Flight") {
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(offer.fromCode) → \(offer.toCode)")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text(offer.date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text(offer.fullFlightInfo)
                                .font(.subheadline)
                            Spacer()
                            Text(offer.departureTime)
                                .font(.subheadline)
                        }
                    }
                }
                
                // Passenger summary
                ReviewCard(title: "Passenger") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(purchaseViewModel.firstName) \(purchaseViewModel.lastName)")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(purchaseViewModel.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                
                // Payment summary
                ReviewCard(title: "Payment") {
                    HStack {
                        Text(purchaseViewModel.selectedCardType.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("****\(purchaseViewModel.cardNumber.suffix(4))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Total price
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Amount")
                                .font(.headline)
                            Text("Second-hand ticket")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(offer.formattedCurrentPrice)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        VStack(spacing: 12) {
            if currentStep < 3 {
                Button("Continue") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(canProceed ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(!canProceed)
                .fontWeight(.semibold)
            } else {
                Button(action: {
                    guard let userId = authViewModel.currentUser?.id else { return }
                    Task {
                        await purchaseViewModel.purchaseFromSecondHand(
                            offer: offer,
                            originalBookingId: originalBookingId,
                            buyerId: userId
                        )
                    }
                }) {
                    HStack {
                        if purchaseViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        
                        Text(purchaseViewModel.isLoading ? "Processing..." : "Confirm Purchase")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(purchaseViewModel.formIsValid ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(!purchaseViewModel.formIsValid || purchaseViewModel.isLoading)
            }
            
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
            return true
        case 1:
            return !purchaseViewModel.firstName.isEmpty &&
                   !purchaseViewModel.lastName.isEmpty &&
                   !purchaseViewModel.email.isEmpty &&
                   purchaseViewModel.email.contains("@") &&
                   !purchaseViewModel.phone.isEmpty
        case 2:
            return !purchaseViewModel.cardNumber.isEmpty &&
                   purchaseViewModel.cardNumber.replacingOccurrences(of: " ", with: "").count == 16 &&
                   !purchaseViewModel.expiryDate.isEmpty &&
                   !purchaseViewModel.cvv.isEmpty &&
                   !purchaseViewModel.cardHolderName.isEmpty
        default:
            return true
        }
    }
    
    // MARK: - Helper Functions
    
    private func prefillUserData() {
        guard let user = authViewModel.currentUser else { return }
        purchaseViewModel.prefillUserData(
            fullname: user.fullname,
            email: user.email,
            phone: user.phone,
            defaultCard: user.defaultCard
        )
    }
    
    private func getInitials(from fullName: String) -> String {
        let nameParts = fullName.split(separator: " ")
        let initials = nameParts.compactMap { $0.first }.map { String($0).uppercased() }
        return initials.joined()
    }
}

// MARK: - Success View

struct SecondHandSuccessView: View {
    let booking: Booking?
    let offer: TicketOffer
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)
                    
                    // Success animation
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Purchase Successful!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("Your second-hand ticket is confirmed")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Savings highlight
                    VStack(spacing: 12) {
                        Text("You Saved")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(offer.formattedSavings)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("\(offer.discountPercent)% off original price")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Booking reference
                    if let booking = booking {
                        VStack(spacing: 12) {
                            Text("Booking Reference")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(booking.bookingReference)
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(.green)
                                .padding()
                                .background(Color.adaptiveSecondaryBackground)
                                .cornerRadius(12)
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding()
            }
            .navigationTitle("Purchase Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
