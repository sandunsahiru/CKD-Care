//
//  WelcomeView.swift
//  CKD Care
//
//  Created by Sandun Sahiru on 2025-03-06.
//

//
//  WelcomeView.swift
//  CKD Care
//
//  Created by Sandun Sahiru on 2025-03-06.
//

import SwiftUI

// MARK: - OnboardingPage Model
struct OnboardingPage: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var iconName: String
    var color: Color
}

// MARK: - WelcomeView
struct WelcomeView: View {
    // MARK: - Properties
    @State private var currentPage = 0
    @State private var isShowingMainApp = false
    @State private var animate = false
    @State private var selectedLanguage = "English"
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    init() {
        // Reset onboarding flag for development
        // Remove this line for production
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
    }
    
    private let languages = ["English", "සිංහල", "தமிழ්"]
    
    private let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Early Detection",
            description: "Take our AI-powered risk assessment to identify kidney disease risks before symptoms appear.",
            iconName: "list.bullet.clipboard.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Health Monitoring",
            description: "Track your vital signs, symptoms, and receive personalized alerts when values need attention.",
            iconName: "waveform.path.ecg",
            color: .green
        ),
        OnboardingPage(
            title: "Expert Support",
            description: "Connect with healthcare providers through secure telemedicine consultations.",
            iconName: "video.fill.badge.person",
            color: .purple
        ),
        OnboardingPage(
            title: "Personalized Guidance",
            description: "Receive customized dietary recommendations and lifestyle advice based on your health data.",
            iconName: "leaf.fill",
            color: .orange
        )
    ]
    
    // MARK: - Main View
    var body: some View {
        ZStack {
            if hasSeenOnboarding || isShowingMainApp {
                // Use the actual MainDashboardView implementation
                MainDashboardView()
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            } else {
                onboardingView
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isShowingMainApp)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasSeenOnboarding)
    }
    
    // MARK: - Onboarding View
    private var onboardingView: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                backgroundView(for: currentPage, in: geometry)
                
                // Content layer
                VStack(spacing: 0) {
                    // Top section with logo and language selector
                    topSection
                        .padding(.top, geometry.safeAreaInsets.top + 20)
                    
                    // Page content
                    pageCarousel(in: geometry)
                    
                    // Navigation controls
                    navigationControls
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                }
                .padding(.horizontal)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Background View
    private func backgroundView(for index: Int, in geometry: GeometryProxy) -> some View {
        ZStack {
            // Base color with dynamic gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    onboardingPages[index].color.opacity(0.7),
                    onboardingPages[index].color.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 0.8), value: index)
            
            // Animated background elements
            ForEach(0..<8) { i in
                Circle()
                    .fill(onboardingPages[index].color.opacity(Double.random(in: 0.05...0.15)))
                    .frame(width: randomSize(for: i, maxSize: geometry.size.width * 0.8))
                    .position(
                        x: randomPosition(for: i, index: 0, maxPos: geometry.size.width),
                        y: randomPosition(for: i, index: 1, maxPos: geometry.size.height)
                    )
                    .animation(
                        Animation.interpolatingSpring(stiffness: 50, damping: 8)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.2),
                        value: animate
                    )
            }
            
            // Overlay pattern for texture
            Color.white.opacity(0.03)
                .mask(
                    Image(systemName: "dot.squareshape.fill")
                        .resizable(resizingMode: .tile)
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.2)
                )
        }
        .onAppear {
            animate = true
        }
    }
    
    // Random sizing and positioning for background elements
    private func randomSize(for index: Int, maxSize: CGFloat) -> CGFloat {
        let multiplier = [0.4, 0.6, 0.5, 0.7, 0.3, 0.6, 0.5, 0.4][index % 8]
        return maxSize * multiplier
    }
    
    private func randomPosition(for index: Int, index axis: Int, maxPos: CGFloat) -> CGFloat {
        let offsets = [
            [0.2, 0.8], [0.8, 0.3], [0.5, 0.9], [0.9, 0.5],
            [0.3, 0.2], [0.7, 0.7], [0.1, 0.5], [0.5, 0.3]
        ]
        return maxPos * offsets[index % 8][axis]
    }
    
    // MARK: - Top Section
    private var topSection: some View {
        HStack {
            // App logo
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(animate ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true),
                            value: animate
                        )
                }
                
                Text("CKD Care")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Language selector
            languageSelector
        }
        .padding(.horizontal, 5)
        .padding(.bottom, 20)
    }
    
    // MARK: - Language Selector
    private var languageSelector: some View {
        Menu {
            ForEach(languages, id: \.self) { language in
                Button(language) {
                    withAnimation {
                        selectedLanguage = language
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedLanguage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Page Carousel
    private func pageCarousel(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<onboardingPages.count, id: \.self) { index in
                    pageView(for: onboardingPages[index], in: geometry)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: geometry.size.height * 0.6)
            .padding(.top, 20)
            
            // Page indicators
            pageIndicators
                .padding(.bottom, 10)
        }
    }
    
    // MARK: - Page View Builder
    private func pageView(for page: OnboardingPage, in geometry: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            // Main illustration with icon
            ZStack {
                // Background glow
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: min(geometry.size.width * 0.8, 350), height: min(geometry.size.width * 0.8, 350))
                
                // Icon container
                ZStack {
                    // Icon background with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    page.color.opacity(0.9),
                                    page.color
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: page.color.opacity(0.5), radius: 15, x: 0, y: 8)
                    
                    // Icon
                    Image(systemName: page.iconName)
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                }
                
                // Decorative rings
                Circle()
                    .stroke(page.color.opacity(0.3), lineWidth: 1)
                    .frame(width: 170, height: 170)
                
                Circle()
                    .stroke(page.color.opacity(0.2), lineWidth: 1)
                    .frame(width: 220, height: 220)
            }
            .frame(height: geometry.size.height * 0.3)
            .offset(y: -20)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                Text(page.description)
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 300)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
    }
    
    // MARK: - Page Indicators
    private var pageIndicators: some View {
        HStack(spacing: 12) {
            ForEach(0..<onboardingPages.count, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? .white : Color.white.opacity(0.3))
                    .frame(width: currentPage == index ? 24 : 8, height: 8)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .animation(.spring(), value: currentPage)
            }
        }
    }
    
    // MARK: - Navigation Controls
    private var navigationControls: some View {
        VStack(spacing: 16) {
            // Primary button (Next or Get Started)
            Button(action: {
                withAnimation {
                    if currentPage < onboardingPages.count - 1 {
                        currentPage += 1
                    } else {
                        hasSeenOnboarding = true
                        isShowingMainApp = true
                    }
                }
            }) {
                HStack {
                    Text(currentPage < onboardingPages.count - 1 ? "Next" : "Get Started")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                    
                    if currentPage < onboardingPages.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(.subheadline, weight: .bold))
                    }
                }
                .foregroundColor(onboardingPages[currentPage].color)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    }
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 20)
            
            // Skip button
            if currentPage < onboardingPages.count - 1 {
                Button(action: {
                    withAnimation {
                        hasSeenOnboarding = true
                        isShowingMainApp = true
                    }
                }) {
                    Text("Skip")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 16)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Footer with credits
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(Color.white.opacity(0.6))
                    .font(.system(size: 12))
                
                Text("National Initiative for Kidney Disease")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        .padding(.top, 20)
    }
}

// MARK: - Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .preferredColorScheme(.dark)
        
        WelcomeView()
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
    }
}
