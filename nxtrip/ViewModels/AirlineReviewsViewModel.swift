//
//  AirlineReviewsViewModel.swift
//  nxtrip
//
//  Created by Lukáš Mader on 11/01/2026.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@MainActor
class AirlineReviewsViewModel: ObservableObject {
    @Published var reviews: [AirlineReview] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    // Load all reviews for a given airline
    func loadReviews(for airline: Airline) async {
        isLoading = true
        errorMessage = ""
        
        do {
            let snapshot = try await db.collection("reviews")
                .whereField("airlineCode", isEqualTo: airline.code)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            var loaded: [AirlineReview] = []
            for document in snapshot.documents {
                do {
                    let review = try document.data(as: AirlineReview.self)
                    loaded.append(review)
                } catch {
                    print("⚠️ Failed to decode AirlineReview: \(error)")
                }
            }
            
            self.reviews = loaded
        } catch {
            errorMessage = "Failed to load reviews: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Create or update a review for the given airline by the given user
    func submitReview(for airline: Airline, rating: Int, comment: String, user: User) async {
        guard let userId = user.id else {
            errorMessage = "Missing user id"
            return
        }
        
        errorMessage = ""
        
        let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeRating = max(1, min(5, rating))
        
        let review = AirlineReview(
            id: nil,
            airlineCode: airline.code,
            airlineName: airline.name,
            userId: userId,
            userName: user.fullname,
            rating: safeRating,
            comment: trimmedComment,
            createdAt: Date()
        )
        
        do {
            // Check if this user already has a review for this airline
            let query = try await db.collection("reviews")
                .whereField("airlineCode", isEqualTo: airline.code)
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            if let existing = query.documents.first {
                // Update existing review
                try existing.reference.setData(from: review)
            } else {
                // Create new review
                let docRef = db.collection("reviews").document()
                try docRef.setData(from: review)
            }
            
            await loadReviews(for: airline)
        } catch {
            errorMessage = "Failed to submit review: \(error.localizedDescription)"
        }
    }
    
    func averageRating() -> Double {
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }
    
    func myReview(for userId: String) -> AirlineReview? {
        reviews.first { $0.userId == userId }
    }
}

// MARK: - Airline Ratings Overview

struct AirlineRatingSummary {
    let averageRating: Double
    let reviewCount: Int
}

@MainActor
class AirlineRatingsOverviewViewModel: ObservableObject {
    @Published var summaries: [String: AirlineRatingSummary] = [:]
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    
    func loadRatings() async {
        isLoading = true
        errorMessage = ""
        
        do {
            var result: [String: AirlineRatingSummary] = [:]
            
            for airline in Airline.all {
                let snapshot = try await db.collection("reviews")
                    .whereField("airlineCode", isEqualTo: airline.code)
                    .getDocuments()
                
                var reviews: [AirlineReview] = []
                for document in snapshot.documents {
                    if let review = try? document.data(as: AirlineReview.self) {
                        reviews.append(review)
                    }
                }
                
                guard !reviews.isEmpty else { continue }
                let total = reviews.reduce(0) { $0 + $1.rating }
                let avg = Double(total) / Double(reviews.count)
                result[airline.code] = AirlineRatingSummary(averageRating: avg, reviewCount: reviews.count)
            }
            
            self.summaries = result
        } catch {
            errorMessage = "Failed to load ratings: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
