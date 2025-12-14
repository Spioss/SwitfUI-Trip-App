//
//  OfferDetailView.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

import SwiftUI
import FirebaseFirestore

struct OfferDetailView: View {
    let offer: TicketOffer
    @EnvironmentObject var viewModel: SaveTheTicketViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteAlert = false
    @State private var showPurchaseView = false
    @State private var originalBookingId: String = ""
    
    private var isMyOffer: Bool {
        offer.sellerId == authViewModel.currentUser?.id
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Status banner
                    if !offer.isActive {
                        inactiveBanner
                    }
                    
                    // Flight info card
                    flightInfoCard
                    
                    // Price card
                    priceCard
                    
                    // Seller info
                    sellerInfoCard
                    
                    // Reason card
                    reasonCard
                    
                    // Details card
                    detailsCard
                    
                    // Actions
                    if isMyOffer {
                        myOfferActions
                    } else {
                        buyerActions
                    }
                }
                .padding()
            }
            .navigationTitle("Offer Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Delete Offer", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteOffer()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this offer? This action cannot be undone.")
            }
            .sheet(isPresented: $showPurchaseView) {
                SecondHandPurchaseView(
                    offer: offer,
                    originalBookingId: originalBookingId
                )
                .environmentObject(authViewModel)
            }
            .onAppear {
                loadOriginalBookingId()
            }
        }
    }
    
    // MARK: - Load Original Booking ID
    
    private func loadOriginalBookingId() {
        Task {
            do {
                guard let offerId = offer.id else { return }
                let doc = try await Firestore.firestore().collection("ticketOffers").document(offerId).getDocument()
                if let bookingId = doc.data()?["originalBookingId"] as? String {
                    originalBookingId = bookingId
                    print("✅ Loaded booking ID: \(bookingId)")
                } else {
                    print("⚠️ No originalBookingId found for offer")
                }
            } catch {
                print("❌ Error loading booking ID: \(error)")
            }
        }
    }
    
    // MARK: - Inactive Banner
    
    private var inactiveBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text("This offer is no longer active")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Flight Info Card
    
    private var flightInfoCard: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.airline)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(offer.fullFlightInfo)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                if offer.isInternational {
                    Text("INTERNATIONAL")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
            }
            
            // Route
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(offer.fromCode)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    Text(offer.fromCity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "airplane")
                        .font(.title3)
                        .foregroundColor(.purple)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 80, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(.secondary.opacity(0.5))
                    .frame(height: 2)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(offer.toCode)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    Text(offer.toCity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Date and time
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Departure")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(offer.date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(offer.departureTime)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Seat Class")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(offer.seat)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.adaptiveInputBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Price Card
    
    private var priceCard: some View {
        VStack(spacing: 16) {
            // Current price
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(offer.formattedCurrentPrice)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            
            // Original price and savings
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Original Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(offer.formattedOriginalPrice)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .strikethrough()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("You Save")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text(offer.formattedSavings)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("(\(offer.discountPercent)%)")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.adaptiveInputBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Seller Info Card
    
    private var sellerInfoCard: some View {
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
                    .background(Color.purple)
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
        }
        .padding()
        .background(Color.adaptiveInputBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Reason Card
    
    private var reasonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reason for Selling")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                if let reason = SellReason(rawValue: offer.reason) {
                    Image(systemName: reason.icon)
                        .font(.title2)
                        .foregroundColor(colorForReason(reason.color))
                    
                    Text(offer.reason)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.adaptiveSecondaryBackground)
            .cornerRadius(12)
        }
        .padding()
        .background(Color.adaptiveInputBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Details Card
    
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Booking Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 10) {
                DetailRow(label: "Booking Reference", value: offer.bookingRef)
                DetailRow(label: "Flight Number", value: offer.fullFlightInfo)
                DetailRow(label: "Route", value: offer.routeWithCities)
                DetailRow(label: "Class", value: offer.seat)
                DetailRow(label: "Type", value: offer.isInternational ? "International" : "Domestic")
            }
        }
        .padding()
        .background(Color.adaptiveInputBackground)
        .cornerRadius(16)
    }
    
    // MARK: - My Offer Actions
    
    private var myOfferActions: some View {
        VStack(spacing: 12) {
            if offer.isActive {
                Button(action: {
                    Task {
                        await deactivateOffer()
                    }
                }) {
                    HStack {
                        Image(systemName: "pause.circle.fill")
                        Text("Mark as Sold")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            Button(action: {
                showDeleteAlert = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete Offer")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Buyer Actions
    
    private var buyerActions: some View {
        VStack(spacing: 12) {
            if offer.isActive {
                // Buy Now button
                Button(action: {
                    if !originalBookingId.isEmpty {
                        showPurchaseView = true
                    } else {
                        print("⚠️ Booking ID not loaded yet")
                    }
                }) {
                    HStack {
                        Image(systemName: "cart.fill")
                        Text("Buy Now - \(offer.formattedCurrentPrice)")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(originalBookingId.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(originalBookingId.isEmpty)
                
                // Contact seller info
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Secure payment - Your money is protected")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
            } else {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.secondary)
                    Text("This offer is no longer available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.adaptiveSecondaryBackground)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func deleteOffer() async {
        guard let offerId = offer.id else { return }
        await viewModel.deleteOffer(offerId)
        dismiss()
    }
    
    private func deactivateOffer() async {
        guard let offerId = offer.id else { return }
        await viewModel.deactivateOffer(offerId)
        dismiss()
    }
    
    private func getInitials(from fullName: String) -> String {
        let nameParts = fullName.split(separator: " ")
        let initials = nameParts.compactMap { $0.first }.map { String($0).uppercased() }
        return initials.joined()
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
