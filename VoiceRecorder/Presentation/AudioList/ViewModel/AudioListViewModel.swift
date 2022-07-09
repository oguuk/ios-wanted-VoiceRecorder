//
//  AudioListViewModel.swift
//  VoiceRecorder
//
//  Created by 김승찬 on 2022/07/06.
//

import Foundation
import AVFoundation
import AVFAudio

enum TestError: LocalizedError {
    case endPointToNameFailed
}

class AudioListViewModel<Repository: AudioRepository> {

    private let repository: Repository
    
    private var soundEffect: AVAudioPlayer?
    let audioInformation: Observable<[AudioInformation]> = Observable([])
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func downloadAll() {
        Task.init {
            let names = try await repository.fetchAll()
            
            var audioInformations: [AudioInformation] = []
            
            for name in names {
                let audio = try await mapper(from: name)
                audioInformations.append(audio)
            }
            audioInformation.value = audioInformations
        }
    }
    
    // FIXME: endPoint로부터 name을 어떻게 얻어올까
    private func mapper(from endPoint: Repository.EndPoint) async throws -> AudioInformation {
        // guard let 옵셔널 바인딩 해주고 throw!!
        guard let name = endPoint as? String else { throw TestError.endPointToNameFailed }
        let data = try await repository.download(from: endPoint)
        let fileURL = repository.putDataLocally(from: endPoint)
        let duration = convertToDuration(from: data)

        let audioInformation = AudioInformation(
            name: name,
            data: data,
            fileURL: fileURL,
            duration: duration
        )

        return audioInformation
    }

    private func convertToDuration(from data: Data) -> TimeInterval {
        do {
            try soundEffect = AVAudioPlayer(data: data)
            guard let sound = soundEffect else {
                return .zero
            }
            return sound.duration
        } catch {
            print(error.localizedDescription)
        }
        return .zero
    }
}
