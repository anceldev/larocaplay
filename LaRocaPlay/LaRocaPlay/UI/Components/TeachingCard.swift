//
//  TeachingCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import SwiftUI

struct TeachingCard: View {
    var teach: Preach
    var listView: ListView
    
    var preacherAndDate: String {
        let role = self.teach.preacher?.role
            let name = self.teach.preacher?.name
            let dateString = teach.date.formatted(date: .numeric, time: .omitted)

            let nameParts = [role, name]
                .compactMap { $0 }
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            let fullName = nameParts.joined(separator: " ")

            if fullName.isEmpty {
                return dateString
            }
            return "\(fullName) - \(dateString)"
    }
    
    
    
    var body: some View {
        VStack(spacing: 8) {
            ThumbImageLoader(storageCollection: .preaches(teach.imageId))
            VStack(alignment: listView.hAlignment, spacing: 0) {
                Text(teach.title)
                    .foregroundStyle(.white)
                    .font(.system(size: listView.fontSize, weight: .medium, design: .default))
                    .multilineTextAlignment(.center)
//                HStack(alignment: .center , spacing: 4) {
                    Text(preacherAndDate)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.gray.opacity(0.7))
//                }
                .frame(maxWidth: .infinity, alignment: listView.textAlignment)
            }
            .padding(.horizontal, 8)
        }
        
    }
}
