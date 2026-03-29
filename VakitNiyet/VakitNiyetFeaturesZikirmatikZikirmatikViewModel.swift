//
//  ZikirmatikViewModel.swift
//  VakitNiyet
//
//  Created by Metehan Mengen on 29.03.2026.
//

import Foundation
import Combine
import WidgetKit

class ZikirmatikViewModel: ObservableObject {

    @Published var count: Int = 0

    private let countKey = "zikirCount"
    private let dateKey  = "zikirDate"
    private let defaults = UserDefaults(suiteName: "group.com.metehanmengen.vakitniyet") ?? .standard

    private var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    init() {
        loadOrReset()
    }

    func increment() {
        count += 1
        defaults.set(count, forKey: countKey)
        defaults.set(todayString, forKey: dateKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "ZikirmatikWidget")
    }

    func reset() {
        count = 0
        defaults.set(0, forKey: countKey)
        defaults.set(todayString, forKey: dateKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "ZikirmatikWidget")
    }

    private func loadOrReset() {
        let stored = defaults.string(forKey: dateKey) ?? ""
        if stored == todayString {
            count = defaults.integer(forKey: countKey)
        } else {
            count = 0
        }
    }
}
