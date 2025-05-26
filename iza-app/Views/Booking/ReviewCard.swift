//
//  ReviewCard.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//
import SwiftUI

struct ReviewCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
            
            content
        }
        .padding()
        .background(Color.adaptiveSecondaryBackground)
        .cornerRadius(12)
    }
}
