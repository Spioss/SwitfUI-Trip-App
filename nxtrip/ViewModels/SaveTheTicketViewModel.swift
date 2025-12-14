//
//  SaveTheTicketViewModel.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@MainActor
class SaveTheTicketViewModel: ObservableObject {
    @Published var offers: [TicketOffer] = []
    @Published var myOffers: [TicketOffer] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    // MARK: - Fetch All Active Offers
    
    func fetchAllOffers() async {
        isLoading = true
        errorMessage = ""
        
        print("🔍 Fetching all ticket offers...")
        
        do {
            let querySnapshot = try await db.collection("ticketOffers")
                .whereField("isActive", isEqualTo: true)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            print("📦 Found \(querySnapshot.documents.count) offers")
            
            var fetchedOffers: [TicketOffer] = []
            
            for document in querySnapshot.documents {
                do {
                    let offer = try document.data(as: TicketOffer.self)
                    fetchedOffers.append(offer)
                    print("✅ Decoded offer: \(offer.route) - \(offer.formattedCurrentPrice)")
                } catch {
                    print("❌ Error decoding offer \(document.documentID): \(error)")
                }
            }
            
            self.offers = fetchedOffers
            print("📊 Total offers loaded: \(fetchedOffers.count)")
            
        } catch {
            errorMessage = "Failed to fetch offers: \(error.localizedDescription)"
            print("❌ Fetch error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch My Offers
    
    func fetchMyOffers(userId: String) async {
        print("🔍 Fetching offers for user: \(userId)")
        
        do {
            let querySnapshot = try await db.collection("ticketOffers")
                .whereField("sellerId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            var fetchedOffers: [TicketOffer] = []
            
            for document in querySnapshot.documents {
                do {
                    let offer = try document.data(as: TicketOffer.self)
                    fetchedOffers.append(offer)
                } catch {
                    print("❌ Error decoding my offer: \(error)")
                }
            }
            
            self.myOffers = fetchedOffers
            print("📊 My offers loaded: \(fetchedOffers.count)")
            
        } catch {
            print("❌ Error fetching my offers: \(error)")
        }
    }
    
    // MARK: - Create New Offer
    
    func createOffer(
        from booking: Booking,
        userId: String,
        userName: String,
        newPrice: Double,
        reason: SellReason
    ) async throws {
        
        guard newPrice < booking.totalPrice && newPrice > 0 else {
            throw NSError(domain: "SaveTheTicket", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "New price must be lower than original and greater than 0"
            ])
        }
        
        isLoading = true
        errorMessage = ""
        
        let discountPercent = Int(((booking.totalPrice - newPrice) / booking.totalPrice) * 100)
        
        let formattedDate = formatDateForOffer(booking.flight.outbound.firstSegment.departure.at)
        print("📅 Formatted date: \(formattedDate)")
        
        let offer = TicketOffer(
            id: nil,
            sellerId: userId,
            sellerName: userName,
            bookingRef: booking.bookingReference,
            fromCode: booking.flight.outbound.firstSegment.departure.iataCode,
            fromCity: getCityName(booking.flight.outbound.firstSegment.departure.iataCode),
            toCode: booking.flight.outbound.lastSegment.arrival.iataCode,
            toCity: getCityName(booking.flight.outbound.lastSegment.arrival.iataCode),
            date: formattedDate,
            departureTime: formatTimeForOffer(booking.flight.outbound.firstSegment.departure.at),
            airline: getAirlineName(booking.flight.outbound.firstSegment.carrierCode),
            flightNumber: booking.flight.outbound.firstSegment.number,
            seat: booking.travelClass.rawValue,
            isInternational: false,
            priceOriginal: booking.totalPrice,
            priceCurrent: newPrice,
            discountPercent: discountPercent,
            reason: reason.rawValue,
            timeAgo: "Just now",
            createdAt: Date(),
            isActive: true,
            originalBookingId: booking.id
        )
        
        do {
            let docRef = db.collection("ticketOffers").document()
            try docRef.setData(from: offer)
            
            print("✅ Offer created successfully: \(offer.route) on \(offer.date)")
            
            // Refresh offers
            await fetchAllOffers()
            
        } catch {
            errorMessage = "Failed to create offer: \(error.localizedDescription)"
            print("❌ Create offer error: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Delete Offer
    
    func deleteOffer(_ offerId: String) async {
        do {
            try await db.collection("ticketOffers").document(offerId).delete()
            
            // Remove from local arrays
            offers.removeAll { $0.id == offerId }
            myOffers.removeAll { $0.id == offerId }
            
            print("Offer deleted: \(offerId)")
            
        } catch {
            errorMessage = "Failed to delete offer: \(error.localizedDescription)"
            print("Delete error: \(error)")
        }
    }
    
    // MARK: - Deactivate Offer
    
    func deactivateOffer(_ offerId: String) async {
        do {
            try await db.collection("ticketOffers").document(offerId).updateData([
                "isActive": false
            ])
            
            // Remove from active offers
            offers.removeAll { $0.id == offerId }
            
            // Update in myOffers
            if let index = myOffers.firstIndex(where: { $0.id == offerId }) {
                let updatedOffer = myOffers[index]
                myOffers[index] = TicketOffer(
                    id: updatedOffer.id,
                    sellerId: updatedOffer.sellerId,
                    sellerName: updatedOffer.sellerName,
                    bookingRef: updatedOffer.bookingRef,
                    fromCode: updatedOffer.fromCode,
                    fromCity: updatedOffer.fromCity,
                    toCode: updatedOffer.toCode,
                    toCity: updatedOffer.toCity,
                    date: updatedOffer.date,
                    departureTime: updatedOffer.departureTime,
                    airline: updatedOffer.airline,
                    flightNumber: updatedOffer.flightNumber,
                    seat: updatedOffer.seat,
                    isInternational: updatedOffer.isInternational,
                    priceOriginal: updatedOffer.priceOriginal,
                    priceCurrent: updatedOffer.priceCurrent,
                    discountPercent: updatedOffer.discountPercent,
                    reason: updatedOffer.reason,
                    timeAgo: updatedOffer.timeAgo,
                    createdAt: updatedOffer.createdAt,
                    isActive: false,
                    originalBookingId: updatedOffer.originalBookingId
                )
            }
            
            print("Offer deactivated: \(offerId)")
            
        } catch {
            errorMessage = "Failed to deactivate offer: \(error.localizedDescription)"
            print("Deactivate error: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    
    // date formatting method
    private func formatDateForOffer(_ isoString: String) -> String {
        // Input format: "2025-12-17T10:30:00" (without timezone)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: isoString) else {
            print("⚠️ Failed to parse date: \(isoString)")
            return isoString
        }
        
        // Output format: "Dec 17, 2025"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        let formatted = outputFormatter.string(from: date)
        print("📅 Date formatting: \(isoString) -> \(formatted)")
        
        return formatted
    }
    
    private func formatTimeForOffer(_ isoString: String) -> String {
        // Input format: "2025-12-17T10:30:00"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: isoString) else {
            print("⚠️ Failed to parse time: \(isoString)")
            // Fallback: try to extract time with regex
            if let timeMatch = isoString.range(of: #"T(\d{2}:\d{2})"#, options: .regularExpression) {
                let timeString = String(isoString[timeMatch]).replacingOccurrences(of: "T", with: "")
                print("📅 Time extracted via regex: \(timeString)")
                return timeString
            }
            return isoString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formatted = outputFormatter.string(from: date)
        print("⏰ Time formatting: \(isoString) -> \(formatted)")
        
        return formatted
    }
    
    private func getCityName(_ iataCode: String) -> String {
        let cities = [
            "VIE": "Vienna",
            "BCN": "Barcelona",
            "BTS": "Bratislava",
            "PRG": "Prague",
            "LHR": "London",
            "CDG": "Paris",
            "BER": "Berlin",
            "MUC": "Munich",
            "FRA": "Frankfurt",
            "AMS": "Amsterdam",
            "FCO": "Rome",
            "MAD": "Madrid",
            "LIS": "Lisbon",
            "DUB": "Dublin",
            "CPH": "Copenhagen",
            "OSL": "Oslo",
            "STO": "Stockholm",
            "WAW": "Warsaw",
            "BUD": "Budapest"
        ]
        return cities[iataCode] ?? iataCode
    }
    
    private func getAirlineName(_ code: String) -> String {
        let airlines = [
            "VY": "Vueling",
            "FR": "Ryanair",
            "BA": "British Airways",
            "LH": "Lufthansa",
            "DY": "Norwegian",
            "U2": "easyJet",
            "W6": "Wizz Air",
            "OS": "Austrian Airlines",
            "KL": "KLM",
            "AF": "Air France",
            "IB": "Iberia",
            "TP": "TAP Portugal"
        ]
        return airlines[code] ?? code
    }
}
