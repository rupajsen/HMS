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
            Rectangle()
                .foregroundColor(Color(red: 0.05, green: 0.51, blue: 0.99))
                .frame(width: 350, height: 170)
                .cornerRadius(25)
                .overlay(
                    HStack(spacing: 10) {
                        Image("doc")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .padding(.bottom,80)
                            .padding(.leading, 0)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 0)
                            )
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(appointment.name)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align from left edge
                            
                            Text(appointment.department)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align from left edge
                        }
                        .frame(width: 130, height: 50)
                        .padding(.leading, 0) // Add padding for spacing from the image
                        .padding(.bottom,80)
                        Button(action: {
                            onCancel?() // Call the cancel closure when tapped
                        }) {
                            Text("Cancel")
                                .foregroundColor(.white)
                                .font(.caption)
                                 // Adjusted horizontal padding
                                 // Adjusted vertical padding
                                .background(Color(red: 0.05, green: 0.51, blue: 0.99)) // Matched appointment card theme color
                                .cornerRadius(10)
                                .padding(5)
                                .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.white, lineWidth: 1) // White border with small thickness
                                                .padding(2) // Adjusted padding for the border
                                        )
                                .padding(.bottom, 100)
                                .padding(.leading, 50)
                                
                                
                                
                        }

                    }
                    .padding(.horizontal, 0)
                    .padding(.top, 20)
                )
            
            Rectangle()
                .foregroundColor(Color(red: 0.03, green: 0.31, blue: 0.59).opacity(0.5))
                .frame(width: 300, height: 50)
                .cornerRadius(26)
                .overlay(
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        Text("\(appointment.date)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.trailing,10)
                        
                        Image(systemName: "clock")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        Text("\(appointment.time)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 20)
                )
                .padding(.top,20)
                .offset(x: 0, y: 30) // Offset to overlap with the larger rectangle
        }
        Spacer()
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
    @State private var historySearchText: String = ""

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
        VStack(alignment: .center) {

            SearchBar(text: $searchText).padding()
            

            ScrollView (showsIndicators: false){
                VStack {
                    ForEach(filteredAppointments) { appointment in
                                        if isTodayOrFuture(appointment.date) {
                                            AppointmentCard(appointment: appointment) {
                                                self.appointmentToDelete = appointment
                                              self.showAlert = true
                                            }
                                        }
                                    }                }
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

    private func isTodayOrFuture(_ dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let appointmentDate = dateFormatter.date(from: dateString) {
            return appointmentDate >= Date()
        }
        return false
    }
    
    private func appointmentHistoryView() -> some View {
        NavigationView {
            VStack(alignment: .center) {
                SearchBar(text: $historySearchText).padding()

                ScrollView {
                    ForEach(filteredHistoryAppointments) { appointment in
                        NavigationLink(destination: PatientHistoryDetailView(appointmentHistory: appointment)) {
                            AppointmentHistoryRow(appointment: appointment, searchText: historySearchText)
                                .buttonStyle(PlainButtonStyle())
                                
                        }
                    }
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
    }


    private var filteredHistoryAppointments: [AppointmentHistory] {
        if historySearchText.isEmpty {
            return appointmentHistory
        } else {
            return appointmentHistory.filter {
                $0.doctorName.localizedCaseInsensitiveContains(historySearchText) ||
                $0.date.localizedCaseInsensitiveContains(historySearchText) ||
                $0.diagnosis.localizedCaseInsensitiveContains(historySearchText)
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
                let time = data["time"] as? String ?? ""
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

                    let appointment = AppointmentHistory(doctorName: doctorName, date: formattedDate, diagnosis: diagnosis, time: time)
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

struct AppointmentHistoryRow: View {
    let appointment: AppointmentHistory
    let searchText: String

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }

    var body: some View {
        if searchText.isEmpty ||
            appointment.doctorName.localizedCaseInsensitiveContains(searchText) ||
            dateFormatter.string(from: convertToDate(appointment.date)).localizedCaseInsensitiveContains(searchText) ||
            appointment.diagnosis.localizedCaseInsensitiveContains(searchText) {

            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(red: 0.05, green: 0.51, blue: 0.99))
                    .frame(width: 350, height: 170)
                    .cornerRadius(25)
                    .overlay(
                        VStack(alignment: .leading, spacing:0) {
                            HStack {
                                Image("doc")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .padding(.leading, 20)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.blue.opacity(0.2), lineWidth: 0)
                                    )
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Doctor: \(appointment.doctorName)")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                        Text("Diagnosis: \(appointment.diagnosis)")
                                            .font(.subheadline)
                                                                                        .foregroundColor(.white)
                                    
                                }
                                .padding(.trailing, 30)
                            }
                            .padding(.top,10)
                            
                            
                            Rectangle()
                                .foregroundColor(Color(red: 0.03, green: 0.31, blue: 0.59).opacity(0.5))
                                .frame(width: 300, height: 50)
                                .cornerRadius(26)
                                .padding(.top,10)
                                .padding(.leading,25)
                                .overlay(
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                            .padding(.top,10)

                                        
                                        Text("Date: \(dateFormatter.string(from: convertToDate(appointment.date)))")
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                            .padding(.trailing,10)
                                            .padding(.top,10)
                                        
                                        
                                        
                                        
                                    }
                                                                    )
                                
                        }
                        
                    )
            }
            .padding(.horizontal, 20)
            
        } else {
            EmptyView()
        }
    }

    private func convertToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // Change to match your date format
        return formatter.date(from: dateString) ?? Date()
    }
}



struct AppointmentHistory: Identifiable {
    var id = UUID()
    var doctorName: String
    var date: String
    var diagnosis: String
    var time: String
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

#Preview{
    ScheduledAppointmentView()
}


