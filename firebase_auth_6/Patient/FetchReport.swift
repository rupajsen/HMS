//
//  FetchReport.swift
//  firebase_auth
//
//  Created by Rupaj Sen on 06/05/24.
//
import SwiftUI
import Firebase
import FirebaseStorage

struct FetchReport: View {
    let appointmentDate: String
    let doctorName: String
    @State private var selectedPDFs: [URL] = []
    @State private var isShowingDocumentPicker = false
    @State private var fetchedPDFs: [URL] = [] // State to hold fetched PDF URLs
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("My Test Reports")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Add PDF upload section
            // ...
            
            // Fetch PDFs section
            VStack(alignment: .leading, spacing: 10) {
                Text("Fetched PDFs")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // List fetched PDFs
                List(fetchedPDFs, id: \.self) { pdfURL in
                    Text(pdfURL.lastPathComponent)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            // Handle tapping on PDF URL if needed
                        }
                }
                .frame(maxHeight: 200)
                .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
            .padding()
            
            Spacer()
        }
        .onAppear {
            // Fetch PDFs from Firebase Storage when the view appears
            fetchPDFsFromFirebase()
        }
    }
    
    // Function to fetch PDFs from Firebase Storage
    func fetchPDFsFromFirebase() {
        let storageRef = Storage.storage().reference().child("pdfs")
        
        storageRef.listAll { result, error in
            if let error = error {
                print("Error fetching PDFs: \(error.localizedDescription)")
                // Handle error if needed
            } else {
                if let pdfItems = result?.items {
                    let pdfURLs = pdfItems.map { $0.fullPath }
                    let urls = pdfURLs.compactMap { URL(string: $0) }
                    self.fetchedPDFs = urls
                    print("Fetched PDF URLs: \(urls)")
                } else {
                    print("No PDFs found.")
                }
            }
        }
    }

}
