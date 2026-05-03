import AudioToolbox

class SoundManager {
    static let shared = SoundManager()
    
    // Using standard iOS system sounds
    func playCorrectSound() {
        // 1322 is a nice "bling" success sound
        AudioServicesPlaySystemSound(1322)
    }
    
    func playIncorrectSound() {
        // 1053 is a standard UI error "bloop"
        AudioServicesPlaySystemSound(1053)
    }
}
