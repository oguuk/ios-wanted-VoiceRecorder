//
//  PlayViewModel.swift
//  VoiceRecorder
//
//  Created by 오국원 on 2022/07/06.
//

import UIKit
import AVFoundation

final class PlayViewModel {
    
    var audioInformation: AudioInformation
    var currentTime: Observable<Double> = Observable(.zero)
    private var audioPlayManager: AudioPlayManager
    private var timer: Timer?
    
    init(audioInformation: AudioInformation) {
        self.audioInformation = audioInformation
        self.audioPlayManager = AudioPlayManager(audioURL: audioInformation.fileURL)
    }
    
    func changePitch(to voice: Int) {
        audioPlayManager.changePitch(to: voice)
    }
    
    func controlVolume(to volume: Float) {
        audioPlayManager.controlVolume(to: volume)
    }
    
    func move(seconds: Double) {
        audioPlayManager.seek(to: seconds)
        updateCurrentTime()
    }
    
    func play() {
        audioPlayManager.play()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateCurrentTime()
        }
        timer?.tolerance = 0.1
    }
    
    func pause() {
        audioPlayManager.pause()
        currentTime.value += 0.01
        timer?.invalidate()
    }
    
    private func updateCurrentTime() {
        currentTime.value = audioPlayManager.currentTime()
    }
}
