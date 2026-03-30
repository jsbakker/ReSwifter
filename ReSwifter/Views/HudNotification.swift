//
//  HudNotification.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-07.
//

import SwiftUI

struct HudNotification: View {
    let text: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
            Text(text)
                .fontWeight(.medium)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 10)
        .transition(.opacity.combined(with: .scale)) // Smooth entrance
    }
}
