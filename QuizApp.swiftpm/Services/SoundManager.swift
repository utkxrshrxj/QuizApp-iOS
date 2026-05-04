import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var backgroundPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?
    
    private init() {}
    
    // SFX
    func playCorrectSound() {
        // System sound as fallback
        AudioServicesPlaySystemSound(1322)
    }
    
    func playIncorrectSound() {
        // System sound as fallback
        AudioServicesPlaySystemSound(1053)
    }
    
    // Dynamic Soundscapes
    func startBackgroundMusic(intensity: String = "normal") {
        let fileName = intensity == "normal" ? "ambient_loop" : "intense_loop"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundPlayer?.volume = 0.3
            backgroundPlayer?.play()
        } catch {
            print("Could not load background music: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }
    
    func setIntensity(_ intensity: String) {
        // In a real app, we would cross-fade between two loops.
        // For now, we'll just restart with the new intensity if the file exists.
        startBackgroundMusic(intensity: intensity)
    }
}
