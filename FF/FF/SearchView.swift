//
//  SearchView.swift
//  FF
//
//

import SwiftUI

struct SearchView: View {
    // hold some image arary... likely just some random users
    let imageArray = ["Car", "car2", "terrifiednootnoot"]
    let itemSize: CGFloat = 100
    
    @State private var searchText: String = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // enable scrolling behavior
            ScrollView {
                // grid to hold the pictures
                LazyVGrid(columns: [GridItem(.adaptive(minimum: itemSize))]) {
                    // iterate through the image array
                    ForEach(imageArray, id: \.self) {
                        imageName in Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: itemSize + 32, height: itemSize)
                            .cornerRadius(5)
                    }
                }
            }
            
            // search bar
            TextField("Search", text: $searchText)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(Color.gray.opacity(0.33))
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.bottom)
                .frame(maxWidth: 500 ) // Set maximum width
        }
    }
}

#Preview {
    SearchView()
}
