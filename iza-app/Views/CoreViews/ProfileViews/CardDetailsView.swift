//
//  CardDetailsView.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//


import SwiftUI

struct CardDetailView: View {
    let card: SavedCreditCard
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    @State private var isUpdating = false
    @State private var refreshView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Large Card Preview
                    largeCardPreview
                    
                    // Card Information
                    cardInformationSection
                    
                    // Actions
                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Card Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Remove Card", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    Task {
                        await removeCard()
                    }
                }
            } message: {
                Text("Are you sure you want to remove this card? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Large Card Preview
    
    private var largeCardPreview: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                // Card Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(card.cardType.rawValue)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if let nickname = card.nickname {
                            Text(nickname)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        if card.isDefault {
                            Text("DEFAULT")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(6)
                        }
                        
                        Image(systemName: card.cardType.icon)
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Card Number
                HStack {
                    Text(card.maskedNumber)
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                // Bottom Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CARDHOLDER")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text(card.cardHolderName.uppercased())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("EXPIRES")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text(card.expiryDate)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(24)
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .background(cardGradient)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 8)
        }
    }
    
    // MARK: - Card Information Section
    
    private var cardInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Card Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InfoRow(label: "Card Type", value: card.cardType.rawValue)
                InfoRow(label: "Cardholder", value: card.cardHolderName)
                InfoRow(label: "Last 4 Digits", value: card.last4Digits)
                InfoRow(label: "Expires", value: card.expiryDate)
                
                if let nickname = card.nickname {
                    InfoRow(label: "Nickname", value: nickname)
                }
                
                InfoRow(
                    label: "Status",
                    value: card.isDefault ? "Default Card" : "Additional Card",
                    valueColor: card.isDefault ? .green : .secondary
                )
            }
            .padding()
            .background(Color.adaptiveInputBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            Text("Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Make Default Button
                if !card.isDefault {
                    Button(action: {
                        Task {
                            await makeDefault()
                        }
                    }) {
                        HStack {
                            if isUpdating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 16, height: 16)
                            } else {
                                Image(systemName: "star.fill")
                            }
                            
                            Text(isUpdating ? "Updating..." : "Make Default Card")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isUpdating)
                }
                
                // Remove Card Button
                Button(action: {
                    showDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Remove Card")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var cardGradient: LinearGradient {
        let colors = getCardColors(for: card.cardType)
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Helper Functions
    
    private func getCardColors(for cardType: CardType) -> [Color] {
        switch cardType {
        case .visa:
            return [Color.blue, Color.blue.opacity(0.7)]
        case .mastercard:
            return [Color.red, Color.orange]
        case .amex:
            return [Color.green, Color.green.opacity(0.7)]
        case .other:
            return [Color.purple, Color.purple.opacity(0.7)]
        }
    }
    
    private func makeDefault() async {
        isUpdating = true
        await authViewModel.setDefaultCard(card.id)
        isUpdating = false
        dismiss()
    }
    
    private func removeCard() async {
        await authViewModel.removeCreditCard(card.id)
        dismiss()
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let label: String
    let value: String
    let valueColor: Color
    
    init(label: String, value: String, valueColor: Color = .primary) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }
}
