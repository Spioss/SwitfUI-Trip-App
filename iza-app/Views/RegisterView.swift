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
                HStack{
                    IconTextField(text: $first_name, systemImageName: "person.fill", placeholder: "First Name")
                    IconTextField(text: $last_name, systemImageName: "person.fill", placeholder: "Last Name")
                }
                IconTextField(text: $email, systemImageName: "envelope.fill", placeholder: "Email Address")
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                IconSecureField(text: $password, systemImageName: "lock.fill", placeholder: "Password")
            }
            
        }
    }
}

#Preview {
    RegisterView()
}
