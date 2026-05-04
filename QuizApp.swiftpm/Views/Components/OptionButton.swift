import SwiftUI

struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isAnswerChecked: Bool
    let isHidden: Bool
    var accentColor: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                
                Spacer()
                
                if isAnswerChecked {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 2)
            )
            .opacity(isHidden ? 0 : 1)
        }
        .disabled(isAnswerChecked || isHidden)
    }
    
    private var backgroundColor: Color {
        if isAnswerChecked {
            if isCorrect { return Color.green.opacity(0.2) }
            if isSelected { return Color.red.opacity(0.2) }
            return Color.white.opacity(0.05)
        }
        return isSelected ? accentColor.opacity(0.2) : Color.white.opacity(0.1)
    }
    
    private var borderColor: Color {
        if isAnswerChecked {
            if isCorrect { return .green }
            if isSelected { return .red }
            return .clear
        }
        return isSelected ? accentColor : .clear
    }
    
    private var textColor: Color {
        if isAnswerChecked {
            if isCorrect { return .green }
            if isSelected { return .red }
            return .primary.opacity(0.6)
        }
        return isSelected ? .primary : .primary
    }
}
