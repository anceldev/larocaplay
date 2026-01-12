//
//  NetworkBanner.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/1/26.
//

import SwiftUI

struct NetworkBanner: View {
  @State private var isCheking = false
  private let feedbackGenerator = UINotificationFeedbackGenerator()
  var body: some View {
      VStack(spacing: 12){
      if isCheking {
          VStack {
              ProgressView()
                  .controlSize(.small)
                  .tint(.customRed)
          }
          .frame(width: 30, height: 30, alignment: .center)
      } else {
          Image(systemName: "wifi.exclamationmark")
              .resizable()
              .scaledToFit()
              .frame(width: 30)
      }

      VStack(alignment: .center, spacing: 2) {

        Text("Sin conexión a internet")
              .font(.system(size: 12, weight: .bold))
        Text("Revisa tu conexión Wi-Fi o datos móviles")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      Button {
        retryConnection()
      } label: {
        Text("Reintentar")
          .font(.caption)
          .bold()
          .padding(.horizontal, 12)
          .padding(.vertical, 4)
          .background(.red.opacity(0.2))
          .clipShape(.capsule)
          .foregroundStyle(.white)
      }
    }
    .padding(24)
    .background(Color(.systemBackground).opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    .padding(.horizontal, 50)  // Margen para que flote como una tarjeta

  }
  private func retryConnection() {
    feedbackGenerator.prepare()
    withAnimation {
      isCheking = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      withAnimation {
        isCheking = false
        if !NetworkMonitor.shared.isConnected {
          //                    triggerHaptic(type: .error)
          feedbackGenerator.notificationOccurred(.error)
        } else {
          //                    triggerHaptic(type: .success)
          feedbackGenerator.notificationOccurred(.success)
        }
      }
    }
  }
  private func triggerHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
  }
}
#Preview {
    Color.customBlack
        .frame(maxWidth: .infinity)
        .supportOfflineMode(isConnected: false)
        .preferredColorScheme(.dark)
}
