//
//  HospitalDepartment.swift
//  firebase_auth
//
//  Created by Rupaj Sen on 09/05/24.
//

import SwiftUI

struct Department: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String // Add imageName property for department images
}

struct HospitalDepartment: View {
    let departments = [
        Department(name: "General", description: "General medicine and healthcare services encompass a wide range of medical practices focused on diagnosing, treating, and preventing various illnesses and conditions affecting adults of all ages.", imageName: "general_image"),
        Department(name: "Pediatrics", description: "Pediatrics is a branch of medicine that deals with the medical care of infants, children, and adolescents. It includes preventive healthcare, treatment of illnesses, and monitoring child growth and development.", imageName: "pediatrics_image"),
        Department(name: "Gynecology", description: "Gynecology is a medical specialty that focuses on the health of the female reproductive system, including the uterus, ovaries, fallopian tubes, cervix, and vagina. Gynecologists provide care related to menstrual disorders, pregnancy, fertility, contraception, and menopause.", imageName: "gynecology_image"),
        Department(name: "Dermatology", description: "Dermatology is the branch of medicine concerned with the diagnosis, treatment, and prevention of skin, hair, and nail disorders. Dermatologists address conditions such as acne, eczema, psoriasis, skin cancer, and cosmetic concerns.", imageName: "dermatology_image"),
        Department(name: "Orthopedics", description: "Orthopedics is the medical specialty that deals with the musculoskeletal system, including bones, joints, muscles, ligaments, tendons, and nerves. Orthopedic surgeons diagnose and treat injuries, fractures, arthritis, sports-related injuries, and perform surgeries like joint replacements.", imageName: "orthopedics_image"),
        Department(name: "Cardiology", description: "Cardiology focuses on the diagnosis and treatment of heart and cardiovascular diseases. Cardiologists manage conditions such as coronary artery disease, heart failure, arrhythmias, high blood pressure, and congenital heart defects.", imageName: "cardiology_image"),
        Department(name: "Endocrinology", description: "Endocrinology is the branch of medicine concerned with hormonal disorders and metabolic conditions. Endocrinologists diagnose and treat disorders of the endocrine glands, such as diabetes, thyroid disorders, adrenal disorders, and hormonal imbalances.", imageName: "endocrinology_image"),
        Department(name: "Neurology", description: "Neurology is the medical specialty that deals with disorders of the nervous system, including the brain, spinal cord, nerves, and muscles. Neurologists diagnose and treat conditions such as epilepsy, stroke, multiple sclerosis, Parkinson's disease, and Alzheimer's disease.", imageName: "neurology_image")
    ]
    
    @State private var selectedDepartment: Department? = nil
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -25) {
                    ForEach(departments) { department in
                        Button(action: {
                            self.selectedDepartment = department
                        }) {
                            HospitalDepartmentCardView(department: department)
                                .frame(width: 150)
                        }
                    }
                }
                .padding(.top, 20)
            }
            Spacer()
        }
        .sheet(item: $selectedDepartment) { department in
            DepartmentDetailSheet(department: department, isPresented: $selectedDepartment)
        }
    }
}

struct HospitalDepartmentCardView: View {
    let department: Department
    
    var body: some View {
        VStack{
            VStack {
                Image(department.name.lowercased()) // Use department's imageName property
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(red: 0.82, green: 0.93, blue: 1.2))
            .cornerRadius(10)
            .clipShape(Circle())
            .shadow(radius: 5)
            
            Text(department.name)
                .foregroundColor(.black)
                .font(.headline)
        }
    }
}

struct DepartmentDetailSheet: View {
    let department: Department
    @Binding var isPresented: Department?
    
    var body: some View {
        VStack {
            Image(department.imageName) // Add image to detail view
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(5)
                .padding()
            
            Text(department.name)
                .font(.title).bold()
                .frame(alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                               .padding(.leading)
            
            Text(department.description)
                .foregroundColor(.black)
                .padding()
                .font(.title3)
            
            Spacer()
            
            Button("Close") {
                isPresented = nil
            }
            .padding()
        }
        .background(Color.blue.opacity(0.10))
    }
}


#Preview {
    HospitalDepartment()
}
