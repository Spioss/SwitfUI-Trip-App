//
//  UIHelpers.swift
//  iza-app
//
//  Created by Lukáš Mader on 23/05/2025.
//
import SwiftUI

struct IconTextField: View {
    @Binding var text: String
    var systemImageName: String
    var placeholder: String

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 12)
        .padding(.leading, 16)
        .frame(width: 320, height: 50)
        .background(Color.black.opacity(0.05))
        .cornerRadius(10)
    }
}

struct IconSecureField: View {
    @Binding var text: String
    var systemImageName: String
    var placeholder: String

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .foregroundColor(.gray)
            SecureField(placeholder, text: $text)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 12)
        .padding(.leading, 16)
        .frame(width: 320, height: 50)
        .background(Color.black.opacity(0.05))
        .cornerRadius(10)
    }
}
