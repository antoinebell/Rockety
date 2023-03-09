//
//  RocketyWidget.swift
//  RocketyWidget
//
//  Created by Antoine Bellanger on 01.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    // - Properties
    private let fetcher = Fetcher()
    
    // - Typealias
    typealias Entry = LaunchEntry
    
    // - Methods
    func placeholder(in context: Context) -> LaunchEntry {
        LaunchEntry(date: Date(), launch: Launch(slug: "slug", id: nil, url: nil, launchLibraryId: nil, name: "Rockety lauching! 🚀", status: nil, net: Date(timeIntervalSinceNow: 172800), windowEnd: nil, windowStart: nil, inhold: nil, tbdtime: nil, tbddate: nil, probability: nil, holdreason: nil, failreason: nil, hashtag: nil, launchServiceProvider: nil, rocket: nil, mission: nil, pad: nil, infoURLs: nil, vidURLs: nil, webcastLive: nil, image: nil, inforgraphic: nil))
    }

    func getSnapshot(in context: Context, completion: @escaping (LaunchEntry) -> ()) {
        fetcher.fetch(decodeTo: Launches.self) { launches in
            guard let launch = launches?.results.first else { return }
            completion(LaunchEntry(date: Date(), launch: launch))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [LaunchEntry] = []
        
        fetcher.fetch(decodeTo: Launches.self) { launches in
            guard let launch = launches?.results.first else { return }
            entries.append(LaunchEntry(date: Date(), launch: launch))
            
            let timeline = Timeline(entries: entries, policy: .after(launch.net!))
            completion(timeline)
        }
    }
}

struct LaunchEntry: TimelineEntry {
    let date: Date
    let launch: Launch
}

struct RocketyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        LaunchWidgetView(launch: entry.launch)
    }
}

@main
struct RocketyWidget: Widget {
    let kind: String = "RocketyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RocketyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Launch")
        .description("See the next rocket launch on your home screen 🚀")
        .supportedFamilies([.systemSmall])
    }
}
