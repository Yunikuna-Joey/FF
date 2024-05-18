//
//  CommentView.swift
//  FF
//
//

import SwiftUI

struct CommentView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CommentCell: View {
    let status: Status
    
    var body: some View {
        //
        HStack {
            Text("Hello World")
        }
    }
}

#Preview {
    CommentView()
}
