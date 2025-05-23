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
                IconTextField(text: $email, systemImageName: "envelope.fill", placeholder: "Email Address")
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                IconSecureField(text: $password, systemImageName: "lock.fill", placeholder: "Password")
            }
            
            // Login Button
            Button("Sign In") {}
                .frame(width: 320, height: 50)
                .background(Color.black)
                .cornerRadius(10)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
            
            // Forgot Password Button
            Button(action: {}) {
                Text("Forgot Password?")
            }
            .buttonStyle(.plain)
            .foregroundColor(Color.gray)
            
            
        }
    }
}

#Preview {
    LoginView()
}



