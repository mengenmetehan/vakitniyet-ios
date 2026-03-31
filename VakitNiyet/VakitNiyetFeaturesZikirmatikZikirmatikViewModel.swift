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
    private let defaults = UserDefaults(suiteName: "group.com.metehanmengen.vakitniyet") ?? .standard

    init() {
        count = defaults.integer(forKey: countKey)
    }

    func increment() {
        count += 1
        defaults.set(count, forKey: countKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "ZikirmatikWidget")
    }

    func reset() {
        count = 0
        defaults.set(0, forKey: countKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "ZikirmatikWidget")
    }
}
