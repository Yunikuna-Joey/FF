//
//  LoadProfileView2.swift
//  FF
//
//

import SwiftUI

struct LoadProfileView2: View {
    @EnvironmentObject var viewModel: AuthView
    @State private var resultUserCurrentImage: ImageUrlWrapper?
    
    let resultUser: User

    var body: some View {
        let screenSize = UIScreen.main.bounds.size
        let itemWidth: CGFloat = (screenSize.width) / 3
        let itemHeight: CGFloat = (screenSize.height) * 0.20
    
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: itemWidth))]) {
                                        
                    let sortedKeys = resultUser.imageHashMap.keys.sorted().reversed()
                    ForEach(sortedKeys, id: \.self) { key in
                        if let pictureUrls = resultUser.imageHashMap[key] {
                            TabView {
                                ForEach(pictureUrls, id: \.self) { urlString in
                                    Button(action: {
                                        resultUserCurrentImage = ImageUrlWrapper(urlString: urlString)
                                    }) {
                                        AsyncImage(url: URL(string: urlString)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 30, height: 30)
                                                
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: itemWidth + 50, height: itemHeight)
                                                    .cornerRadius(5)
                                                    .padding()
                                                
                                            case .failure:
                                                Image(systemName: "xmark.circle")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .foregroundStyle(Color.red)
                                               
                                               
                                            
                                            @unknown default:
                                                EmptyView()
                                                
                                            } // end of switch case
                                            
                                        } // end of AsyncImage closure
                                        
                                    } // end of Button
                                    
                                } // end of For loop
                                
                            } // end of TabView
                            .frame(width: itemWidth + 50, height: itemHeight)
                            .tabViewStyle(PageTabViewStyle())
                            .cornerRadius(5)
                            .padding()
                            
                        } // end of variable unwrapping
                        
                    } // ForEach
                    
                } // end of vgrid
            } // end of scroll view
            .fullScreenCover(item: $resultUserCurrentImage) { imageInfo in
                ImageFullScreenView(imageUrl: imageInfo.urlString) {
                    resultUserCurrentImage = nil // dismiss full screen view
                }
            }
        } // end of Vstack

    }
}

//struct LoadProfileView2_Previews: PreviewProvider {
//    static var previews: some View {
//        let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "", coverPicture: "")
//        LoadProfileView2(imageArray: [], resultUser: user)
//    }
//}
