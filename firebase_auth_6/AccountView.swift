//
//  AccountView.swift
//  firebase_auth
//
//  Created by Rupaj Sen on 25/04/24.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var viewModel: AuthViewModel
      @State private var currentUser: User?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Health Details")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        if let userName = viewModel.currentUser?.fullname {
                            Text(userName).bold()
                        } else {
                            Text("Name not available").foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        Text("DOB")
                        Spacer()
                        if let dob = viewModel.currentUser?.dob {
                            Text("\(dob, formatter: dateFormatter)").bold()
                        } else {
                            Text("DOB not available").foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        Text("Gender")
                        Spacer()
                        if let gender = viewModel.currentUser?.gender {
                            Text(gender.rawValue).bold()
                        } else {
                            Text("Gender not available").foregroundColor(.red)
                        }
                    }
                }
                Section(header: Text("Account")) {
                    NavigationLink(destination: EditAccountView()) {
                        SettingsRowView(imageName: "person.circle.fill", title: "Edit Profile", tintColor: .blue)
                    }
                    Button("Sign Out") {
                        viewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationBarTitle("Account Settings")
                        .onAppear {
                            viewModel.fetchUserSynchronously()
                            currentUser = viewModel.currentUser            }
        }
    }
}



#Preview {
    AccountView()
}
