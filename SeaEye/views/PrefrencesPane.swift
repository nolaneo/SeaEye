//
//  PrefrencesPane.swift
//  SeaEye
//
//  Created by Conor Mongey on 10/04/2021.
//  Copyright © 2021 Nolaneo. All rights reserved.
//

import SwiftUI

struct ServersView : View {
    @State var clients: [CircleCIClient] = []
    @State var url : String = ""
    @State var accessToken : String = ""
    @State private var selection: String?

    var body: some View {
        HStack{
            VStack{
                List {
                    Section(header: Text("CI Systems")) {
                        ForEach(clients){
                            Text("CircleCI \($0.token)")
                        }
                    }
                }
                Spacer()
                HStack{
                    Button("Add New Server"){}
                    .frame(width: .infinity)
                    Spacer()
                }
            }
            VStack(alignment: .leading){
                TextField("Server name", text: $url)
                TextField("Access Token", text: $accessToken)
                Text("You can use 'Test' to verify your settings and move to 'Projects' from above, or if you are an advanced user, you can add more servers to the left.")
                Spacer()
                HStack{
                    Button("Create Token") {}
                    Spacer()
                    Button("Test") {}
                    Spacer()
                    Button("Reset To Defaults") {}
                }
            }.frame(height: .infinity, alignment: .topLeading)
            .padding(.horizontal)
        }.padding()
        
    }
}

struct ProjectsView : View {
    @State var projects: [CircleCIProject]
    @State var unfollowedProjects: [Project] = []
    
    var body: some View {
        VStack{
            VStack{
                List {
                    Section(header:
                                HStack{
                                    Text("Followed Projects \(projects.count)")
                                    
                                }.frame(width: .infinity)
                    ) {
                        ForEach(projects){
                            FollowedProjectSettingsRow(project: $0)
                        }
                    }
                }
                Spacer()
                List {
                    Section(header: Text("Available Projects \(unfollowedProjects.count)")) {
                        ForEach(unfollowedProjects){
                            UnfollowedProjectSettingsRow(project: $0)
                        }
                    }
                }
            }
        }.padding()
    }
}
extension Set {
    var array: [Element] {
        return Array(self)
    }
}

struct PrefrencesPane: View {
    @State var settings = Settings.load()
    @State var projects : [CircleCIProject] = []
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProjectsView(projects:  projects)
                        .tabItem {
                            Label("Projects", systemImage: "square.and.pencil")
                        }
            ServersView(clients: settings.clients())
                        .tabItem {
                            Label("Servers", systemImage: "list.dash")
                        }
        }
        .onAppear{
            self.settings.clients().forEach { (c)  in
                c.getProjects { (r) in
                    switch r {
                    case .success(let projects):
                        print("Got \(projects.count) projects \(projects.map({$0.vcsUrl}))")
                        self.projects.append(contentsOf: projects)
                        
                    case .failure:
                        print("shit")
                    
                    }
                }
            }
        }.padding()
    }
}

struct PrefrencesPane_Previews: PreviewProvider {
    static var previews: some View {
        PrefrencesPane()
            .frame(width: 800, height: 450, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        ProjectsView(projects: [])
        ServersView()
    }
}

struct FollowedProjectSettingsRow: View {
    @State var project: CircleCIProject

    var body: some View {
        HStack{
            Text("nolaneo/Seaeye")
            Spacer()
            Text("main|en-*")
            Spacer()
            Text("Regex")
            Spacer()
//            Toggle("Success notifications", isOn: project.following)
//                .toggleStyle(CheckboxToggleStyle())
//            Toggle("Failure notifications", isOn: project.following)
//                .toggleStyle(CheckboxToggleStyle())
            Spacer()
            Button("Delete"){}
        }
    }
}
struct UnfollowedProjectSettingsRow: View {
    @State var project : Project
    
    var body: some View {
        HStack{
            Text(project.description)
            Spacer()
            Button("Add"){}
        }
        .frame(width: .infinity)
//        .border(Color.black)
    }
}
