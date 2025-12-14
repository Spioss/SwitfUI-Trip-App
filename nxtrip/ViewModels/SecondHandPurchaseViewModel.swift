//
//  SecondHandPurchaseViewModel.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

import Foundation
import Firebase
import FirebaseFirestore

@MainActor
class SecondHandPurchaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var purchaseSuccess = false
    @Published var currentPurchase: Booking?
    
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
    
    // MARK: - Purchase from Second Hand
    
    func purchaseFromSecondHand(
        offer: TicketOffer,
        originalBookingId: String,
        buyerId: String
    ) async {
        guard formIsValid else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            // 1. Get original booking
            let originalBookingDoc = try await db.collection("bookings").document(originalBookingId).getDocument()
            guard let originalBooking = try? originalBookingDoc.data(as: Booking.self) else {
                throw NSError(domain: "Purchase", code: 1, userInfo: [NSLocalizedDescriptionKey: "Original booking not found"])
            }
            
            // 2. Generate new booking reference
            let newBookingReference = generateBookingReference()
            
            // 3. Create passenger info
            let passengerInfo = PassengerInfo(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone,
                dateOfBirth: dateOfBirth
            )
            
            // ✅ Extract real last 4 digits from card number (remove spaces and asterisks)
            let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "*", with: "")
            let last4 = String(cleanCardNumber.suffix(4))
            
            // 4. Create payment info with NEW price (from offer)
            let paymentInfo = PaymentInfo(
                amount: offer.priceCurrent,
                cardHolderName: cardHolderName,
                cardNumber: last4,
                cardType: selectedCardType.rawValue,
                currency: "EUR",
                paymentDate: Date()
            )
            
            // 5. Create new booking with SAME flight but NEW owner
            let newBooking = Booking(
                id: nil,
                userId: buyerId,
                bookingReference: newBookingReference,
                bookingDate: Date(),
                flight: originalBooking.flight,
                passengerInfo: passengerInfo,
                paymentInfo: paymentInfo,
                status: "confirmed",
                numberOfTickets: originalBooking.numberOfTickets,
                travelClass: originalBooking.travelClass
            )
            
            // 6. Save new booking to Firestore
            let docRef = db.collection("bookings").document()
            let encodedBooking = try Firestore.Encoder().encode(newBooking)
            try await docRef.setData(encodedBooking)
            
            // 7. Load saved booking
            let savedSnapshot = try await docRef.getDocument()
            self.currentPurchase = try savedSnapshot.data(as: Booking.self)
            
            // 8. Mark offer as sold (deactivate)
            if let offerId = offer.id {
                try await db.collection("ticketOffers").document(offerId).updateData([
                    "isActive": false
                ])
            }
            
            // 9. Optionally: Mark original booking as "transferred"
            try await db.collection("bookings").document(originalBookingId).updateData([
                "status": "transferred",
                "transferredTo": buyerId,
                "transferredAt": Timestamp(date: Date())
            ])
            
            purchaseSuccess = true
            clearForm()
            
            print("✅ Second-hand purchase successful!")
            print("📝 New booking ref: \(newBookingReference)")
            print("💰 Price paid: \(offer.priceCurrent) EUR")
            
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("❌ Purchase error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Functions
    
    private func generateBookingReference() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        
        var reference = ""
        
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
        cardNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "*", with: "").count >= 4 &&
        !expiryDate.isEmpty &&
        !cvv.isEmpty &&
        !cardHolderName.isEmpty
    }
    
    // ✅ UPDATED: Auto-fill user data with complete card details (except CVV)
    func prefillUserData(fullname: String, email: String, phone: String = "", defaultCard: SavedCreditCard? = nil) {
        if firstName.isEmpty {
            let nameParts = fullname.split(separator: " ")
            if nameParts.count >= 2 {
                firstName = String(nameParts[0])
                lastName = nameParts.dropFirst().joined(separator: " ")
            } else if nameParts.count == 1 {
                firstName = String(nameParts[0])
            }
        }
        
        if self.email.isEmpty {
            self.email = email
        }
        
        if self.phone.isEmpty && !phone.isEmpty {
            self.phone = phone
        }
        
        // ✅ NEW: Auto-fill complete card details (except CVV for security)
        if let card = defaultCard {
            if cardHolderName.isEmpty {
                cardHolderName = card.cardHolderName
            }
            if cardNumber.isEmpty {
                // Fill masked card number with last 4 digits
                cardNumber = "**** **** **** \(card.last4Digits)"
                selectedCardType = card.cardType
            }
            if expiryDate.isEmpty {
                expiryDate = card.expiryDate
            }
            // ⚠️ CVV is intentionally NOT pre-filled for security reasons
            // User must always enter CVV manually
        }
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
