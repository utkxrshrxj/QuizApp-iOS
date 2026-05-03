import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var xVelocity: CGFloat
    var yVelocity: CGFloat
    let color: Color
    var rotation: Double
    var rotationSpeed: Double
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: 8, height: 8)
                        .position(x: particle.x, y: particle.y)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                startAnimation(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles(in size: CGSize) {
        for _ in 0..<100 {
            let particle = ConfettiParticle(
                x: size.width / 2,
                y: size.height / 2, // Start from center or top
                xVelocity: CGFloat.random(in: -10...10),
                yVelocity: CGFloat.random(in: -15...0),
                color: colors.randomElement() ?? .blue,
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -10...10)
            )
            particles.append(particle)
        }
    }
    
    private func startAnimation(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            for i in particles.indices {
                particles[i].x += particles[i].xVelocity
                particles[i].y += particles[i].yVelocity
                particles[i].yVelocity += 0.5 // Gravity
                particles[i].rotation += particles[i].rotationSpeed
            }
            
            // Stop when all fall off
            if particles.allSatisfy({ $0.y > size.height + 50 }) {
                timer.invalidate()
            }
        }
    }
}
