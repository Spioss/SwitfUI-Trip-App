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
                                FlightCard(flight: flight)
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
            
            // Number of passangers
            VStack{
                CustomStepper (
                    title: "Adults:",
                    value: $viewModel.adults,
                    range: 1...9
                )
                CustomStepper (
                    title: "Kids:",
                    value: $viewModel.kids,
                    range: 1...9
                )
            }
            .background(Color.adaptiveSecondaryBackground)
            .cornerRadius(12)
            
        }
        .padding(.horizontal)
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
