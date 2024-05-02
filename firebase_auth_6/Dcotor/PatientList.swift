//
//  PatientList.swift
//  HMS_Main
//
//  Created by Rupaj Sen on 24/04/24.
//
//
//import SwiftUI
//import Firebase
//
//struct PatientList: View {
//    @State private var patientHistory: [PatientHistory] = []
//    private var loggedInUserID: String? { Auth.auth().currentUser?.uid }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                ScrollView {
//                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
//                        ForEach(patientHistory, id: \.id) { history in
//                            NavigationLink(destination: PatientDetailsView(history: history)) {
//                                PatientCard(history: history)
//                            }
//                        }
//                    }
//                }
//                .padding()
//            }
//            .onAppear {
//                fetchPatientHistory()
//            }
//            .navigationTitle("Patient List")
//            .navigationBarItems(trailing: Image(systemName: "person.crop.circle"))
//        }
//    }
//    
//    func fetchPatientHistory() {
//        guard let loggedInUserID = loggedInUserID else {
//            print("Logged-in user ID not found.")
//            return
//        }
//        
//        let db = Firestore.firestore()
//        
//        db.collection("patienthistory")
//            .whereField("doctorId", isEqualTo: loggedInUserID)
//            .getDocuments { querySnapshot, error in
//                if let error = error {
//                    print("Error fetching patient history: \(error)")
//                } else {
//                    guard let documents = querySnapshot?.documents else { return }
//                    patientHistory = documents.compactMap { queryDocumentSnapshot in
//                        let data = queryDocumentSnapshot.data()
//                        let id = queryDocumentSnapshot.documentID
//                        return PatientHistory(id: id, data: data)
//                    }
//                }
//            }
//    }
//}
//
//struct PatientCard: View {
//    let history: PatientHistory
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Circle()
//                    .fill(Color.gray)
//                    .frame(width: 50, height: 50)
//                
//                VStack(alignment: .leading) {
//                    Text(history.userId) // Display patient's name
//                        .font(.headline)
//                    Text("Patient ID: \(history.userId)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//            }
//            
//            Divider()
//            
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Diagnosis: \(history.diagnosis)")
//                Text("Follow-up Date: \(formatDate(history.followUpDate))")
//                Text("Medication Entries:")
//                ForEach(history.medicationEntries.indices, id: \.self) { index in
//                    CustomMedicationEntryView(entry: history.medicationEntries[index])
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 10)
//    }
//    
//    func formatDate(_ date: Timestamp) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
//        return dateFormatter.string(from: date.dateValue())
//    }
//}
//
//struct CustomMedicationEntryView: View {
//    let entry: CustomMedicationEntry
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Medicine Name: \(entry.customMedicineName)")
//            Text("Dosage: \(entry.customDosage)")
//            Text("Time: \(entry.customTime)")
//            Text("Additional Description: \(entry.customAdditionalDescription)")
//        }
//    }
//}
//
//struct PatientHistory {
//    let id: String
//    let userId: String
//    let diagnosis: String
//    let followUpDate: Timestamp
//    let medicationEntries: [CustomMedicationEntry]
//    
//    init(id: String, data: [String: Any]) {
//        self.id = id
//        self.userId = data["userId"] as? String ?? ""
//        self.diagnosis = data["diagnosis"] as? String ?? ""
//        self.followUpDate = data["followUpDate"] as? Timestamp ?? Timestamp()
//        
//        if let medications = data["medicationEntries"] as? [[String: String]] {
//            self.medicationEntries = medications.map { entry in
//                return CustomMedicationEntry(customMedicineName: entry["medicineName"] ?? "",
//                                             customDosage: entry["dosage"] ?? "",
//                                             customTime: entry["time"] ?? "",
//                                             customAdditionalDescription: entry["additionalDescription"] ?? "")
//            }
//        } else {
//            self.medicationEntries = []
//        }
//    }
//}
//
//struct CustomMedicationEntry {
//    let customMedicineName: String
//    let customDosage: String
//    let customTime: String
//    let customAdditionalDescription: String
//}
//
//struct PatientDetailsView: View {
//    let history: PatientHistory
//    
//    var body: some View {
//        Text("Patient Details")
//            .navigationTitle("Patient Details")
//    }
//}
//
//struct PatientList_Previews: PreviewProvider {
//    static var previews: some View {
//        PatientList()
//    }
//}



import SwiftUI
import Firebase

struct PatientList: View {
    @State private var patientHistory: [PatientHistory] = []
    private var loggedInUserID: String? { Auth.auth().currentUser?.uid }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 1)) {
                        ForEach(patientHistory, id: \.id) { history in
                            NavigationLink(destination: PatientDetailsView(history: history)) {
                                PatientCard(history: history)
                            }
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                fetchPatientHistory()
            }
            .navigationTitle("Patient List")
            .navigationBarItems(trailing: Image(systemName: "person.crop.circle"))
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use StackNavigationViewStyle for iPad
    }
    
    func fetchPatientHistory() {
        guard let loggedInUserID = loggedInUserID else {
            print("Logged-in user ID not found.")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("patienthistory")
            .whereField("doctorId", isEqualTo: loggedInUserID)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching patient history: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    patientHistory = documents.compactMap { queryDocumentSnapshot in
                        let data = queryDocumentSnapshot.data()
                        let id = queryDocumentSnapshot.documentID
                        return PatientHistory(id: id, data: data)
                    }
                }
            }
    }
}

struct PatientCard: View {
    let history: PatientHistory
    @State private var patientInfoFetched: Bool = false
    @State private var patientName: String = ""
    @State private var patientBloodGroup: String = ""
    @State private var patientEmail: String = ""
    @State private var patientGender: String = ""
    @State private var showingDetails = false // Tracks whether to show patient details
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text("Patient's Name:")
                        .font(.headline)
                    if patientInfoFetched {
                        Text(patientName)
                            .font(.subheadline)
                    } else {
                        Text("Fetching...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Blood Group:")
                    .font(.headline)
                if patientInfoFetched {
                    Text(patientBloodGroup)
                        .font(.subheadline)
                        .foregroundColor(.black) // Change text color to black
                } else {
                    Text("Fetching...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text("Email:")
                    .font(.headline)
                if patientInfoFetched {
                    Text(patientEmail)
                        .font(.subheadline)
                        .foregroundColor(.black) // Change text color to black
                } else {
                    Text("Fetching...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text("Gender:")
                    .font(.headline)
                if patientInfoFetched {
                    Text(patientGender)
                        .font(.subheadline)
                        .foregroundColor(.black) // Change text color to black
                } else {
                    Text("Fetching...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text("Diagnosis:")
                    .font(.headline)
                Text(history.diagnosis)
                    .font(.subheadline)
                
                Text("Follow-up Date:")
                    .font(.headline)
                Text(formatDate(history.followUpDate))
                    .font(.subheadline)
                
                Text("Medication Entries:")
                    .font(.headline)
                ForEach(history.medicationEntries.indices, id: \.self) { index in
                    CustomMedicationEntryView(entry: history.medicationEntries[index])
                }
                
                Button(action: {
                    showingDetails = true
                }) {
                    Text("View Details")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showingDetails) {
                    PatientDetailsView(history: history)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .onAppear {
            fetchPatientInfo()
        }
    }


    
    func fetchPatientInfo() {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(history.userId)
            .getDocument { document, error in
                if let error = error {
                    print("Error fetching patient details: \(error)")
                } else {
                    if let document = document, let data = document.data() {
                        patientName = data["fullname"] as? String ?? ""
                        patientBloodGroup = data["bloodGroup"] as? String ?? ""
                        patientEmail = data["email"] as? String ?? ""
                        patientGender = data["gender"] as? String ?? ""
                        patientInfoFetched = true
                    }
                }
            }
    }
    
    func formatDate(_ date: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return dateFormatter.string(from: date.dateValue())
    }
}



struct CustomMedicationEntryView: View {
    let entry: CustomMedicationEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Medicine Name: \(entry.customMedicineName)")
            Text("Dosage: \(entry.customDosage)")
            Text("Time: \(entry.customTime)")
            Text("Additional Description: \(entry.customAdditionalDescription)")
        }
    }
}

struct PatientHistory {
    let id: String
    let userId: String
    let diagnosis: String
    let followUpDate: Timestamp
    let medicationEntries: [CustomMedicationEntry]
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.userId = data["userId"] as? String ?? ""
        self.diagnosis = data["diagnosis"] as? String ?? ""
        self.followUpDate = data["followUpDate"] as? Timestamp ?? Timestamp()
        
        if let medications = data["medicationEntries"] as? [[String: String]] {
            self.medicationEntries = medications.map { entry in
                return CustomMedicationEntry(customMedicineName: entry["medicineName"] ?? "",
                                             customDosage: entry["dosage"] ?? "",
                                             customTime: entry["time"] ?? "",
                                             customAdditionalDescription: entry["additionalDescription"] ?? "")
            }
        } else {
            self.medicationEntries = []
        }
    }
}

struct CustomMedicationEntry {
    let customMedicineName: String
    let customDosage: String
    let customTime: String
    let customAdditionalDescription: String
}

struct PatientDetailsView: View {
    let history: PatientHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Patient's Name: \(history.userId)")
            Text("Diagnosis: \(history.diagnosis)")
            Text("Follow-up Date: \(formatDate(history.followUpDate))")
            
            Text("Medication Entries:")
                .font(.headline)
            ForEach(history.medicationEntries.indices, id: \.self) { index in
                CustomMedicationEntryView(entry: history.medicationEntries[index])
            }
        }
        .padding()
        .navigationTitle("Patient Details")
    }
    
    func formatDate(_ date: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return dateFormatter.string(from: date.dateValue())
    }
}

struct PatientList_Previews: PreviewProvider {
    static var previews: some View {
        PatientList()
    }
}

