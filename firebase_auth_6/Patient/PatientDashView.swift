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
                                                 
                                                    .frame(width:360 ,height: 150)
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
                                .padding(.bottom, UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?
                                    .windows
                                    .first?
                                    .safeAreaInsets
                                    .bottom ?? 0)
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
        HStack(spacing: 10) {
            // Left Image
            Image("med")
                .resizable()
                .frame(width: 50, height: 50)
                
                .padding(.trailing, 10)
            
            // Content VStack
                VStack(alignment: .leading, spacing: 5) {
                    // Title
                    Text(entry["medicineName"] as? String ?? "")
                        .foregroundColor(Color(red: 0.05, green: 0.51, blue: 0.99))
                        .font(.title3) // Adjusted font size
                        .bold()
                    
                    Text("Dosage: \(entry["dosage"] as? String ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.03, green: 0.31, blue: 0.59).opacity(0.8))
                        .lineLimit(1)
                    
                    Text("Note: \(entry["additionalDescription"] as? String ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.03, green: 0.31, blue: 0.59).opacity(0.8))
                        .lineLimit(1)
                    
                    
                }
                .frame(width: 120)
                
               
                    // Time
                    
                ZStack {
                                    Circle()
                        .fill(Color(red: 0.82, green: 0.93, blue: 1.2)) // Light blue background
                                        .frame(width: 60, height: 60)
                                    
                                    Text(entry["time"] as? String ?? "")
                                        .foregroundColor(Color(red: 0.05, green: 0.51, blue: 0.99)) 
                                        .bold()// Primary color
                                        .font(.subheadline)
                                        .padding(.horizontal, 5) // Padding to keep text inside the circle
                                }
                .padding(.leading,30)
                
            
            
            // Spacer to make the card shorter
             // Add spacer to push content to the left
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white) // Background color of the card
        .cornerRadius(10) // Rounded corners
        .shadow(radius: 2) // Shadow for depth
    }
}





struct PatientDashView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDashView()
    }
}
