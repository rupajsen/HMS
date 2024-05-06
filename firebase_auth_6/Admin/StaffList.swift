//
//  AddStaff.swift
//  HMS_Main
//
//  Created by Rupaj Sen on 24/04/24.
//
//
//import SwiftUI
//
//struct StaffList: View {
//    @State private var selectedTab = 1
//    @State private var isAddStaffSheetPresented = false
//
//    var body: some View {
//            VStack {
//                Picker(selection: $selectedTab, label: Text("What is your favorite color?")) {
//                    Text("Overview").tag(0)
//                    Text("Staff List").tag(1)
//                    Text("Patient List").tag(2)
//                    Text("Patient Appointments").tag(3)
//                }.pickerStyle(SegmentedPickerStyle())
//                
//                SearchBar(text: .constant(""))
//                
//                if selectedTab == 1 {
//                    ScrollView {
//                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
//                            ForEach(0..<10) { _ in
//                                StaffCard()
//                            }
//                        }
//                    }
//                } else {
//                    // Display other content for the Overview, Patient List, and Patient Appointments tabs
//                }
//                
//                
//                if selectedTab == 2 {
//                    ScrollView {
//                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
//                            ForEach(0..<10) { _ in
//                                PatientCard()
//                            }
//                        }
//                    }
//                } else {
//                    // Display other content for the Overview, Patient List, and Patient Appointments tabs
//                }
//                
//                
//                
//                Spacer()
//                
//                Button(action: {
//                               // Show the AddStaff sheet when the button is tapped
//                               isAddStaffSheetPresented.toggle()
//                           }) {
//                               Text("Add New Staff")
//                                   .foregroundColor(.white)
//                                   .padding()
//                                   .background(Color.blue)
//                                   .cornerRadius(10)
//                           }
//            }
//            .padding()
//            .navigationTitle("Staff Management")
//            .navigationBarItems(trailing: Image(systemName: "person.crop.circle"))
//            .sheet(isPresented: $isAddStaffSheetPresented) {
//                        // Present the AddStaff sheet when isAddStaffSheetPresented is true
//                        AddStaff()
//                    }
//    }
//}
//
//struct StaffCard: View {
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Circle()
//                    .fill(Color.gray)
//                    .frame(width: 50, height: 50)
//                
//                VStack(alignment: .leading) {
//                    Text("Kristan Watson")
//                        .font(.headline)
//                    Text("Employee ID: 27140440")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//            }
//            
//            Divider()
//            
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Designation: Cardiologists, Head")
//                Text("Department: Cardiology")
//                Text("Contact no.: 9893823937")
//            }
//            
//            Spacer()
//            
//            Button(action: {}) {
//                Text("View Doctor Details")
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.purple)
//                    .cornerRadius(10)
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 10)
//    }
//}
//
//
//
//#Preview {
//    StaffList()
//}

import SwiftUI
import Firebase

struct StaffList: View {
    @State private var selectedTab = 0
    @State private var isAddStaffSheetPresented = false
    @State private var doctors: [Doctor1] = []
    @State private var patients: [Patient1] = []
    @State private var appointments: [Appointment1] = []
    @State private var searchText: String = ""
    @State private var searchTextDoctor = ""
    @State private var searchTextPatient = ""
    
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
                    SearchBar(text: $searchTextDoctor, placeholder: "Search Doctors")
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
                        OverviewTabView(totalPatientsVisited: totalPatientsVisited,
                                                        activeAppointmentsCount: activeAppointmentsCount,
                                                        closedAppointmentsCount: closedAppointmentsCount,
                                                        scheduledAppointmentsCount: scheduledAppointmentsCount,
                                                        doctorsAppointments: doctorsAppointments)
                    }
                    .padding()
                }
            }

            
            Spacer()
            
            Button(action: {
                isAddStaffSheetPresented.toggle()
            }) {
                Text("Add New Staff")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
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
struct OverviewTabView: View {
    var totalPatientsVisited: Int
    var activeAppointmentsCount: Int
    var closedAppointmentsCount: Int
    var scheduledAppointmentsCount: Int
    var doctorsAppointments: [(doctorName: String, appointmentsCount: Int)]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Overview")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                HStack(spacing: 30) {
                    OverviewCard(title: "Total Patients Visited", count: totalPatientsVisited, icon: "person.fill")
                    OverviewCard(title: "Active Appointments", count: activeAppointmentsCount, icon: "calendar.circle.fill")
                }
                
                HStack(spacing: 30) {
                    OverviewCard(title: "Closed Appointments", count: closedAppointmentsCount, icon: "checkmark.circle.fill")
                    OverviewCard(title: "Scheduled Appointments", count: scheduledAppointmentsCount, icon: "clock.fill")
                }
                
                
             
            }
            .padding(.horizontal,20)
            .padding(.bottom,20)

            
        }
        .frame(maxWidth: 3000, maxHeight: 2500)
        .background(Color.white)
    }
}

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

struct AppointmentCard1: View {
    let appointment: Appointment1
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text("Doctor: \(appointment.doctorId)")
                        .font(.headline)
                    Text("Patient: \(appointment.userId)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Date: \(formattedDate)")
                Text("Time: \(appointment.time)")
                Text("Additional Info: \(appointment.additionalInfo)")
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("View Details")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }

    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy "
        return dateFormatter.string(from: appointment.date)
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
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(doctor.name)
                        .font(.headline)
                    Text("Employee ID: \(doctor.position)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Designation: \(doctor.designation)")
                Text("Department: \(doctor.department)")
                Text("Contact no.: \(doctor.contactNo)")
                Text("Educational Details: \(doctor.educationalDetails)")
                Text("Email: \(doctor.email)")
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("View Details")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct PatientCard1: View {
    let patient: Patient1
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(patient.name)
                        .font(.headline)
                    Text("Patient ID: \(patient.patientID)")
                        .font(.subheadline)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Weight: \(patient.weight)")
                Text("Blood Pressure: \(patient.bloodPressure)")
                Text("Blood Glucose: \(patient.bloodGlucose)")
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("View Details")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
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


#Preview {
    StaffList()
}
