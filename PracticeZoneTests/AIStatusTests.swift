import Testing
@testable import PracticeZone

struct AIStatusTests {

    @Test(arguments: [
        AIStatus.available,
        .appleIntelligenceNotEnabled,
        .deviceNotEligible,
        .modelNotReady,
        .unsupportedLanguage,
        .unavailable,
    ])
    func `Only the available status turns AI on and shows no message`(status: AIStatus) {
        let isAvailable = status == .available

        #expect(status.isAvailable == isAvailable)
        #expect(status.message.isEmpty == isAvailable)
        #expect(status.practiceMessage.isEmpty == isAvailable)
        #expect(status.examsMessage.isEmpty == isAvailable)
    }
}
