//
//  TopBar.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import AppRouter
import SwiftUI

struct TopBar: View {
  //    @Environment(AuthService.self) var auth
  @Environment(AuthManager.self) var authManager
  @Environment(AppRouter.self) var router

  var displayName: String {
    guard let displayName = authManager.currentUserProfile?.displayName else {
      guard let email = authManager.currentUserProfile?.email else {
        return "Invitado"
      }
      return email
    }
    return displayName
  }
  var body: some View {
    VStack {
      ZStack {
        HStack {
          Spacer()
          Image(.topbarLogo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 40)
          Spacer()
        }
        HStack {
          Spacer()
          Button {
            router.navigateTo(.account)
          } label: {
            Image(.user)
              .resizable()
              .scaledToFit()
              .frame(width: 28)
              .foregroundStyle(.customRed)
          }
        }
      }
      .frame(height: 38)
      HStack(spacing: 4) {
        Text("Bienvenido, ")
        Text(displayName)
          .fontWeight(.semibold)
          .foregroundStyle(.white)
      }
      .font(.system(size: 12))
    }
    .padding(.horizontal)
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

#Preview {
  TopBar()
}
