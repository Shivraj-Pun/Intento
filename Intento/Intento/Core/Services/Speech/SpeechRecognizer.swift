import Foundation

#if canImport(Speech) && os(iOS)
import Speech
import AVFoundation

@MainActor
final class SpeechRecognizer: SpeechRecognizing {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_IN")) ?? SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func requestAuthorization() async -> Bool {
        let speechGranted = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        guard speechGranted else { return false }

        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startTranscribing() -> AsyncThrowingStream<String, Error> {
        let (stream, continuation) = AsyncThrowingStream<String, Error>.makeStream()
        
        do {
            try start { text in
                continuation.yield(text)
            } onError: { error in
                continuation.finish(throwing: error)
            }
        } catch {
            continuation.finish(throwing: error)
        }

        continuation.onTermination = { @Sendable [weak self] _ in
            guard let strongSelf = self else { return }
            Task { @MainActor in
                strongSelf.stopTranscribing()
            }
        }
        
        return stream
    }

    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func start(onText: @escaping (String) -> Void, onError: @escaping (Error) -> Void) throws {
        task?.cancel()
        task = nil

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer?.recognitionTask(with: request) { result, error in
            if let result {
                onText(result.bestTranscription.formattedString)
            }
            if let error {
                onError(error)
            }
        }
    }
}
#endif
