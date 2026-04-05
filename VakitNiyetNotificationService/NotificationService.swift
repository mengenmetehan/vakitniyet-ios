import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent

        guard let content = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // Backend payload'ından namaz adı ve offset al
        if let formattedBody = formatPrayerBody(userInfo: content.userInfo) {
            content.body = formattedBody
        }

        contentHandler(content)
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: - Formatting

    private func formatPrayerBody(userInfo: [AnyHashable: Any]) -> String? {
        let rawName = userInfo["prayerName"] as? String
            ?? userInfo["prayer_name"] as? String
        guard let rawName else { return nil }

        let displayName: String
        switch rawName.uppercased() {
        case "FAJR",    "SABAH", "IMSAK": displayName = "Sabah"
        case "DHUHR",   "OGLE",  "ÖĞLE":  displayName = "Öğle"
        case "ASR",     "IKINDI","İKİNDİ":displayName = "İkindi"
        case "MAGHRIB", "AKSAM", "AKŞAM": displayName = "Akşam"
        case "ISHA",    "YATSI":           displayName = "Yatsı"
        default: displayName = rawName.capitalized
        }

        let offset: Int
        if let payloadOffset = userInfo["offsetMinutes"] as? Int
            ?? (userInfo["offsetMinutes"] as? String).flatMap(Int.init) {
            offset = payloadOffset
        } else {
            // UserDefaults'tan app group üzerinden oku
            let defaults = UserDefaults(suiteName: "group.com.metehanmengen.vakitniyet")
            offset = defaults?.integer(forKey: "notificationOffset") ?? 10
        }

        return "\(displayName) namazına \(offset) dk kaldı"
    }
}
