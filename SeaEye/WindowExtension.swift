//
//  WindowExtension.swift
//  SeaEye
//
//  Created by Eoin Nolan on 26/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa
//Fix for a bug in OSX where a window cannot become the key window if it is presented as a popover from the menubar
extension NSWindow {
    func canBecomeKeyWindow() -> Bool {
        return true;
    }
}