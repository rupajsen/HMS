import SwiftUI
import FirebaseFirestore
import Firebase

struct PatientDashView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var name: String = ""
    @State private var image: UIImage?
    @State private var dateOfBirth = Date()
    @State private var allergies: String = ""
    @State private var bloodPressure: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var otherVitals: String = ""
    @State private var latestLabTestReports: String = ""
    @State private var showImagePicker: Bool = false
    @State private var medicationEntries: [[String: Any]] = [] // Array to hold medication entries

    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showProfileView = false // State variable to control the visibility of the PatientProfileView
    
    var popularDoctors: [Doctor] = [
        Doctor(name: "Dr. Smith", specialization: "Dentist", photo: "doc"),
        Doctor(name: "Dr. Johnson", specialization: "Ophthalmologist", photo: "doc"),
        Doctor(name: "Dr. Williams", specialization: "General Physician", photo: "doc"),
        Doctor(name: "Dr. Brown", specialization: "Pathologist", photo: "doc"),
        Doctor(name: "Dr. Davis", specialization: "Immunologist", photo: "doc")
    ]
    
    var body: some View {
        NavigationView{
            ZStack{
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack{
                            Text("Patient View")
                            if let fullName = viewModel.currentUser?.fullname {
                                Text("Welcome \(fullName)!")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .padding()
                            } else {
                                Text("Welcome!")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .padding()
                            }
                            
                            Text("Get Health Checkup done today!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom)
                            
                            NavigationLink(destination: DepartmentView()) {
                                Text("Book Your Appointment")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .foregroundColor(.clear)
                        .frame(width: 398, height: 300)
                        .offset(y:20)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.05, green: 0.51, blue: 0.99), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.03, green: 0.3, blue: 0.59), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .cornerRadius(42)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                        .ignoresSafeArea()
                        .offset(y:-59)
                        
                        VStack{
                            Text("Your upcoming Appointments")
                                .font(.title2)
                                
                                .frame(maxWidth: .infinity,alignment: .leading)
                            
                            TestView()
                            
                            
                            VStack(alignment: .leading) {
                                Text("Medication Entries")
                                    .font(.title2)
                                    
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                
                                ScrollView(.horizontal,showsIndicators: false) {
                                    ScrollViewReader { proxy in
                                        HStack {
                                            ForEach(medicationEntries.indices, id: \.self) { index in
                                                MedicationCard(entry: medicationEntries[index])
                                                    .padding()
                                                    .background(Color.white)
                                                    .cornerRadius(10)
                                                    .padding(.horizontal)
                                                 .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.blue.opacity(0.2), lineWidth: 2))
                                                    .frame(width:340 ,height: 160)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                            HStack{
                                Text("Doctor Speciality")
                                    .font(.title2)
                                    .padding(.vertical)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                            }
                            
                            VStack(alignment: .leading) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(popularDoctors) { doctor in
                                            VStack {
                                                if let photoName = doctor.photo {
                                                    Image(photoName)
                                                        .resizable()
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                        .shadow(radius: 5)
                                                        .padding(.bottom, 8)
                                                }
                                                Text(doctor.name)
                                                    .font(.headline)
                                                Text(doctor.specialization)
                                                    .font(.subheadline)
                                            }
                                            .padding()
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(10)
                                            .padding(.horizontal, 8)
                                            
                                        }
                                        
                                        
                                    }
                                }
                            }
                            
                            
                        }
                        .padding()
                        .offset(y:-59)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            guard let phoneNum = URL(string: "tel://102") else { return }
                            UIApplication.shared.open(phoneNum)
                        }) {
                            Image(systemName: "phone.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .clipShape(Circle())
                                .padding(.trailing)
                                .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                                .offset(y:-50)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear {
            fetchLatestMedicationEntries() // Fetch patient history when the view appears
        }
    }
    

    private func fetchLatestMedicationEntries() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently logged in")
            return
        }

        let db = Firestore.firestore()
        let userId = currentUser.uid

        let medicationHistoryRef = db.collection("patienthistory")
            .whereField("userId", isEqualTo: userId) // Query by user ID
            .limit(to: 1)

        medicationHistoryRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching medication history: \(error)")
                return
            }

            guard let document = querySnapshot?.documents.first else {
                print("No documents found")
                return
            }

            if let medicationEntries = document.data()["medicationEntries"] as? [[String: Any]] {
                self.medicationEntries = medicationEntries
                print("Fetched medication entries successfully: \(self.medicationEntries)")
            } else {
                print("No medication entries found in the document")
            }
        }
    }



}


struct MedicationCard: View {
    var entry: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry["medicineName"] as? String ?? "")
                .foregroundColor(Color(red: 0.05, green: 0.51, blue: 0.99))
                .font(.title2)
                .bold()
            
            Text("Dosage: \(entry["dosage"] as? String ?? "")")
                .foregroundColor(Color(red: 0.03, green: 0.31, blue: 0.59).opacity(0.5))
            
            Text("Time: \(entry["time"] as? String ?? "")")
                .foregroundColor(Color(red: 0.03, green: 0.31, blue: 0.59).opacity(0.5))
            
            Text("Additional Description: \(entry["additionalDescription"] as? String ?? "")")
                .foregroundColor(Color(red: 0.03, green: 0.31, blue: 0.59).opacity(0.5))
        }
        .frame(maxWidth: 300, maxHeight: 95)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white) // Use a white background to prevent the shadow from being clipped
//                ./*shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 0) // Add shadow with appropriate radius and offset*/
        )
        .cornerRadius(10)
        
    }
}



struct PatientDashView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDashView()
    }
}
