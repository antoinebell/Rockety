//
//  LaunchWidgetView.swift
//  RocketyWidgetExtension
//
//  Created by Antoine Bellanger on 01.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import RemoteImage
import SwiftUI
import WidgetKit

struct LaunchWidgetView: View {
    var launch: Launch
    
    var body: some View {
        
        let daysComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: launch.net!)
        let date = Calendar.current.date(byAdding: daysComponents, to: Date())!
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("BackgroundGradient-Top"), Color("BackgroundGradient-Bottom")]), startPoint: .top, endPoint: .bottom)
            VStack(alignment: .center) {
                Text(launch.launchTitle ?? "Unnamed launch")
                    .foregroundColor(.white)
                    .font(Font.custom("Barlow-SemiBold", size: 19.0))
                    .padding(.bottom, 8)
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(launch.launchServiceProvider?.name ?? "Unnamed provider")
                                .foregroundColor(.white)
                                .lineLimit(3)
                                .font(Font.custom("Barlow-Regular", size: 15.0))
                        }
                        .padding(.bottom, 4)
                        HStack {
                            Text("T-")
                                .foregroundColor(.white)
                                .font(Font.custom("Barlow-Light", size: 15.0))
                            Text(date, style: .timer)
                                .foregroundColor(.white)
                                .lineLimit(3)
                                .font(Font.custom("Barlow-Medium", size: 20.0))
                        }
                    }

                    RemoteImage(type: .url(launch.rocket?.configuration?.launchLibraryId?.imageURL() ?? URL(string: "")!), errorView: { _ in
                    }, imageView: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                    }, loadingView: {
                        Text("")
                            .frame(width: 0)
                    })
                }
            }
            .padding(8)
        }
        .widgetURL(URL(string: "rockety://v1/launch/\(launch.id ?? "")")!)
    }
}

struct LaunchWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchWidgetView(launch: Launch(slug: "slug", id: nil, url: nil, launchLibraryId: nil, name: "Rockety lauching! 🚀", status: nil, net: Date(timeIntervalSinceNow: 172800), windowEnd: nil, windowStart: nil, inhold: nil, tbdtime: nil, tbddate: nil, probability: nil, holdreason: nil, failreason: nil, hashtag: nil, launchServiceProvider: nil, rocket: nil, mission: nil, pad: nil, infoURLs: nil, vidURLs: nil, webcastLive: nil, image: nil, inforgraphic: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
