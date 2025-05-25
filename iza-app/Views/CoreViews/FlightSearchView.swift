//
//  FlightSearchView.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//
import SwiftUI

struct FlightSearchView: View {
    @EnvironmentObject var viewModel: FlightViewModel
    @State private var showAirportPicker = false
    @State private var pickingDeparture = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // form
                    searchForm
                    
                    // search button
                    searchButton
                    
                    // Chybová správa
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
                    
                    // Výsledky s novou kartou
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.flights) { flight in
                            Button(action: {
                                print("Choosed flight: \(flight.id)")
                                // Tu môžeš pridať navigáciu na detail letu alebo booking
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
            .navigationTitle("NxTrip")
            .sheet(isPresented: $showAirportPicker) {
                AirportPickerView(
                    isSelectingDeparture: $pickingDeparture,
                    selectedAirport: pickingDeparture ? $viewModel.fromAirport : $viewModel.toAirport
                )
                .environmentObject(viewModel)
            }
        }
    }
    
    // Forms
    private var searchForm: some View {
        VStack(spacing: 16) {
            // Letiská
            HStack(spacing: 12) {
                // Odkiaľ
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
                    .background(Color.adaptiveInputBackground)
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
                    .background(Color.adaptiveInputBackground)
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
            
            // Number of passangers
            HStack {
                Text("Adults:")
                Spacer()
                Text("\(viewModel.adults)")
                Stepper("", value: $viewModel.adults, in: 1...9)
                    .labelsHidden()
            }
            .background(Color.adaptiveInputBackground)
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
        .font(.system(size: 16, weight: .semibold, design: .monospaced))
        .foregroundColor(Color.adaptiveBackground)
        .disabled(viewModel.fromAirport == nil || viewModel.toAirport == nil)
    }
}

//#Preview {
//    FlightSearchView()
//        .environmentObject(FlightViewModel())
//}
