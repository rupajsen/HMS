//  AdminView.swift
//  firebase_auth
//  Created by Rupaj Sen on 24/04/24.

import SwiftUI

struct AdminView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    var body: some View {
        Text("Admin View")
        Section("Account")
                        {
                            Button{
                                viewModel.signOut()
                            } label: {
                                SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                            }
                        }
    }
}

#Preview {
    AdminView()
}
