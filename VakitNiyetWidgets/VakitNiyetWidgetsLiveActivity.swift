//
//  VakitNiyetWidgetsLiveActivity.swift
//  VakitNiyetWidgets
//
//  Created by Metehan Mengen on 29.03.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct VakitNiyetWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct VakitNiyetWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VakitNiyetWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension VakitNiyetWidgetsAttributes {
    fileprivate static var preview: VakitNiyetWidgetsAttributes {
        VakitNiyetWidgetsAttributes(name: "World")
    }
}

extension VakitNiyetWidgetsAttributes.ContentState {
    fileprivate static var smiley: VakitNiyetWidgetsAttributes.ContentState {
        VakitNiyetWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: VakitNiyetWidgetsAttributes.ContentState {
         VakitNiyetWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: VakitNiyetWidgetsAttributes.preview) {
   VakitNiyetWidgetsLiveActivity()
} contentStates: {
    VakitNiyetWidgetsAttributes.ContentState.smiley
    VakitNiyetWidgetsAttributes.ContentState.starEyes
}
