//
//  FlightSearchView.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

import SwiftUI

struct FlightSearchView: View {
    @EnvironmentObject var viewModel: FlightViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAirportPicker = false
    @State private var pickingDeparture = true
    @State private var showBookingView = false
    @State private var selectedFlight: SimpleFlight?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // form
                    searchForm
                    
                    // search button
                    searchButton
                    
                    // error
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Loading
                    if viewModel.isLoading {
                        ProgressView("Searching for flights...")
                            .padding()
                    }
                    
                    // flight cards
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.flights) { flight in
                            Button(action: {
                                selectedFlight = flight
                                showBookingView = true
                            }) {
                                FlightCard(flight: flight, numberOfTickets: viewModel.numberOfTickets)
                                    .environmentObject(viewModel)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .sheet(isPresented: $showAirportPicker) {
                AirportPickerView(
                    isSelectingDeparture: $pickingDeparture,
                    selectedAirport: pickingDeparture ? $viewModel.fromAirport : $viewModel.toAirport
                )
                .environmentObject(viewModel)
            }
            .sheet(item: $selectedFlight) { flight in
                BookingView(flight: flight)
                    .environmentObject(authViewModel)
                    .environmentObject(viewModel)
            }
        }
    }
    
    // Forms
    private var searchForm: some View {
        VStack(spacing: 16) {
            
            // Airports
            HStack(spacing: 12) {
                // FROM
                Button {
                    pickingDeparture = true
                    showAirportPicker = true
                } label: {
                    VStack(alignment: .leading) {
                        Text("FROM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.fromAirport?.iataCode ?? "Choose")
                            .font(.headline)
                        Text(viewModel.fromAirport?.name ?? "Airport")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.adaptiveSecondaryBackground)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // Swap
                Button {
                    viewModel.swapAirports()
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
                
                // TO
                Button {
                    pickingDeparture = false
                    showAirportPicker = true
                } label: {
                    VStack(alignment: .leading) {
                        Text("TO")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(viewModel.toAirport?.iataCode ?? "Choose")
                            .font(.headline)
                        Text(viewModel.toAirport?.name ?? "Airport")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.adaptiveSecondaryBackground)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            
            // Type of flight
            Picker("Type of flight", selection: $viewModel.isRoundTrip) {
                Text("One-Way Flight").tag(false)
                Text("Return Flight").tag(true)
            }
            .pickerStyle(.segmented)
            
            // Dates
            VStack {
                DatePicker("Departure", selection: $viewModel.departureDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                if viewModel.isRoundTrip {
                    DatePicker("Arrival", selection: $viewModel.returnDate, in: viewModel.departureDate..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
            .padding()
            .background(Color.adaptiveSecondaryBackground)
            .cornerRadius(12)
            
            // Number of tickets
            VStack(spacing: 0) {
                CustomStepper(
                    title: "Number of Tickets:",
                    value: $viewModel.numberOfTickets,
                    range: 1...9
                )
            }
            .background(Color.adaptiveSecondaryBackground)
            .cornerRadius(12)
            
            // Travel Class Selector
            travelClassSelector
            
        }
        .padding(.horizontal)
    }
    
    private var travelClassSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Travel Class")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TravelClass.allCases, id: \.self) { travelClass in
                        TravelClassCard(
                            travelClass: travelClass,
                            isSelected: viewModel.travelClass == travelClass
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.travelClass = travelClass
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
        .background(Color.adaptiveSecondaryBackground)
        .cornerRadius(12)
    }
    
    private var searchButton: some View {
        Button("Search Flights") {
            Task {
                await viewModel.searchFlights()
            }
        }
        .frame(width: 360, height: 50)
        .background(viewModel.fromAirport != nil && viewModel.toAirport != nil ? Color.purple : Color.adaptivePrimaryText)
        .cornerRadius(10)
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(Color.adaptiveBackground)
        .disabled(viewModel.fromAirport == nil || viewModel.toAirport == nil)
    }
}

// MARK: - Travel Class Card Component

struct TravelClassCard: View {
    let travelClass: TravelClass
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: travelClass.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : travelClass.color)
                
                Text(travelClass.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 100, height: 90)
            .background(isSelected ? travelClass.color : Color.adaptiveInputBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? travelClass.color : Color.adaptiveBorder, lineWidth: isSelected ? 2 : 0.5)
            )
            .shadow(color: isSelected ? travelClass.color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
