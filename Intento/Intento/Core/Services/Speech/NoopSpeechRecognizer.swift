import Foundation

struct NoopSpeechRecognizer: SpeechRecognizing {
    func requestAuthorization() async -> Bool { false }

    func startTranscribing() -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { $0.finish() }
    }

    func stopTranscribing() {}
}
