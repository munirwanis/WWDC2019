import UIKit
import AVFoundation

public protocol MusicDelegate {
    
    /// Notifies when the music stops playing
    ///
    /// - Parameter successfully: Boolean that confirms if the music stopped
    /// with success or no
    func musicDidEndPlaying(successfully: Bool)
    
    /// This is called on every beat of the music, it's based on the BPM
    func musicDidPassOneBeat()
}

public class Music: NSObject {
    private let audioPlayer: AVAudioPlayer
    public let bpm: Double
    
    private var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }
    
    public var isPlaying: Bool {
        return self.audioPlayer.isPlaying
    }
    
    public var delegate: MusicDelegate? {
        didSet {
            self.audioPlayer.delegate = self
        }
    }
    
    /// Starts the music class
    ///
    /// - Parameters:
    ///   - fileName: The name of the music to be played
    ///   - ext: The extension of the music to be played
    ///   - bpm: The BPM of the music to be played
    public init(fileName: String, ext: String, bpm: Double) {
        self.bpm = bpm
        
        guard let songPath = Bundle.main.path(forResource: fileName,
                                              ofType: ext) else {
            fatalError("Could not load song")
        }
        let url = URL(fileURLWithPath: songPath)
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            try AVAudioSession.sharedInstance()
                .setCategory(.playback,
                             mode: .default,
                             options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            fatalError("Could not load song, \(error)")
        }
        self.audioPlayer.isMeteringEnabled = true
        self.audioPlayer.prepareToPlay()
    }
}


// MARK: - Public methods

extension Music {
    
    /// The duration in seconds of a beat
    ///
    /// - Parameter duration: The duration of a quarter
    /// - Returns: Seconds of a beat
    public func seconds(duration: Double = 0.25) -> Double {
        return 1.0 / bpm * 60.0 * 4.0 * duration
    }
    
    /// Play or pauses the music
    public func playOrPause() {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            timer = nil
        } else {
            audioPlayer.play()
            
            timer = Timer.scheduledTimer(timeInterval: seconds(),
                                         target: self,
                                         selector: #selector(timerAction),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    /// Stop the music completly
    public func stop() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        timer = nil
    }
    
    /// The average dBs at the instant
    ///
    /// - Returns: The average dBs from the instant of the music
    public func getAverageDecibels() -> Float {
        self.audioPlayer.updateMeters()
        let left = audioPlayer.averagePower(forChannel: 0)
        let right = audioPlayer.averagePower(forChannel: 1)
        return (left + right) / 2
    }
}

// MARK: - Actions

extension Music {
    @objc private func timerAction() {
        delegate?.musicDidPassOneBeat()
    }
}


// MARK: - Delegate

extension Music: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                            successfully flag: Bool) {
        print("Audio player finished")
        delegate?.musicDidEndPlaying(successfully: flag)
        timer = nil
    }
}
