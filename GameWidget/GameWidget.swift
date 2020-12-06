//  Created by Hannes Bergthaler on 04.12.20.

import WidgetKit
import SwiftUI

//Alternatively, if future events are unpredictable, you can tell WidgetKit to not request a new timeline at all by specifying .never for the policy. In that case, your app calls the WidgetCenter function reloadTimelines(ofKind:) when a new timeline is available. Some examples of when using .never makes sense include:
//When the user has a widget configured to display the health of a character, but that character is no longer actively engaging in battle and its health level won’t change.
//When a widget’s content is dependent on the user being logged into an account and they aren’t currently logged in.

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// Data what should be shown
struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct GameWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct GameWidget: Widget {
    let kind: String = "GameWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GameWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("s is an example widget.")
    }
}

struct GameWidget_Previews: PreviewProvider {
    static var previews: some View {
        GameWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
