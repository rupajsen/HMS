import SwiftUI
import Firebase
import FirebaseAuth

class EditAccountViewModel: ObservableObject {
    @Published var dob = Date()
    @Published var allergies = ""
    @Published var bloodPressure = ""
    @Published var height = ""
    @Published var weight = ""
    @Published var bloodGroup = ""
    @Published var gender = Gender.male
    
    // Function to load user data from Firestore
    func loadUserData() {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    let userData = document.data()
                    self.dob = userData?["dob"] as? Date ?? Date()
                    self.allergies = userData?["allergies"] as? String ?? ""
                    self.bloodPressure = userData?["bloodPressure"] as? String ?? ""
                    self.height = userData?["height"] as? String ?? ""
                    self.weight = userData?["weight"] as? String ?? ""
                    self.bloodGroup = userData!["bloodGroup"] as? String ?? ""
                    self.gender = (userData?["gender"] as? String ?? "") == "male" ? .male : .female
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            print("No user logged in.")
        }
    }
    
    // Function to save user data to Firestore
    func saveUserData() {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            let userDetails: [String: Any] = [
                "dob": dob,
                "bloodGroup": bloodGroup,
                "allergies": allergies,
                "bloodPressure": bloodPressure,
                "height": height,
                "weight": weight,
                "gender": gender == .male ? "male" : "female"
            ]
            
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

struct EditAccountView: View {
    @ObservedObject var viewModel = EditAccountViewModel()
    @State private var showAlert = false

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                DatePicker("Date of Birth", selection: $viewModel.dob, displayedComponents: .date)
                TextField("Blood Group", text: $viewModel.bloodGroup)
                TextField("Allergies", text: $viewModel.allergies)
                TextField("Blood Pressure", text: $viewModel.bloodPressure)
                TextField("Height", text: $viewModel.height)
                TextField("Weight", text: $viewModel.weight)
                Picker("Gender", selection: $viewModel.gender) {
                    Text("Male").tag(Gender.male)
                    Text("Female").tag(Gender.female)
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section {
                Button("Save") {
                    viewModel.saveUserData()
                    showAlert = true
                }
            }
        }
        .onAppear {
            viewModel.loadUserData() // Load user data when the view appears
        }
        .navigationTitle("Edit Profile")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Data saved successfully!"),
                dismissButton: .default(Text("OK")) {
                    // Do nothing or navigate back to previous page as needed
                }
            )
        }
    }
}

#Preview{
    EditAccountView()
}
