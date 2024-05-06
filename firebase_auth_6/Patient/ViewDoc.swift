//  ViewDoc.swift
//  firebase_auth
//  Created by admin on 25/04/24.

/*
import SwiftUI
import Firebase

struct ViewDoc: View {
    
    @State private var isShowingAppointmentView = false
    
    @State var doctors: [Doctor] = []
    var department: String // Department name
    
    var body: some View {
        List(doctors) { doctor in
            VStack {
                HStack {
                    if let photo = doctor.photo,
                       let img = UIImage(named: photo) {
                        Image(uiImage: img)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    
                    VStack(alignment:.leading) {
                        Text(doctor.name).font(.headline)
                        Text(doctor.specialization).font(.subheadline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment:.trailing) {
                        Image(systemName:"star.fill").foregroundColor(.yellow)
                        Text("4.8").font(.caption)
                        Text("49 Reviews").font(.caption)
                    }
                }
                Button(action: {
                    print("Selected Doctor ID:", doctor.doctorId ?? "N/A")
                    isShowingAppointmentView = true
                }) {
                    Text("Make Appointment")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $isShowingAppointmentView) {
                    AppointmentView(selectedDoctorId: doctor.doctorId ?? "")
                }

            }
        }
        .onAppear {
            fetchDoctorsFromFirestore()
        }
    }
    
    func fetchDoctorsFromFirestore() {
        let db = Firestore.firestore()
        
        db.collection("doctors").whereField("specialization", isEqualTo: department).getDocuments { (querySnapshot, error) in
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
                print()
                let name = data["fullName"] as? String ?? ""
                let specialization = data["specialization"] as? String ?? ""
                let photo = data["photo"] as? String ?? ""
                
                return Doctor(name: name, specialization: specialization, photo: photo , doctorId: queryDocumentSnapshot.documentID)
            }
        }
    }
}
*/




import SwiftUI
import FirebaseFirestore

struct ViewDoc: View {
    
    @State private var isShowingAppointmentView = false
    
    @State var doctors: [Doctor] = []
    var department: String // Department name
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(doctors, id: \.doctorId) { doctor in
                    DoctorListItem(doctor: doctor)
                        .onTapGesture {
                            print("Selected Doctor ID:", doctor.doctorId ?? "N/A")
                            isShowingAppointmentView = true
                        }
                        .sheet(isPresented: $isShowingAppointmentView) {
                            AppointmentView(selectedDoctorId: doctor.doctorId ?? "")
                        }
                }
            }
            .padding()
        }
        .onAppear {
            fetchDoctorsFromFirestore()
        }
    }
    
    func fetchDoctorsFromFirestore() {
        let db = Firestore.firestore()
        
        db.collection("doctors").whereField("specialization", isEqualTo: department).getDocuments { (querySnapshot, error) in
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
                print()
                let name = data["fullName"] as? String ?? ""
                let specialization = data["specialization"] as? String ?? ""
                let photo = data["photo"] as? String ?? ""
                
                return Doctor(name: name, specialization: specialization, photo: photo , doctorId: queryDocumentSnapshot.documentID)
            }
        }
    }
}

struct DoctorListItem: View {
    let doctor: Doctor
    
    var body: some View {
        VStack(alignment: .leading) {
            if let photo = doctor.photo,
               let img = UIImage(named: photo) {
                Image(uiImage: img)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
            }
            Text(doctor.name)
                .font(.headline)
            Text(doctor.specialization)
                .font(.subheadline)
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("4.8")
                    .font(.caption)
                Text("49 Reviews")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct ViewDoc_Previews: PreviewProvider {
    static var previews: some View {
        ViewDoc(department: "General")
    }
}
