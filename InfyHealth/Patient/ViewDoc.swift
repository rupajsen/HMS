

import SwiftUI
import FirebaseFirestore

struct ViewDoc: View {
    
    @State private var doctorAppointmentStates: [String: Bool] = [:] // Dictionary to store appointment view states for each doctor
    @State var doctors: [Doctor] = []
    var department: String // Department name
    
    var body: some View {
     
         ScrollView {
             VStack(alignment: .leading){
                 Text("Available Doctors") // Title added here
                     .font(.largeTitle).bold()
                                .padding(.horizontal)
                 VStack(spacing: 20) {
                     ForEach(doctors, id: \.doctorId) { doctor in
                         DoctorListItem(doctor: doctor)
 //                            .onTapGesture {
 //                                print("Selected Doctor ID:", doctor.doctorId ?? "N/A")
 //                                isShowingAppointmentView = true
 //                            }
 //                            .sheet(isPresented: $isShowingAppointmentView) {
 //                                AppointmentView(selectedDoctorId: doctor.doctorId ?? "")
 //                            }
                     }
                 }
                 .padding()
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
    @State private var isShowingAppointmentView = false
    
    var body: some View {
        HStack {
            Image("doc")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                )
                .padding(.leading, 10)
            
            VStack(alignment: .leading) {
                Text(doctor.name)
                    .font(.title3).bold()
                    .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59))
                Text(doctor.specialization)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59))
                
                Button(action: {
                    print("Selected Doctor ID:", doctor.doctorId ?? "N/A")
                    isShowingAppointmentView = true
                }) {
                    Text("View slots")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(red: 0.82, green: 0.93, blue: 1.2))
                        .foregroundColor(Color(red: 0.05, green: 0.51, blue: 0.99))
                        .cornerRadius(10)
                }
                .sheet(isPresented: $isShowingAppointmentView) {
                    AppointmentView(selectedDoctorId: doctor.doctorId ?? "")
                }
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
//        .shadow(radius: 3)
        .shadow(radius: 2)
        .frame(width: 300, height: 140)
    }
}


struct ViewDoc_Previews: PreviewProvider {
    static var previews: some View {
        ViewDoc(department: "General")
    }
}
