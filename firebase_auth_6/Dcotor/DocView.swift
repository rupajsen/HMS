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
            DocDashView()
                .tabItem {
                    Image(systemName: "stethoscope")
                    Text("Dashboard")
                }
            
            PatientList()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
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
