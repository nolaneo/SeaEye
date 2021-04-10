//
//  BuildStatusView.swift
//  SeaEye
//
//  Created by Conor Mongey on 30/03/2021.
//  Copyright © 2021 Nolaneo. All rights reserved.
//

import SwiftUI

struct BuildStatusView : View {
    var build: CircleCIBuild
    
    var b : BuildDecorator {
        BuildDecorator.init(build: build)
    }
    
    func openLink() {
        NSWorkspace.shared.open(build.buildUrl)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeClosePopover"), object: nil)
    }
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color(b.statusColor))
                .frame(width: 3)
            VStack(alignment: .leading){
                Text(b.statusAndSubject())
                    .font(.headline)
                    .foregroundColor(Color(b.statusColor))
                Text(b.branchName())
                    .font(.subheadline)
                Text(b.timeAndBuildNumber())
                    .font(.subheadline)
            }
            
            Button(action: {
                openLink()
            }) {
                HStack(spacing: 10) {
                    if #available(OSX 11.0, *) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.black)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
    
struct BuildsView: View {
    var builds: [CircleCIBuild]
    
    var body: some View {
        ScrollView(.vertical){
            VStack{
                ForEach(builds) {
                    BuildStatusView(build: $0)
                        .frame(width: 280, height: 80)
                }
            }
        }
    }
}

struct BuildStatusView_Previews: PreviewProvider {
    static var previews: some View {
        
        let failedBuild = CircleCIBuild(branch: "master",
                                       project: "foobar",
                                       status: .failed,
                                       subject: "wat how long does this go.... all the way plz",
                                       user: "Homer Simpson",
                                       buildNum: 5,
                                       url: URL(string: "http://google.com")!,
                                       date: Date())
        let queuedBuild = CircleCIBuild(branch: "master",
                                       project: "foobar",
                                       status: .queued,
                                       subject: "wat",
                                       user: "Homer Simpson",
                                       buildNum: 5,
                                       url: URL(string: "http://google.com")!,
                                       date: Date())
        let succBuild = CircleCIBuild(branch: "master",
                                       project: "foobar",
                                       status: .success,
                                       subject: "wat",
                                       user: "Homer Simpson",
                                       buildNum: 5,
                                       url: URL(string: "http://google.com")!,
                                       date: Date())
        let cancelledBuild = CircleCIBuild(branch: "master",
                                       project: "foobar",
                                       status: .canceled,
                                       subject: "wat",
                                       user: "Homer Simpson",
                                       buildNum: 5,
                                       url: URL(string: "http://google.com")!,
                                       date: Date())
        BuildsView(builds: [failedBuild,queuedBuild, succBuild, cancelledBuild])
            .previewLayout(.sizeThatFits)
    }
}
