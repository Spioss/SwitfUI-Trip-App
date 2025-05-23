//
//  RegisterView.swift
//  iza-app
//
//  Created by Lukáš Mader on 23/05/2025.
//

import SwiftUI


struct RegisterView : View {
    
    @State var first_name: String = ""
    @State var last_name: String = ""
    @State var email: String = ""
    @State var password: String = ""
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
            .padding(.bottom, 30)
            
            Group {
                HStack(spacing: 8){
                    IconTextField(text: $first_name, systemImageName: "person.fill", placeholder: "First Name")
                    IconTextField(text: $last_name, systemImageName: "person.fill", placeholder: "Last Name")
                }.padding(.horizontal, 20)
                IconTextField(text: $email, systemImageName: "envelope.fill", placeholder: "Email Address", width: 360)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                IconSecureField(text: $password, systemImageName: "lock.fill", placeholder: "Password", width: 360)
            }
            
            // Register Button
            Button("Create Account") { print("Creating account...") }
                .frame(width: 360, height: 50)
                .background(Color.black)
                .cornerRadius(10)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Link na Login View
            NavigationLink("Already have an account? Sign in") {
                LoginView()
            }
            .foregroundColor(.purple)
            .padding(.top, 20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Create Account")
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
    RegisterView()
}
