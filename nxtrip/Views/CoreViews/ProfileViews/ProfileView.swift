//
//  ProfileView.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showDeleteAlert = false
    @State private var showRenameAlert = false
    @State private var showAddCardView = false
    @State private var selectedCard: SavedCreditCard?
    @State private var newFullName = ""
    
    // Inline phone editing
    @State private var isEditingPhone = false
    @State private var phoneText = ""
    @FocusState private var isPhoneFocused: Bool
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack{
                        Text(getInitials(fullname: user.fullname))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4){
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Personal Information") {
                    // Inline Phone Editing
                    HStack {
                        Image(systemName: "phone.fill")
                            .imageScale(.small)
                            .font(.title)
                            .foregroundColor(.green)
                            .frame(width: 28)
                        
                        if isEditingPhone {
                            // Editing mode
                            TextField("Phone Number", text: $phoneText)
                                .keyboardType(.phonePad)
                                .focused($isPhoneFocused)
                                .font(.subheadline)
                            
                            Button("Save") {
                                savePhone()
                            }
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            
                            Button("Cancel") {
                                cancelPhoneEdit()
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        } else {
                            // Display mode
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Phone")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(user.hasPhone ? user.phone : "Add phone number")
                                    .font(.subheadline)
                                    .foregroundColor(user.hasPhone ? .primary : .orange)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                startPhoneEdit(currentPhone: user.phone)
                            }) {
                                Image(systemName: user.hasPhone ? "pencil.circle.fill" : "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(user.hasPhone ? .blue : .green)
                            }
                        }
                    }
                    
                    // Change Name
                    Button{
                        newFullName = user.fullname
                        showRenameAlert = true
                    } label: {
                        TextWithImage(imageName: "pencil.circle.fill", title: "Change Name", tintColor: .blue)
                    }
                }
                
                Section {
                    // Cards List
                    if user.hasCards {
                        ForEach(user.savedCards) { card in
                            Button{
                                selectedCard = card
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Image(systemName: card.cardType.icon)
                                                .font(.system(size: 16))
                                                .foregroundColor(.purple)
                                            
                                            Text(card.displayName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            
                                            if card.isDefault {
                                                Text("DEFAULT")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.purple)
                                                    .cornerRadius(4)
                                            }
                                        }
                                        
                                        HStack(spacing: 12) {
                                            Text(card.maskedNumber)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text("Expires \(card.expiryDate)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.purple)
                            
                            Text("No cards saved")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Tap + to add")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    // Card limit message
                    if !user.canAddMoreCards {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.orange)
                            Text("Maximum 3 cards reached")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: { // Payment Methods Header with Add Button
                    HStack {
                        Text("Payment Methods")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        if user.canAddMoreCards {
                            Button(action: {
                                showAddCardView = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                }
                
                
                Section("Reviews") {
                    HStack {
                        TextWithImage(imageName: "star.fill", title: "My Reviews", tintColor: .yellow)
                        Spacer()
                        Text("Coming Soon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Account") {
                    Button{
                        viewModel.signOut()
                    } label: {
                        TextWithImage(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        TextWithImage(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                    }
                    .alert("Delete Account", isPresented: $showDeleteAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            Task {
                                await viewModel.deleteAccount()
                            }
                        }
                    } message: {
                        Text("Are you sure you want to delete your account? This action cannot be undone.")
                    }
                }
            }
            .sheet(isPresented: $showAddCardView) {
                AddCardView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card)
                    .environmentObject(viewModel)
            }
            .alert("Change Name", isPresented: $showRenameAlert) {
                TextField("Full Name", text: $newFullName)
                    .textInputAutocapitalization(.words)
                
                Button("Cancel", role: .cancel) {
                    newFullName = ""
                }
                
                Button("Save") {
                    Task {
                        await updateUserName()
                    }
                }
                .disabled(newFullName.trimmingCharacters(in: .whitespaces).isEmpty)
                
            } message: {
                Text("Enter your new name")
            }
        }
    }
    
    // MARK: - Phone Editing Functions
    
    private func startPhoneEdit(currentPhone: String) {
        phoneText = currentPhone
        isEditingPhone = true
        isPhoneFocused = true
    }
    
    private func savePhone() {
        let trimmedPhone = phoneText.trimmingCharacters(in: .whitespaces)
        
        Task {
            do {
                try await viewModel.updateUserProfile(fullname: nil, phone: trimmedPhone.isEmpty ? "" : trimmedPhone)
                isEditingPhone = false
                phoneText = ""
            } catch {
                print("Failed to update phone: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelPhoneEdit() {
        isEditingPhone = false
        phoneText = ""
        isPhoneFocused = false
    }
    
    // MARK: - Helper Functions
    
    private func updateUserName() async {
        let trimmedName = newFullName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        do {
            try await viewModel.updateUserProfile(fullname: trimmedName, phone: nil)
        } catch {
            print("Failed to update name: \(error.localizedDescription)")
        }
        
        newFullName = ""
    }
}
