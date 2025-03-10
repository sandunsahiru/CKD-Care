//
//  ProfileView.swift
//  CKD Care
//
//  Created by Sandun Sahiru on 2025-03-10.
//


import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    // MARK: - Properties
    @State private var showingEditProfile = false
    @State private var showingMedicalRecords = false
    @State private var showingHealthcareProviders = false
    @State private var showingSettings = false
    @State private var showingHelp = false
    @State private var userProfile: UserProfile
    
    // Initialize with default profile
    init() {
        _userProfile = State(initialValue: UserProfile.sampleProfile)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                profileHeader
                
                // Health summary card
                healthSummaryCard
                
                // Action buttons
                actionButtonsSection
                
                // Medical information
                medicalInfoSection
                
                // Healthcare providers
                healthcareProvidersSection
                
                // Preferences
                preferencesSection
                
                // Support and logout
                supportSection
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(profile: $userProfile)
        }
        .sheet(isPresented: $showingMedicalRecords) {
            MedicalRecordsView(userId: userProfile.id)
        }
        .sheet(isPresented: $showingHealthcareProviders) {
            HealthcareProvidersView(providers: userProfile.healthcareProviders)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpSupportView()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 20) {
            // User image and edit button
            ZStack(alignment: .bottomTrailing) {
                // User image
                Image(userProfile.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                
                // Edit button
                Button(action: {
                    showingEditProfile = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                }
            }
            .padding(.top, 20)
            
            // User info
            VStack(spacing: 8) {
                Text(userProfile.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("CKD Stage \(userProfile.ckdStage)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(stageColor(for: userProfile.ckdStage))
                    .cornerRadius(12)
                
                Text("\(userProfile.age) years • \(userProfile.gender) • \(userProfile.bloodType)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // MARK: - Health Summary Card
    private var healthSummaryCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Health Summary")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                healthMetricView(
                    icon: "kidneys.fill",
                    value: "\(userProfile.eGFR)",
                    unit: "mL/min",
                    label: "eGFR",
                    color: .purple
                )
                
                healthMetricView(
                    icon: "heart.fill",
                    value: "\(userProfile.bloodPressure)",
                    unit: "mmHg",
                    label: "BP",
                    color: .red
                )
                
                healthMetricView(
                    icon: "drop.fill",
                    value: "\(userProfile.bloodSugar)",
                    unit: "mg/dL",
                    label: "Sugar",
                    color: .blue
                )
            }
            
            Divider()
                .padding(.vertical, 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Last Update")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(formattedDate(userProfile.lastCheckup))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        showingMedicalRecords = true
                    }) {
                        Text("View History")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: 15) {
            actionButton(title: "Medical Records", icon: "list.clipboard.fill", color: .blue) {
                showingMedicalRecords = true
            }
            
            actionButton(title: "Healthcare Team", icon: "person.2.fill", color: .green) {
                showingHealthcareProviders = true
            }
            
            actionButton(title: "Appointments", icon: "calendar.badge.clock", color: .orange) {
                // Handle appointments
            }
        }
    }
    
    // MARK: - Medical Information Section
    private var medicalInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Medical Information", icon: "heart.text.square.fill")
            
            VStack(spacing: 15) {
                // Conditions
                infoRow(title: "Conditions", content: formatList(userProfile.medicalConditions))
                
                Divider()
                
                // Allergies
                infoRow(title: "Allergies", content: formatList(userProfile.allergies))
                
                Divider()
                
                // Medications
                infoRow(title: "Medications", content: formatList(userProfile.medications))
            }
            .padding(15)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(15)
            
            Button(action: {
                showingEditProfile = true
            }) {
                Text("Update Medical Information")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // MARK: - Healthcare Providers Section
    private var healthcareProvidersSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Healthcare Providers", icon: "person.text.rectangle.fill")
            
            if userProfile.healthcareProviders.isEmpty {
                emptyStateView(
                    message: "You haven't added any healthcare providers yet",
                    buttonText: "Add Provider"
                ) {
                    showingHealthcareProviders = true
                }
            } else {
                ForEach(userProfile.healthcareProviders.prefix(2)) { provider in
                    providerRow(provider: provider)
                }
                
                if userProfile.healthcareProviders.count > 2 {
                    Button(action: {
                        showingHealthcareProviders = true
                    }) {
                        Text("View All Providers")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeader(title: "Preferences", icon: "gearshape.fill")
            
            Button(action: {
                showingSettings = true
            }) {
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    Text("Notifications")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
            }
            
            Button(action: {
                showingSettings = true
            }) {
                HStack {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    Text("Privacy & Data")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
            }
            
            Button(action: {
                showingSettings = true
            }) {
                HStack {
                    Image(systemName: "textformat.size")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    Text("Appearance")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(spacing: 15) {
            Button(action: {
                showingHelp = true
            }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    Text("Help & Support")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            Button(action: {
                // Logout action would go here
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                        .frame(width: 30)
                    
                    Text("Logout")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            HStack {
                Spacer()
                
                VStack(spacing: 2) {
                    Text("CKD Care v1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("© 2025 Sandun Sahiru")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Helper Components
    
    private func healthMetricView(icon: String, value: String, unit: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
        }
    }
    
    private func infoRow(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
    
    private func providerRow(provider: HealthcareProvider) -> some View {
        HStack(spacing: 15) {
            // Provider icon
            ZStack {
                Circle()
                    .fill(providerTypeColor(provider.type))
                    .frame(width: 40, height: 40)
                
                Image(systemName: providerTypeIcon(provider.type))
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            // Provider details
            VStack(alignment: .leading, spacing: 4) {
                Text("\(provider.title) \(provider.name)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(provider.specialization)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(provider.facility)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Contact button
            Button(action: {
                // Handle contact action
            }) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    private func emptyStateView(message: String, buttonText: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.blue.opacity(0.5))
                .padding(.vertical, 10)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                Text(buttonText)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 5)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    // MARK: - Helper Functions
    
    private func stageColor(for stage: Int) -> Color {
        switch stage {
        case 1: return .green
        case 2: return .blue
        case 3: return .yellow
        case 4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatList(_ items: [String]) -> String {
        if items.isEmpty {
            return "None"
        }
        return items.joined(separator: ", ")
    }
    
    private func providerTypeIcon(_ type: ProviderType) -> String {
        switch type {
        case .primaryCare: return "heart.text.square.fill"
        case .nephrologist: return "kidneys.fill"
        case .dietitian: return "fork.knife"
        case .nurse: return "cross.fill"
        case .other: return "stethoscope"
        }
    }
    
    private func providerTypeColor(_ type: ProviderType) -> Color {
        switch type {
        case .primaryCare: return .blue
        case .nephrologist: return .purple
        case .dietitian: return .green
        case .nurse: return .red
        case .other: return .gray
        }
    }
}

// MARK: - Supporting Views (Placeholders)

struct EditProfileView: View {
    @Binding var profile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("Edit Profile View (Placeholder)")
                .navigationTitle("Edit Profile")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

struct MedicalRecordsView: View {
    let userId: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("Medical Records View (Placeholder)")
                .navigationTitle("Medical Records")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

struct HealthcareProvidersView: View {
    let providers: [HealthcareProvider]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("Healthcare Providers View (Placeholder)")
                .navigationTitle("Healthcare Team")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("Settings View (Placeholder)")
                .navigationTitle("Settings")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

struct HelpSupportView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("Help & Support View (Placeholder)")
                .navigationTitle("Help & Support")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

// MARK: - Models

struct UserProfile {
    var id: String
    var fullName: String
    var age: Int
    var gender: String
    var bloodType: String
    var profileImage: String
    var ckdStage: Int
    var eGFR: Int
    var bloodPressure: String
    var bloodSugar: Int
    var lastCheckup: Date
    var medicalConditions: [String]
    var allergies: [String]
    var medications: [String]
    var healthcareProviders: [HealthcareProvider]
    
    static var sampleProfile: UserProfile {
        UserProfile(
            id: "12345",
            fullName: "Sandun Sahiru",
            age: 35,
            gender: "Male",
            bloodType: "A+",
            profileImage: "user-avatar",
            ckdStage: 2,
            eGFR: 75,
            bloodPressure: "120/80",
            bloodSugar: 95,
            lastCheckup: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
            medicalConditions: ["Hypertension", "Early CKD"],
            allergies: ["Penicillin"],
            medications: ["Lisinopril 10mg", "Vitamin D3"],
            healthcareProviders: [
                HealthcareProvider(
                    id: "dr1",
                    type: .primaryCare,
                    title: "Dr.",
                    name: "Anura Perera",
                    specialization: "General Practitioner",
                    facility: "Colombo General Hospital",
                    contactNumber: "+94112365478"
                ),
                HealthcareProvider(
                    id: "dr2",
                    type: .nephrologist,
                    title: "Dr.",
                    name: "Kamala Fernando",
                    specialization: "Nephrology",
                    facility: "National Kidney Center",
                    contactNumber: "+94112789456"
                )
            ]
        )
    }
}

enum ProviderType: String, Codable {
    case primaryCare
    case nephrologist
    case dietitian
    case nurse
    case other
}

struct HealthcareProvider: Identifiable {
    var id: String
    var type: ProviderType
    var title: String
    var name: String
    var specialization: String
    var facility: String
    var contactNumber: String
}

// MARK: - Previews
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            ProfileView()
        }
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
