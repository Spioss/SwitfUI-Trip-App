//
//  AuthViewModel.swift
//  iza-app
//
//  Created by Lukáš Mader on 24/05/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init(){}
    
    func signIn(withEmail email: String, password: String) async throws{
        
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws{
        
    }
    
    func signOut(){
        
    }
    
    func deleteAccount(){
    
    }
    
    func fetchUser() async{
        
    }
}
