//
//  LoginView.swift
//  iza-app
//
//  Created by Lukáš Mader on 23/05/2025.
//


import SwiftUI

struct LoginView : View {
    @State var email: String = ""
    @State var password: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16){
            HStack {
                Text("NX")
                    .font(.system(size: 40, weight: .heavy, design: .monospaced))
                    .foregroundColor(.purple)
                Text("TRIP")
                    .font(.system(size: 40, weight: .heavy, design: .monospaced))
                    .foregroundColor(.black)
            }
            
            // Email and password fields
            Group {
                IconTextField(text: $email, systemImageName: "envelope.fill", placeholder: "Email Address", width: 360)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                IconSecureField(text: $password, systemImageName: "lock.fill", placeholder: "Password", width: 360)
            }
            
            // Login Button
            Button("Sign In") {
                Task{
                    try await viewModel.signIn(withEmail: email, password: password)
                }
            }
                .frame(width: 360, height: 50)
                .background(.black)
                .cornerRadius(10)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
            
            // Forgot Password Button
            Button(action: {}) {
                Text("Forgot Password?")
            }
                .buttonStyle(.plain)
                .foregroundColor(Color.gray)
            
            // Link na Register View
            NavigationLink("Don't have an account? Sign up") {
                RegisterView()
            }
            .foregroundColor(.purple)
            .padding(.top, 20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}



