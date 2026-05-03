import SwiftUI

struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isAnswerChecked: Bool
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
                            .font(.title3)
                            .transition(.scale)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                            .transition(.scale)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
            )
            .background(
                // Glassmorphism effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isAnswerChecked && (isCorrect || isSelected) ? 2 : 1)
            )
            .shadow(color: shadowColor, radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
        }
        .disabled(isAnswerChecked)
    }
    
    // MARK: - Dynamic Colors
    
    private var backgroundColor: Color {
        if isAnswerChecked {
            if isCorrect {
                return Color.green.opacity(0.4)
            } else if isSelected {
                return Color.red.opacity(0.4)
            } else {
                return Color.primary.opacity(0.05)
            }
        } else {
            return isSelected ? Color.blue.opacity(0.3) : Color.primary.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if isAnswerChecked {
            if isCorrect {
                return .green
            } else if isSelected {
                return .red
            } else {
                return Color.primary.opacity(0.1)
            }
        } else {
            return isSelected ? .blue : Color.primary.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        if isAnswerChecked && !isCorrect && !isSelected {
            return Color.primary.opacity(0.4)
        }
        return .primary
    }
    
    private var shadowColor: Color {
        if isAnswerChecked {
            if isCorrect { return Color.green.opacity(0.4) }
            if isSelected { return Color.red.opacity(0.4) }
        } else if isSelected {
            return Color.blue.opacity(0.4)
        }
        return Color.clear
    }
}
