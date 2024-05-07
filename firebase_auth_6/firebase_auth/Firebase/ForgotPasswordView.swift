//
//  ForgotPasswordView.swift
//  firebase_auth
//
//  Created by  Gunna Rahul on 02/05/24.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var showAlert = false
    @State private var errorMessage = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Forgot Password")
                    .font(.title)
                    .padding()
                
                InputView(text: $email, title: "Email address", placeholder: "name@example.com", isSecureField: false)
                    .autocapitalization(.none)
                    .padding()
                
                Button(action: {
                    Task {
                        do {
                            // Check if email exists before sending reset email
                            let emailExists = try await viewModel.checkIfEmailExists(email: email)
                            if emailExists {
                                // Email exists, proceed with password reset
                                try await viewModel.resetPassword(email: email)
                                self.showAlert.toggle()
                            } else {
                                // Email doesn't exist, show alert
                                self.errorMessage = "Account does not exist for this email"
                                self.showAlert.toggle()
                            }
                        } catch {
                            // Handle any errors
                            self.errorMessage = error.localizedDescription
                            self.showAlert.toggle()
                            print("Failed to reset password with error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    HStack {
                        Text("Reset Password")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.top, 24)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(errorMessage.isEmpty ? "Password Reset" : "Error"), message: Text(errorMessage.isEmpty ? "A password reset email has been sent to your email address." : errorMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
