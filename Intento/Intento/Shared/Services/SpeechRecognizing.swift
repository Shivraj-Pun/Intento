import Foundation

protocol SpeechRecognizing: Sendable {
    func requestAuthorization() async -> Bool

    func startTranscribing() -> AsyncThrowingStream<String, Error>

    func stopTranscribing()
}
