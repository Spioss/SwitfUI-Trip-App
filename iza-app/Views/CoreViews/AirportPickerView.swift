//
//  AirportPickerView.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//
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
    @State private var searchTask: Task<Void, Never>?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search by airport, city or code...", text: $searchText)
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                                viewModel.airports = []
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.adaptiveInputBackground)
                    .cornerRadius(10)
                    
                    // Status/debug info
                    if !viewModel.searchStatus.isEmpty {
                        Text(viewModel.searchStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }
                }
                .padding()
                
                // Suggestions or results
                if searchText.isEmpty {
                    popularAirportsSection
                } else if viewModel.airports.isEmpty && !viewModel.searchStatus.contains("Searching") {
                    noResultsView
                } else {
                    airportsList
                }
                
                Spacer()
            }
            .navigationTitle(isSelectingDeparture ? "Where are you flying from?" : "Where are you flying?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancle") {
                        dismiss()
                    }
                }
            }
            .onChange(of: searchText) { oldValue, newValue in
                // Debounced search
                searchTask?.cancel()
                searchTask = Task {
                    try? await Task.sleep(nanoseconds: 300_000_000) // 300ms delay
                    if !Task.isCancelled {
                        await viewModel.searchAirports(keyword: newValue)
                    }
                }
            }
        }
    }
    
    // MARK: - Views
    
    private var popularAirportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular destinations")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(getPopularAirportCodes(), id: \.self) { code in
                        Button {
                            selectedAirport = createMockAirport(iataCode: code)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(code)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Text(getAirportName(code))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(getCityAndCountry(code))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.adaptiveSecondaryBackground)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No airports found")
                    .font(.headline)
                
                Text("Try searching by:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• City name (e.g. 'London')")
                    Text("• Airport name (e.g. 'Heathrow')")
                    Text("• IATA code (e.g. 'LHR')")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Button("Check out popular airports") {
                searchText = ""
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
    
    private var airportsList: some View {
        List(viewModel.airports) { airport in
            Button {
                selectedAirport = airport
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(airport.iataCode)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(airport.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                        }
                        
                        if let city = airport.address.cityName,
                           let country = airport.address.countryName {
                            Text("\(city), \(country)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }
    
    // MARK: - Helper Functions mostly for Popular Airports
    
    private func getPopularAirportCodes() -> [String] {
        return ["PRG", "VIE", "BTS", "LHR", "CDG", "FRA", "MUC", "FCO", "MAD", "BCN"]
    }
    
    private func createMockAirport(iataCode: String) -> SimpleAirport {
        return SimpleAirport(
            id: iataCode,
            name: getAirportName(iataCode),
            iataCode: iataCode,
            address: AirportAddress(
                cityName: getCityName(iataCode),
                countryName: getCountryName(iataCode)
            )
        )
    }
    
    private func getAirportName(_ iataCode: String) -> String {
        let airportNames = [
            "BTS": "M. R. Štefánik Airport",
            "VIE": "Vienna International Airport",
            "PRG": "Václav Havel Airport Prague",
            "LHR": "London Heathrow Airport",
            "CDG": "Charles de Gaulle Airport",
            "FRA": "Frankfurt Airport",
            "MUC": "Munich Airport",
            "FCO": "Leonardo da Vinci Airport",
            "MAD": "Adolfo Suárez Madrid-Barajas Airport",
            "BCN": "Barcelona-El Prat Airport"
        ]
        return airportNames[iataCode] ?? "\(iataCode) Airport"
    }
    
    private func getCityName(_ iataCode: String) -> String {
        let cityNames = [
            "BTS": "Bratislava",
            "VIE": "Vienna",
            "PRG": "Prague",
            "LHR": "London",
            "CDG": "Paris",
            "FRA": "Frankfurt",
            "MUC": "Munich",
            "FCO": "Rome",
            "MAD": "Madrid",
            "BCN": "Barcelona"
        ]
        return cityNames[iataCode] ?? iataCode
    }
    
    private func getCountryName(_ iataCode: String) -> String {
        let countryNames = [
            "BTS": "Slovakia",
            "VIE": "Austria",
            "PRG": "Czech Republic",
            "LHR": "United Kingdom",
            "CDG": "France",
            "FRA": "Germany",
            "MUC": "Germany",
            "FCO": "Italy",
            "MAD": "Spain",
            "BCN": "Spain"
        ]
        return countryNames[iataCode] ?? "Unknown"
    }
    
    private func getCityAndCountry(_ iataCode: String) -> String {
        return "\(getCityName(iataCode)), \(getCountryName(iataCode))"
    }
}
