//
//  SeaEyePopover.swift
//  SeaEye
//
//  Created by Conor Mongey on 10/04/2021.
//  Copyright © 2021 Nolaneo. All rights reserved.
//

import SwiftUI

struct SeaEyePopover : View {
    @State var builds : [CircleCIBuild] = Fixtures.builds
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing:0){
            HStack{
                Button(action: {
                    print("TODO:close popover")
                }) {
                    Image(systemName: "power")
                }.buttonStyle(PlainButtonStyle())
                
                Spacer()
                Text("SeaEye")
                    .font(.headline)

                Spacer()
                Button(action: {
//                    print("TODO: open settings")
                    NSApp.sendAction(#selector(AppDelegate.openPreferencesWindow), to: nil, from:nil)
                    appState.showPrefrencesWindow = true
                }) {
                    Image(systemName: "gear")
                }
//                .buttonStyle(PlainButtonStyle())
                
            }.padding(15)
            
            BuildsView(builds: builds)
                .frame(width: .infinity,
                       height: .infinity)
                .layoutPriority(1)
                .padding(.horizontal, 15)
        }
    }
}

struct SeaEyePopover_Previews: PreviewProvider {
    static var previews: some View {
        SeaEyePopover(builds: Fixtures.builds)
            .frame(width:320, height:450)
    }
}
