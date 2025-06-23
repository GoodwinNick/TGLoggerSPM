// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - NotificationType Protocol

public protocol NotificationTypeProtocol {
    var rawValue: String { get }
    var threadID: Int { get }
}

// MARK: - Default NotificationType

public enum NotificationType: String, NotificationTypeProtocol {
    case subscriptions
    case errors
    case analytics
    case support
    case paywallOpened
    case promotion
    case debug
    
    private var debugTopicID: Int {
        52
    }
    
    public var threadID: Int {
        #if DEBUG
        return debugTopicID
        #endif
        
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
            return debugTopicID
        }
        
        return switch self {
            case .subscriptions: 2
            case .errors: 3
            case .analytics: 35
            case .support: 145
            case .paywallOpened: 3028
            case .promotion: 3901
            case .debug: debugTopicID
        }
    }
}

// MARK: - Custom NotificationType

public struct CustomNotificationType: NotificationTypeProtocol, Sendable {
    public let rawValue: String
    public let threadID: Int
    
    public init(rawValue: String, threadID: Int) {
        self.rawValue = rawValue
        self.threadID = threadID
    }
}

// MARK: - TopicTarget Configuration

public struct TopicTarget: Sendable {
    public let chatID: Int64
    public let botTokens: [String]
    
    public init(chatID: Int64, botTokens: [String]) {
        self.chatID = chatID
        self.botTokens = botTokens
    }
    
    /// Порожня дефолтна конфігурація. Передай свої токени та chatID через ініціалізатор.
    public static let `default` = TopicTarget(
        chatID: 0,
        botTokens: []
    )
}

// MARK: - TelegramNotificationService

@available(macOS 10.15, iOS 13.0, *)
public actor TelegramNotificationService {
    private let maxLength = 4000
    private let topicTarget: TopicTarget
    
    public init() {
        self.topicTarget = TopicTarget.default
    }
    
    public init(topicTarget: TopicTarget) {
        self.topicTarget = topicTarget
    }
    
    public func send<T: NotificationTypeProtocol>(_ text: String, as type: T) {
        Task(priority: .background) {
            await self.sendImpl(text, as: type)
        }
    }
    
    private func sendImpl<T: NotificationTypeProtocol>(_ text: String, as type: T) async {
        for token in topicTarget.botTokens.shuffled() {
            let success = await sendMessage(
                text: text,
                chatID: topicTarget.chatID,
                threadID: type.threadID,
                botToken: token,
            )
            
            if success { return }
        }
        
        print("❌ All bots failed for type: \(type.rawValue)")
    }
    
    private func sendMessage(
        text: String,
        chatID: Int64,
        threadID: Int,
        botToken: String,
        parseMode: String? = "HTML"
    ) async -> Bool {
        let message = String(text.prefix(maxLength))
        
        let url = URL(string: "https://api.telegram.org/bot\(botToken)/sendMessage")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var payload: [String: Any] = [
            "chat_id": chatID,
            "message_thread_id": threadID,
            "text": message
        ]
        if let parseMode {
            payload["parse_mode"] = parseMode
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.waitsForConnectivity = true
            
            let (data, response) = try await URLSession(configuration: config).data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                    case 200:
                        return true
                    case 429:
                        print("⏱ Too many requests for bot: \(botToken)")
                        return false
                    default:
                        let body = String(data: data, encoding: .utf8) ?? ""
                        print("⚠️ Error \(httpResponse.statusCode): \(body)")
                        return false
                }
            }
        } catch {
            print("🌐 Network error: \(error)")
            return false
        }
        
        return true
    }
}

// MARK: - String Extensions

extension String {
    public func escapedMarkdownV2() -> String {
        let special: Set<Character> = ["_", "*", "[", "]", "(", ")", "~", "`", ">", "#", "+", "-", "=", "|", "{", "}", ".", "!"]
        return reduce("") { $0 + (special.contains($1) ? "\\" + String($1) : String($1)) }
    }
    
    public func tgBoldUnderline() -> String {
        return "<ins><b>\(self.escapedMarkdownV2())</b></ins>"
    }
    
    public func tgBold() -> String {
        return "<b>\(self.escapedMarkdownV2())</b>"
    }
    
    public func tgUnderline() -> String {
        return "<u>\(self.escapedMarkdownV2())</u>"
    }
    
    public func italic() -> String {
        return "<i>\(self.escapedMarkdownV2())</i>"
    }
    
    public func boldItalic() -> String {
        return "<b><i>\(self.escapedMarkdownV2())</i></b>"
    }
    
    public static var tgYes: String {
        return "Yes".boldItalic()
    }
    
    public static var tgNo: String {
        return "No".boldItalic()
    }
    
    public static func prettyJSONString(from dictionary: [String: Any]) -> String? {
        if dictionary.isEmpty { return nil }
        guard JSONSerialization.isValidJSONObject(dictionary),
              let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
