//
//  OnboardingScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 30/11/25.
//

import SwiftUI

struct OnboardingScreen: View {
//    @Environment(AppRouter.self) var router
//    @Binding var appState: AppState
//    
//    init(_ appState: Binding<AppState>) {
//        self._appState = appState
//    }
    @Binding var hideOnboarding: Bool
    
    var body: some View {
        // TODO: En esta pantalla se muestran las principales características de la app.
        VStack {
            Spacer()
            Text("Welcome Screen")
            Spacer()
            Button {
//                UserDefaults.standard.appState = .unauthenticated
//                appState = .unauthenticated
                UserDefaults.standard.set(true, forKey: "hideOnboarding")
                hideOnboarding = true
            } label: {
                Text("Empezar")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    OnboardingScreen(hideOnboarding: .constant(false))
}
