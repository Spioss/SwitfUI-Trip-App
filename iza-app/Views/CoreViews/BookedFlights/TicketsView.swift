//
//  TicketsView.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//

import SwiftUI

struct TicketsView: View {
    @StateObject private var ticketViewModel = TicketViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTicket: BookedTicket?
    @State private var searchText = ""
    @State private var selectedFilter: TicketFilter = .all
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if ticketViewModel.isLoading {
                    loadingView
                } else if ticketViewModel.bookedTickets.isEmpty {
                    emptyStateView
                } else {
                    ticketsContent
                }
            }
            .navigationTitle("My Tickets")
            .refreshable {
                if let userId = authViewModel.currentUser?.id {
                    await ticketViewModel.fetchUserTickets(userId: userId)
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    Task {
                        await ticketViewModel.fetchUserTickets(userId: userId)
                    }
                }
            }
            .sheet(item: $selectedTicket) { ticket in
                TicketDetailView(ticket: ticket)
                    .environmentObject(ticketViewModel)
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(1.2)
            
            Text("Loading your tickets...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.adaptiveBackground)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 80))
                .foregroundColor(.purple.opacity(0.5))
            
            VStack(spacing: 12) {
                Text("No Flights Booked Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your booked flights will appear here. Start exploring destinations and book your next adventure!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.adaptiveBackground)
    }
    
    // MARK: - Tickets Content
    private var ticketsContent: some View {
        VStack(spacing: 0) {
            // Search and Filter Section
            searchAndFilterSection
            
            // Tickets List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredTickets) { ticket in
                        Button {
                            selectedTicket = ticket
                        } label: {
                            TicketCard(ticket: ticket)
                                .environmentObject(ticketViewModel)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
    }
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search by destination or booking reference...", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.adaptiveInputBackground)
            .cornerRadius(10)
            
            // Filter Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TicketFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            title: filter.title,
                            count: ticketCount(for: filter),
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding()
        .background(Color.adaptiveSecondaryBackground.opacity(0.5))
    }
    
    // MARK: - Computed Properties
    private var filteredTickets: [BookedTicket] {
        var tickets = ticketViewModel.bookedTickets
        
        // Apply search filter
        if !searchText.isEmpty {
            tickets = tickets.filter { ticket in
                ticket.bookingReference.localizedCaseInsensitiveContains(searchText) ||
                ticket.flight.outbound.firstSegment.departure.iataCode.localizedCaseInsensitiveContains(searchText) ||
                ticket.flight.outbound.lastSegment.arrival.iataCode.localizedCaseInsensitiveContains(searchText) ||
                ticket.passengerInfo.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .upcoming:
            tickets = tickets.filter { ticket in
                ticketViewModel.getFlightStatus(ticket.flight.outbound.firstSegment.departure.at) == .upcoming
            }
        case .soon:
            tickets = tickets.filter { ticket in
                ticketViewModel.getFlightStatus(ticket.flight.outbound.firstSegment.departure.at) == .soon
            }
        case .completed:
            tickets = tickets.filter { ticket in
                ticketViewModel.getFlightStatus(ticket.flight.outbound.firstSegment.departure.at) == .completed
            }
        }
        
        return tickets
    }
    
    private func ticketCount(for filter: TicketFilter) -> Int {
        switch filter {
        case .all:
            return ticketViewModel.bookedTickets.count
        case .upcoming:
            return ticketViewModel.bookedTickets.filter { ticket in
                ticketViewModel.getFlightStatus(ticket.flight.outbound.firstSegment.departure.at) == .upcoming
            }.count
        case .soon:
            return ticketViewModel.bookedTickets.filter { ticket in
                ticketViewModel.getFlightStatus(ticket.flight.outbound.firstSegment.departure.at) == .soon
            }.count
        case .completed:
            return ticketViewModel.bookedTickets.filter { ticket in
                ticketViewModel.getFlightStatus(ticket.flight.outbound.firstSegment.departure.at) == .completed
            }.count
        }
    }
}

// MARK: - Filter Button Component
struct FilterButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .purple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        (isSelected ? Color.white.opacity(0.2) : Color.purple.opacity(0.1))
                    )
                    .cornerRadius(8)
            }
            .foregroundColor(isSelected ? .white : .purple)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.purple : Color.purple.opacity(0.1))
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ticket Filter Enum
enum TicketFilter: CaseIterable {
    case all
    case upcoming
    case soon
    case completed
    
    var title: String {
        switch self {
        case .all:
            return "All"
        case .upcoming:
            return "Upcoming"
        case .soon:
            return "Check-in"
        case .completed:
            return "Completed"
        }
    }
}
