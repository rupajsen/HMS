import SwiftUI
import Firebase
import FirebaseStorage

struct ReportView: View {
    let appointmentDate: String
    let doctorName: String
    @State private var selectedPDFs: [URL] = []
    @State private var isShowingDocumentPicker = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("My Test Reports")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add Test Reports")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 8)
                
                // Upload PDF button
                Button(action: {
                    self.isShowingDocumentPicker.toggle()

                }) {
                    Text("Upload PDF")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $isShowingDocumentPicker) {
                    DocumentPicker(onDocumentPicked: { urls in
                        self.selectedPDFs = urls
                        print(urls)
                        // Call a function to upload the selected PDF(s) to Firebase
                        self.uploadPDFsToFirebase(urls: urls)
                    })
                }
            }
            .padding()
            .padding(.horizontal, -180)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
            .padding()
            
            Spacer()
        }
    }
    
    // Function to upload selected PDF(s) to Firebase
    func uploadPDFsToFirebase(urls: [URL]) {
        // Example Firebase upload code
        for url in urls {
            print(url)
            let storageRef = Storage.storage().reference().child("pdfs").child("\(UUID().uuidString).pdf")
            storageRef.putFile(from: url, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading PDF: \(error.localizedDescription)")
                    // Handle error if needed
                } else {
                    print("PDF uploaded successfully!")
                    // Handle success if needed
                }
            }
        }
    }
}

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}


// Preview
struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(appointmentDate: "May 10, 2024", doctorName: "Dr. Smith")
    }
}




import UIKit

struct DocumentPicker: UIViewControllerRepresentable {
    var onDocumentPicked: ([URL]) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        documentPicker.allowsMultipleSelection = true
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onDocumentPicked: ([URL]) -> Void
        
        init(onDocumentPicked: @escaping ([URL]) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onDocumentPicked(urls)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle cancellation if needed
        }
    }
}
