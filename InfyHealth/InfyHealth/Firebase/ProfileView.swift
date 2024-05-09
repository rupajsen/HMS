//
//  ProfileView.swift
//  firebase_auth
//
//  Created by Rupaj Sen on 24/04/24.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    
    var body: some View {
        if let user = viewModel.currentUser {
                        switch user.userType {
                        case .patient:
                            PatientView()
                        case .doctor:
                           DocView()
                        case .admin:
                            AdView()
                        }
                    }
    }
}



#Preview {
    ProfileView()
}

