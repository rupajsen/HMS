//
//  PatientHistoryUpdate.swift
//  firebase_auth
//
//  Created by admin on 01/05/24.
//
import SwiftUI
import Firebase

struct PatientHistoryUpdate: View {
    @State private var diagnosis: String = ""
    @State private var followUpDate = Date()
    @State private var medicationEntries: [MedicationEntry] = [MedicationEntry(medicineName: "", dosage: "", time: "", additionalDescription: "")]
    @State private var reasonOfConsult: String = ""

    let appointment: AppointmentForDoctor
    
    var body: some View {
        VStack {
            Text("Patient History Update")
                .font(.largeTitle)
                .padding()
            
            Divider()
            
            Form {
                Section(header: Text("Appointment Details")) {
                    Text("Patient Name: \(appointment.userId)")
                    Text("Appointment Date: \(formatDate(appointment.date))")
                    Text("Appointment Time: \(appointment.time)")
                }
                
                Section(header: Text("Consultation Details")) {
                    TextField("Reason of Consult", text: $reasonOfConsult)
                    TextField("Diagnosis", text: $diagnosis)
                    DatePicker("Follow-up Date", selection: $followUpDate, displayedComponents: .date)
                }
                
                Section(header: Text("Medication")) {
                    ForEach(medicationEntries.indices, id: \.self) { index in
                        MedicationEntryView(medicationEntry: $medicationEntries[index])
                    }
                }

                VStack {
                    Button(action: {
                        medicationEntries.append(MedicationEntry(medicineName: "", dosage: "", time: "", additionalDescription: ""))
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                            Text("Add Medication")
                        }
                    }
                    .padding()

                }
                
                Section(header: Text("Additional Description")) {
                    TextField("Additional Description", text: $medicationEntries[0].additionalDescription)
                }
                
                Button(action: {
                    savePatientHistory()
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    func formatDate(_ date: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date.dateValue())
    }
    
    func savePatientHistory() {
        let db = Firestore.firestore()
        
        // Document reference in the "patienthistory" collection with appointment ID as the document name
        let patientHistoryRef = db.collection("patienthistory").document(appointment.id)
        
        // Prepare the data to be saved
        let patientHistoryData: [String: Any] = [
            "userId": appointment.userId,
            "doctorId": appointment.doctorId,
            "date": appointment.date,
            "appointmentId": appointment.id,
            "reasonOfConsult": reasonOfConsult,
            "diagnosis": diagnosis,
            "followUpDate": followUpDate,
            "medicationEntries": medicationEntries.map { entry in
                return [
                    "medicineName": entry.medicineName,
                    "dosage": entry.dosage,
                    "time": entry.time,
                    "additionalDescription": entry.additionalDescription
                ]
            },
            "additionalDescription": medicationEntries[0].additionalDescription // Additional description from the form
        ]
        
        // Delete the previous document if it exists
        db.collection("patienthistory").document(appointment.id).delete { error in
            if let error = error {
                print("Error deleting previous patient history document: \(error)")
            } else {
                print("Previous patient history document deleted successfully")
            }
        }
        
        // Save the data to Firestore
        patientHistoryRef.setData(patientHistoryData) { error in
            if let error = error {
                print("Error saving patient history: \(error)")
            } else {
                print("Patient history saved successfully")
            }
        }
    }


}


struct MedicationEntryView: View {
    @Binding var medicationEntry: MedicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "pills")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                TextField("Medicine Name", text: $medicationEntry.medicineName)
            }

            HStack {
                Image(systemName: "drop")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                TextField("Dosage", text: $medicationEntry.dosage)
            }

            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                TextField("Time", text: $medicationEntry.time)
            }

            HStack {
                Image(systemName: "text.bubble")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                TextField("Additional Description", text: $medicationEntry.additionalDescription)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct MedicationEntry {
    var medicineName: String
    var dosage: String
    var time: String
    var additionalDescription: String
}

struct PatientHistoryUpdate_Previews: PreviewProvider {
    static var previews: some View {
        PatientHistoryUpdate(appointment: AppointmentForDoctor(id: "1", date: Timestamp(), doctorId: "doctorId", time: "10:00 AM", userId: "Patient Name"))
    }
}
