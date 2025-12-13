//
//  BookingSuccessView.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//

import SwiftUI

struct BookingSuccessView: View {
    let ticket: BookedTicket?
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 40)
                        
                        // Success Animation
                        SuccessAnimationView()
                        
                        // Booking Details
                        if let ticket = ticket {
                            BookingDetailsCard(ticket: ticket)
                        }
                        
                        // Action Buttons
                        ActionButtonsView(ticket: ticket)
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Booking Confirmed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
