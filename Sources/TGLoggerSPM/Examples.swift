import Foundation

// MARK: - Usage Examples

/*
 Приклади використання TGLoggerSPM бібліотеки
 */

// MARK: - Example 1: Використання стандартних типів нотифікацій

@available(macOS 10.15, iOS 13.0, *)
func example1_StandardTypes() async {
    let service = TelegramNotificationService()
    
    // Відправка повідомлення з використанням стандартних типів
    await service.send("Помилка в додатку", as: NotificationType.errors)
    await service.send("Нова підписка", as: NotificationType.subscriptions)
    await service.send("Аналітика", as: NotificationType.analytics)
}

// MARK: - Example 2: Створення власних типів нотифікацій

@available(macOS 10.15, iOS 13.0, *)
func example2_CustomTypes() async {
    let service = TelegramNotificationService()
    
    // Створення власного типу нотифікації
    let customError = CustomNotificationType(rawValue: "custom_error", threadID: 100)
    let customAnalytics = CustomNotificationType(rawValue: "custom_analytics", threadID: 101)
    
    // Використання власних типів
    await service.send("Власна помилка", as: customError)
    await service.send("Власна аналітика", as: customAnalytics)
}

// MARK: - Example 3: Використання власних ботів та чату

@available(macOS 10.15, iOS 13.0, *)
func example3_CustomConfiguration() async {
    // Створення власної конфігурації
    let customTarget = TopicTarget(
        chatID: -1001234567890, // Твій власний chat ID
        botTokens: [
            "1234567890:AAHfYwuPesvPhM3InH1woCtbkq4kaEkslMI", // Твій власний бот
            "9876543210:AAHfOu95jgxH-THrCv79oXjvIfmMG4WBNmI"  // Другий бот
        ]
    )
    
    // Створення сервісу з власною конфігурацією
    let customService = TelegramNotificationService(topicTarget: customTarget)
    
    // Створення власних типів нотифікацій для твоєї конфігурації
    let myErrorType = CustomNotificationType(rawValue: "my_errors", threadID: 1)
    let myAnalyticsType = CustomNotificationType(rawValue: "my_analytics", threadID: 2)
    
    // Відправка повідомлень
    await customService.send("Моя помилка", as: myErrorType)
    await customService.send("Моя аналітика", as: myAnalyticsType)
}

// MARK: - Example 4: Розширені можливості форматування

@available(macOS 10.15, iOS 13.0, *)
func example4_AdvancedFormatting() async {
    let service = TelegramNotificationService()
    
    // Використання різних методів форматування
    let formattedMessage = """
    \("ПОМИЛКА".tgBold())
    
    \("Деталі:".tgUnderline())
    • Функція: \("processData".italic())
    • Статус: \(String.tgNo)
    • Час: \(Date().description)
    
    \("Стек викликів:".tgBoldUnderline())
    ```
    Thread 1: main
    - processData()
    - validateInput()
    ```
    """
    
    await service.send(formattedMessage, as: NotificationType.errors)
}

// MARK: - Example 5: Відправка JSON даних

@available(macOS 10.15, iOS 13.0, *)
func example5_JSONData() async {
    let service = TelegramNotificationService()
    
    let userData: [String: Any] = [
        "user_id": 12345,
        "action": "purchase",
        "amount": 9.99,
        "currency": "USD",
        "timestamp": Date().timeIntervalSince1970
    ]
    
    if let jsonString = String.prettyJSONString(from: userData) {
        let message = """
        \("НОВА ПІДПИСКА".tgBold())
        
        \("Дані користувача:".tgUnderline())
        \(jsonString)
        """
        
        await service.send(message, as: NotificationType.subscriptions)
    }
}

// MARK: - Example 6: Створення enum з власними типами

@available(macOS 10.15, iOS 13.0, *)
func example6_CustomEnum() async {
    // Створення власного enum, що відповідає протоколу
    enum MyAppNotificationType: String, NotificationTypeProtocol {
        case userRegistration
        case paymentSuccess
        case appCrash
        case featureUsage
        
        var threadID: Int {
            switch self {
            case .userRegistration: return 10
            case .paymentSuccess: return 11
            case .appCrash: return 12
            case .featureUsage: return 13
            }
        }
    }
    
    let service = TelegramNotificationService()
    
    // Використання власного enum
    await service.send("Новий користувач зареєструвався", as: MyAppNotificationType.userRegistration)
    await service.send("Платіж успішний", as: MyAppNotificationType.paymentSuccess)
    await service.send("Додаток впав", as: MyAppNotificationType.appCrash)
}

// MARK: - Example 7: Конфігурація для різних середовищ

@available(macOS 10.15, iOS 13.0, *)
func example7_EnvironmentConfiguration() async {
    #if DEBUG
    // Конфігурація для debug
    let debugTarget = TopicTarget(
        chatID: -1001234567890,
        botTokens: ["DEBUG_BOT_TOKEN"]
    )
    let debugService = TelegramNotificationService(topicTarget: debugTarget)
    #else
    // Конфігурація для production
    let prodTarget = TopicTarget(
        chatID: -1009876543210,
        botTokens: ["PROD_BOT_TOKEN_1", "PROD_BOT_TOKEN_2"]
    )
    let prodService = TelegramNotificationService(topicTarget: prodTarget)
    #endif
    
    // Використання відповідного сервісу
    #if DEBUG
    await debugService.send("Debug повідомлення", as: NotificationType.debug)
    #else
    await prodService.send("Production повідомлення", as: NotificationType.analytics)
    #endif
} 