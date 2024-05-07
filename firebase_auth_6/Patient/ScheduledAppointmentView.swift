//  ScheduledAppointmentView.swift
//  firebase_auth
//  Created by Rupaj Sen on 26/04/24.
//
//import SwiftUI
//import Firebase
//
//struct Appointment: Identifiable {
//    var id = UUID()
//    var name: String
//    var department: String
//    var time: String
//    var date: String
//}
//
//
//
//struct AppointmentCard: View {
//    let appointment: Appointment
//
//
//    var body: some View {
//
//        ZStack {
//             RoundedRectangle(cornerRadius: 10)
//                 .fill(Color.blue.opacity(0.2))
//                 .frame(width: 300, height: 150)
//                 .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.blue, lineWidth: 1) // Adjust the border width as needed
//                        )
//
//
//
//            HStack(spacing: 10) {
//                Image("doc")
//                    .resizable()
//                    .frame(width: 80, height: 80) // Adjust the width and height values
//                    .clipShape(Circle())
//                    .overlay(
//                        Circle()
//                            .stroke(Color.blue.opacity(0.2), lineWidth: 2)
//                    )
//                    .padding(.leading, 50)
//
//
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(appointment.name)
//                        .font(.title3).bold()
//                    Text(appointment.department)
//                        .font(.subheadline)
//                    Text(" \(appointment.time)")
//                        .frame(width: 90)
//                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
//                        .background(Color.blue.opacity(0.2))
//                        .foregroundColor(.blue)
//                        .cornerRadius(10)
//                        .font(.subheadline)
//
//                    Text("\(appointment.date)")
//                        .frame(width:90)
//                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
//                        .background(Color.blue.opacity(0.2))
//                        .foregroundColor(.blue)
//                        .cornerRadius(10)
//                        .font(.subheadline)
//                }
//                .frame(maxWidth: .infinity)
//
//             }
//         }
//
//
//    }
//}
//
//struct SearchBar: View {
//    @Binding var text: String
//
//    var body: some View {
//        HStack {
//            TextField("Search Doctors", text: $text)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
//                .padding(.leading,20)
//            Button(action: {
//                self.text = ""
//            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//                    .padding(.trailing)
//                    .onTapGesture {
//                        self.text = "" // Clear the search text
//                    }
//            }
//        }
//    }
//}
//
//struct ScheduledAppointmentView: View {
//    @State var userUID : String?
//    @State var appointmentsBooked : [Appointment] = []
//    @State private var searchText: String = ""
//    var body: some View {
//            VStack(alignment: .leading) {
//                Text("Appointments")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding(.vertical)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                SearchBar(text: $searchText).padding(.bottom,20)
//
//                ScrollView {
//                    VStack {
//                        ForEach(filteredAppointments) { appointment in
//                            AppointmentCard(appointment: appointment)
//                        }
//                    }
//                }
//            }
//            .onAppear {
//                getUserUID()
//                fetchAppointments(forUserID: userUID ?? "") { dataFetched, error in
//                    if let fetchedAppointments = dataFetched {
//                        self.appointmentsBooked = fetchedAppointments
//                    }
//                }
//            }
//            .padding()
//        }
//
//        // Filter appointments based on search query and doctor's name
//        private var filteredAppointments: [Appointment] {
//            if searchText.isEmpty {
//                return appointmentsBooked
//            } else {
//                return appointmentsBooked.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//            }
//        }
//
//
//
//    func getUserUID(){
//        guard let user = Auth.auth().currentUser else {
//            print("User is not authenticated.")
//            return
//        }
//        // Print authenticated user UID
//        print("Authenticated user UID:", user.uid)
//        self.userUID = user.uid
//    }
//
//
//
//
//    func fetchAppointments(forUserID userID: String, completion: @escaping ([Appointment]?, Error?) -> Void) {
//        let db = Firestore.firestore()
//
//        // Reference to the appointments collection
//        let appointmentsRef = db.collection("appointments")
//
//        // Query appointments where doctorID matches the user's ID
//        appointmentsRef.whereField("userId", isEqualTo: userID).getDocuments { (querySnapshot, error) in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//
//            var appointments: [Appointment] = []
//
//            for document in querySnapshot!.documents {
//                let data = document.data()
//                let time = data["time"] as? String ?? ""
//
//                let timestamp = data["date"] as? Timestamp ?? Timestamp(date: Date())
//                let date = timestamp.dateValue()
//
//                // Create a DateFormatter
//                let formatter = DateFormatter()
//                formatter.dateFormat = "dd/MM/yyyy"
//
//                // Format the date
//                let formattedDate = formatter.string(from: date)
//                print("Formatted date: \(formattedDate)")
//
//
//                let doctorID = data["doctorId"] as? String ?? ""
//
//
//                print(data)
//
////                 Fetch doctor details using doctorID
//                fetchDoctorDetails(forDoctorID: doctorID) { (doctor, error) in
//                    if let error = error {
//                        completion(nil, error)
//                        return
//                    }
//                    guard let doctor = doctor else {
//                        completion(nil, nil)
//                        return
//                    }
//
//                    let name = doctor.name
//                    let department = doctor.specialization
//                    let appointment = Appointment(name: name, department: department, time: time, date: formattedDate)
//                    appointments.append(appointment)
//
//                    // Check if all appointments are fetched
//                        completion(appointments, nil)
//
//                }
//            }
//        }
//    }
//
//
//    func fetchDoctorDetails(forDoctorID doctorID: String, completion: @escaping (Doctor?, Error?) -> Void) {
//        let db = Firestore.firestore()
//
//        // Reference to the doctors collection
//        let doctorsRef = db.collection("doctors")
//
//        // Query doctor details based on doctorID
//        doctorsRef.document(doctorID).getDocument { (document, error) in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//
//            guard let document = document, document.exists else {
//                completion(nil, nil)
//                return
//            }
//
//            let data = document.data()
//            let name = data?["fullName"] as? String ?? ""
//            let specialization = data?["specialization"] as? String ?? ""
//            let photo = data?["photo"] as? String ?? ""
//
//            let doctor = Doctor(name: name, specialization: specialization, photo: photo)
//            completion(doctor, nil)
//        }
//    }
//
//}
//
//
//#Preview {
//    ScheduledAppointmentView()
//}
import SwiftUI
import Firebase

struct Appointment: Identifiable {
    var id = UUID()
    var name: String
    var department: String
    var time: String
    var date: String
}

struct AppointmentCard: View {
    let appointment: Appointment

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.2))
                .frame(width: 300, height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )

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
                }
                .frame(maxWidth: .infinity)
            }
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

    var body: some View {
        VStack(alignment: .leading) {
            Picker("", selection: $selectedTabIndex) {
                Text("Upcoming Appointments").tag(0)
                Text("Appointment History").tag(1)
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
        .onAppear {
            getUserUID()
            fetchAppointments(forUserID: userUID ?? "") { dataFetched, error in
                if let fetchedAppointments = dataFetched {
                    self.appointmentsBooked = fetchedAppointments
                }
            }
            fetchAppointmentHistory(forUserID: userUID ?? "") { dataFetched, error in
                if let fetchedHistory = dataFetched {
                    self.appointmentHistory = fetchedHistory
                }
            }
        }
        .padding()
    }

    private func upcomingAppointmentsView() -> some View {
        VStack(alignment: .leading) {
            Text("Appointments")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)

            SearchBar(text: $searchText).padding(.bottom,20)

            ScrollView {
                VStack {
                    ForEach(filteredAppointments) { appointment in
                        AppointmentCard(appointment: appointment)
                    }
                }
            }
        }
    }

    private func appointmentHistoryView() -> some View {
        NavigationView { // Ensure that the view is embedded in a NavigationView
            VStack(alignment: .leading) {
                Text("Appointment History")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, alignment: .leading)

                List(appointmentHistory) { appointment in
                    NavigationLink(destination: PatientHistoryDetailView(appointmentHistory: appointment)) {
                        VStack(alignment: .leading) {
                            Text("Doctor: \(appointment.doctorName)")
                            Text("Date: \(appointment.date)")
                            Text("Diagnosis: \(appointment.diagnosis)")
                        }
                    }
                }
                .padding()
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

    private func fetchAppointments(forUserID userID: String, completion: @escaping ([Appointment]?, Error?) -> Void) {
        let db = Firestore.firestore()

        let appointmentsRef = db.collection("appointments")

        appointmentsRef.whereField("userId", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            var appointments: [Appointment] = []

            for document in querySnapshot!.documents {
                let data = document.data()
                let time = data["time"] as? String ?? ""

                let timestamp = data["date"] as? Timestamp ?? Timestamp(date: Date())
                let date = timestamp.dateValue()

                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"

                let formattedDate = formatter.string(from: date)

                let doctorID = data["doctorId"] as? String ?? ""

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
                    let appointment = Appointment(name: name, department: department, time: time, date: formattedDate)
                    appointments.append(appointment)

                    if appointments.count == querySnapshot!.documents.count {
                        completion(appointments, nil)
                    }
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
}

struct AppointmentHistory: Identifiable {
    var id = UUID()
    var doctorName: String
    var date: String
    var diagnosis: String
}

struct ScheduledAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledAppointmentView()
    }
}


import SwiftUI

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
