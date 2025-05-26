//
//  AddCardView.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//
import SwiftUI

struct AddCardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var cardHolderName = ""
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var nickname = ""
    @State private var isDefault = false
    @State private var selectedCardType: CardType = .visa
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Card Preview
                    cardPreviewSection
                    
                    // Card Form
                    cardFormSection
                    
                    // Options
                    cardOptionsSection
                    
                    // Save Button
                    saveButton
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Add Credit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let user = authViewModel.currentUser {
                    cardHolderName = user.fullname
                    isDefault = user.savedCards.isEmpty // First card is default
                }
            }
        }
    }
    
    // MARK: - Card Preview Section
    private var cardPreviewSection: some View {
        VStack(spacing: 16) {
            // Card mockup
            VStack(spacing: 12) {
                HStack {
                    Text(selectedCardType.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: selectedCardType.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack {
                    Text(cardNumber.isEmpty ? "**** **** **** ****" : formatCardNumberPreview(cardNumber))
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CARDHOLDER")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Text(cardHolderName.isEmpty ? "YOUR NAME" : cardHolderName.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("EXPIRES")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Text(expiryDate.isEmpty ? "MM/YY" : expiryDate)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(20)
            .frame(height: 200)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Card Form Section
    
    private var cardFormSection: some View {
        VStack(spacing: 16) {
            Text("Card Details")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Cardholder Name
                IconTextField(
                    text: $cardHolderName,
                    systemImageName: "person.text.rectangle",
                    placeholder: "Cardholder Name"
                )
                .autocapitalization(.words)
                
                // Card Number
                HStack {
                    Image(systemName: selectedCardType.icon)
                        .foregroundColor(.secondary)
                        .frame(width: 16)
                    
                    TextField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: cardNumber) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count <= 16 {
                                cardNumber = formatCardNumber(filtered)
                                selectedCardType = detectCardType(filtered)
                            }
                        }
                }
                .padding(.vertical, 12)
                .padding(.leading, 16)
                .frame(height: 50)
                .background(Color.adaptiveInputBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.adaptiveBorder, lineWidth: 0.5)
                )
                
                // Expiry and CVV
                HStack(spacing: 12) {
                    IconTextField(
                        text: $expiryDate,
                        systemImageName: "calendar",
                        placeholder: "MM/YY"
                    )
                    .onChange(of: expiryDate) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count <= 4 {
                            expiryDate = formatExpiryDate(filtered)
                        }
                    }
                    
                    IconSecureField(
                        text: $cvv,
                        systemImageName: "lock.fill",
                        placeholder: "CVV"
                    )
                    .onChange(of: cvv) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count <= 4 {
                            cvv = filtered
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Card Options Section
    
    private var cardOptionsSection: some View {
        VStack(spacing: 16) {
            Text("Card Options")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Nickname
                IconTextField(
                    text: $nickname,
                    systemImageName: "tag.fill",
                    placeholder: "Card Nickname (Optional)"
                )
                
                // Default card toggle
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Make Default Card")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Use this card as your primary payment method")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $isDefault)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                }
                .padding()
                .background(Color.adaptiveInputBackground)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        Button(action: {
            Task {
                await saveCard()
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "creditcard.fill")
                }
                
                Text(isLoading ? "Saving..." : "Save Card")
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(formIsValid ? Color.purple : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(12)
        .disabled(!formIsValid || isLoading)
    }
    
    // MARK: - Heleper functions
    private var formIsValid: Bool {
        !cardHolderName.isEmpty &&
        !cardNumber.isEmpty &&
        cardNumber.replacingOccurrences(of: " ", with: "").count == 16 &&
        !expiryDate.isEmpty &&
        expiryDate.count == 5 &&
        !cvv.isEmpty &&
        cvv.count == 3
    }
    
    private func saveCard() async {
        isLoading = true
        errorMessage = ""
        
        let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let last4 = String(cleanCardNumber.suffix(4))
        let expiryParts = expiryDate.split(separator: "/")
        
        guard expiryParts.count == 2 else {
            errorMessage = "Invalid expiry date"
            isLoading = false
            return
        }
        
        let newCard = SavedCreditCard(
            cardHolderName: cardHolderName.trimmingCharacters(in: .whitespaces),
            last4Digits: last4,
            expiryMonth: String(expiryParts[0]),
            expiryYear: String(expiryParts[1]),
            cardType: selectedCardType,
            isDefault: isDefault,
            nickname: nickname.isEmpty ? nil : nickname.trimmingCharacters(in: .whitespaces)
        )
        
        do {
            try await authViewModel.addCreditCard(newCard)
            dismiss()
        } catch {
            errorMessage = "Failed to save card: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func formatCardNumber(_ number: String) -> String {
        var formatted = ""
        for (index, character) in number.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted += String(character)
        }
        return formatted
    }
    
    private func formatCardNumberPreview(_ number: String) -> String {
        let clean = number.replacingOccurrences(of: " ", with: "")
        let masked = String(repeating: "*", count: max(0, 12 - clean.count)) + clean
        return formatCardNumber(String(masked.prefix(16)))
    }
    
    private func formatExpiryDate(_ date: String) -> String {
        if date.count >= 2 {
            let month = String(date.prefix(2))
            let year = String(date.dropFirst(2))
            return year.isEmpty ? month : "\(month)/\(year)"
        }
        return date
    }
    
    private func detectCardType(_ number: String) -> CardType {
        if number.hasPrefix("4") {
            return .visa
        } else if number.hasPrefix("5") || number.hasPrefix("2") {
            return .mastercard
        } else if number.hasPrefix("34") || number.hasPrefix("37") {
            return .amex
        }
        return .other
    }
}
