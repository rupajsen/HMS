import SwiftUI
import Firebase
import SwiftUICharts

struct StaffList: View {
    @State private var selectedTab = 0
    @State private var isAddStaffSheetPresented = false
    @State private var doctors: [Doctor1] = []
    @State private var patients: [Patient1] = []
    @State private var appointments: [Appointment1] = []
    @State private var searchText: String = ""
    @State private var searchTextDoctor = ""
    @State private var searchTextPatient = ""
    
    @State private var totalAppointmentsCount = 0

    
    let totalPatientsVisited = 100
        let activeAppointmentsCount = 20
        let closedAppointmentsCount = 30
        let scheduledAppointmentsCount = 50
        
        let doctorsAppointments = [("Dr. John Doe", 5), ("Dr. Jane Smith", 8),("Dr. Varad Kadtan", 14)] // Sample data
        
    var filteredDoctors: [Doctor1] {
           if searchTextDoctor.isEmpty {
               return doctors
           } else {
               return doctors.filter { $0.name.localizedCaseInsensitiveContains(searchTextDoctor) }
           }
       }

       var filteredPatients: [Patient1] {
           if searchTextPatient.isEmpty {
               return patients
           } else {
               return patients.filter { $0.name.localizedCaseInsensitiveContains(searchTextPatient) }
           }
       }


    var body: some View {
        VStack {
            Picker(selection: $selectedTab, label: Text("Select Tab")) {
                Text("Overview").tag(0)
                Text("Staff List").tag(1)
                Text("Patient List").tag(2)
                Text("Patient Appointments").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 1 {
                VStack {
                    HStack{
                        SearchBar(text: $searchTextDoctor, placeholder: "Search Doctors")
                        Button(action: {
                            isAddStaffSheetPresented.toggle()
                        }) {
                            Text("Add New Staff")
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                            ForEach(filteredDoctors.indices, id: \.self) { index in
                                DoctorCard1(doctor: filteredDoctors[index])
                            }
                        }
                    }
                }
            } else if selectedTab == 2 {
                VStack {
                    SearchBar(text: $searchTextPatient, placeholder: "Search Patients")
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                            ForEach(filteredPatients.indices, id: \.self) { index in
                                PatientCard1(patient: filteredPatients[index])
                            }
                        }
                    }
                }
            } else if selectedTab == 3 {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                        ForEach(appointments.indices, id: \.self) { index in
                            AppointmentCard1(appointment: appointments[index])
                        }
                    }
                }
            }
            else {
                ScrollView {
                    VStack(spacing: 20) {
                        OverviewTabView()
                    }
                    .padding()
                }
            }

            
            Spacer()
            
//            Button(action: {
//                isAddStaffSheetPresented.toggle()
//            }) {
//                Text("Add New Staff")
//                    .foregroundColor(.blue)
//                    .padding()
//                    .background(Color.blue.opacity(0.2))
//                    .cornerRadius(10)
//            }
        }
        .padding()
        .navigationTitle("Staff Management")
        .navigationBarItems(trailing: Image(systemName: "person.crop.circle"))
        .sheet(isPresented: $isAddStaffSheetPresented) {
            AddStaff()
        }
        .onAppear {
            fetchDoctorsFromFirestore()
            fetchPatientsFromFirestore()
            fetchAppointmentsFromFirestore()
        }
    }
    
    func fetchDoctorsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("doctors").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching doctors: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.doctors = documents.compactMap { queryDocumentSnapshot in
                let data = queryDocumentSnapshot.data()
                return Doctor1(data: data)
            }
        }
    }
    
    func fetchPatientsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("users").whereField("userType", isEqualTo: "Patient").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching patients: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.patients = documents.compactMap { queryDocumentSnapshot in
                let data = queryDocumentSnapshot.data()
                return Patient1(data: data)
            }
        }
    }

//    func fetchAppointmentsFromFirestore() {
//        let db = Firestore.firestore()
//        db.collection("appointments").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error fetching appointments: \(error.localizedDescription)")
//                return
//            }
//
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//
//            self.appointments = documents.compactMap { queryDocumentSnapshot in
//                let data = queryDocumentSnapshot.data()
//                return Appointment1(data: data)
//            }
//
//        }
//    }
    
    func fetchAppointmentsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("appointments").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching appointments: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            
            
            self.appointments = documents.compactMap { queryDocumentSnapshot in
                let data = queryDocumentSnapshot.data()
                return Appointment1(data: data)
            }
            
            // Print the total appointments count for debugging
            let totalAppointmentsCount = documents.count
            print("Total Appointments Count: \(totalAppointmentsCount)")
            
            // Update the total appointments count using a separate state variable
            DispatchQueue.main.async {
                self.totalAppointmentsCount = totalAppointmentsCount
            }
        }
    }

    struct SearchBar: View {
        @Binding var text: String
        var placeholder: String
        
        var body: some View {
            HStack {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing)
                        .onTapGesture {
                            self.text = "" // Clear the search text
                        }
                }
            }
        }
    }
}

import SwiftUI
import Firebase

struct OverviewTabView: View {
    @State private var totalAppointmentsCount = 0 // Define totalAppointmentsCount as a state variable
    @State private var totalPatientsCount = 0 // Define totalPatientsCount as a state variable
    @State private var totalDoctorsCount = 0 // Define totalDoctorsCount as a state variable

    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    GreetingCard(title: "Hello, Admin", subtitle: "Welcome to your dashboard")
                        //.frame(width: 755, height: 150)
                        .frame(alignment: .leading)
                        .padding()

                    HStack {
                        // Total Bookings Card
                        TotalBookingsCard(title: "Total Bookings", value: "\(totalAppointmentsCount)", buttonAction: {})

                        // Total patients Card
                        TotalBookingsCard(title: "Total patients", value: "\(totalPatientsCount)", buttonAction: {})

                        // Doctors Available Card
                        TotalBookingsCard(title: "Doctors Available", value: "\(totalDoctorsCount)", buttonAction: {})
                        
                        SummaryStatisticsView()
                            .offset(y:-45)
                        
                    }
                    .offset(y: -70)
                    .frame(maxWidth: .infinity)
                    .padding()

                    // Summary Statistics

                    HStack {
                        // Patient List
                        PatientListView()

                        // Doctors List
                    }
                    .frame(maxWidth: .infinity)
                }

//                VStack {
//                    SummaryStatisticsView()
//                        .offset(y: -60)
//
////                    DoctorListView()
////                        .offset(y: -70)
//                }
//                .offset(y: 60)
            }
        }
        .onAppear {
            // Fetch appointments, patient, and doctor counts from Firestore
            fetchAppointmentsCountFromFirestore()
            fetchPatientsCountFromFirestore()
            fetchDoctorsCountFromFirestore()
        }
    }

    // Function to fetch appointments count from Firestore
    func fetchAppointmentsCountFromFirestore() {
        let db = Firestore.firestore()
        db.collection("appointments").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching appointments count: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No appointment documents")
                return
            }
            
            // Update totalAppointmentsCount with the count of documents
            self.totalAppointmentsCount = documents.count
        }
    }
    
    // Function to fetch patients count from Firestore
    func fetchPatientsCountFromFirestore() {
        let db = Firestore.firestore()
        db.collection("users").whereField("userType", isEqualTo: "Patient").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching patients count: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No patient documents")
                return
            }
            
            // Update totalPatientsCount with the count of documents
            self.totalPatientsCount = documents.count
        }
    }
    
    // Function to fetch doctors count from Firestore
    func fetchDoctorsCountFromFirestore() {
        let db = Firestore.firestore()
        db.collection("users").whereField("userType", isEqualTo: "Doctor").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching doctors count: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No doctor documents")
                return
            }
            
            // Update totalDoctorsCount with the count of documents
            self.totalDoctorsCount = documents.count
        }
    }
}

struct TotalBookingsCard: View {
    var title: String
    var value: String
    var buttonAction: () -> Void
    
    init(title: String, value: String, buttonAction: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 10)
            
            Divider()
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 10)
        }
        .frame(width: 200, height: 120)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        //.shadow(radius: 5)
    }
}


import SwiftUI
import FirebaseFirestore

struct SummaryStatisticsView: View {
    @State private var appointmentsCount: Int = 0
    @State private var completedAppointmentsCount: Int = 0
    @State private var pendingAppointmentsCount: Int = 0
    
    var body: some View {
        VStack {
            
            PieChartView(total: appointmentsCount, completed: completedAppointmentsCount, pending: pendingAppointmentsCount)
                .frame(width: 200, height: 200)
                .offset(y: -40)



            // Summary Card
            VStack(alignment: .leading) {
                Text("Summary")
                    .font(.headline)
                Divider()
                SummaryRow(status: "Total Appointments", count: "\(appointmentsCount)", color: .yellow)
                SummaryRow(status: "Completed Appointments", count: "\(completedAppointmentsCount)", color: .green)
                SummaryRow(status: "Pending Appointments", count: "\(pendingAppointmentsCount)", color: .red)
                // Add other SummaryRows for different status types here
            }
            .frame(width: 260)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .offset(y: -60)
        .padding()
        .onAppear {
            fetchAppointmentsDataFromFirestore()
        }
    }
    
    
    // Function to fetch appointments data from Firestore
    func fetchAppointmentsDataFromFirestore() {
        let db = Firestore.firestore()
        
        // Fetch total appointments count
        db.collection("appointments").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching appointments data: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No appointment documents")
                return
            }
            
            // Update appointmentsCount with the total count of appointments
            self.appointmentsCount = documents.count
            
            // Calculate pending appointments count
            self.pendingAppointmentsCount = self.appointmentsCount - self.completedAppointmentsCount
        }
        
        // Fetch completed appointments count from patienthistory collection
        db.collection("patienthistory").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching completed appointments data: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No completed appointment documents")
                return
            }
            
            // Update completedAppointmentsCount with the count of completed appointments
            self.completedAppointmentsCount = documents.count
            
            // Calculate pending appointments count
            self.pendingAppointmentsCount = self.appointmentsCount - self.completedAppointmentsCount
        }
    }
}

struct SummaryRow: View {
    var status: String
    var count: String
    var color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text("\(status): \(count)")
        }
    }
}


import SwiftUI
import FirebaseFirestore

struct PatientListView: View {
    @State private var appointmentsData: [Date: Double] = [:]
    @State private var selectedGraphOption = 0
    let graphOptions = ["Day", "Week", "Year"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Appointments")
                .font(.headline)
                .padding()
            
            Divider()
            
            // Display all graphs side by side
            HStack(spacing: 20) {
                
                GraphView(data: getAppointmentsDataForGraph(option: 0), title: "Day")
                    .frame(maxWidth: .infinity)
                
                
                GraphView(data: getAppointmentsDataForGraph(option: 1), title: "Week")
                    .frame(maxWidth: .infinity)
                
                
                GraphView(data: getAppointmentsDataForGraph(option: 2), title: "Year")
                    .frame(maxWidth: .infinity)
            }
            .padding()
            //.frame(maxHeight: 600)
            
            
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .offset(y:-170)
        
        .padding()
        .onAppear {
            fetchAppointmentsDataFromFirestore(for: selectedGraphOption)
        }
    }
    
    // Function to fetch appointments data from Firestore
    func fetchAppointmentsDataFromFirestore(for option: Int) {
        let db = Firestore.firestore()
        db.collection("appointments").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("Error fetching appointments data:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            // Parse the appointment data and count appointments for each date
            var appointmentsData: [Date: Double] = [:]
            let calendar = Calendar.current
            for document in documents {
                if let timestamp = document["date"] as? Timestamp {
                    // Convert Timestamp to Date
                    let date = timestamp.dateValue()
                    
                    // Depending on the selected graph option, count appointments
                    switch option {
                    case 0: // Day
                        // For day option, count appointments for each date
                        appointmentsData[calendar.startOfDay(for: date), default: 0] += 1
                        
                    case 1: // Week
                        // For week option, group appointments by week
                        let weekOfYear = calendar.component(.weekOfYear, from: date)
                        let year = calendar.component(.year, from: date)
                        let weekDate = calendar.date(from: DateComponents(year: year, weekOfYear: weekOfYear))
                        appointmentsData[weekDate!, default: 0] += 1
                        
                    case 2: // Year
                        // For year option, group appointments by year
                        let year = calendar.component(.year, from: date)
                        let yearDate = calendar.date(from: DateComponents(year: year))
                        appointmentsData[yearDate!, default: 0] += 1
                        
                    default:
                        break
                    }
                }
            }
            
            // Update the appointmentsData state variable
            DispatchQueue.main.async {
                self.appointmentsData = appointmentsData
            }
        }
    }

    
    // Function to get appointments data based on selected graph option
    private func getAppointmentsDataForGraph(option: Int) -> [Double] {
        let data = appointmentsData
            .sorted { $0.key < $1.key }
            .map { $0.value }
        
        switch option {
        case 0: // Day
            return data
        case 1: // Week
            // Filter appointments data for weekly view
            return data.enumerated().compactMap { index, value in
                index % 7 == 0 ? value : nil
            }
        case 2: // Year
            // Filter appointments data for yearly view
            return data.enumerated().compactMap { index, value in
                index % 30 == 0 ? value : nil
            }
        default:
            return []
        }
    }
}

struct GraphView: View {
    let data: [Double]
    let title: String
    
    var body: some View {
        VStack {
            if !data.isEmpty {
                LineChartView(data: data, title: "\(title)", legend: "Appointments in \(title)")
                    
            } else {
                Text("No data available")
                    .foregroundColor(.gray)
            }
        }
        
    }
}




struct DoctorListItemm: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "person")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Dr. Smith")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Specialty: Cardiology")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}



// Preview



struct OverviewCard: View {
    var title: String
    var count: Int
    var icon: String
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(Color.blue)
                
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray)
            }
            
            Text("\(count)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            LineGraphView(count: count) // Line graph visualization
            
        }
        .padding(20)
        .frame(width: 500, height:300) // Fixed size for consistency
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct LineGraphView: View {
    var count: Int
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let stepWidth = geometry.size.width / CGFloat(count)
                
                // Move to the starting point
                path.move(to: CGPoint(x: 0, y: geometry.size.height))
                
                // Iterate through each step and add points to the path
                for i in 0..<count {
                    let x = CGFloat(i) * stepWidth
                    let y = CGFloat.random(in: geometry.size.height * 0.2...geometry.size.height * 0.8) // Randomize the y-coordinate
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                // Add a final line to the end of the view
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
            }
            .stroke(Color.blue, lineWidth: 2)
        }
        .padding(20)
    }
}

struct GreetingCard: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                VStack(alignment: .leading){
                    Text(title)
                        .font(.largeTitle)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
                .padding(.leading)
                Image("admin")
                    .resizable()
                    .frame(height: 250)
            }
        }
        .frame(width: 760,height: 150)// Align VStack contents to the left
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct AppointmentCard1: View {
    let appointment: Appointment1
    @State private var doctorName: String = ""
    @State private var patientName: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Doctor: \(doctorName)")
                        .font(.headline)
                    Text("Patient: \(patientName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Date: \(formattedDate)")
                Text("Time: \(appointment.time)")
                Text("Additional Info: \(appointment.additionalInfo)")
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("View Details")
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .shadow(color: Color.blue.opacity(0.5), radius: 3, x: 0, y: 2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .onAppear {
            fetchDoctorName()
            fetchPatientName()
        }
    }

    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: appointment.date)
    }
    
    private func fetchDoctorName() {
        let db = Firestore.firestore()
        let doctorRef = db.collection("users").document(appointment.doctorId)
        
        doctorRef.getDocument { document, error in
            if let document = document, document.exists {
                let doctorData = document.data()
                self.doctorName = doctorData?["fullName"] as? String ?? "Unknown Doctor"
            } else {
                print("Doctor document does not exist")
            }
        }
    }
    
    private func fetchPatientName() {
        let db = Firestore.firestore()
        let patientRef = db.collection("users").document(appointment.userId)
        
        patientRef.getDocument { document, error in
            if let document = document, document.exists {
                let patientData = document.data()
                self.patientName = patientData?["fullname"] as? String ?? "Unknown Patient"
            } else {
                print("Patient document does not exist")
            }
        }
    }
}


struct Appointment1 {
    let additionalInfo: String
    let date: Date
    let doctorId: String
    let time: String
    let userId: String
    var doctorName: String = ""
    var patientName: String = ""

    init(data: [String: Any]) {
        self.additionalInfo = data["additionalInfo"] as? String ?? ""
        if let timestamp = data["date"] as? Timestamp {
            self.date = timestamp.dateValue()
        } else {
            self.date = Date()
        }
        self.doctorId = data["doctorId"] as? String ?? ""
        self.time = data["time"] as? String ?? ""
        self.userId = data["userId"] as? String ?? ""
    }
}



struct DoctorCard1: View {
    let doctor: Doctor1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(doctor.name)
                        .font(.headline)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Designation: \(doctor.designation)")
                Text("Department: \(doctor.department)")
                Text("Contact No.: \(doctor.contactNo)")
                Text("Educational Details: \(doctor.educationalDetails)")
                Text("Email: \(doctor.email)")
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("View Details")
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .shadow(color: Color.blue.opacity(0.5), radius: 3, x: 0, y: 2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct PatientCard1: View {
    let patient: Patient1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.name)
                        .font(.headline)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Weight: \(patient.weight) kg")
                Text("Blood Pressure: \(patient.bloodPressure)")
                Text("Blood Glucose: \(patient.bloodGlucose)")
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("View Details")
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .shadow(color: Color.blue.opacity(0.5), radius: 3, x: 0, y: 2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}





struct Doctor1 {
    let name: String
    let designation: String
    let department: String
    let contactNo: String
    let educationalDetails: String
    let email: String
    let position: String
    
    init(data: [String: Any]) {
        self.name = data["fullName"] as? String ?? ""
        self.designation = data["designation"] as? String ?? ""
        self.department = data["specialization"] as? String ?? ""
        self.contactNo = data["contactNo"] as? String ?? ""
        self.educationalDetails = data["educationalDetails"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.position = data["position"] as? String ?? ""
    }
}


struct Patient1 {
    let name: String
    let patientID: String
    let weight: String
    let bloodPressure: String
    let bloodGlucose: String
    
    init(data: [String: Any]) {
        self.name = data["fullname"] as? String ?? ""
        self.patientID = data["id"] as? String ?? ""
        self.weight = data["weight"] as? String ?? ""
        self.bloodPressure = data["bloodPressure"] as? String ?? ""
        self.bloodGlucose = data["bloodGlucose"] as? String ?? ""
    }
}

struct PieChartSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
    
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.degrees, endAngle.degrees) }
        set { startAngle.degrees = newValue.first; endAngle.degrees = newValue.second }
    }
}

struct ColoredPieChartSlice: View {
    var shape: PieChartSlice
    var body: some View {
        shape.fill(shape.color)
    }
}

struct PieChartView: View {
    var total: Int
    var completed: Int
    var pending: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ColoredPieChartSlice(shape: PieChartSlice(startAngle: .degrees(0),
                                                          endAngle: .degrees(self.angle(for: self.completed, total: self.total)), color:Color.gray.opacity(0.1)))
                
                ColoredPieChartSlice(shape: PieChartSlice(startAngle: .degrees(self.angle(for: self.completed, total: self.total)),
                              endAngle: .degrees(self.angle(for: self.completed + self.pending, total: self.total)),
                             color: Color.blue.opacity(0.15)))
                
                ColoredPieChartSlice(shape: PieChartSlice(startAngle: .degrees(self.angle(for: self.completed + self.pending, total: self.total)),
                              endAngle: .degrees(360),
                             color: .clear)) // Use a transparent color for the remaining space
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func angle(for value: Int, total: Int) -> Double {
        guard total != 0 else { return 0 } // Prevent division by zero
        let valueDouble = Double(value)
        let totalDouble = Double(total)
        return 360 * (valueDouble / totalDouble)
    }
}



#Preview {
    StaffList()
}
