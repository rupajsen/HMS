//  LoginView.swift
//  firebase_auth
//  Created by Rupaj Sen on 24/04/24.

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Image
//                Image("logo")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 100, height: 120)
//                    .padding(.vertical, 32)
//                
                Text("InfyHealth")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.top,50)
                
                Spacer()
                // Form fields
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email address", placeholder: "name@example.com", isSecureField: false)
                        .autocapitalization(.none)
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                        .padding(.bottom, 20) // Adding padding between password input and "Forgot Password?" link
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Forgot password link
                NavigationLink(destination: ForgotPasswordView().navigationBarBackButtonHidden(true)) {
                    Text("Forgot Password?")
                        .font(.system(size: 14))
                }
                
                // Sign in button
                Button(action: {
                    Task {
                        do {
                            // Attempt to sign in with provided email and password
                            try await viewModel.signIn(withEmail: email, password: password)
                        } catch {
                            // Handle sign-in error
                            self.showAlert.toggle()
                            print("Failed to sign in with error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    HStack {
                        Text("Sign in")
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
                    return Alert(title: Text("Failed to sign in"), message: Text("Invalid login credentials"), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
                
                // Sign up button
                NavigationLink(destination: RegistrationView().navigationBarBackButtonHidden(true)) {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
