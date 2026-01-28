//
//  TeachingRow.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import SwiftUI

struct TeachingRow: View {
  var teach: Preach
  var position: Int
  var listView: ListView

  var preacherAndDate: String {
    let role = self.teach.preacher?.role
    let name = self.teach.preacher?.name
    let dateString = teach.date.formatted(date: .numeric, time: .omitted)

    let nameParts = [role, name]
      .compactMap { $0 }
      .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    let fullName = nameParts.joined(separator: " ")
    if fullName.isEmpty { return dateString }
    return "\(fullName) - \(dateString)"
  }

  var body: some View {
    VStack {
      HStack(spacing: 8) {
        ZStack(alignment: .topLeading) {
          ThumbImageLoader(storageCollection: .preaches(teach.imageId), radius: Theme.Radius.small)
          if position != 0 {
            VStack {
              Text(position, format: .number)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.dirtyWhite)
                .padding(8)
            }
          }
        }
        VStack(alignment: .leading, spacing: 0) {
          Text(teach.title)
            .foregroundStyle(.white)
            .font(.system(size: listView.titleSize, weight: .medium, design: .default))
            .multilineTextAlignment(.leading)
          Text(preacherAndDate)
            .font(.system(size: listView.subtitleSize, weight: .medium, design: .rounded))
            .foregroundStyle(.gray.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
      }
      .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
      .padding(.vertical, 6)
    }
    .enableInjection()

  }
  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}
