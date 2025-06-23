# TGLoggerSPM

Бібліотека для відправки логів та нотифікацій в Telegram з гнучкою архітектурою та можливістю створення власних типів нотифікацій.

## Особливості

- ✅ Гнучка архітектура з протоколом `NotificationTypeProtocol`
- ✅ Можливість створення власних типів нотифікацій
- ✅ Налаштування власних ботів та чатів
- ✅ Підтримка HTML форматування
- ✅ Автоматичне перемикання між ботами при помилках
- ✅ Підтримка різних середовищ (DEBUG/RELEASE)
- ✅ Асинхронна відправка повідомлень

## Встановлення

### Swift Package Manager

Додай залежність до твого `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/TGLoggerSPM.git", from: "1.0.0")
]
```

Або через Xcode: `File` → `Add Package Dependencies` → введи URL репозиторію.

## Швидкий старт

### Базове використання

```swift
import TGLoggerSPM

// Використання стандартного сервісу
let service = TelegramNotificationService.shared

// Відправка повідомлення
service.send("Помилка в додатку", as: .errors)
service.send("Нова підписка", as: .subscriptions)
```

### Створення власних типів нотифікацій

```swift
// Створення власного типу
let customError = CustomNotificationType(rawValue: "my_error", threadID: 100)

// Використання
service.send("Моя помилка", as: customError)
```

### Використання власних ботів

```swift
// Створення власної конфігурації
let customTarget = TopicTarget(
    chatID: -1001234567890,
    botTokens: [
        "YOUR_BOT_TOKEN_1",
        "YOUR_BOT_TOKEN_2"
    ]
)

// Створення сервісу з власною конфігурацією
let customService = TelegramNotificationService(topicTarget: customTarget)
```

## Типи нотифікацій

### Стандартні типи

- `.subscriptions` - Підписки
- `.errors` - Помилки
- `.analytics` - Аналітика
- `.support` - Підтримка
- `.paywallOpened` - Відкриття paywall
- `.promotion` - Промоції
- `.debug` - Debug повідомлення

### Створення власних типів

#### Через struct

```swift
let myType = CustomNotificationType(rawValue: "my_type", threadID: 123)
```

#### Через enum

```swift
enum MyAppNotificationType: String, NotificationTypeProtocol {
    case userRegistration
    case paymentSuccess
    
    var threadID: Int {
        switch self {
        case .userRegistration: return 10
        case .paymentSuccess: return 11
        }
    }
}
```

## Форматування повідомлень

Бібліотека підтримує HTML форматування:

```swift
let message = """
\("ПОМИЛКА".tgBold())

\("Деталі:".tgUnderline())
• Функція: \("processData".italic())
• Статус: \(String.tgNo)
"""

service.send(message, as: .errors)
```

### Доступні методи форматування

- `.tgBold()` - Жирний текст
- `.tgUnderline()` - Підкреслений текст
- `.italic()` - Курсив
- `.tgBoldUnderline()` - Жирний + підкреслений
- `.boldItalic()` - Жирний + курсив

## Конфігурація для різних середовищ

```swift
#if DEBUG
let debugTarget = TopicTarget(
    chatID: -1001234567890,
    botTokens: ["DEBUG_BOT_TOKEN"]
)
let service = TelegramNotificationService(topicTarget: debugTarget)
#else
let prodTarget = TopicTarget(
    chatID: -1009876543210,
    botTokens: ["PROD_BOT_TOKEN_1", "PROD_BOT_TOKEN_2"]
)
let service = TelegramNotificationService(topicTarget: prodTarget)
#endif
```

## Відправка JSON даних

```swift
let userData: [String: Any] = [
    "user_id": 12345,
    "action": "purchase",
    "amount": 9.99
]

if let jsonString = String.prettyJSONString(from: userData) {
    let message = """
    \("НОВА ПІДПИСКА".tgBold())
    
    \("Дані користувача:".tgUnderline())
    \(jsonString)
    """
    
    service.send(message, as: .subscriptions)
}
```

## Налаштування Telegram бота

1. Створи бота через [@BotFather](https://t.me/botfather)
2. Отримай токен бота
3. Додай бота до групи/каналу
4. Отримай chat ID групи/каналу
5. Створи топики в групі для різних типів нотифікацій
6. Отримай thread ID для кожного топику

### Отримання Chat ID

```swift
// Додай тимчасовий код для отримання chat ID
service.send("Test message", as: .debug)
// Подивись в логах бота chat ID
```

## Ліцензія

MIT License

## Підтримка

Якщо у тебе є питання або пропозиції, створюй issue в репозиторії. 