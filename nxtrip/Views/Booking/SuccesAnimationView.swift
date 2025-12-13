//
//  SuccessAnimationView.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//

import SwiftUI

struct SuccessAnimationView: View {
    @State private var showAnimation = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Outer circle
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showAnimation ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: showAnimation
                    )
                
                // Inner circle
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                // Checkmark
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                    .scaleEffect(showAnimation ? 1.0 : 0.5)
                    .animation(
                        Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0),
                        value: showAnimation
                    )
            }
            
            VStack(spacing: 8) {
                Text("Booking Confirmed!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Your flight has been successfully booked")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                showAnimation = true
            }
        }
    }
}
