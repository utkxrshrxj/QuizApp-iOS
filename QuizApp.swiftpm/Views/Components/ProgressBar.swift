import SwiftUI

struct ProgressBar: View {
    let progress: Double
    var color: Color = .blue
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(height: 8)
                    .foregroundColor(Color.white.opacity(0.15))
                
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                    .foregroundColor(color)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: 8)
    }
}
