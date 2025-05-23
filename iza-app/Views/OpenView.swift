import SwiftUI

struct OpenView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Background
                    Color(hex: 0x1E1E1E).ignoresSafeArea()
                    
                    // Top Part
                    VStack {
                        HStack {
                            Text("NX")
                                .font(.system(size: 40, weight: .heavy, design: .monospaced))
                                .foregroundColor(.purple)
                            Text("TRIP")
                                .font(.system(size: 40, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Spacer().frame(height: 20)
                        
                        Text("Where will your")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Text("Next Trip be ?")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Spacer()  // Push everything up
                    }
                    .frame(height: geo.size.height * 0.5)
                    .frame(maxWidth: .infinity)
                    
                    // Bottom part
                    VStack() {
                        Spacer()
                        
                        ZStack {
                            RoundedCorners(radius: 30, corners: [.topLeft, .topRight])
                                .fill(Color.white)
                                .frame(height: geo.size.height * 0.5)
                                .ignoresSafeArea(edges: .bottom)
                            
                            // Sign in, Create Account Buttons
                            VStack(spacing: 12) {
                                Spacer().frame(height: 60)
                                NavigationLink(destination: LoginView()){
                                    Text("Sign in")
                                        .font(.system(size: 20, weight: .semibold))
                                        .padding()
                                        .frame(maxWidth: .infinity, maxHeight: 60)
                                        .background(Color.black)
                                        .foregroundColor(Color.white)
                                        .cornerRadius(10)
                                }
                                
                                NavigationLink(destination: RegisterView()){
                                    Text("Create Account")
                                        .font(.system(size: 20, weight: .semibold))
                                        .padding()
                                        .frame(maxWidth: .infinity, maxHeight: 60)
                                        .background(Color.white)
                                        .foregroundColor(Color.black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                }
                                               
                            }
                            .padding()
                            .frame(height: geo.size.height * 0.5, alignment: .top)
                        }.ignoresSafeArea()
                        
                    }
                }
            }
        }.navigationBarHidden(true)
    }
}

#Preview {
    OpenView()
}
