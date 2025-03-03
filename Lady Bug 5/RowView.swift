//
//  RowView.swift
//  Lady Bug 5
//
//  Created by Kiefer Hay on 2025-03-03.
//

import SwiftUI

/// LadyBug represents a LadyBug object.
struct Ladybug: Identifiable {
    var id = UUID()
    var name: String = "Ladybug"
    var date: Date = Date()
}

/// RowView represents a row in a list of LadyBugs.
struct RowView: View {
    var ladybug: Ladybug
    
    var body: some View {
        HStack {
            Image(systemName: "ladybug.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.black)
            
            Text(ladybug.name)
            
            Spacer()
        }
    }
}
