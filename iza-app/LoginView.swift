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
            Group {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            
        }
    }
}

#Preview {
    LoginView()
}



