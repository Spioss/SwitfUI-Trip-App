import SwiftUI

struct OpenView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                
                ZStack {
                    // Dark background
                    Color(hex: 0x1E1E1E).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Top section with logo and text
                        VStack() {
                            Spacer().frame(height: 80)
                            
                            // Logo
                            HStack(spacing: 0) {
                                Text("Nx")
                                    .font(.system(size: 60, weight: .heavy, design: .default))
                                    .foregroundColor(.purple)
                                Text("Trip")
                                    .font(.system(size: 60, weight: .heavy, design: .default))
                                    .foregroundColor(.white)
                            }
                            
                            // Main text
                            VStack() {
                                Text("WHERE WILL YOUR")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                HStack(spacing: 0) {
                                    Text("NEXT TRIP ")
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .foregroundColor(.purple)
                                    Text("BE ?")
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(height: geo.size.height * 0.55)
                        
                        
                        // Bottom section with buttons
                        VStack(spacing: 0) {
                            ZStack {
                                // White rounded background
                                RoundedCorners(radius: 30, corners: [.topLeft, .topRight])
                                    .fill(Color.white)
                                    .frame(height: geo.size.height * 0.65)
                                
                                // Buttons container
                                VStack(spacing: 12) {
                                    Spacer().frame(height: 30)
                                    
                                    // Continue with Google
                                    Button(action: { print("Continue with Google") })
                                    {
                                        HStack(spacing: 10) {
                                            Image(systemName: "globe")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.black)
                                            Text("Continue with Google")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.black)
                                        }
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, maxHeight: 60)
                                        .background(Color.white)
                                        .cornerRadius(24)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    // Continue with Apple
                                    Button(action: {
                                        print("Continue with Apple")
                                    }) {
                                        HStack(spacing: 10) {
                                            Image(systemName: "applelogo")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.black)
                                            Text("Continue with Apple")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.black)
                                        }
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, maxHeight: 55)
                                        .background(Color.white)
                                        .cornerRadius(24)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    // Sign In button
                                    NavigationLink(destination: LoginView()) {
                                        Text("Sign In")
                                            .font(.system(size: 20, weight: .semibold))
                                            .padding()
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, maxHeight: 55)
                                            .background(.black)
                                            .cornerRadius(24)
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    // Create account button
                                    NavigationLink(destination: RegisterView()) {
                                        Text("Create account")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, maxHeight: 55)
                                            .background(Color.white)
                                            .cornerRadius(24)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .stroke(Color.black, lineWidth: 2)
                                            )
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    
                                    Spacer().frame(height: 45)
                                    
                                    // Social media icons
                                    HStack(spacing: 25) {
                                        Button(action: {}) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Button(action: {}) {
                                            Image(systemName: "link")
                                                .font(.system(size: 20))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    
                                    // Terms text
                                    VStack(spacing: 2) {
                                        Text("By creating an account or signing you")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                        HStack(spacing: 4) {
                                            Text("agree to our")
                                                .font(.system(size: 11))
                                                .foregroundColor(.gray)
                                            Button(action: {}) {
                                                Text("Terms and Conditions")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.black)
                                                    .underline()
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .frame(height: geo.size.height * 0.45)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    OpenView()
}
