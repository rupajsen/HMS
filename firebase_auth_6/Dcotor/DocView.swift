//
//  DoctorView.swift
//  firebase_auth
//
//  Created by Rupaj Sen on 03/05/24.
//

import SwiftUI

struct DocView: View {
    var body: some View {
        TabView {
            DocNav()
                .tabItem {
                    Image(systemName: "stethoscope")
                    Text("Dashboard")
                }
            
            AccountView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    DoctorView()
}
