//
//  firebase_authApp.swift
//  firebase_auth
//
//  Created by Rupaj Sen on 24/04/24.
//

import SwiftUI
import Firebase

@main
struct firebase_authApp: App {
    init()
    {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthViewModel())
        }
    }
}
