//
//  DetailView.swift
//  Lady Bug 5
//
//  Created by Kiefer Hay on 2025-03-03.
//

import SwiftUI

struct DetailView: View {
    @Binding var ladybug: Ladybug
    
    var body: some View {
        VStack {
            Image(systemName: "ladybug.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.black)
            
            TextField("Name", text: $ladybug.name)
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, h:mma"
        return formatter.string(from: ladybug.date)
    }
}
