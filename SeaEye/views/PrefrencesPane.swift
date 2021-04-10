//
//  PrefrencesPane.swift
//  SeaEye
//
//  Created by Conor Mongey on 10/04/2021.
//  Copyright © 2021 Nolaneo. All rights reserved.
//

import SwiftUI

struct ServersView : View {
    @State var url : String = ""
    @State var accessToken : String = ""
    @State private var selection: String?

    var body: some View {
        HStack{
            VStack{
                List {
                    Section(header: Text("CI Systems")) {
                        ForEach((1..<51)){
                            Text("CircleCI \($0)")
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
            .padding()
        }
        
    }
}

struct ProjectsView : View {
    var body: some View {
        VStack{
            VStack{
                List {
                    Section(header:
                                HStack{
                                    Text("Projects")
                                    
                                }.frame(width: .infinity)
                    ) {
                        ForEach(1..<51){_ in
                            FollowedProjectSettingsRow()
                        }
                    }
                }
                Spacer()
                List {
                    Section(header: Text("second section")) {
                        ForEach(1..<51){ _ in
                            UnfollowedProjectSettingsRow()
                        }
                    }
                }
            }
        }.padding()
    }
}

struct PrefrencesPane: View {
    var body: some View {
        TabView {
            ServersView()
                        .tabItem {
                            Label("Servers", systemImage: "list.dash")
                        }

            ProjectsView()
                        .tabItem {
                            Label("Order", systemImage: "square.and.pencil")
                        }
        }.padding()
    }
}

struct PrefrencesPane_Previews: PreviewProvider {
    static var previews: some View {
        PrefrencesPane()
            .frame(width: 800, height: 450, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        ProjectsView()
    }
}

struct FollowedProjectSettingsRow: View {
    @State private var showGreeting = true

    var body: some View {
        HStack{
            Text("nolaneo/Seaeye")
            Text("main|en-*")
            Text("Regex")
            Toggle("Success notifications", isOn: $showGreeting)
                .toggleStyle(CheckboxToggleStyle())
            Toggle("Failure notifications", isOn: $showGreeting)
                .toggleStyle(CheckboxToggleStyle())
            Button("Delete"){}
        }
    }
}
struct UnfollowedProjectSettingsRow: View {
    var body: some View {
        HStack{
            Text("Project name")
            Spacer()
            Button("Add"){}
        }
        .frame(width: .infinity)
//        .border(Color.black)
    }
}
