//
//  AdminView.swift
//  firebase_auth
//
//  Created by Rupaj Sen on 03/05/24.
//

import SwiftUI

struct AdView: View {
    var body: some View {
        TabView {
            
            StaffList()
                .tabItem {
                    Image(systemName: "house.fill")
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
    AdView()
}
