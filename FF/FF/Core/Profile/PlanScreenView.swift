//
//  PlanScreenView.swift
//  FF
//
//

import SwiftUI

struct createButton: View {
    var text: String
    
    var body: some View {
        HStack {
            Button(action: {
                print("[DEBUG]: You pressed the creation button")
            }) {
                Image(systemName: "plus.app.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text("Create your plan")
                    .font(.system(size: 20))
            }
            .foregroundStyle(Color.blue)
            .padding()
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white)
        )
    }
}

// Titling the different categories
struct planButton: View {
    var title: String
    
    var body: some View {
        HStack {
            Button(action: {
                print("[DEBUG]: You pressed one of the \(title) button")
            }) {
                Image(systemName: "arrowshape.right.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(title)
                    .font(.system(size: 20))
            }
            .foregroundStyle(Color.blue)
            .padding()
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.white)
        )
    }
}

struct PlanScreenView: View {
    // Categories
    // Legs || Arms || Chest || Back ||
    private var categories: [String] = ["Arms", "Back", "Chest", "Legs"]
    @State private var selectedCategory: String?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10) // Adjust corner radius as needed
            .fill(Color.gray)
            .overlay(
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(categories.indices, id: \.self) { index in
                            planButton(title: categories[index])
                        }
                        
                        // pushes button towards the top
                        Spacer()
                    }
                    .padding()
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
    }
}

#Preview {
    PlanScreenView()
}
