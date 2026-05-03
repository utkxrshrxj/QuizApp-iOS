import SwiftUI

struct ProgressBar: View {
    let progress: Double // Value between 0.0 and 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(height: 8)
                    .foregroundColor(Color.gray.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                    .foregroundColor(.blue)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: 8)
    }
}
