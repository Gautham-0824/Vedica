import AVFoundation

/// Reads captions aloud. Mirrors the web build's speechSynthesis wrapper.
final class Narrator {
    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String, localeId: String) {
        stop()
        var t = text
        let swaps: [(String, String)] = [
            ("\u{00D7}", " times "), ("\u{2212}", " minus "), ("\u{00B2}", " squared "), ("\u{00B3}", " cubed "),
            ("=", " equals "), ("\u{00F7}", " divided by "), ("\u{2713}", ""), ("\u{2717}", ""), ("\u{2260}", " is not equal to "),
        ]
        for (a, b) in swaps { t = t.replacingOccurrences(of: a, with: b) }
        let u = AVSpeechUtterance(string: t)
        u.voice = AVSpeechSynthesisVoice(language: localeId) ?? AVSpeechSynthesisVoice(language: String(localeId.prefix(2)))
        u.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95
        synth.speak(u)
    }

    func stop() {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
    }
}
