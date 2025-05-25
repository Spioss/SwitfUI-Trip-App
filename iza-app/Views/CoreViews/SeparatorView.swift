//
//  SeparatorView.swift
//  iza-app
//
//  Created by Lukáš Mader on 24/05/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack{
            Group {
                if viewModel.userSession != nil {
                    MainView()
                } else {
                    OpenView()
                }
            }
            
            if viewModel.showLoadingView == true{
                LoadingView().transition(.opacity).zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showLoadingView)
    }
}
