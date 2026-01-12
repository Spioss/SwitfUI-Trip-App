//
//  AirlineReviewsView.swift
//  nxtrip
//
//  Created by Lukáš Mader on 11/01/2026.
//

import SwiftUI

struct AirlineReviewsListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var ratingsViewModel = AirlineRatingsOverviewViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.adaptiveBackground
                    .ignoresSafeArea()
                
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Rate Airlines")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("Choose an airline to see reviews and share your experience.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section("All Airlines") {
                        ForEach(Airline.all, id: \.id) { airline in
                            NavigationLink(destination: AirlineDetailReviewsView(airline: airline)) {
                                airlineRow(for: airline)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                if ratingsViewModel.isLoading {
                    ProgressView("Loading ratings...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                }
            }
            .navigationTitle("Airline Reviews")
        }
        .onAppear {
            if ratingsViewModel.summaries.isEmpty {
                Task {
                    await ratingsViewModel.loadRatings()
                }
            }
        }
    }
    
    private func airlineRow(for airline: Airline) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                Text(airline.code)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(airline.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let summary = ratingsViewModel.summaries[airline.code] {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", summary.averageRating))
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("· \(summary.reviewCount) review\(summary.reviewCount == 1 ? "" : "s")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("No ratings yet")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct AirlineDetailReviewsView: View {
    let airline: Airline
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = AirlineReviewsViewModel()
    
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var hasExistingReview = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(airline.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(airline.code)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                let avg = viewModel.averageRating()
                if avg > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", avg))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("· \(viewModel.reviews.count) review\(viewModel.reviews.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("No reviews yet. Be the first!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top)
            
            // Write review section
            ReviewCard(title: "Write a Review") {
                VStack(alignment: .leading, spacing: 16) {
                    if hasExistingReview {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.purple)
                            Text("You are editing your previous review")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Rating selector
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Your Rating")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text(ratingDescription(rating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.title3)
                                    .padding(4)
                                    .background(
                                        Circle()
                                            .fill(star <= rating ? Color.yellow.opacity(0.15) : Color.clear)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                            rating = star
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Comment editor
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Your Comment")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(comment.count)/300")
                                .font(.caption2)
                                .foregroundColor(comment.count > 300 ? .red : .secondary)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            if comment.isEmpty {
                                Text("Share details about your experience (service, comfort, punctuality, ...)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                            }
                            
                            TextEditor(text: $comment)
                                .frame(minHeight: 100, maxHeight: 150)
                                .padding(8)
                                .background(Color.adaptiveInputBackground)
                                .cornerRadius(10)
                                .onChange(of: comment) { _, newValue in
                                    if newValue.count > 300 {
                                        comment = String(newValue.prefix(300))
                                    }
                                }
                        }
                    }
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: submitTapped) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 16, height: 16)
                            } else {
                                Image(systemName: "paperplane.fill")
                            }
                            Text(isSubmitting ? "Submitting..." : "Submit Review")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(canSubmit ? Color.purple : Color.gray.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!canSubmit)
                }
            }
            .padding(.horizontal)
            
            // Reviews list
            if viewModel.isLoading {
                ProgressView("Loading reviews...")
                    .padding()
            } else if viewModel.reviews.isEmpty {
                Text("No reviews for this airline yet.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.reviews) { review in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(review.userName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(review.rating)")
                                        .font(.caption)
                                }
                            }
                            
                            if !review.comment.isEmpty {
                                Text(review.comment)
                                    .font(.footnote)
                            }
                            
                            Text(review.createdAt, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            
            Spacer(minLength: 0)
        }
        .navigationTitle(airline.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.loadReviews(for: airline)
                if let user = authViewModel.currentUser, let userId = user.id {
                    if let myReview = viewModel.myReview(for: userId) {
                        rating = myReview.rating
                        comment = myReview.comment
                        hasExistingReview = true
                    }
                }
            }
        }
    }
    
    private var canSubmit: Bool {
        guard authViewModel.currentUser != nil else { return false }
        return !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }
    
    private func ratingDescription(_ value: Int) -> String {
        switch value {
        case 1: return "Very poor"
        case 2: return "Poor"
        case 3: return "OK"
        case 4: return "Good"
        default: return "Excellent"
        }
    }
    
    private func submitTapped() {
        guard let user = authViewModel.currentUser else { return }
        isSubmitting = true
        Task {
            await viewModel.submitReview(for: airline, rating: rating, comment: comment, user: user)
            isSubmitting = false
        }
    }
}
