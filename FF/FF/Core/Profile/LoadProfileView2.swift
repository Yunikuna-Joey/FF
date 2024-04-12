//
//  LoadProfileView2.swift
//  FF
//
//

import SwiftUI

struct LoadProfileView2: View {
    @EnvironmentObject var viewModel: AuthView
    @State private var resultUserCurrentImage: ImageInfo?
    @State var imageArray: [ImageInfo]
    
    let resultUser: User

    init(imageArray: [ImageInfo] = [], resultUser: User) {
        self._imageArray = State(initialValue: imageArray)
        self.resultUser = resultUser
    }
    
    var body: some View {
        let screenSize = UIScreen.main.bounds.size
        let itemWidth: CGFloat = (screenSize.width) / 3
        let itemHeight: CGFloat = (screenSize.height) * 0.10
    
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: itemWidth))]) {
                    // iterate through the image array
                    ForEach(imageArray) { imageInfo in
                        Button(action: {
                            resultUserCurrentImage = imageInfo
                        }) {
                            Image(imageInfo.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: itemWidth + 50, height: itemHeight)
                                .cornerRadius(5)
                                .padding()
                        }
                    } // for loop
                } // end of vgrid
            } // end of scroll view
            .fullScreenCover(item: $resultUserCurrentImage) { imageInfo in
                ImageFullScreenView(imageName: imageInfo.imageName) {
                    resultUserCurrentImage = nil // dismiss full screen view
                }
            }
        } // end of Vstack
        .onAppear(perform: {
            Task {
                do {
                    let imageNames = await viewModel.fetchUserImages(userId: resultUser.id)
                    imageArray = imageNames.map { ImageInfo(imageName: $0) }
                }
                
                catch {
                    print("[DEBUG]: There was an error fetching images in LPV2 \(error.localizedDescription)")
                }
            }
        })
    }
}

struct LoadProfileView2_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(id: "testString", username: "TesterE", databaseUsername: "testere", firstName: "Tester", lastName: "E", email: "e@email.com", imageArray: ["Car", "car2", "car3"], profilePicture: "")
        LoadProfileView2(imageArray: [], resultUser: user)
    }
}
