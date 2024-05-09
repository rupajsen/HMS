//  DoctorDetailView.swift
//  firebase_auth
//  Created by admin on 25/04/24.

import SwiftUI
import Foundation
struct Doctor: Identifiable {
    var id = UUID()
    var name: String
    var specialization: String
    var photo: String? // Optional property to store the doctor's photo
    var doctorId : String?
}

struct DoctorDetailView: View {
    var doctor: Doctor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let photo = doctor.photo, !photo.isEmpty,
               let img = UIImage(named: photo) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            }
            
            Text(doctor.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(doctor.specialization)
                .font(.subheadline)
                .foregroundColor(.gray)

            // Add more UI elements as needed to display other details
        }
        .padding()
    }
}

struct Doctor_Previews: PreviewProvider {
    static var previews: some View {
        DoctorDetailView(doctor:
                            Doctor(name:"Dr. John Odette",
                                   specialization:"Head of Neurology, XYZ Hospital",
                                   photo:nil))
    }
}
