//
//  EditAccountView.swift
//  firebase_auth
//
//  Created by Rupaj Sen on 25/04/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct EditAccountView: View {
    @State private var dob = Date()
    @State private var allergies = ""
    @State private var bloodPressure = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var bloodGroup = ""
    @State private var gender = Gender.male // Assuming Gender is an enum with cases male and female

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                TextField("Blood Group", text: $bloodGroup)
                TextField("Allergies", text: $allergies)
                TextField("Blood Pressure", text: $bloodPressure)
                TextField("Height", text: $height)
                TextField("Weight", text: $weight)
                Picker("Gender", selection: $gender) {
                    Text("Male").tag(Gender.male)
                    Text("Female").tag(Gender.female)
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section {
                Button("Save") {
                    // Check if there's a logged-in user
                    if let user = Auth.auth().currentUser {
                        // Reference to Firestore collection for users
                        let db = Firestore.firestore()
                        let userRef = db.collection("users").document(user.uid)

                        // Create a dictionary with the user's details
                        let userDetails: [String: Any] = [
                            "dob": dob,
                            "bloodGroup": bloodGroup,
                            "allergies": allergies,
                            "bloodPressure": bloodPressure,
                            "height": height,
                            "weight": weight,
                            "gender": gender == .male ? "male" : "female" // Store as string
                        ]

                        // Update the user's document in Firestore
                        userRef.setData(userDetails, merge: true) { error in
                            if let error = error {
                                print("Error updating user details: \(error.localizedDescription)")
                            } else {
                                print("User details updated successfully!")
                            }
                        }
                    } else {
                        print("No user logged in.")
                    }
                }

            }
        }
        .navigationTitle("Edit Profile")
    }
}


#Preview {
    EditAccountView()
}
