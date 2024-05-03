//
//  ReportView.swift
//  firebase_auth
//
//  Created by Admin on 03/05/24.
//

import SwiftUI

struct ReportView: View {
    let appointmentDate: String
    let doctorName: String
    
    var body: some View {
        
        
        VStack(alignment:.leading){
            Text("My Test Reports")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment:.leading) {
               
              
                VStack(alignment: .leading, spacing: 10) {
                    Text("Appointment Date: \(appointmentDate)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Doctor: \(doctorName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 8)
                
                // Download PDF button
                Button(action: {
                    // Add action to download PDF
                    // This could trigger a download function
                }) {
                    Text("Upload PDF")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .padding(.horizontal,-180)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
            .padding()
            
            
            Spacer()
        }
      
    }
}

// Preview
struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(appointmentDate: "May 10, 2024", doctorName: "Dr. Smith")
    }
}
