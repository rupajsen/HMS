//import SwiftUI
//import Firebase
//import FirebaseFirestore
//
//struct DocDashView: View {
//    @State private var appointments: [AppointmentForDoctor] = []
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                VStack(alignment: .leading, spacing: 20) {
//                    HStack(spacing: 20) {
//                        DashboardCard(title: "New Patients", count: "405", color: .blue, isFirstCard: true, isSecondCard: false, isThirdCard: false)
//                        DashboardCard(title: "OPD Patients", count: "218", color: .green, isFirstCard: false, isSecondCard: true, isThirdCard: false)
//                        DashboardCard(title: "Visitors", count: "2,479", color: .purple, isFirstCard: false, isSecondCard: false, isThirdCard: true)
//                    }
//                    .padding(.leading, 50)
//
//                    Text("Today's Appointments")
//                        .font(.headline)
//                        .padding(.leading, 44.5)
//
//                    ScrollView {
//                        VStack(alignment: .center) {
//                            // Header
//                            HStack {
//                                Text("Serial No.")
//                                    .fontWeight(.bold)
//                                    .frame(width: 80, alignment: .leading)
//                                    .foregroundColor(.black)
//                                Text("Patient Name")
//                                    .fontWeight(.bold)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(.black)
//                                Text("Appointment Time")
//                                    .fontWeight(.bold)
//                                    .frame(width: 250, alignment: .leading)
//                                    .padding(.trailing, 70)
//                                    .foregroundColor(.black)
//                                Text("Actions")
//                                    .fontWeight(.bold)
//                                    .frame(width: 100, alignment: .leading)
//                                    .foregroundColor(.black)
//                            }
//                            .padding(.horizontal, 10)
//                            .padding(.bottom, 5)
//                            .background(Color.white)
//
//                            // List of appointments
//                            ForEach(appointments.indices, id: \.self) { index in
//                                let appointment = appointments[index]
//                                AppointmentRow(index: index, appointment: appointment)
//                            }
//                            .padding(.horizontal, 10)
//                            .cornerRadius(10)
//                            .background(Color.white)
//                            .shadow(color: Color(red: 0.85, green: 0.87, blue: 0.91), radius: 8, x: 0, y: 4)
//                        }
//                        .padding(.vertical, 20)
//                    }
//                }
//                .padding(.leading, 40.5)
//                .padding(.trailing, 4.5)
//            }
//            .background(Color.white)
//            .onAppear {
//                fetchAppointmentsForLoggedInDoctor()
//            }
//        }
//    }
//
//    func fetchAppointmentsForLoggedInDoctor() {
//        let db = Firestore.firestore()
//        guard let loggedInUserId = Auth.auth().currentUser?.uid else {
//            print("No logged-in user.")
//            return
//        }
//
//        let appointmentsRef = db.collection("appointments")
//
//        appointmentsRef.whereField("doctorId", isEqualTo: loggedInUserId).getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error fetching appointments: \(error.localizedDescription)")
//                return
//            }
//
//            guard let documents = querySnapshot?.documents else {
//                print("No appointments found.")
//                return
//            }
//
//            var fetchedAppointments: [AppointmentForDoctor] = []
//            for document in documents {
//                let data = document.data()
//                let id = document.documentID
//                let date = data["date"] as? Timestamp ?? Timestamp()
//                let doctorId = data["doctorId"] as? String ?? ""
//                let time = data["time"] as? String ?? ""
//                let userId = data["userId"] as? String ?? ""
//
//                let appointment = AppointmentForDoctor(id: id, date: date, doctorId: doctorId, time: time, userId: userId)
//                fetchedAppointments.append(appointment)
//            }
//
//            self.appointments = fetchedAppointments
//        }
//    }
//}
//
//struct AppointmentRow: View {
//    let index: Int
//    let appointment: AppointmentForDoctor
//
//    var body: some View {
//        HStack {
//            Text(appointment.id)
//                .frame(width: 80, alignment: .center)
//                .foregroundColor(.black)
//
//            Text(appointment.userId)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.leading, 20)
//                .foregroundColor(.black)
//
//            Text(appointment.time)
//                .frame(width: 150, alignment: .center)
//                .padding(.trailing, 180)
//                .foregroundColor(.black)
//
//            HStack(spacing: 20) {
//                Image(systemName: "pencil")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                    .foregroundColor(.green)
//
//                Image(systemName: "xmark")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                    .padding(.trailing, 60)
//                    .foregroundColor(.red)
//            }
//            .frame(width: 100, alignment: .center)
//        }
//        .frame(width: 1150, height: 50)
//        .background(Color.white)
//        .overlay(
//            RoundedRectangle(cornerRadius: 0)
//                .stroke(Color.gray.opacity(0.3), lineWidth: 0.2)
//        )
//    }
//}
//
//struct DashboardCard: View {
//    var title: String
//    var count: String
//    var color: Color
//    var isFirstCard: Bool
//    var isSecondCard: Bool
//    var isThirdCard: Bool
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 10) {
//                Text(title)
//                    .font(.headline)
//
//                Text(count)
//                    .font(.largeTitle)
//
//                Spacer()
//
//                ZStack(alignment: .leading) {
//                    Rectangle()
//                        .frame(height: 10)
//                        .foregroundColor(Color.gray.opacity(0.3))
//                        .cornerRadius(5)
//
//                    Rectangle()
//                        .frame(width: CGFloat(Double(count.replacingOccurrences(of: ",", with: "")) ?? 0) / 10, height: 10)
//                        .foregroundColor(color)
//                        .cornerRadius(5)
//                }
//            }
//
//            Spacer()
//
//            if isFirstCard {
//                Image("pie")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 50, height: 45)
//                    .clipped()
//            } else if isSecondCard {
//                Image("bar")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 124, height: 45)
//                    .clipped()
//            } else if isThirdCard {
//                Image("graph")
//                    .resizable()
//                    .padding(.trailing, 80)
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 60, height: 70)
//                    .clipped()
//            }
//        }
//        .padding()
//        .frame(width: 346, height: 158)
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(color: Color(red: 0.85, green: 0.87, blue: 0.91), radius: 9, x: -8, y: 12)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .inset(by: 0.5)
//                .stroke(Color(red: 0.87, green: 0.92, blue: 0.99), lineWidth: 1)
//        )
//    }
//}
//
//struct AppointmentForDoctor {
//    let id: String
//    let date: Timestamp
//    let doctorId: String
//    let time: String
//    let userId: String
//}
//
//struct DashboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        DocDashView()
//    }
//}
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct DocDashView: View {
    @State private var appointments: [AppointmentForDoctor] = []
    @State private var selectedFilterIndex = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 20) {
                        DashboardCard(title: "New Patients", count: "405", color: .blue, isFirstCard: true, isSecondCard: false, isThirdCard: false)
                        DashboardCard(title: "OPD Patients", count: "218", color: .green, isFirstCard: false, isSecondCard: true, isThirdCard: false)
                        DashboardCard(title: "Visitors", count: "2,479", color: .purple, isFirstCard: false, isSecondCard: false, isThirdCard: true)
                    }
                    .padding(.leading, 50)
                    
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
            }
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
        switch selectedFilterIndex {
        case 0: // Today's Appointments
            let today = Calendar.current.startOfDay(for: Date())
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            return appointments.filter { $0.date.dateValue() >= today && $0.date.dateValue() < endOfDay }
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
            
            NavigationLink(destination: PatientHistoryUpdate(appointment: appointment)) {
                Image(systemName: "pencil")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
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
        .shadow(color: Color(red: 0.85, green: 0.87, blue: 0.91), radius: 9, x: -8, y: 12)
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

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DocDashView()
    }
}
