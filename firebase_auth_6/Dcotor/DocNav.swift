//
//  DocNav.swift
//  firebase_auth
//
//  Created by admin on 01/05/24.
//
import SwiftUI
struct DocNav: View {
    @State private var selection: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $selection, label: Text("Select View")) {
                    Text("Today's Appointments").tag(0)
                    Text("All Appointment History ").tag(1)
                    Text("Schedule").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                TabView(selection: $selection) {
                    DocDashView()
                        .tag(0)
                    PatientList()
                        .tag(1)
                    ScheduleView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .padding(.top, 20)
            }
            .navigationBarTitle("Select View")
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use StackNavigationViewStyle to prevent sidebar navigation on iPad
    }
}


struct ScheduleView: View {
    var body: some View {
        Text("Schedule")
    }
}

#Preview {
    DocNav()
}
