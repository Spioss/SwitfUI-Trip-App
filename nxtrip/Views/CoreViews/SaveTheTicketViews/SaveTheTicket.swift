//
//  SaveTheTicketView.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

import SwiftUI

struct SaveTheTicketView: View {
    @StateObject private var viewModel = SaveTheTicketViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedOffer: TicketOffer?
    @State private var showCreateOffer = false
    @State private var selectedTab: OfferTab = .all
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                tabSelector
                
                // Content based on selected tab
                if selectedTab == .all {
                    allOffersView
                } else {
                    myOffersView
                }
            }
            .navigationTitle("Save The Ticket")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateOffer = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchAllOffers()
                    if let userId = authViewModel.currentUser?.id {
                        await viewModel.fetchMyOffers(userId: userId)
                    }
                }
            }
            .refreshable {
                await viewModel.fetchAllOffers()
                if let userId = authViewModel.currentUser?.id {
                    await viewModel.fetchMyOffers(userId: userId)
                }
            }
            .sheet(isPresented: $showCreateOffer) {
                CreateOfferView()
                    .environmentObject(authViewModel)
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedOffer) { offer in
                OfferDetailView(offer: offer)
                    .environmentObject(viewModel)
                    .environmentObject(authViewModel)
            }
        }
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(OfferTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab.title)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundColor(selectedTab == tab ? .purple : .secondary)
                        
                        if selectedTab == tab {
                            Rectangle()
                                .fill(Color.purple)
                                .frame(height: 2)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .background(Color.adaptiveSecondaryBackground.opacity(0.5))
    }
    
    // MARK: - All Offers View
    
    private var allOffersView: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.offers.isEmpty {
                emptyStateView
            } else {
                offersList(offers: viewModel.offers)
            }
        }
    }
    
    // MARK: - My Offers View
    
    private var myOffersView: some View {
        Group {
            if viewModel.myOffers.isEmpty {
                myOffersEmptyState
            } else {
                offersList(offers: viewModel.myOffers, isMyOffers: true)
            }
        }
    }
    
    // MARK: - Offers List
    
    private func offersList(offers: [TicketOffer], isMyOffers: Bool = false) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(offers) { offer in
                    Button {
                        selectedOffer = offer
                    } label: {
                        OfferCard(offer: offer, isMyOffer: isMyOffers)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(1.2)
            
            Text("Loading offers...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State Views
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple.opacity(0.5))
            
            VStack(spacing: 12) {
                Text("No Offers Available")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Check back later for great deals on flight tickets!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var myOffersEmptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 80))
                .foregroundColor(.purple.opacity(0.5))
            
            VStack(spacing: 12) {
                Text("No Active Offers")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Sell your unused tickets and help someone travel cheaper!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {
                showCreateOffer = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Offer")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: 200, minHeight: 50)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Offer Card Component

struct OfferCard: View {
    let offer: TicketOffer
    let isMyOffer: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with airline and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.airline)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(offer.fullFlightInfo)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                if isMyOffer {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(offer.isActive ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(offer.isActive ? "Active" : "Sold")
                            .font(.caption)
                            .foregroundColor(offer.isActive ? .green : .gray)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(offer.isActive ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.adaptiveSecondaryBackground.opacity(0.5))
            
            // Main content
            VStack(spacing: 16) {
                // Route
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(offer.fromCode)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(offer.fromCity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: "airplane")
                            .font(.caption)
                            .foregroundColor(.purple)
                        
                        Rectangle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(height: 2)
                            .frame(width: 60)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(offer.toCode)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(offer.toCity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Date and time
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(offer.date)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(offer.departureTime)
                            .font(.subheadline)
                    }
                }
                
                Divider()
                
                // Price section
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(offer.formattedCurrentPrice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Original: \(offer.formattedOriginalPrice)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .strikethrough()
                        
                        Text("Save \(offer.formattedSavings)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
        }
        .background(Color.adaptiveInputBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Tab Enum

enum OfferTab: CaseIterable {
    case all
    case myOffers
    
    var title: String {
        switch self {
        case .all:
            return "All Offers"
        case .myOffers:
            return "My Offers"
        }
    }
}
