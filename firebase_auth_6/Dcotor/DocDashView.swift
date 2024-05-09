

import SwiftUI
import Firebase
import FirebaseFirestore

struct DocDashView: View {
    @State private var appointments: [AppointmentForDoctor] = []
    @State private var selectedFilterIndex = 0
    @State private var todaysAppointmentsCount = 0
    @State private var patientHistoryCount: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 20) {
                        DashboardCard(title: "Appointments", count: "\(filteredAppointments().count)", color: .blue, isFirstCard: true, isSecondCard: false, isThirdCard: false)
                        DashboardCard(title: "Completed appointments", count: "\(patientHistoryCount)", color: .green, isFirstCard: false, isSecondCard: true, isThirdCard: false)
                        DashboardCard(title: "Visitors", count: "247", color: .purple, isFirstCard: false, isSecondCard: false, isThirdCard: true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    Text("Appointments")
                        .font(.headline)
                        .padding(.leading, 44.5)
                    
                    // Filter dropdown or segmented control
                    Picker(selection: $selectedFilterIndex, label: Text("")) {
                        Text("Today's").tag(0)
                        Text("This Week's").tag(1)
                        Text("All").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(alignment: .center) {
                            // Header
                            HStack {
                                Text("Serial No.")
                                    .fontWeight(.bold)
                                    .frame(width: 80, alignment: .leading)
                                    .foregroundColor(.black)
                                Text("Patient Name")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.black)
                                Text("Appointment Date & Time")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.black)
                                Text("Actions")
                                    .fontWeight(.bold)
                                    .frame(width: 100, alignment: .leading)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 10)
                            .padding(.bottom, 5)
                            .background(Color.white)
                            
                            // List of appointments
                            ForEach(filteredAppointments().indices, id: \.self) { index in
                                AppointmentRow(appointment: appointments[index], serialNumber: index + 1)
                            }
                            
                            .padding(.horizontal, 10)
                            .cornerRadius(10)
                            .background(Color.white)
                            .shadow(color: Color(red: 0.85, green: 0.87, blue: 0.91), radius: 8, x: 0, y: 4)
                        }
                        .padding(.vertical, 20)
                    }
                }
                .padding(.leading, 4.5)
                .padding(.trailing, 4.5)
            }
            .background(Color.white)
            .onAppear {
                fetchAppointmentsForLoggedInDoctor()
                fetchPatientHistoryCount()

            }
            .navigationTitle("Doctor Dashboard")
        }
    }
    
    func fetchPatientHistoryCount() {
           let db = Firestore.firestore()
           guard let loggedInUserId = Auth.auth().currentUser?.uid else {
               print("No logged-in user.")
               return
           }
           
           db.collection("patienthistory")
               .whereField("doctorId", isEqualTo: loggedInUserId)
               .getDocuments { (querySnapshot, error) in
                   if let error = error {
                       print("Error fetching patient history: \(error.localizedDescription)")
                       return
                   }
                   
                   guard let documents = querySnapshot?.documents else {
                       print("No patient history found.")
                       return
                   }
                   
                   // Count the number of patient history entries
                   self.patientHistoryCount = documents.count
               }
       }
   
    
    func fetchAppointmentsForLoggedInDoctor() {
        let db = Firestore.firestore()
        guard let loggedInUserId = Auth.auth().currentUser?.uid else {
            print("No logged-in user.")
            return
        }
        
        let appointmentsRef = db.collection("appointments")
        
        appointmentsRef.whereField("doctorId", isEqualTo: loggedInUserId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching appointments: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No appointments found.")
                return
            }
            
            var fetchedAppointments: [AppointmentForDoctor] = []
            for document in documents {
                let data = document.data()
                let id = document.documentID
                let date = data["date"] as? Timestamp ?? Timestamp()
                let doctorId = data["doctorId"] as? String ?? ""
                let time = data["time"] as? String ?? ""
                let userId = data["userId"] as? String ?? ""
                
                let appointment = AppointmentForDoctor(id: id, date: date, doctorId: doctorId, time: time, userId: userId)
                fetchedAppointments.append(appointment)
            }
            
            self.appointments = fetchedAppointments
        }
    }
    
    
    
    func filteredAppointments() -> [AppointmentForDoctor] {
        let today = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        // Print today and end of the day for debugging
        print("Today: \(today)")
        print("End of the day: \(endOfDay)")
        
        switch selectedFilterIndex {
        case 0: // Today's Appointments
            // Filter appointments to include only those within today
            return appointments.filter { appointment in
                let appointmentDate = Calendar.current.startOfDay(for: appointment.date.dateValue())
                return appointmentDate == today
            }
            
        case 1: // This Week's Appointments
            let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!
            return appointments.filter { $0.date.dateValue() >= startOfWeek && $0.date.dateValue() < endOfWeek }
            
        default: // All Appointments
            return appointments
        }
    }




}


struct AppointmentRow: View {
    let appointment: AppointmentForDoctor
    let serialNumber: Int
    @State private var patientName: String = ""
    @State private var isShowingPatientHistoryUpdate = false
    
    var body: some View {
        HStack {
            Text("\(serialNumber)")
                .frame(width: 80, alignment: .center)
                .foregroundColor(.black)
            
            Text(patientName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .foregroundColor(.black)
            
            Text("\(formatDate(appointment.date)) \(appointment.time)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black)
            
            Button(action: {
                isShowingPatientHistoryUpdate.toggle()
            }) {
                Image(systemName: "pencil")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
            }
            .sheet(isPresented: $isShowingPatientHistoryUpdate) {
                PatientHistoryUpdate(appointment: appointment)
            }
        }
        .frame(width: 1150, height: 50)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.2)
        )
        .onAppear {
            fetchPatientName()
        }
    }
    
    func fetchPatientName() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(appointment.userId)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let fullname = data?["fullname"] as? String {
                    self.patientName = fullname
                }
            } else {
                print("User document does not exist for userID: \(appointment.userId)")
            }
        }
    }
    
    func formatDate(_ date: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date.dateValue())
    }
}

struct DashboardCard: View {
    var title: String
    var count: String
    var color: Color
    var isFirstCard: Bool
    var isSecondCard: Bool
    var isThirdCard: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                
                Text(count)
                    .font(.largeTitle)
                
                Spacer()
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 10)
                        .foregroundColor(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                    
                    Rectangle()
                        .frame(width: CGFloat(Double(count.replacingOccurrences(of: ",", with: "")) ?? 0) / 10, height: 10)
                        .foregroundColor(color)
                        .cornerRadius(5)
                }
            }
            
            Spacer()
            
            if isFirstCard {
                Image("pie")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 45)
                    .clipped()
            } else if isSecondCard {
                Image("bar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 124, height: 45)
                    .clipped()
            } else if isThirdCard {
                Image("graph")
                    .resizable()
                    .padding(.trailing, 80)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 70)
                    .clipped()
            }
        }
        .padding()
        .frame(width: 346, height: 158)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color(red: 0.85, green: 0.87, blue: 0.91), radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .inset(by: 0.5)
                .stroke(Color(red: 0.87, green: 0.92, blue: 0.99), lineWidth: 1)
        )
    }
}

struct AppointmentForDoctor {
    let id: String
    let date: Timestamp
    let doctorId: String
    let time: String
    let userId: String
}

#Preview{
    DocDashView()
}

