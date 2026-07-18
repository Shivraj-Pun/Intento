import SwiftUI

struct SplashView: View {
    @State private var startAnimation = false
    
    var body: some View {
        ZStack {
            AppColor.Semantic.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    // Icon falls from top
                    .offset(y: startAnimation ? 0 : -400)
                    .opacity(startAnimation ? 1 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0).delay(0.1),
                        value: startAnimation
                    )
                
                Text("Intend it we find it")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(AppColor.Semantic.textPrimary)
                    // Text falls from top with the icon
                    .offset(y: startAnimation ? 0 : -400)
                    .opacity(startAnimation ? 1 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0).delay(0.1),
                        value: startAnimation
                    )
            }
        }
        .onAppear {
            // Trigger animations
            startAnimation = true
        }
    }
}

#Preview {
    SplashView()
}
