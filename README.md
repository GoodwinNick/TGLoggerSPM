# TGLoggerSPM

A library for sending logs and notifications to Telegram with a flexible architecture. Now the user defines all notification types and can omit threadID if not needed.

## Features

- ✅ Flexible architecture via `NotificationTypeProtocol`
- ✅ User defines their own enum/struct for notification types
- ✅ `threadID` is optional — you can omit it if you don't use topics
- ✅ Custom bot and chat configuration
- ✅ HTML formatting support
- ✅ Asynchronous message sending

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/GoodwinNick/TGLoggerSPM.git", from: "1.0.0")
]
```

Or via Xcode: `File` → `Add Package Dependencies` → enter the repository URL.

## Quick Start

### 1. Define your notification type

#### Using struct

```swift
struct MyNotificationType: NotificationTypeProtocol {
    let rawValue: String
    let threadID: Int? // optional
}

let errorType = MyNotificationType(rawValue: "error", threadID: 123)
let simpleType = MyNotificationType(rawValue: "simple") // without threadID
```

#### Using enum

```swift
enum MyAppNotificationType: String, NotificationTypeProtocol {
    case userRegistration
    case paymentSuccess
    case appCrash
    case info
    
    var threadID: Int? {
        switch self {
        case .userRegistration: return 10
        case .paymentSuccess: return 11
        case .appCrash: return 12
        case .info: return nil // no topic
        }
    }
}
```

### 2. Configure your bots

```swift
let target = TopicTarget(
    chatID: 0,
    botTokens: ["YOUR_BOT_TOKEN_1", "YOUR_BOT_TOKEN_2"]
)
let service = TelegramNotificationService(topicTarget: target)
```

### 3. Send messages

```swift
await service.send("Error!", as: errorType)
await service.send("Info", as: MyAppNotificationType.info)
```

## Message formatting

The library supports HTML formatting:

```swift
let message = """
\("ERROR".tgBold())
\("Details:".tgUnderline())
• Function: \("processData".italic())
• Status: \(String.tgNo)
"""
await service.send(message, as: errorType)
```

### Available formatting methods

- `.tgBold()` — Bold text
- `.tgUnderline()` — Underlined text
- `.italic()` — Italic text
- `.tgBoldUnderline()` — Bold + underlined
- `.boldItalic()` — Bold + italic

## Sending JSON data

```swift
let userData: [String: Any] = [
    "user_id": 12345,
    "action": "purchase",
    "amount": 9.99
]
if let jsonString = String.prettyJSONString(from: userData) {
    let message = """
    \("NEW SUBSCRIPTION".tgBold())
    \("User data:".tgUnderline())
    \(jsonString)
    """
    await service.send(message, as: simpleType)
}
```

## Telegram bot setup

1. Create a bot via [@BotFather](https://t.me/botfather)
2. Get the bot token
3. Add the bot to your group/channel
4. Get the chat ID of the group/channel
5. (Optional) Create topics in the group for different notification types
6. (Optional) Get the thread ID for each topic

### If you don't use topics
Just omit threadID in your type — messages will go to the main chat.

## License

MIT License

## Support

If you have questions or suggestions, create an issue in the repository. 