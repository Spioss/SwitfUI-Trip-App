//
//  MainView.swift
//  iza-app
//
//  Created by Lukáš Mader on 24/05/2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var flightViewModel = FlightViewModel()
    
    var body: some View {
        TabView {
            FlightSearchView()
                .environmentObject(flightViewModel)
                .tabItem {
                    Image(systemName: "airplane")
                    Text("Flights")
                }
            
            TicketsView()
                .tabItem {
                    Image(systemName: "text.book.closed.fill")
                    Text("Booked tickets")
                }
                
            SaveTheTicket()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("SaveTheTicket")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
        }
        .accentColor(.purple)
    }
}

