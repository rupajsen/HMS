import SwiftUI
import FirebaseFirestore
import Firebase

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
    @State private var medicationEntries: [[String: Any]] = []
    @State private var followUpDateString: String = ""
    @State private var doctorName: String = "" // State variable to hold doctor's name
    @State private var isLoading = false// State variable to hold doctor's name
    @State private var isSuggestionsSheetVisible = false
    @State private var chatbotResponse: String = ""
    let apiKey = "YOUR_API_KEY"
    @State private var chat = ""

    
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
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        VStack{
                            Text("Patient View")
                            if let fullName = viewModel.currentUser?.fullname {
                                Text("Welcome \(fullName)!")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .padding()
                            } else {
                                Text("Welcome!")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .padding()
                            }
                            
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
                            Text("Consult our DocAi")
                                                            .font(.title2)
                                                            .padding(.leading)
                                                            .frame(maxWidth: .infinity,alignment: .leading)
                                                       
                                                            
                                                            
                                                        HStack {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 15)
                                                                    .foregroundColor(Color.white) // Light gray background
                                                                    .shadow(radius: 2) // Shadow
                                                                
                                                                TextField("What issues are you facing", text: $chat)
                                                                    .font(.custom("Inter", size: 15))
                                                                    .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59)) // Text color
                                                                    .padding(.leading, 23)
                                                                    .padding(.trailing, 0)
                                                                    .padding(.vertical, 10) // Add padding vertically
                                                            }
                                                            .frame(height: 50) // Adjust height
                                                            
                                                            Button(action: {
                                                                sendPromptToChatGPT(prompt: chat)
                                                            }) {
                                                                Image(systemName: "paperplane.circle.fill") // Use system image for consistency
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fit)
                                                                    .frame(width: 35, height: 35)
                                                                    .padding(.trailing, 10)
                                                                    .foregroundColor(.blue) // Button color
                                                            }
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.horizontal, 20) // Add horizontal padding
                                                        .sheet(isPresented: $isSuggestionsSheetVisible) {
                                                            RecipeDisplayPage(chatbotResponse: chatbotResponse)
                                                        }
                            
                            Text("Your upcoming Appointments")
                                .font(.title2)
                                .padding(.leading)
                                .padding(.top,15)
                                .frame(maxWidth: .infinity,alignment: .leading)
                            
                            TestView()
                                .padding(.top,-10)
                                .frame(width: 340, height: 170)
                            
                            if !followUpDateString.isEmpty{
                                Text("Follow Up Appointment")
                                    .font(.title2)
                                    .padding(.bottom,15)
                                    .padding(.top,10)
                                    .padding(.leading)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                
                                VStack(alignment: .leading, spacing:0) {
                                
                                    HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59)) // Calendar icon color
                                        .font(.subheadline) // Calendar icon size
                                    
                                    if !followUpDateString.isEmpty {
                                        
                                            
                                            Text("\(followUpDateString)")
                                                .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59)) // Change color as needed
                                                .font(.subheadline)
                                        

                                        // Adjust spacing
                                    }
                                }
                                
                                HStack{
                                    Image("doc")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(Circle()) // Clip the image into a circle
                                        .frame(width: 20, height: 20) // Size of the doctor image
                                        .foregroundColor(Color(red: 0.82, green: 0.93, blue: 1.2))
                                        .padding(.top,4)
                                        .offset(x:-0)
                                    Text("Doctor: \(doctorName)")
                                        .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59))
                                        .padding(.top,5)
                                        .font(.subheadline)
                                        .padding(.trailing,0)
                                        .offset(x:-2)
                                    // Adjust spacing
                                    
                                    
                                }
                                .offset(x:-100)
                                .frame(width: 320, height: 30)
                            }
                            .padding(10)
                            
                            .background(Color.white) // Light blue background
                                    .cornerRadius(10) // Rounded corners
                                    .shadow(radius: 2)
                                    .frame(width: 325, height: 50)
                            }
                            
                            
                            
                            
                            VStack(alignment: .leading) {
                                Text("Medication Entries")
                                    .font(.title2)
                                    .padding(.top,20)
                                    .padding(.leading)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                
                                ScrollView(.horizontal,showsIndicators: false) {
                                    ScrollViewReader { proxy in
                                        HStack {
                                            ForEach(medicationEntries.indices, id: \.self) { index in
                                                MedicationCard(entry: medicationEntries[index])
                                                    .padding()
                                                    .background(Color.white)
                                                    .cornerRadius(10)
                                                    .padding(.horizontal)
                                                    .frame(width:360 ,height: 150)
                                            }
                                        }
                                    }
                                }
                                .padding(.top,-20)
                                .padding(.leading)
                            }
                            
                            
                            
                            VStack{
                                HStack{
                                    Text("Categories")
                                        .font(.title2)
                                        .padding(.leading)
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                }
                                
                                HospitalDepartment()
                                    .frame(maxWidth: .infinity,alignment: .center)
                                    .padding(.top,-20)
                                   // .offset(x:-20,y: -20)
                            }
                            .padding(.top,-5)
                            
                            
                        }
                       // .padding(20)
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
                                .padding(.bottom, UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?
                                    .windows
                                    .first?
                                    .safeAreaInsets
                                    .bottom ?? 0)
                                .offset(y:-50)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear {
            fetchLatestMedicationEntries() // Fetch patient history when the view appears
        }
    }
    
    
    

    private func fetchLatestMedicationEntries() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently logged in")
            return
        }

        let db = Firestore.firestore()
        let userId = currentUser.uid

        let medicationHistoryRef = db.collection("patienthistory")
            .whereField("userId", isEqualTo: userId) // Query by user ID
            .limit(to: 1)

        medicationHistoryRef.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching medication history: \(error)")
                        return
                    }

                    guard let document = querySnapshot?.documents.first else {
                        print("No documents found")
                        return
                    }

                    // Fetch doctor ID
                    guard let doctorId = document.data()["doctorId"] as? String else {
                        print("Doctor ID not found in the document")
                        return
                    }

                    // Fetch doctor's name using doctor ID
                    let doctorRef = db.collection("users").document(doctorId)
                    doctorRef.getDocument { (doctorSnapshot, doctorError) in
                        if let doctorError = doctorError {
                            print("Error fetching doctor details: \(doctorError)")
                            return
                        }

                        guard let doctorData = doctorSnapshot?.data() else {
                            print("Doctor details not found")
                            return
                        }

                        // Fetch doctor's full name
                        if let doctorFullName = doctorData["fullname"] as? String {
                            print("Doctor Name: \(doctorFullName)")
                            self.doctorName = doctorFullName // Assign doctor's name to state variable
                        } else {
                            print("Doctor full name not found")
                        }
                    }

            if let medicationEntries = document.data()["medicationEntries"] as? [[String: Any]] {
                self.medicationEntries = medicationEntries
                print("Fetched medication entries successfully: \(self.medicationEntries)")
            } else {
                print("No medication entries found in the document")
            }
            if let followUpDate = document.data()["followUpDate"] as? Timestamp {
                            let date = followUpDate.dateValue()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMM d, yyyy "
                            
                            self.followUpDateString = dateFormatter.string(from: date)
                            print("Follow-up Date: \(self.followUpDateString)")
                        }

        }
    }
    private func sendPromptToChatGPT(prompt: String) {
            isLoading = false
            isSuggestionsSheetVisible = true
            let prompt = chat + "\nYou are my personalized AI doctor, here to provide comprehensive guidance for my health concerns. As my AI doctor, your primary role is to suggest me which department to visit at Infyhealth hospital based on my symptoms. Please ensure to provide a detailed response with appropriate spacing to make it easier for me to read and understand.After suggesting the department, please provide recommendations on what actions I should take before visiting the doctor. Ensure to include spacing between different action points for clarity.Additionally, I would appreciate it if you could offer tips to overcome my health issues before my hospital visit. These tips should be spaced out appropriately for easy readability.Thank you for being my trusted AI doctor, guiding me towards better health outcomes!"
                    
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let parameters: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [["role": "user", "content": prompt]]
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print("Error serializing JSON: \(error)")
                return
            }
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
                    
                    if !decodedResponse.choices.isEmpty {
                        let chatbotResponse = decodedResponse.choices[0].message.content
                        DispatchQueue.main.async {
                            self.chatbotResponse = chatbotResponse
                            self.isSuggestionsSheetVisible = true
                        }
                    } else {
                        print("Empty response choices")
                    }
                } catch {
                    print("Error decoding response: \(error)")
                }
            }.resume()
        }



    }
    struct RecipeDisplayPage: View {
        var chatbotResponse: String

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("DocAi")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    ForEach(chatbotResponse.components(separatedBy: "\n"), id: \.self) { step in
                        if !step.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            RecipeStepView(step: step)
                                .padding(.horizontal)
                        }                }
                }
                .padding()
            }
            .navigationBarTitle("DocBot", displayMode: .inline)
        }
    }

struct RecipeStepView: View {
    
    var step: String
    
    
    
    var body: some View {
        
        HStack {
            
            Image(systemName: "circle.fill")
            
                .foregroundColor(.blue)
            
                .font(.system(size: 10))
            
                .padding(.trailing, 5)
            
            
            
            Text(step)
            
                .font(.body)
            
                .foregroundColor(.black)
            
            
            
            Spacer()
            
        }
        
        .padding(.vertical, 5)
        
        .padding(.horizontal, 10)
        
        .background(Color.gray.opacity(0.1))
        
        .cornerRadius(10)
        
    }
    
}


struct MedicationCard: View {
    var entry: [String: Any]
    
    var body: some View {
        HStack(spacing: 10) {
            // Left Image
            Image("med")
                .resizable()
                .frame(width: 50, height: 50)
                
                .padding(.trailing, 10)
            
            // Content VStack
                VStack(alignment: .leading, spacing: 5) {
                    // Title
                    Text(entry["medicineName"] as? String ?? "")
                        .foregroundColor(Color(red: 0.05, green: 0.51, blue: 0.99))
                        .font(.title3) // Adjusted font size
                        .bold()
                    
                    Text("Dosage: \(entry["dosage"] as? String ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.03, green: 0.31, blue: 0.59).opacity(0.8))
                        .lineLimit(1)
                    
                    Text("Note: \(entry["additionalDescription"] as? String ?? "")")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.03, green: 0.31, blue: 0.59).opacity(0.8))
                        .lineLimit(1)
                    
                    
                }
                .frame(width: 120)
                
               
                    // Time
                    
                ZStack {
                                    Circle()
                        .fill(Color(red: 0.82, green: 0.93, blue: 1.2)) // Light blue background
                                        .frame(width: 60, height: 60)
                                    
                                    Text(entry["time"] as? String ?? "")
                                        .foregroundColor(Color(red: 0.05, green: 0.51, blue: 0.99))
                                        .bold()// Primary color
                                        .font(.subheadline)
                                        .padding(.horizontal, 5) // Padding to keep text inside the circle
                                }
                .padding(.leading,30)
                
            
            
            // Spacer to make the card shorter
             // Add spacer to push content to the left
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white) // Background color of the card
        .cornerRadius(10) // Rounded corners
        .shadow(radius: 2) // Shadow for depth
    }
}


struct Choice: Codable {

    let text: String

}

struct ChatGPTResponse: Decodable {

    let choices: [ChatGPTChoice]

}



struct ChatGPTChoice: Decodable {

    let message: ChatGPTMessage

}



struct ChatGPTMessage: Decodable {

    let role: String

    let content: String

}

struct ChatGPTErrorResponse: Decodable {

    let error: ChatGPTError

}



struct ChatGPTError: Decodable {

    let message: String

    let type: String

    let param: String?

    let code: String

}


struct PatientDashView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDashView()
    }
}
