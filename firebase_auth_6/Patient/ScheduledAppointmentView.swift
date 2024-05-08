

import SwiftUI
import Firebase

struct Appointment: Identifiable {
    var appointmentId: String
    var id = UUID()
    var name: String
    var department: String
    var time: String
    var date: String
}

struct AppointmentCard: View {
    let appointment: Appointment
    var onCancel : (() -> Void)?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.2))
                .frame(width: 300, height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
            VStack(spacing: 10){
                HStack(spacing: 10) {
                    Image("doc")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                        )
                        .padding(.leading, 50)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(appointment.name)
                            .font(.title3).bold()
                        Text(appointment.department)
                            .font(.subheadline)
                        Text(" \(appointment.time)")
                            .frame(width: 90)
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                            .font(.subheadline)

                        Text("\(appointment.date)")
                            .frame(width:90)
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                            .font(.subheadline)
                        Button(action: {
                            onCancel?() // Call the cancel closure when tapped
                        }) {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 8) // Adjusted horizontal padding
                                .padding(.vertical, 4) // Adjusted vertical padding
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }}

                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical,10)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search Doctors", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .padding(.leading,20)
            Button(action: {
                self.text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(.trailing)
                    .onTapGesture {
                        self.text = ""
                    }
            }
        }
    }
}

struct ScheduledAppointmentView: View {
    @State private var selectedTabIndex = 0
    @State private var userUID : String?
    @State private var appointmentsBooked : [Appointment] = []
    @State private var appointmentHistory: [AppointmentHistory] = []
    @State private var searchText: String = ""
    @State private var appointmentToDelete: Appointment?
    @State private var showAlert = false

    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Appointments")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("", selection: $selectedTabIndex) {
                Text("Upcoming").tag(0)
                Text("History").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 10)

            if selectedTabIndex == 0 {
                upcomingAppointmentsView()
            } else {
                appointmentHistoryView()
            }
        }
        .padding()
        .onAppear {
            getUserUID()
            fetchAppointments(forUserID: userUID ?? "") { dataFetched, error in
                if let fetchedAppointments = dataFetched {
                    self.appointmentsBooked = fetchedAppointments
                }
            }
        }
    }

    private func upcomingAppointmentsView() -> some View {
        VStack(alignment: .leading) {

            SearchBar(text: $searchText).padding()
            

            ScrollView {
                VStack {
                    ForEach(filteredAppointments) { appointment in
                        // AppointmentCard with cancel appointment action
                        AppointmentCard(appointment: appointment) {
                            // Set the appointment to delete
                            self.appointmentToDelete = appointment
                            // Show alert
                            self.showAlert = true
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Cancel Appointment"),
                message: Text("Are you sure you want to cancel this appointment?"),
                primaryButton: .destructive(Text("Yes")) {
                    // Call function to delete appointment when user confirms
                    deleteAppointment()
                },
                secondaryButton: .cancel(Text("No"))
            )
        }
    }

    private func appointmentHistoryView() -> some View {
        NavigationView { // Ensure that the view is embedded in a NavigationView
            VStack(alignment: .leading) {
                List(appointmentHistory) { appointment in
                    NavigationLink(destination: PatientHistoryDetailView(appointmentHistory: appointment)) {
                        VStack(alignment: .leading) {
                            Text("Doctor: \(appointment.doctorName)")
                            Text("Date: \(appointment.date)")
                            Text("Diagnosis: \(appointment.diagnosis)")
                        }
                    }
                }
                .backgroundStyle(.white)
                .padding()
            }
        }
        .onAppear {
            fetchAppointmentHistory(forUserID: userUID ?? "") { dataFetched, error in
                if let fetchedHistory = dataFetched {
                    self.appointmentHistory = fetchedHistory
                }
            }
        }
    }

    private var filteredAppointments: [Appointment] {
        if searchText.isEmpty {
            return appointmentsBooked
        } else {
            return appointmentsBooked.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func getUserUID(){
        guard let user = Auth.auth().currentUser else {
            print("User is not authenticated.")
            return
        }
        print("Authenticated user UID:", user.uid)
        self.userUID = user.uid
    }

    func fetchAppointments(forUserID userID: String, completion: @escaping ([Appointment]?, Error?) -> Void) {
        let db = Firestore.firestore()

        // Reference to the appointments collection
        let appointmentsRef = db.collection("appointments")

        // Query appointments where doctorID matches the user's ID
        appointmentsRef.whereField("userId", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            var appointments: [Appointment] = []

            for document in querySnapshot!.documents {
                let data = document.data()
                let time = data["time"] as? String ?? ""
                let id = document.documentID

                let timestamp = data["date"] as? Timestamp ?? Timestamp(date: Date())
                let date = timestamp.dateValue()

                // Create a DateFormatter
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"

                // Format the date
                let formattedDate = formatter.string(from: date)
                print("Formatted date: \(formattedDate)")


                let doctorID = data["doctorId"] as? String ?? ""


                print(data)

                // Fetch doctor details using doctorID
                fetchDoctorDetails(forDoctorID: doctorID) { (doctor, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    guard let doctor = doctor else {
                        completion(nil, nil)
                        return
                    }

                    let name = doctor.name
                    let department = doctor.specialization
                    let appointment = Appointment(appointmentId: id ,name: name, department: department, time: time, date: formattedDate)
                    appointments.append(appointment)

                    // Check if all appointments are fetched
                    completion(appointments, nil)

                }
            }
        }
    }

    private func fetchAppointmentHistory(forUserID userID: String, completion: @escaping ([AppointmentHistory]?, Error?) -> Void) {
        let db = Firestore.firestore()

        let historyRef = db.collection("patienthistory")

        historyRef.whereField("userId", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            var history: [AppointmentHistory] = []

            for document in querySnapshot!.documents {
                let data = document.data()
                let doctorID = data["doctorId"] as? String ?? ""
                let date = data["date"] as? Timestamp ?? Timestamp(date: Date())
                let diagnosis = data["diagnosis"] as? String ?? ""

                fetchDoctorName(forDoctorID: doctorID) { (doctorName, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }

                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a z"

                    let formattedDate = formatter.string(from: date.dateValue())

                    let appointment = AppointmentHistory(doctorName: doctorName, date: formattedDate, diagnosis: diagnosis)
                    history.append(appointment)

                    if history.count == querySnapshot!.documents.count {
                        completion(history, nil)
                    }
                }
            }
        }
    }

    private func fetchDoctorDetails(forDoctorID doctorID: String, completion: @escaping (Doctor?, Error?) -> Void) {
        let db = Firestore.firestore()

        let doctorsRef = db.collection("doctors")

        doctorsRef.document(doctorID).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }

            let data = document.data()
            let name = data?["fullName"] as? String ?? ""
            let specialization = data?["specialization"] as? String ?? ""
            let photo = data?["photo"] as? String ?? ""

            let doctor = Doctor(name: name, specialization: specialization, photo: photo)
            completion(doctor, nil)
        }
    }

    private func fetchDoctorName(forDoctorID doctorID: String, completion: @escaping (String, Error?) -> Void) {
        let db = Firestore.firestore()

        let doctorsRef = db.collection("doctors")

        doctorsRef.document(doctorID).getDocument { (document, error) in
            if let error = error {
                completion("", error)
                return
            }

            guard let document = document, document.exists else {
                completion("", nil)
                return
            }

            let data = document.data()
            let name = data?["fullName"] as? String ?? ""

            completion(name, nil)
        }
    }

    private func deleteAppointment() {
        guard let appointment = appointmentToDelete else { return }
        let db = Firestore.firestore()
        let appointmentID = appointment.appointmentId

        print(appointmentID)
        // Get a reference to the appointment document
        let appointmentRef = db.collection("appointments").document(appointmentID)
        // Delete the appointment document
        appointmentRef.delete { error in
            if let error = error {
                print("Error deleting appointment:", error.localizedDescription)
            } else {
                print("Appointment deleted successfully!")

                // Remove appointment from local state only after successful deletion
                self.appointmentsBooked.removeAll { $0.id == appointment.id }
            }
        }
    }
}

struct AppointmentHistory: Identifiable {
    var id = UUID()
    var doctorName: String
    var date: String
    var diagnosis: String
}

struct PatientHistoryDetailView: View {
    let appointmentHistory: AppointmentHistory

    var body: some View {
        Form {
            Section(header: Text("Doctor Details")) {
                Text("Name: \(appointmentHistory.doctorName)")
            }

            Section(header: Text("Appointment Details")) {
                Text("Date: \(appointmentHistory.date)")
                Text("Diagnosis: \(appointmentHistory.diagnosis)")
            }
        }
        .navigationBarTitle("Appointment Details", displayMode: .inline)
    }
}


