//
//  AirportPickerView.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//
import SwiftUI

struct AirportPickerView: View {
    @Binding var isSelectingDeparture: Bool
    @Binding var selectedAirport: SimpleAirport?
    @EnvironmentObject var viewModel: FlightViewModel
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Hľadaj letisko...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onChange(of: searchText, initial: true) { initial, newValue in
                        Task {
                            await viewModel.searchAirports(keyword: newValue)
                        }
                    }
                
                // Zoznam letísk
                List(viewModel.airports) { airport in
                    Button {
                        selectedAirport = airport
                        dismiss()
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(airport.iataCode)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(airport.name)
                                    .font(.subheadline)
                            }
                            if let city = airport.address.cityName,
                               let country = airport.address.countryName {
                                Text("\(city), \(country)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(isSelectingDeparture ? "Odkiaľ" : "Kam")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zrušiť") {
                        dismiss()
                    }
                }
            }
        }
    }
}
