//
//  iza_appApp.swift
//  iza-app
//
//  Created by Lukáš Mader on 20/05/2025.
//

import SwiftUI
import Firebase

@main
struct iza_appApp: App{
    @StateObject var viewModel = AuthViewModel()
    
    init (){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
