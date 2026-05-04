//
//  PlanlyApp.swift
//  Planly
//

/* App entry point. This is where we create and keep alive the shared view models
 that the rest of the UI depends on (auth state + app data). */

import SwiftUI

@main
struct planlyapp: App {
    init() {
        print(" APP LAUNCHED!")
    }
    
    var body: some Scene {
        WindowGroup {
            /*First screen shown to the user. Splash handles the initial animation while the app warms up (e.g. preparing UI, checking auth, preloading data).*/
                    LottieSplashView()
                }
        }
    }

