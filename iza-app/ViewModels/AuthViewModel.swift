//
//  AuthViewModel.swift
//  iza-app
//
//  Created by Lukáš Mader on 24/05/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var showLoadingView = false
    @Published var errorMessage = ""
    
    
    init(){
        self.userSession = Auth.auth().currentUser
        
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        showLoadingView = true
        errorMessage = ""
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch let error as NSError{
            switch AuthErrorCode(rawValue: error.code) {
                case .invalidEmail:
                    errorMessage = "Invalid Mail"
                case .tooManyRequests:
                    errorMessage = "Too many attempts, please try again later"
                case .networkError:
                    errorMessage = "Network Error"
                default:
                    errorMessage = "Password or Email is incorrect."
                }
        }
        
        showLoadingView = false 
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws{
        showLoadingView = true
        errorMessage = ""
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email, phone: nil, savedCards: []) // our model currentUser
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser() // wait for fetch of data to our Model
        } catch let error as NSError{
            switch AuthErrorCode(rawValue: error.code) {
                case .invalidEmail:
                    errorMessage = "Invalid Mail"
                case .tooManyRequests:
                    errorMessage = "Too many attempts, please try again later"
                case .networkError:
                    errorMessage = "Network Error"
                default:
                    errorMessage = "Incorrect email, password or fullname."
                }
        }
        
        showLoadingView = false
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut() // signs out user in Firebase
            self.userSession = nil // wipes userSession
            self.currentUser = nil // wipes our Model
        } catch {
            print("DEBUG: Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async{
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        do {
            try await Firestore.firestore().collection("users").document(uid).delete()
            try await user.delete()
        
            signOut()
        } catch {
            print("")
        }
    }
    
    func fetchUser() async{
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    func updateUserProfile(fullname: String?, phone: String?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        errorMessage = ""
        
        do {
            var updateData: [String: Any] = [:]
            
            // Update fullname if provided
            if let fullname = fullname {
                updateData["fullname"] = fullname
            }
            
            // Update phone if provided (can be nil to remove)
            if phone != nil {
                updateData["phone"] = phone
            }
            
            // Update in Firestore
            try await Firestore.firestore().collection("users").document(uid).updateData(updateData)
            
            // Update local currentUser
            if let currentUser = self.currentUser {
                self.currentUser = User(
                    id: currentUser.id,
                    fullname: fullname ?? currentUser.fullname,
                    email: currentUser.email,
                    phone: phone ?? currentUser.phone,
                    savedCards: currentUser.savedCards
                )
            }
            
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            throw error
        }
    }
}


extension AuthViewModel {
    func prefillBookingData() -> (fullname: String, email: String, phone: String) {
        guard let user = currentUser else {
            return ("", "", "")
        }
        
        return (
            fullname: user.fullname,
            email: user.email,
            phone: user.phone ?? ""
        )
    }
}

//Credit Card Managment
extension AuthViewModel {
    func addCreditCard(_ card: SavedCreditCard) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        guard let currentUser = self.currentUser else { return }
        errorMessage = ""
        
        do {
            var updatedCards = currentUser.savedCards
            
            // If this is the first card or set as default, make it default
            if card.isDefault || updatedCards.isEmpty {
                // Remove default from other cards
                updatedCards = updatedCards.map { existingCard in
                    SavedCreditCard(
                        id: existingCard.id,
                        cardHolderName: existingCard.cardHolderName,
                        last4Digits: existingCard.last4Digits,
                        expiryMonth: existingCard.expiryMonth,
                        expiryYear: existingCard.expiryYear,
                        cardType: existingCard.cardType,
                        isDefault: false,
                        nickname: existingCard.nickname
                    )
                }
            }
            
            // Add new card
            updatedCards.append(card)
            
            // Update in Firestore
            let encodedCards = try updatedCards.map { try Firestore.Encoder().encode($0) }
            try await Firestore.firestore().collection("users").document(uid).updateData([
                "savedCards": encodedCards
            ])
            
            // Update local currentUser
            self.currentUser = User(
                id: currentUser.id,
                fullname: currentUser.fullname,
                email: currentUser.email,
                phone: currentUser.phone,
                savedCards: updatedCards
            )
            
        } catch {
            errorMessage = "Failed to add credit card: \(error.localizedDescription)"
            throw error
        }
    
    }
    
    func removeCreditCard(_ cardId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let currentUser = self.currentUser else { return }
        errorMessage = ""
        
        do {
            var updatedCards = currentUser.savedCards.filter { $0.id != cardId }
            
            // If we removed the default card and there are other cards, make the first one default
            if !updatedCards.isEmpty && !updatedCards.contains(where: { $0.isDefault }) {
                updatedCards[0] = SavedCreditCard(
                    id: updatedCards[0].id,
                    cardHolderName: updatedCards[0].cardHolderName,
                    last4Digits: updatedCards[0].last4Digits,
                    expiryMonth: updatedCards[0].expiryMonth,
                    expiryYear: updatedCards[0].expiryYear,
                    cardType: updatedCards[0].cardType,
                    isDefault: true,
                    nickname: updatedCards[0].nickname
                )
            }
            
            // Update in Firestore
            let encodedCards = try updatedCards.map { try Firestore.Encoder().encode($0) }
            try await Firestore.firestore().collection("users").document(uid).updateData([
                "savedCards": encodedCards
            ])
            
            // Update local currentUser
            self.currentUser = User(
                id: currentUser.id,
                fullname: currentUser.fullname,
                email: currentUser.email,
                phone: currentUser.phone,
                savedCards: updatedCards
            )
            
        } catch {
            errorMessage = "Failed to remove credit card: \(error.localizedDescription)"
        }
    
    }
    
    func setDefaultCard(_ cardId: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let currentUser = self.currentUser else { return }
        
        errorMessage = ""
        
        do {
            let updatedCards = currentUser.savedCards.map { card in
                SavedCreditCard(
                    id: card.id,
                    cardHolderName: card.cardHolderName,
                    last4Digits: card.last4Digits,
                    expiryMonth: card.expiryMonth,
                    expiryYear: card.expiryYear,
                    cardType: card.cardType,
                    isDefault: card.id == cardId,
                    nickname: card.nickname
                )
            }
            
            // Update in Firestore
            let encodedCards = try updatedCards.map { try Firestore.Encoder().encode($0) }
            try await Firestore.firestore().collection("users").document(uid).updateData([
                "savedCards": encodedCards
            ])
            
            // Update local currentUser
            self.currentUser = User(
                id: currentUser.id,
                fullname: currentUser.fullname,
                email: currentUser.email,
                phone: currentUser.phone,
                savedCards: updatedCards
            )
            
        } catch {
            errorMessage = "Failed to set default card: \(error.localizedDescription)"
        }
    }
    
    func getDefaultCardForBooking() -> SavedCreditCard? {
        return currentUser?.defaultCard
    }
}
