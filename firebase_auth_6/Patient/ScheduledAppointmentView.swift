//  ScheduledAppointmentView.swift
//  firebase_auth
//  Created by Rupaj Sen on 26/04/24.

import SwiftUI
import Firebase

struct Appointment: Identifiable {
    var id = UUID()
    var name: String
    var department: String
    var time: String
    var date: String
}

//let appointments = [
//    Appointment(name: "Dr. Name : John Soliya", department: "Dept : General", time: "11:00 AM", date: "11/02/2023"),
//    // Add more appointments as needed
//]

struct AppointmentCard: View {
    let appointment: Appointment

   
    var body: some View {
        
        ZStack {
             RoundedRectangle(cornerRadius: 10)
                 .fill(Color.blue.opacity(0.2))
                 .frame(width: 300, height: 150)
                 .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1) // Adjust the border width as needed
                        )
            
                 
             
            HStack(spacing: 10) {
                Image("doc")
                    .resizable()
                    .frame(width: 80, height: 80) // Adjust the width and height values
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
        
//        HStack(spacing: 15) {
//            Image("doc")
//                .resizable()
//                .frame(width: 50, height: 50)
//                .cornerRadius(10)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.blue.opacity(0.2), lineWidth: 2)
//                )
//
//            VStack(alignment: .leading, spacing: 5) {
//                Text(appointment.name)
//                    .font(.headline)
//                Text(appointment.department)
//                    .font(.subheadline)
//                Text("Time Slot: \(appointment.time)")
//                    .font(.subheadline)
//                Text("Date: \(appointment.date)")
//                    .font(.subheadline)
//            }
//        }
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.2)))
//        .padding(.horizontal)
//        .frame(width: 280)
    }
}

struct ScheduledAppointmentView: View {
    @State var userUID : String?
    @State var appointmentsBooked : [Appointment] = []
    var body: some View {
        VStack(alignment: .leading) {
            Text("Appointments")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .frame(maxWidth: .infinity,alignment: .leading)
            
            ScrollView {
                VStack {
                    ForEach(appointmentsBooked) { appointment in
                        AppointmentCard(appointment: appointment)
                    }
                }
            }
        }
        .onAppear{
            getUserUID()
            fetchAppointments(forUserID: userUID ?? "") { dataFetched, error in
                print(dataFetched)
                
                self.appointmentsBooked = dataFetched ??     [Appointment(name: "Dr. Name : John Soliya", department: "Dept1 : General", time: "11:00 AM", date: "11/02/2023")]

            }
        }
        .padding()
    }
    
    func getUserUID(){
        guard let user = Auth.auth().currentUser else {
            print("User is not authenticated.")
            return
        }
        // Print authenticated user UID
        print("Authenticated user UID:", user.uid)
        self.userUID = user.uid
    }
    
    /*
    func fetchAppointments(forUserID userID: String, completion: @escaping ([Appointment]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Reference to the user's document
        let userRef = db.collection("users").document(userID)
        
        // Reference to the appointments sub-collection under the user's document
        let appointmentsRef = userRef.collection("appointments")
        
        // Fetch appointments from the appointments sub-collection
        appointmentsRef.getDocuments { (querySnapshot, error) in
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

                // Create a DateFormatter
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"

                // Format the date
                let formattedDate = formatter.string(from: date)
                print("Formatted date: \(formattedDate)")

                
                let doctorID = data["doctorId"] as? String ?? ""
                
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
                    let appointment = Appointment(name: name, department: department, time: time, date: formattedDate)
                    appointments.append(appointment)
                    
                    // Check if all appointments are fetched
                    if appointments.count == querySnapshot!.documents.count {
                        completion(appointments, nil)
                    }
                }
            }
        }
    }*/

    
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
                
//                 Fetch doctor details using doctorID
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
                    
                    // Check if all appointments are fetched
                        completion(appointments, nil)
                    
                }
            }
        }
    }


    func fetchDoctorDetails(forDoctorID doctorID: String, completion: @escaping (Doctor?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Reference to the doctors collection
        let doctorsRef = db.collection("doctors")
        
        // Query doctor details based on doctorID
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

}


#Preview {
    ScheduledAppointmentView()
}
