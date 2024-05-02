import SwiftUI
import Firebase
import FirebaseFirestore
struct AddStaff: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isSavingComplete = false
        @State private var showAlert = false
        @State private var alertMessage = ""
        @Environment(\.presentationMode) var presentationMode
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var contactNo = ""
    @State private var department = "General"
    @State private var position = ""
    @State private var specialization = "General"
    @State private var educationalDetails = ""
    
    @State private var selectedShifts = Array(repeating: Array(repeating: (startTime: "", endTime: ""), count: 2), count: 7)
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var departmentOptions = ["General", "Pediatrics", "Gynecology", "Dermatology", "Orthopedics", "Cardiology", "Endocrinology", "Neurology"]
    var specializationOptions = ["General", "Pediatrics", "Gynecology", "Dermatology", "Orthopedics", "Cardiology", "Endocrinology", "Neurology"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sign Up")) {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                    TextField("Password", text: $password)
                        .textContentType(.password)
                    TextField("Confirm Password", text: $confirmPassword)
                        .textContentType(.password)
                }
                
                Section(header: Text("Profile Information")) {
                    TextField("Contact No.", text: $contactNo)
                    Picker("Department", selection: $department) {
                        ForEach(departmentOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Specialization", selection: $specialization) {
                        ForEach(specializationOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("Position", text: $position)
                    TextField("Educational Details", text: $educationalDetails)
                }
                
                Section(header: Text("Scheduled Shifts")) {
                    ForEach(0..<daysOfWeek.count) { dayIndex in
                        HStack {
                            Text(self.daysOfWeek[dayIndex])
                            Spacer()
                            HStack {
                                TextField("Start Time", text: self.$selectedShifts[dayIndex][0].startTime)
                                    .frame(width: 100)
                                TextField("End Time", text: self.$selectedShifts[dayIndex][0].endTime)
                                    .frame(width: 100)
                                Text(self.calculateHours(start: self.selectedShifts[dayIndex][0].startTime, end: self.selectedShifts[dayIndex][0].endTime))
                                    .frame(width: 100)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Add Staff", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        signUpAndSaveData()
                    }) {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Full screen mode
        .background(
                    NavigationLink(
                        destination: EmptyView(),
                        isActive: $isSavingComplete,
                        label: { EmptyView() }
                    )
                    .hidden()
                )
    }
    
    func calculateHours(start: String, end: String) -> String {
        guard let startHour = Int(start), let endHour = Int(end) else {
            return ""
        }
        let totalHours = endHour - startHour
        return "\(totalHours) hrs"
    }
    

    func signUpAndSaveData() {
        if password == confirmPassword {
            Task {
                do {
                    // Create user
                    let user = try await viewModel.createUser(withEmail: email, password: password, fullname: fullName, userType: .doctor)
                    
                    // Save doctor data to Firestore "doctors" collection
                    let doctorData: [String: Any] = [
                        "userId": user.id,
                        "fullName": fullName,
                        "email": email,
                        "contactNo": contactNo,
                        "department": department,
                        "position": position,
                        "specialization": specialization,
                        "educationalDetails": educationalDetails,
                        "shifts": flattenShifts() // Assuming you have a function to flatten the shifts
                    ]
                    try await Firestore.firestore().collection("doctors").document(user.id).setData(doctorData)
                    
                    // Data saving logic could be moved here if needed after successful data saving
                    DispatchQueue.main.async {
                        isSavingComplete = true
                    }
                } catch {
                    alertMessage = "Error signing up and saving data: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        } else {
            print("Passwords do not match")
        }
    }




    // Function to flatten the shifts array
    func flattenShifts() -> [[String: String]] {
        var flattenedShifts: [[String: String]] = []
        for dayShifts in selectedShifts {
            for shift in dayShifts {
                let flattenedShift: [String: String] = ["startTime": shift.startTime, "endTime": shift.endTime]
                flattenedShifts.append(flattenedShift)
            }
        }
        return flattenedShifts
    }


}

struct AddStaff_Previews: PreviewProvider {
    static var previews: some View {
        AddStaff().environmentObject(AuthViewModel())
    }
}
