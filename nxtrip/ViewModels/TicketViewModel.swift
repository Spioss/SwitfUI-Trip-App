//
//  TicketViewModel.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@MainActor
class TicketViewModel: ObservableObject {
    @Published var bookedTickets: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    // MARK: - Fetch User's Tickets
    
    func fetchUserTickets(userId: String) async {
        isLoading = true
        errorMessage = ""
        
        do {
            let querySnapshot = try await db.collection("bookings")
                .whereField("userId", isEqualTo: userId)
                .order(by: "bookingDate", descending: true)
                .getDocuments()
            
            var tickets: [Booking] = []
            
            for document in querySnapshot.documents {
                do {
                    let ticket = try document.data(as: Booking.self)
                    tickets.append(ticket)
                } catch {
                    print("DEBUG: Error decoding ticket \(document.documentID): \(error)")
                    print("DEBUG: Document data: \(document.data())")
                }
            }
            
            self.bookedTickets = tickets
            print("DEBUG: Successfully loaded \(tickets.count) tickets")
            
        } catch {
            errorMessage = "Failed to fetch tickets: \(error.localizedDescription)"
            print("DEBUG: Fetch error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Functions
    
    func formatFlightDate(_ isoString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let date = inputFormatter.date(from: isoString) else {
            return isoString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        return outputFormatter.string(from: date)
    }
    
    func formatTime(_ isoString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.timeZone = TimeZone(identifier: "UTC")
    
        guard let date = inputFormatter.date(from: isoString) else {
            if let timeMatch = isoString.range(of: #"T(\d{2}:\d{2})"#, options: .regularExpression) {
                let timeString = String(isoString[timeMatch]).replacingOccurrences(of: "T", with: "")
                return timeString
            }
            return isoString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.current
        
        return outputFormatter.string(from: date)
    }
    
    func isUpcoming(_ isoString: String) -> Bool {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let flightDate = inputFormatter.date(from: isoString) else {
            return false
        }
        
        return flightDate > Date()
    }
    
    func getFlightStatus(_ isoString: String) -> FlightStatus {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let flightDate = inputFormatter.date(from: isoString) else {
            return .unknown
        }
        
        let now = Date()
        let hoursUntilFlight = flightDate.timeIntervalSince(now) / 3600
        
        if hoursUntilFlight > 24 {
            return .upcoming
        } else if hoursUntilFlight > 0 {
            return .soon
        } else {
            return .completed
        }
    }
}

// MARK: - Flight Status Enum
enum FlightStatus {
    case upcoming
    case soon
    case completed
    case unknown
    
    var color: Color {
        switch self {
        case .upcoming:
            return .blue
        case .soon:
            return .orange
        case .completed:
            return .green
        case .unknown:
            return .gray
        }
    }
    
    var text: String {
        switch self {
        case .upcoming:
            return "Upcoming"
        case .soon:
            return "Check-in Open"
        case .completed:
            return "Completed"
        case .unknown:
            return "Unknown"
        }
    }
    
    var icon: String {
        switch self {
        case .upcoming:
            return "clock"
        case .soon:
            return "exclamationmark.triangle"
        case .completed:
            return "checkmark.circle"
        case .unknown:
            return "questionmark.circle"
        }
    }
}
