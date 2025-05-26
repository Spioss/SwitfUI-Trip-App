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
            let user = User(id: result.user.uid, fullname: fullname, email: email, phone: nil) // our model currentUser
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
                    phone: phone ?? currentUser.phone
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
