//  AppointmentView.swift
//  HMS_Main
//  Created by Admin on 23/04/24.

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AppointmentView: View {
    @State private var selectedDate: Date = Date()
        @State private var selectedTimeSlot: Int?
        @State private var additionalInfo: String = ""
        let selectedDoctorId: String? // Change selectedDoctorId to be an optional String
        @EnvironmentObject var viewModel : AuthViewModel
        @Environment(\.presentationMode) var presentationMode
        @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    /*if let user = viewModel.currentUser{
                        Text(user.id)
                    }*/
                    Text("Select Date")
                        .font(.title2)
                        .bold()
                        .padding(.top, 20)
                    
                    DatePicker("", selection: $selectedDate, in: Date()...Date().addingTimeInterval(60*60*24*30), displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    Text("Available Time Slot")
                        .font(.title2)
                        .bold()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(9..<17) { hour in
                                let displayHour = hour > 12 ? hour - 12 : hour
                                let displaySuffix = hour >= 12 ? "PM" : "AM"
                                let displayTime = "\(displayHour):00 \(displaySuffix)"
                                
                                Text(displayTime)
                                    .frame(width: 100, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedTimeSlot == hour ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                    )
                                    .cornerRadius(8)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 4)
                                    .onTapGesture {
                                        selectedTimeSlot = hour
                                    }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    Text("What issue are you facing")
                        .font(.title2)
                        .bold()
                    
                    TextField("Any additional information", text: $additionalInfo)
                        .foregroundColor(Color.gray.opacity(1))
                        .font(.title3)
                        .padding()
                        .background(
                            RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        saveAppointment()
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
                .navigationBarTitle("", displayMode: .inline) // Set navigation bar title to empty string
                .padding(.bottom, -30)
            }
        }
    }
    
//    func saveAppointment() {
//        // Check if user is authenticated
//        guard let user = Auth.auth().currentUser else {
//            print("User is not authenticated.")
//            return
//        }
//
//        // Print authenticated user UID
//        print("Authenticated user UID:", user.uid)
//
//        // Get Firestore reference
//        let db = Firestore.firestore()
//        
//        // Reference to the user's document
//        let userRef = db.collection("users").document(user.uid)
//        
//        // Generate UUID for appointment
//        let appointmentId = UUID().uuidString
//
//        // Appointment data to be saved
//        let appointmentData: [String: Any] = [
//            "date": Timestamp(date: selectedDate), // Convert selectedDate to Firestore Timestamp
//            "time": selectedTimeSlot != nil ? "\(selectedTimeSlot!):00 \(selectedTimeSlot! >= 12 ? "PM" : "AM")" : "", // Format time
//            "additionalInfo": additionalInfo, // Additional information
//            "userId": user.uid, // User ID
//            "doctorId": selectedDoctorId // Doctor ID
//        ]
//
//        // Add appointment data to user's appointments sub-collection
//        userRef.collection("appointments").document(appointmentId).setData(appointmentData) { error in
//            if let error = error {
//                print("Error saving appointment:", error.localizedDescription)
//            } else {
//                print("Appointment saved successfully!")
//            }
//        }
//    }
//    
    
    
//    
//    func saveAppointment() {
//        // Check if user is authenticated
//        guard let user = Auth.auth().currentUser else {
//            print("User is not authenticated.")
//            return
//        }
//
//        // Print authenticated user UID
//        print("Authenticated user UID:", user.uid)
//
//        // Print selected doctor's ID
//        print("Selected Doctor ID:", selectedDoctorId)
//
//        // Get Firestore reference
//        let db = Firestore.firestore()
//        
//        // Generate UUID for appointment
//        let appointmentId = UUID().uuidString
//
//        // Appointment data to be saved
//        let appointmentData: [String: Any] = [
//            "date": Timestamp(date: selectedDate), // Convert selectedDate to Firestore Timestamp
//            "time": selectedTimeSlot != nil ? "\(selectedTimeSlot!):00 \(selectedTimeSlot! >= 12 ? "PM" : "AM")" : "", // Format time
//            "additionalInfo": additionalInfo, // Additional information
//            "userId": user.uid, // User ID
//            "doctorId": selectedDoctorId // Doctor ID
//        ]
//
//        // Reference to appointments collection
//        let appointmentsRef = db.collection("appointments")
//        
//        // Add appointment data to appointments collection
//        appointmentsRef.document(appointmentId).setData(appointmentData) { error in
//            if let error = error {
//                print("Error saving appointment:", error.localizedDescription)
//            } else {
//                // Print appointment details
//                print("Appointment saved successfully!")
//                print("Appointment ID:", appointmentId)
//                print("Doctor ID:", selectedDoctorId)
//                print("Patient ID:", user.uid)
//            }
//        }
//        presentationMode.wrappedValue.dismiss()
//    }

    func saveAppointment() {
        // Check if user is authenticated
        guard let user = Auth.auth().currentUser else {
            print("User is not authenticated.")
            return
        }

        // Print authenticated user UID
        print("Authenticated user UID:", user.uid)

        // Get Firestore reference
        let db = Firestore.firestore()
        
        // Generate UUID for appointment
        let appointmentId = UUID().uuidString

        // Appointment data to be saved
        var appointmentData: [String: Any] = [
            "date": Timestamp(date: selectedDate), // Convert selectedDate to Firestore Timestamp
            "time": selectedTimeSlot != nil ? "\(selectedTimeSlot!):00 \(selectedTimeSlot! >= 12 ? "PM" : "AM")" : "", // Format time
            "additionalInfo": additionalInfo, // Additional information
            "userId": user.uid // User ID
        ]
        
        // Add doctor ID to appointment data if doctor is selected
        if let selectedDoctorId = selectedDoctorId {
            appointmentData["doctorId"] = selectedDoctorId
        }

        // Reference to the appointments collection
        let appointmentsCollection = db.collection("appointments")

        // Add appointment data to appointments collection
        appointmentsCollection.document(appointmentId).setData(appointmentData) { error in
            if let error = error {
                print("Error saving appointment:", error.localizedDescription)
            } else {
                print("Appointment saved successfully!")
            }
        }
    }


    

    struct AppointmentView_Previews: PreviewProvider {
        static var previews: some View {
            AppointmentView(selectedDoctorId: "")
        }
    }
}

#Preview {
    AppointmentView(selectedDoctorId: "")
}



