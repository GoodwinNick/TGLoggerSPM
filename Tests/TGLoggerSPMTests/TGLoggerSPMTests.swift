import Testing
import Foundation
@testable import TGLoggerSPM

// MARK: - NotificationType Tests

@Test func testDefaultNotificationTypes() async throws {
    // Test that all default notification types have valid thread IDs
    #expect(NotificationType.subscriptions.threadID == 2)
    #expect(NotificationType.errors.threadID == 3)
    #expect(NotificationType.analytics.threadID == 35)
    #expect(NotificationType.support.threadID == 145)
    #expect(NotificationType.paywallOpened.threadID == 3028)
    #expect(NotificationType.promotion.threadID == 3901)
    #expect(NotificationType.debug.threadID == 52)
}

@Test func testCustomNotificationType() async throws {
    let customType = CustomNotificationType(rawValue: "test_type", threadID: 999)
    
    #expect(customType.rawValue == "test_type")
    #expect(customType.threadID == 999)
}

@Test func testCustomEnumNotificationType() async throws {
    enum TestNotificationType: String, NotificationTypeProtocol {
        case test1
        case test2
        
        var threadID: Int {
            switch self {
            case .test1: return 100
            case .test2: return 200
            }
        }
    }
    
    #expect(TestNotificationType.test1.rawValue == "test1")
    #expect(TestNotificationType.test1.threadID == 100)
    #expect(TestNotificationType.test2.rawValue == "test2")
    #expect(TestNotificationType.test2.threadID == 200)
}

// MARK: - TopicTarget Tests

@Test func testTopicTargetCustom() async throws {
    let customTokens = ["token1", "token2", "token3"]
    let customTarget = TopicTarget(chatID: 123456789, botTokens: customTokens)
    
    #expect(customTarget.chatID == 123456789)
    #expect(customTarget.botTokens == customTokens)
}

// MARK: - TelegramNotificationService Tests

@available(macOS 10.15, iOS 13.0, *)
@Test func testTelegramNotificationServiceCustom() async throws {
    let customTarget = TopicTarget(chatID: 123456789, botTokens: ["test_token"])
    let service = TelegramNotificationService(topicTarget: customTarget)
    #expect(type(of: service) == TelegramNotificationService.self)
}

// MARK: - String Extensions Tests

@Test func testStringEscapedMarkdownV2() async throws {
    let testString = "Hello *world* [test] (link)"
    let escaped = testString.escapedMarkdownV2()
    
    #expect(escaped.contains("\\*"))
    #expect(escaped.contains("\\["))
    #expect(escaped.contains("\\]"))
    #expect(escaped.contains("\\("))
    #expect(escaped.contains("\\)"))
}

@Test func testStringFormatting() async throws {
    let testString = "Test"
    
    let bold = testString.tgBold()
    #expect(bold.contains("<b>"))
    #expect(bold.contains("</b>"))
    
    let underline = testString.tgUnderline()
    #expect(underline.contains("<u>"))
    #expect(underline.contains("</u>"))
    
    let italic = testString.italic()
    #expect(italic.contains("<i>"))
    #expect(italic.contains("</i>"))
    
    let boldItalic = testString.boldItalic()
    #expect(boldItalic.contains("<b>"))
    #expect(boldItalic.contains("<i>"))
    #expect(boldItalic.contains("</b>"))
    #expect(boldItalic.contains("</i>"))
}

@Test func testStringConstants() async throws {
    #expect(String.tgYes.contains("Yes"))
    #expect(String.tgNo.contains("No"))
    #expect(String.tgYes.contains("<b>"))
    #expect(String.tgYes.contains("<i>"))
    #expect(String.tgNo.contains("<b>"))
    #expect(String.tgNo.contains("<i>"))
}

@Test func testPrettyJSONString() async throws {
    let validDict: [String: Any] = [
        "name": "Test",
        "value": 123,
        "active": true
    ]
    
    let jsonString = String.prettyJSONString(from: validDict)
    #expect(jsonString != nil)
    #expect(jsonString!.contains("Test"))
    #expect(jsonString!.contains("123"))
    #expect(jsonString!.contains("true"))
    
    let emptyDict: [String: Any] = [:]
    let emptyJsonString = String.prettyJSONString(from: emptyDict)
    #expect(emptyJsonString == nil)
    
    let invalidDict: [String: Any] = [
        "invalid": Date() // Date is not JSON serializable
    ]
    let invalidJsonString = String.prettyJSONString(from: invalidDict)
    #expect(invalidJsonString == nil)
}

// MARK: - Integration Tests

@Test func testNotificationTypeProtocol() async throws {
    // Test that all notification types conform to the protocol
    let defaultType: NotificationTypeProtocol = NotificationType.errors
    #expect(defaultType.rawValue == "errors")
    #expect(defaultType.threadID == 3)
    
    let customType: NotificationTypeProtocol = CustomNotificationType(rawValue: "custom", threadID: 500)
    #expect(customType.rawValue == "custom")
    #expect(customType.threadID == 500)
}

@available(macOS 10.15, iOS 13.0, *)
@Test func testServiceInitialization() async throws {
    // Test that service can be initialized with different configurations
    let target1 = TopicTarget(chatID: 1, botTokens: ["token1"])
    let service1 = TelegramNotificationService(topicTarget: target1)
    #expect(type(of: service1) == TelegramNotificationService.self)
    
    let target2 = TopicTarget(chatID: 2, botTokens: ["token2", "token3"])
    let service2 = TelegramNotificationService(topicTarget: target2)
    #expect(type(of: service2) == TelegramNotificationService.self)
}

// MARK: - Performance Tests

@Test func testStringFormattingPerformance() async throws {
    let testString = "This is a test string with some special characters: *bold* [link] (text)"
    
    let start = Date()
    for _ in 0..<1000 {
        _ = testString.tgBold()
        _ = testString.tgUnderline()
        _ = testString.italic()
        _ = testString.boldItalic()
    }
    let end = Date()
    
    let duration = end.timeIntervalSince(start)
    #expect(duration < 1.0) // Should complete in less than 1 second
}
