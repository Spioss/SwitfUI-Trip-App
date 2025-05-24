//
//  iza_appApp.swift
//  iza-app
//
//  Created by Lukáš Mader on 20/05/2025.
//

import SwiftUI

@main
struct iza_appApp: App{
    @StateObject var viewModel = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            OpenView()
                .environmentObject(viewModel)
        }
    }
}
