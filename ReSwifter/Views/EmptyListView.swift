//
//  EmptyListView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-29.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "doc.on.clipboard")
                .font(.largeTitle)
            Text("Press Command + Shift + V to add a\nnew snippet from the clipboard.")
                .font(.title)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("emptyListMessage") // For automation
            Text("or")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Text("Send selections through the\nReSwifter Editor Extension for Xcode.")
                .font(.title)
                .multilineTextAlignment(.center)
            Text("(Xcode Menu ⮕ Editor ⮕ ReSwifter)")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("or")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Image(systemName: "doc.badge.plus")
                .font(.largeTitle)
            Text("Press Command + N to create a\nnew snippet in the editor.")
                .font(.title)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    EmptyListView()
}
