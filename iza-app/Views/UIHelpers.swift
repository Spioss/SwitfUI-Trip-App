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
    var width: CGFloat? = nil

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .foregroundColor(.gray)
                .frame(width: 16)
            TextField(placeholder, text: $text)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 12)
        .padding(.leading, 16)
        .frame(width: width, height: 50)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .background(Color.black.opacity(0.05))
        .cornerRadius(10)
    }
}

struct IconSecureField: View {
    @Binding var text: String
    var systemImageName: String
    var placeholder: String
    var width: CGFloat? = nil

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .foregroundColor(.gray)
                .frame(width: 16)
            SecureField(placeholder, text: $text)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 12)
        .padding(.leading, 16)
        .frame(width: width, height: 50)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .background(Color.black.opacity(0.05))
        .cornerRadius(10)
    }
}

// extensions for hex color
extension Color {
    init(hex: UInt, opacity: Double = 1){
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

struct RoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner = []
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
