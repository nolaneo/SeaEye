//
//  BuildStatusView.swift
//  SeaEye
//
//  Created by Conor Mongey on 30/03/2021.
//  Copyright © 2021 Nolaneo. All rights reserved.
//

import SwiftUI

struct BuildStatusView : View {
    @State var build: CircleCIBuild
    var seperator: String = "|"

    var branchName: String {
        return "\(build.branch) \(seperator) \(build.reponame)"
    }

    var statusAndSubject : String {
        if build.status == .noTests {
            return "No tests"
        }

        var status = build.status.rawValue.capitalized

        if let subject = build.subject {
            status += ": \(subject)"
        } else {
            if let workflow = build.workflows {
                status += ": \(workflow.workflowName!) - \(workflow.jobName!)"
            }
        }

        return status
    }

    var color: Color {
        return Color(statusColor)
    }
    var statusColor: NSColor {
        switch build.status {
        case .success: return greenColor()
        case .fixed: return greenColor()
        case .noTests: return redColor()
        case .failed: return redColor()
        case .timedout: return redColor()
        case .running: return blueColor()
        case .notRunning: return grayColor()
        case .canceled: return grayColor()
        case .retried: return grayColor()
        case .notRun: return grayColor()
        case .queued: return NSColor.systemPurple
        default:
            print("unknown status" + build.status.rawValue)
            return grayColor()
        }
    }

    var timeAndBuildNumber:  String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm MMM dd"
        let startTime =  dateFormatter.string(from: build.lastUpdateTime())
        var result =  startTime + " \(seperator) Build #\(build.buildNum)"
        if build.authorName != nil {
            result += " \(seperator) By \(build.authorName!)"
        }
        return result
    }

    private func greenColor() -> NSColor {
        return NSColor.systemGreen
    }

    private func redColor() -> NSColor {
        return NSColor.systemRed
    }

    private func blueColor() -> NSColor {
        return NSColor.systemBlue
    }

    private func grayColor() -> NSColor {
        return NSColor.systemGray
    }
    
    func openLink() {
        NSWorkspace.shared.open(build.buildUrl)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeClosePopover"), object: nil)
    }
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color(statusColor))
                .frame(width: 3)
            VStack(alignment: .leading, spacing:0){
                Text(statusAndSubject)
                    .font(.headline)
                    .foregroundColor(color)
                    .padding(.bottom, 5)
                    .accessibility(label: Text("Build Status"))
                Text(branchName)
                    .font(.subheadline)
                    .padding(.bottom, 5)
                Spacer()
                Text(timeAndBuildNumber)
                    .font(.subheadline)
            }
            Spacer()
            VStack{
                Spacer()
                Button(action: {
                    openLink()
                }) {
                    Image(systemName: "square.and.arrow.up")

                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            
        }
//        .background(Color.white)
    }
}
    
struct BuildsView: View {
    var builds: [CircleCIBuild]
    
    var body: some View {
        ScrollView(.vertical){
            VStack{
                ForEach(builds) {
                    BuildStatusView(build: $0)
                        .frame(width: .infinity, height: 80)
                }
            }
        }
    }
}

struct BuildStatusView_Previews: PreviewProvider {
    static var previews: some View {
      
        BuildsView(builds: Fixtures.builds)
            .previewLayout(.sizeThatFits)
        ForEach( Fixtures.builds){ build in
            VStack {
                Text("\(build.status.rawValue)")
                BuildStatusView(build: build)
            }
        }.previewLayout(.fixed(width: 400, height: 100))
    }
}
