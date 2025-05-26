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
    @State private var showPhoneAlert = false
    @State private var showAddCardView = false
    @State private var selectedCard: SavedCreditCard?
    @State private var newFullName = ""
    @State private var newPhoneNumber = ""
    
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
                    
                    // Phone row
                    HStack {
                        TextWithImage(imageName: "phone.fill", title: "Phone", tintColor: .green)
                        Spacer()
                        Text(user.hasPhone ? user.phone! : "Not provided")
                            .font(.subheadline)
                            .foregroundColor(user.hasPhone ? .secondary : .orange)
                    }
                    
                    // Edit buttons
                    Button{
                        newPhoneNumber = user.phone ?? ""
                        showPhoneAlert = true
                    } label: {
                        TextWithImage(
                            imageName: user.hasPhone ? "phone.arrow.up.right.fill" : "phone.badge.plus.fill",
                            title: user.hasPhone ? "Update Phone" : "Add Phone Number",
                            tintColor: user.hasPhone ? .green : .orange
                        )
                    }
                    
                    Button{
                        newFullName = user.fullname
                        showRenameAlert = true
                    } label: {
                        TextWithImage(imageName: "pencil.circle.fill", title: "Change Name", tintColor: .blue)
                    }
                    
                }
                
                Section("Payment Methods") {
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
                                            
                                            Spacer()
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
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        HStack {
                            TextWithImage(imageName: "creditcard.fill", title: "Credit Cards", tintColor: .purple)
                            Spacer()
                            Text("No cards saved")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    // Add card button
                    Button{
                        showAddCardView = true
                    } label: {
                        TextWithImage(
                            imageName: user.canAddMoreCards ? "creditcard.and.123" : "creditcard.trianglebadge.exclamationmark",
                            title: user.canAddMoreCards ? "Add Credit Card" : "Maximum 3 cards",
                            tintColor: user.canAddMoreCards ? .purple : .gray
                        )
                    }
                    .disabled(!user.canAddMoreCards)
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
            .alert(user.hasPhone ? "Update Phone Number" : "Add Phone Number", isPresented: $showPhoneAlert) {
                TextField("Phone Number", text: $newPhoneNumber)
                    .keyboardType(.phonePad)
                
                Button("Cancel", role: .cancel) {
                    newPhoneNumber = ""
                }
                
                if user.hasPhone {
                    Button("Remove", role: .destructive) {
                        Task {
                            await updatePhoneNumber(phone: "")
                        }
                    }
                }
                
                Button("Save") {
                    Task {
                        await updatePhoneNumber(phone: newPhoneNumber.trimmingCharacters(in: .whitespaces))
                    }
                }
                .disabled(newPhoneNumber.trimmingCharacters(in: .whitespaces).isEmpty)
                
            } message: {
                Text(user.hasPhone ? "Update your phone number or remove it" : "Add your phone number for easier booking")
            }
        }
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
    
    private func updatePhoneNumber(phone: String?) async {
        do {
            try await viewModel.updateUserProfile(fullname: nil, phone: phone)
        } catch {
            print("Failed to update phone: \(error.localizedDescription)")
        }
        
        newPhoneNumber = ""
    }
}
