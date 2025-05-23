import SwiftUI

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
    var radius: CGFloat = .infinity
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

struct ContentView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                Color(hex: 0x1E1E1E)
                    .ignoresSafeArea()
                
                // Top Part
                VStack {
                    HStack {
                        Text("NX")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.purple)
                        Text("TRIP")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
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
                        
                        // components
                        VStack(spacing: 12) {
                            Spacer().frame(height: 60)
                            Button("Sign in") { }
                                .font(.system(size: 24, weight: .bold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
        
                            Button("Create Account") { }
                                .font(.system(size: 24, weight: .bold))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(Color.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                            
                        }
                        .padding()
                        .frame(height: geo.size.height * 0.5, alignment: .top)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
