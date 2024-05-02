//  ScheduledAppointmentView.swift
//  firebase_auth
//  Created by Rupaj Sen on 26/04/24.



import SwiftUI
import Firebase


//let appointments = [
//    Appointment(name: "Dr. Name : John Soliya", department: "Dept : General", time: "11:00 AM", date: "11/02/2023"),
//    // Add more appointments as needed
//]

struct TestView: View {
    @State var userUID : String?
    @State var appointmentsBooked : [Appointment] = []
    var body: some View {
        
        VStack(alignment: .leading) {
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(appointmentsBooked) { appointment in
                        AppointmentCard(appointment: appointment)
                    }
                }
            }.frame(width:350)
        }
        .onAppear{
            getUserUID()
            fetchAppointments(forUserID: userUID ?? "") { dataFetched, error in
                print(dataFetched)
                
                self.appointmentsBooked = dataFetched ??     [Appointment(name: "Dr. Name : John Soliya", department: "Dept1 : General", time: "11:00 AM", date: "11/02/2023")]
            }
        }
        .padding()
        .frame(width:300)
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
                        // Sort appointments by date and time
                        appointments.sort { (first, second) -> Bool in
                            if first.date == second.date {
                                return first.time < second.time
                            } else {
                                return first.date < second.date
                            }
                        }
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
    TestView()
}
