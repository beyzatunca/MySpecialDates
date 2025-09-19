import SwiftUI

// MARK: - Add Birthday View
struct AddBirthdayView: View {
    @ObservedObject var viewModel: ContactSyncViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var contactName = ""
    @State private var selectedDate = Date()
    @State private var selectedType: BirthdayEntry.BirthdayType = .birthday
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kişi Bilgileri")) {
                    TextField("Kişi Adı", text: $contactName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Doğum Günü Bilgileri")) {
                    DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    Picker("Tür", selection: $selectedType) {
                        ForEach(BirthdayEntry.BirthdayType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button(action: addBirthday) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Doğum Günü Ekle")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(isValidInput ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isValidInput || isLoading)
                }
            }
            .navigationTitle("Doğum Günü Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        !contactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func addBirthday() {
        isLoading = true
        
        Task {
            await viewModel.addManualBirthday(
                contactName: contactName.trimmingCharacters(in: .whitespacesAndNewlines),
                birthday: selectedDate,
                type: selectedType
            )
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}

#Preview {
    AddBirthdayView(viewModel: ContactSyncViewModel())
}
