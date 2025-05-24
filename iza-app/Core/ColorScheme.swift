//
//  ColorScheme.swift
//  iza-app
//
//  Created by Lukáš Mader on 25/05/2025.
//
//color system for light/dark mode

import SwiftUI

extension Color {
    // MARK: - Background Colors
    static let primaryBackground = Color("PrimaryBackground")
    static let secondaryBackground = Color("SecondaryBackground")
    static let cardBackground = Color("CardBackground")
    
    // MARK: - Text Colors
    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    static let placeholderText = Color("PlaceholderText")
    
    // MARK: - Brand Colors
    static let brandPurple = Color("BrandPurple")
    static let brandBlack = Color("BrandBlack")
    
    // MARK: - Interactive Colors
    static let buttonBackground = Color("ButtonBackground")
    static let buttonText = Color("ButtonText")
    static let inputBackground = Color("InputBackground")
    static let borderColor = Color("BorderColor")
    
    // MARK: - Status Colors
    static let errorColor = Color("ErrorColor")
    static let successColor = Color("SuccessColor")
    
    // MARK: - Fallback colors (ak nechceš vytvárať color assets)
    static let adaptiveBackground: Color = {
        Color(UIColor.systemBackground)
    }()
    
    static let adaptiveSecondaryBackground: Color = {
        Color(UIColor.secondarySystemBackground)
    }()
    
    static let adaptivePrimaryText: Color = {
        Color(UIColor.label)
    }()
    
    static let adaptiveSecondaryText: Color = {
        Color(UIColor.secondaryLabel)
    }()
    
    static let adaptivePlaceholder: Color = {
        Color(UIColor.placeholderText)
    }()
    
    static let adaptiveInputBackground: Color = {
        Color(UIColor.tertiarySystemBackground)
    }()
    
    static let adaptiveBorder: Color = {
        Color(UIColor.separator)
    }()
}

// MARK: - Theme Provider
class ThemeProvider: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    init() {
        isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
}
