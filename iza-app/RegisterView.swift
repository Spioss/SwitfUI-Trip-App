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
    var body: some View {
        VStack(spacing: 16){
            Group {
                TextField("First Name", text: $first_name)
                TextField("Last Name", text: $last_name)
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
    RegisterView()
}
