//
//  RegisterView.swift
//  iza-app
//
//  Created by Lukáš Mader on 23/05/2025.
//

import SwiftUI

protocol AuthenticationForm {
    var formIsValid: Bool { get }
}

struct RegisterView : View {
    @State var first_name: String = ""
    @State var last_name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var conf_password: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Adaptívne pozadie
            Color.adaptiveBackground
                .ignoresSafeArea()
            
            VStack(spacing: 16){
                HStack {
                    Text("NX")
                        .font(.system(size: 40, weight: .heavy, design: .monospaced))
                        .foregroundColor(.purple)
                    Text("TRIP")
                        .font(.system(size: 40, weight: .heavy, design: .monospaced))
                        .foregroundColor(Color.adaptivePrimaryText)
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
                    
                    ZStack(alignment: .trailing){
                        IconSecureField(text: $password, systemImageName: "lock.fill", placeholder: "Password", width: 360)
                        
                        if !password.isEmpty && !conf_password.isEmpty {
                            if password == conf_password {
                                Image(systemName: "checkmark")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .padding(.trailing, 20)
                            } else {
                                Image(systemName: "xmark")
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                    
                    ZStack(alignment: .trailing){
                        IconSecureField(text: $conf_password, systemImageName: "lock.fill", placeholder: "Confirm Password", width: 360)
                        
                        if !password.isEmpty && !conf_password.isEmpty {
                            if password == conf_password {
                                Image(systemName: "checkmark")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .padding(.trailing, 20)
                            } else {
                                Image(systemName: "xmark")
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                }
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .scale))
                }
                
                // Register Button
                Button("Create Account") {
                    Task{
                        try await viewModel.createUser(
                            withEmail: email,
                            password: password,
                            fullname: (first_name + " " +  last_name)
                        )
                    }
                }
                .frame(width: 360, height: 50)
                .background(Color.adaptivePrimaryText)
                .cornerRadius(10)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.adaptiveBackground)
                .padding(.top, 20)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                // Link na Login View
                NavigationLink("Already have an account? Sign in") {
                    LoginView()
                }
                .foregroundColor(.purple)
                .padding(.top, 20)
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage.isEmpty)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(Color.adaptivePrimaryText)
                }
            }
        }
    }
}

extension RegisterView: AuthenticationForm {
    var formIsValid: Bool {
        return !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count > 5
            && !first_name.isEmpty
            && !last_name.isEmpty
            && conf_password == password
    }
}
