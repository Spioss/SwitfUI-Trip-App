//
//  ProfileView.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/09/2025.
//

import SwiftUI
import FirebaseAuth

struct SaveTheTicket: View {
    
    var body: some View {
        VStack {
            Button(action: {}) {
                Text("Ahoj")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.red)
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
