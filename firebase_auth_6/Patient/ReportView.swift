import SwiftUI
import Firebase
import FirebaseStorage
import UIKit
import PDFKit

struct ReportView: View {
    @State private var pdfURLs: [URLWrapper] = []
    @State private var selectedPDF: URLWrapper? = nil
    @State private var isShowingDocumentPicker = false
    @State private var selectedPDFs: [URL] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text("My Test Reports")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                self.isShowingDocumentPicker.toggle()

            }) {
                Text("Upload PDF")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $isShowingDocumentPicker) {
                DocumentPicker(onDocumentPicked: { urls in
                    self.selectedPDFs = urls
                    print(urls)
                    // Call a function to upload the selected PDF(s) to Firebase
                    self.uploadPDFsToFirebase(urls: urls)
                })
            }
            
            // Display PDFs
            if pdfURLs.isEmpty {
                Text("No reports found.")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    
                
            } else {
                List(pdfURLs) { pdfURL in
                    Button(action: {
                        self.selectedPDF = pdfURL
                    }) {
                        Text(pdfURL.url.lastPathComponent)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
                    .padding()
                }
            }
            Spacer()
        }
        .onAppear {
            fetchPDFsForCurrentUser()
        }
        .sheet(item: $selectedPDF) { pdfWrapper in
            NavigationView {
                PDFViewer(pdfURL: pdfWrapper.url)
                    .navigationBarItems(trailing: Button(action: {
                        self.selectedPDF = nil // Dismiss the sheet
                    }) {
                        Text("Done")
                            .font(.callout)
                            .foregroundColor(.blue)
                    })
            }
        }
    }
    
    // Wrapper type for URL to conform to Identifiable
    struct URLWrapper: Identifiable {
        let id = UUID()
        let url: URL
    }
    
    // Function to fetch PDF URLs for the current user from Firebase Storage
    func fetchPDFsForCurrentUser() {
        if let currentUserUID = Auth.auth().currentUser?.uid {
            let storageRef = Storage.storage().reference().child("users/\(currentUserUID)/pdfs")
            
            storageRef.listAll { result, error in
                if let error = error {
                    print("Error listing PDFs: \(error.localizedDescription)")
                    // Handle error if needed
                } else if let items = result?.items {
                    self.fetchDownloadURLs(for: items)
                } else {
                    print("No PDFs found.")
                    // Handle case where no PDFs are found
                }
            }
        } else {
            print("User not authenticated.")
            // Handle authentication error if needed
        }
    }
    
    // Function to fetch download URLs for each PDF file
    private func fetchDownloadURLs(for references: [StorageReference]) {
        for reference in references {
            reference.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    // Handle error if needed
                } else if let downloadURL = url {
                    self.pdfURLs.append(URLWrapper(url: downloadURL))
                }
            }
        }
    }
    // Function to upload selected PDF(s) to Firebase
    func uploadPDFsToFirebase(urls: [URL]) {
        if let currentUserUID = Auth.auth().currentUser?.uid {
            for url in urls {
                let storageRef = Storage.storage().reference().child("users/\(currentUserUID)/pdfs/\(UUID().uuidString).pdf")
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
        } else {
            print("User not authenticated.")
            // Handle authentication error if needed
        }
    }
}

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}




struct PDFViewer: View {
    let pdfURL: URL
    
    var body: some View {
        PDFKitView(url: pdfURL)
    }
}

// PDFKitView SwiftUI View for PDF rendering
struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}


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


// Preview
struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
