//  TabBarView.swift
//  firebase_auth
//  Created by Rupaj Sen on 25/04/24.

import SwiftUI

struct PatientView: View {
    var body: some View {

                TabView {
                    PatientDashView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Dashboard")
                        }
                    
                    ScheduledAppointmentView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Appointments")
                        }
                    ReportView(appointmentDate: "May 10, 2024", doctorName: "Dr. Smith")
                        .tabItem {
                            Image(systemName: "newspaper.fill")
                            Text("Reports")
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
    PatientView()
}
