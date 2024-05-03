//
//  PatientDashView.swift
//  firebase_auth
//
//  Created by Rupaj Sen on 03/05/24.
//


import SwiftUI
struct PatientDashView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var name: String = ""
    @State private var image: UIImage?
    @State private var dateOfBirth = Date()
    @State private var allergies: String = ""
    @State private var bloodPressure: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var otherVitals: String = ""
    @State private var latestLabTestReports: String = ""
    @State private var showImagePicker: Bool = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showProfileView = false // State variable to control the visibility of the PatientProfileView
    
    var popularDoctors: [Doctor] = [
        Doctor(name: "Dr. Smith", specialization: "Dentist", photo: "doc"),
        Doctor(name: "Dr. Johnson", specialization: "Ophthalmologist", photo: "doc"),
        Doctor(name: "Dr. Williams", specialization: "General Physician", photo: "doc"),
        Doctor(name: "Dr. Brown", specialization: "Pathologist", photo: "doc"),
        Doctor(name: "Dr. Davis", specialization: "Immunologist", photo: "doc")
    ]
    
    var body: some View {
        NavigationView{
            ZStack{
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack{
                            Text("Patient View")
                            Text("Welcome \(name)!")
                                .foregroundStyle(.white)
                                .font(.title)
                                .padding(.top)
                            
                            Text("Get Health Checkup done today!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom)
             
                            NavigationLink(destination: DepartmentView()) {
                                Text("Book Your Appointment")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .foregroundColor(.clear)
                        .frame(width: 398, height: 300)
                        .offset(y:20)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.05, green: 0.51, blue: 0.99), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.03, green: 0.3, blue: 0.59), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .cornerRadius(42)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                        .ignoresSafeArea()
                        .offset(y:-59)
                        
                        VStack{
                            Text("Your upcoming Appointments")
                                .font(.title2)
                                .padding(.vertical)
                                .frame(maxWidth: .infinity,alignment: .leading)
                            
                            TestView()
                            
                            HStack{
                                Text("Doctor Speciality")
                                    .font(.title2)
                                    .padding(.vertical)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                            }
                            
                            VStack(alignment: .leading) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(popularDoctors) { doctor in
                                            VStack {
                                                if let photoName = doctor.photo {
                                                    Image(photoName)
                                                        .resizable()
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                        .shadow(radius: 5)
                                                        .padding(.bottom, 8)
                                                }
                                                Text(doctor.name)
                                                    .font(.headline)
                                                Text(doctor.specialization)
                                                    .font(.subheadline)
                                            }
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(10)
                                            .padding(.horizontal, 8)
                                            
                                        }
                                    }
                                }
                            }
                            
                            HStack{
                                Text("Medication")
                                    .font(.title2)
                                    .padding(.vertical)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                            }
                        }
                        .padding()
                        .offset(y:-59)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button(action: {
                                                                        guard let phoneNum = URL(string: "tel://102") else { return }
                                                                        UIApplication.shared.open(phoneNum)
                        }) {
                            Image(systemName: "phone.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .clipShape(Circle())
                                .padding(.trailing)
                                .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                                .offset(y:-50)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}


#Preview {
    PatientDashView()
}

