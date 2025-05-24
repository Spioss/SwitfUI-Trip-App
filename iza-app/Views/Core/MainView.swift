//
//  MainView.swift
//  iza-app
//
//  Created by Lukáš Mader on 24/05/2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showDeleteAlert = false
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack{
                        Text(getInitials(fullname: user.fullname))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4){
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Account"){
                    Button{
                        viewModel.signOut()
                    } label: {
                        TextWithImage(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        TextWithImage(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                    }
                    .alert("Delete Account", isPresented: $showDeleteAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            Task {
                                await viewModel.deleteAccount()
                            }
                        }
                    } message: {
                        Text("Are you sure you want to delete your account? This action cannot be undone.")
                    }
                    
                }
            
            }
        }
    }
}


