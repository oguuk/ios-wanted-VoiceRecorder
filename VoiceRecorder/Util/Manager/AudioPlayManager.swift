//
//  AudioPlayManager.swift
//  VoiceRecorder
//
//  Created by 오국원 on 2022/07/07.
//

import AVFoundation

struct AudioPlayManager {
    
    let audioURL: URL
    
    let engine = AVAudioEngine()
    var audioFile: AVAudioFile?
    
    var unitTimePitch = AVAudioUnitTimePitch()
    let speedControl = AVAudioUnitVarispeed()
    let audioPlayer = AVAudioPlayerNode()
    
    private var audioSampleRate: Double = 0
    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    
    init(audioURL: URL) {
        self.audioURL = audioURL
        do {
           try setupAudio(audioURL)
        }catch {

        }
    }
    
    mutating func setupAudio(_ url: URL) throws {
        audioFile = try AVAudioFile(forReading: url)
        
        guard let file = audioFile else {return}
        let format = file.processingFormat
        
        audioLengthSamples = file.length
        audioSampleRate = format.sampleRate
        
        audioFile = file

        engine.attach(audioPlayer)
        engine.attach(unitTimePitch)
        engine.attach(speedControl)
        
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: unitTimePitch, format: nil)
        engine.connect(unitTimePitch, to: engine.mainMixerNode, format: nil)
        
        audioPlayer.scheduleFile(file, at: nil)
        
        try engine.start()
    }
    
    func changePitch(to pitch: Int) {
        switch pitch {
        case 0:
            unitTimePitch.pitch = 0
        case 1:
            unitTimePitch.pitch = 1300
        default:
            unitTimePitch.pitch = -1300
        }
    }
    
    func controlVolume(to volume: Float) {
        audioPlayer.volume = volume
    }
    
    mutating func seek(to time: Double) {
        guard let audioFile = audioFile else {
            return
        }
        
        let offset = AVAudioFramePosition(time * audioSampleRate)
        
        seekFrame = currentPosition + offset
        seekFrame = max(seekFrame, 0)
        seekFrame = min(seekFrame, audioLengthSamples)
        currentPosition = seekFrame
        
        let wasPlaying = audioPlayer.isPlaying
        audioPlayer.stop()
        
        
        
        if currentPosition < audioLengthSamples {
            
            let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
            audioPlayer.scheduleSegment(
                audioFile,
                startingFrame: seekFrame,
                frameCount: frameCount,
                at: nil
            )
            
            if wasPlaying {
                audioPlayer.play()
            }
        }
    }
    
    func play() {
        audioPlayer.play()
    }
    
    func pause() {
        audioPlayer.pause()
    }

    func currentTime() -> Double {
        
        guard let nodeTime = audioPlayer.lastRenderTime,
              let playerTime = audioPlayer.playerTime(forNodeTime: nodeTime) else {
            return .zero
        }
        
        let sampleRate = audioPlayer.outputFormat(forBus: 0).sampleRate
        
        let currentTime = Double(playerTime.sampleTime) / sampleRate
        return currentTime
    }
}
