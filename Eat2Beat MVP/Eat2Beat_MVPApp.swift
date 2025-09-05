//
//  Eat2Beat_MVPApp.swift
//  Eat2Beat MVP
//
//  Created by Igor Odaryuk on 05.09.2025.
//

import SwiftUI

@main
struct Eat2BeatApp: App {
    @AppStorage("didOnboard") private var didOnboard = false

    var body: some Scene {
        WindowGroup {
            Group {
                if didOnboard {
                    ContentView()
                } else {
                    StartView {
                        didOnboard = true
                    }
                }
            }
        }
    }
}
