//
//  VakitNiyetWidgetsBundle.swift
//  VakitNiyetWidgets
//
//  Created by Metehan Mengen on 29.03.2026.
//

import WidgetKit
import SwiftUI

@main
struct VakitNiyetWidgetsBundle: WidgetBundle {
    var body: some Widget {
        PrayerTimesWidget()
        ZikirmatikWidget()
    }
}
