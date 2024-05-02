import SwiftUI
struct DepartmentView: View {
    let departments = ["General", "Pediatrics", "Gynecology", "Dermatology", "Orthopedics", "Cardiology", "Endocrinology", "Neurology"]
    
    var body: some View {
        VStack {
            Text("Departments")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 20) {
                ForEach(departments, id: \.self) { department in
                    NavigationLink(destination: ViewDoc(department: department)) {
                        DepartmentCardView(department: department)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct DepartmentCardView: View {
    let department: String
    
    var body: some View {
        VStack {
            Image(department.lowercased())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding(.bottom, 8)
            
            Text(department)
                .foregroundColor(.black)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
        .padding()
    }
}

// Preview
struct DepartmentView_Previews: PreviewProvider {
    static var previews: some View {
        DepartmentView()
    }
}

