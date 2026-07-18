//
//  SpeechRecognizing.swift
//  Intento (Ask Blinkit)
//

import Foundation

/// Voice-input transcription used as an alternate mode of the text input (not a
/// separate screen). Wraps the Speech framework in Phase 2; consumers depend
/// only on this protocol so it can be mocked in previews/tests.
protocol SpeechRecognizing: Sendable {
    /// Requests microphone + speech-recognition authorization.
    func requestAuthorization() async -> Bool

    /// Begins transcription, streaming partial then final transcripts.
    func startTranscribing() -> AsyncThrowingStream<String, Error>

    /// Stops an in-progress transcription session.
    func stopTranscribing()
}
