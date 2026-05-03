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
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .disabled(isAnswerChecked)
    }
    
    // MARK: - Dynamic Colors
    
    private var backgroundColor: Color {
        if isAnswerChecked {
            if isCorrect {
                return Color.green.opacity(0.1)
            } else if isSelected {
                return Color.red.opacity(0.1)
            } else {
                return Color.gray.opacity(0.05)
            }
        } else {
            return isSelected ? Color.blue.opacity(0.1) : Color(UIColor.systemBackground)
        }
    }
    
    private var borderColor: Color {
        if isAnswerChecked {
            if isCorrect {
                return .green
            } else if isSelected {
                return .red
            } else {
                return .gray.opacity(0.3)
            }
        } else {
            return isSelected ? .blue : .gray.opacity(0.3)
        }
    }
    
    private var textColor: Color {
        if isAnswerChecked && !isCorrect && !isSelected {
            return .gray
        }
        return .primary
    }
}
