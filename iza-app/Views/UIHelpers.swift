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
                .foregroundColor(Color.adaptiveSecondaryText)
                .frame(width: 16)
            TextField(placeholder, text: $text)
                .foregroundColor(Color.adaptivePrimaryText)
        }
        .padding(.vertical, 12)
        .padding(.leading, 16)
        .frame(width: width, height: 50)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .background(Color.adaptiveInputBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.adaptiveBorder, lineWidth: 0.5)
        )
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
                .foregroundColor(Color.adaptiveSecondaryText)
                .frame(width: 16)
            SecureField(placeholder, text: $text)
                .foregroundColor(Color.adaptivePrimaryText)
        }
        .padding(.vertical, 12)
        .padding(.leading, 16)
        .frame(width: width, height: 50)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .background(Color.adaptiveInputBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.adaptiveBorder, lineWidth: 0.5)
        )
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

struct TextWithImage: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12){
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.adaptivePrimaryText)
        }
    }
}

func getInitials(fullname: String) -> String {
    let initials = fullname
        .split(separator: " ")
        .compactMap { $0.first }
        .map { String($0).uppercased() }
        .joined()
    return initials
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.adaptivePrimaryText)
            .foregroundColor(Color.adaptiveBackground)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.adaptiveSecondaryBackground)
            .foregroundColor(Color.adaptivePrimaryText)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.adaptiveBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

private func getInitials(from fullName: String) -> String {
    let nameParts = fullName.split(separator: " ")
    let initials = nameParts.compactMap { $0.first }.map { String($0).uppercased() }
    return initials.joined()
}


struct CustomStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(value > range.lowerBound ? Color.purple : Color.gray)
                        .cornerRadius(6)
                }
                .disabled(value <= range.lowerBound)
                
                Text("\(value)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(minWidth: 24)
                
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(value < range.upperBound ? Color.purple : Color.gray)
                        .cornerRadius(6)
                }
                .disabled(value >= range.upperBound)
            }
        }
        .padding()
        .background(Color.adaptiveSecondaryBackground)
        .cornerRadius(12)
    }
}
