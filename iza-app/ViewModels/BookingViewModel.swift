//
//  BookingViewModel.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

import Foundation
import Firebase
import FirebaseFirestore

@MainActor
class BookingViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var bookingSuccess = false
    @Published var currentBooking: BookedTicket?
    
    // Form fields
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var dateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    
    // Payment fields
    @Published var cardNumber = ""
    @Published var expiryDate = ""
    @Published var cvv = ""
    @Published var cardHolderName = ""
    @Published var selectedCardType: CardType = .visa
    
    private let db = Firestore.firestore()
    
    // MARK: - Booking Function
    
    func bookFlight(_ flight: SimpleFlight, userId: String) async {
        guard formIsValid else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let bookingReference = generateBookingReference()
            
            let passengerInfo = PassengerInfo(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone,
                dateOfBirth: dateOfBirth
            )
            
            let paymentInfo = PaymentInfo(
                cardNumber: String(cardNumber.suffix(4)),
                cardType: selectedCardType,
                cardHolderName: cardHolderName,
                amount: Double(flight.totalPrice) ?? 0.0,
                currency: flight.currency,
                paymentDate: Date()
            )
            
            let bookedTicket = BookedTicket(
                id: UUID().uuidString,
                userId: userId,
                bookingReference: bookingReference,
                flight: flight,
                passengerInfo: passengerInfo,
                paymentInfo: paymentInfo,
                bookingDate: Date()
            )
            
            // Save to Firestore
            let encodedTicket = try Firestore.Encoder().encode(bookedTicket)
            try await db.collection("bookings").document(bookedTicket.id).setData(encodedTicket)
            
            // Update local state
            currentBooking = bookedTicket
            bookingSuccess = true
            clearForm()
            
        } catch {
            errorMessage = "Booking failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Functions
    
    private func generateBookingReference() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        
        var reference = ""
        
        // Add 2 letters + 4 numbers
        for _ in 0..<2 {
            reference += String(letters.randomElement()!)
        }
        for _ in 0..<4 {
            reference += String(numbers.randomElement()!)
        }
        
        return reference
    }
    
    private func clearForm() {
        firstName = ""
        lastName = ""
        email = ""
        phone = ""
        cardNumber = ""
        expiryDate = ""
        cvv = ""
        cardHolderName = ""
    }
    
    var formIsValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        !phone.isEmpty &&
        !cardNumber.isEmpty &&
        cardNumber.replacingOccurrences(of: " ", with: "").count >= 16 &&
        !expiryDate.isEmpty &&
        !cvv.isEmpty &&
        !cardHolderName.isEmpty
    }
    
    // Auto-fill user data
    func prefillUserData(fullname: String, email: String) {
        let nameParts = fullname.split(separator: " ")
        if nameParts.count >= 2 {
            firstName = String(nameParts[0])
            lastName = nameParts.dropFirst().joined(separator: " ")
        } else if nameParts.count == 1 {
            firstName = String(nameParts[0])
        }
        
        self.email = email
    }
    
    // MARK: - Card Formatting
    
    func formatCardNumber(_ number: String) -> String {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        var formatted = ""
        
        for (index, character) in cleanNumber.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted += String(character)
        }
        
        return formatted
    }
    
    func formatExpiryDate(_ date: String) -> String {
        let cleanDate = date.replacingOccurrences(of: "/", with: "")
        if cleanDate.count >= 2 {
            let month = String(cleanDate.prefix(2))
            let year = String(cleanDate.dropFirst(2))
            return year.isEmpty ? month : "\(month)/\(year)"
        }
        return cleanDate
    }
    
    func detectCardType(_ number: String) -> CardType {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        
        if cleanNumber.hasPrefix("4") {
            return .visa
        } else if cleanNumber.hasPrefix("5") || cleanNumber.hasPrefix("2") {
            return .mastercard
        } else if cleanNumber.hasPrefix("34") || cleanNumber.hasPrefix("37") {
            return .amex
        }
        
        return .other
    }
}
