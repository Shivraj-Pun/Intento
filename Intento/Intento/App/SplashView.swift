import SwiftUI

struct FallingItem: Identifiable {
    let id = UUID()
    let systemName: String
    let color: Color
    let finalOffset: CGSize
    let rotation: Double
}

struct SplashView: View {
    @State private var itemsStartedFalling = false
    
    let fallingItems: [FallingItem] = [
        FallingItem(systemName: "carrot.fill", color: .orange, finalOffset: CGSize(width: -60, height: -40), rotation: -20),
        FallingItem(systemName: "leaf.fill", color: .green, finalOffset: CGSize(width: 40, height: -70), rotation: 15),
        FallingItem(systemName: "cup.and.saucer.fill", color: .brown, finalOffset: CGSize(width: 70, height: -10), rotation: 30),
        FallingItem(systemName: "fork.knife", color: .gray, finalOffset: CGSize(width: -40, height: -80), rotation: -45)
    ]
    
    var body: some View {
        ZStack {
            AppColor.Semantic.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .zIndex(1) // Keep logo on top of falling items if they overlap
                    
                    // Falling items
                    ForEach(fallingItems) { item in
                        Image(systemName: item.systemName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(item.color)
                            .rotationEffect(.degrees(itemsStartedFalling ? item.rotation : item.rotation + 180))
                            .offset(
                                x: item.finalOffset.width,
                                y: itemsStartedFalling ? item.finalOffset.height : -400
                            )
                            .opacity(itemsStartedFalling ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0).delay(Double.random(in: 0...0.2)), value: itemsStartedFalling)
                    }
                }
                
                Text("Intend it we find it")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColor.Semantic.textPrimary)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                itemsStartedFalling = true
            }
        }
    }
}

#Preview {
    SplashView()
}
