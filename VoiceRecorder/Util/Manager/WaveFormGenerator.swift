//
//  WaveFormGenerator.swift
//  VoiceRecorder
//
//  Created by 이윤주 on 2022/07/07.
//

import UIKit
import AVFoundation

final class WaveFormGenerator {
    
    func generateWaveImage(from audioURL: URL, in imageSize: CGSize) -> UIImage? {
        let samples = readBuffer(audioURL)
        let waveImage = generateWaveImage(samples, imageSize, UIColor.systemRed, UIColor.systemGray6)
        return waveImage
    }
    
    private func readBuffer(_ audioURL: URL) -> [Float] {
        // TODO: 1. fileURL을 받아서 해당 오디오 파일의 메모리에 접근한다.
        guard let file = try? AVAudioFile(forReading: audioURL) else { return [] }
        let audioFormat = file.processingFormat
        let audioFrameCount = UInt32(file.length)
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: audioFormat,
            frameCapacity: audioFrameCount
        ) else { return [] }
        
        do {
            try file.read(into: buffer)
        } catch {
            print(error.localizedDescription)
        }

        let bufferPointers = Array(
            UnsafeBufferPointer(
                start: buffer.floatChannelData![0],
                count: Int(buffer.frameLength / 1500)
            )
        )

        return bufferPointers
    }

    // TODO: 2. 메모리의 포인터를 통해 비트에 접근해(하는것처럼)
    private func generateWaveImage(
        _ samples: [Float],
        _ imageSize: CGSize,
        _ strokeColor: UIColor,
        _ backgroundColor: UIColor
    ) -> UIImage? {
        let drawingRect = CGRect(origin: .zero, size: imageSize)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        let middleY = imageSize.height / 2

        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(backgroundColor.cgColor)
        context.setAlpha(1.0)
        context.fill(drawingRect)
        context.setLineWidth(1.8)

        let max: CGFloat = CGFloat(samples.max() ?? 0)
        let heightNormalizationFactor = imageSize.height / max / 4
        let widthNormalizationFactor = imageSize.width / CGFloat(samples.count)
        for index in 0 ..< samples.count {
            // samples[index]는 각 비트에 접근한다고 보면될 듯
            let pixel = CGFloat(samples[index]) * heightNormalizationFactor

            let x = CGFloat(index) * widthNormalizationFactor

            // 커서의 위치를 해당 좌표로 이동
            context.move(to: CGPoint(x: x, y: middleY - pixel))
            // 시작 위치에서 해당 좌표까지 선 추가
            context.addLine(to: CGPoint(x: x, y: middleY + pixel))

            // 선 색상 설정
            context.setStrokeColor(strokeColor.cgColor)
            // 추가한 선을 그림
            context.strokePath()
        }
        guard let soundWaveImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

        UIGraphicsEndImageContext()
        return soundWaveImage
    }
}
