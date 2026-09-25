import FoundationModels
import SwiftUI

/// Whether the on-device model can be used, and if not, why.
/// Only AI features depend on it: groups and words can always be added by hand.
enum AIStatus: Equatable {
    case available
    case appleIntelligenceNotEnabled
    case deviceNotEligible
    case modelNotReady
    case unsupportedLanguage
    case unavailable

    var isAvailable: Bool {
        self == .available
    }

    /// Tells people what they can do about it.
    var message: String {
        switch self {
        case .available:
            ""
        case .appleIntelligenceNotEnabled:
            "Turn on Apple Intelligence in Settings to use AI suggestions, practice and exams."
        case .deviceNotEligible:
            "This device doesn't support Apple Intelligence. You can still add and review words by hand."
        case .modelNotReady:
            "Apple Intelligence is still downloading. You can add words by hand in the meantime."
        case .unsupportedLanguage:
            "Apple Intelligence doesn't support English and Spanish on this device. You can still add and review words by hand."
        case .unavailable:
            "Apple Intelligence isn't available right now. You can still add and review words by hand."
        }
    }

    /// Explains why sentences can't be checked, next to the Practice button.
    var practiceMessage: String {
        switch self {
        case .available:
            ""
        case .appleIntelligenceNotEnabled:
            "Turn on Apple Intelligence in Settings to practice with this word."
        case .deviceNotEligible:
            "This device doesn't support Apple Intelligence, so your sentences can't be checked. You can still review and edit this word."
        case .modelNotReady:
            "Apple Intelligence is still downloading. You can practice when it finishes."
        case .unsupportedLanguage:
            "Apple Intelligence doesn't support English and Spanish on this device, so your sentences can't be checked. You can still review and edit this word."
        case .unavailable:
            "Apple Intelligence isn't available right now, so your sentences can't be checked. You can still review and edit this word."
        }
    }

    /// Explains why exams can't be taken, and that word groups can still grow.
    var examsMessage: String {
        switch self {
        case .available:
            ""
        case .appleIntelligenceNotEnabled:
            "Turn on Apple Intelligence in Settings to take exams. Meanwhile, you can keep building your word groups."
        case .deviceNotEligible:
            "This device doesn't support Apple Intelligence, which grades your exams. You can still keep building your word groups."
        case .modelNotReady:
            "Apple Intelligence is still downloading. Exams will be ready when it finishes. Meanwhile, keep building your word groups."
        case .unsupportedLanguage:
            "Apple Intelligence doesn't support English and Spanish on this device, so exams can't be graded. You can still keep building your word groups."
        case .unavailable:
            "Apple Intelligence isn't available right now, so exams can't be graded. You can still keep building your word groups."
        }
    }

    /// The app asks the model for English definitions and examples, and Spanish translations.
    static var current: AIStatus {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            let supportsAppLanguages = model.supportsLocale(Locale(identifier: "en"))
                && model.supportsLocale(Locale(identifier: "es"))
            return supportsAppLanguages ? .available : .unsupportedLanguage
        case .unavailable(.appleIntelligenceNotEnabled):
            return .appleIntelligenceNotEnabled
        case .unavailable(.deviceNotEligible):
            return .deviceNotEligible
        case .unavailable(.modelNotReady):
            return .modelNotReady
        case .unavailable:
            return .unavailable
        }
    }
}

extension EnvironmentValues {
    @Entry var aiStatus: AIStatus = .available
}
