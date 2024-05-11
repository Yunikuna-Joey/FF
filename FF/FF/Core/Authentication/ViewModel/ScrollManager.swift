//
//  ScrollManager.swift
//  FF
//
//

import Foundation
import SwiftUI

struct ScrollViewWithDelegate<Content: View>: UIViewRepresentable {
    typealias UIViewType = UIScrollView
    typealias Coordinator = ScrollViewCoordinator

    let content: () -> Content
    @Binding var scrolledToTop: Bool
    @Binding var scrollProxy: ScrollViewProxy?
    var showsIndicators: Bool

    init(scrolledToTop: Binding<Bool>, scrollProxy: Binding<ScrollViewProxy?>, showsIndicators: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self._scrolledToTop = scrolledToTop
        self._scrollProxy = scrollProxy
        self.showsIndicators = showsIndicators
    }

    func makeCoordinator() -> Coordinator {
        return ScrollViewCoordinator(scrolledToTop: $scrolledToTop)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = showsIndicators
        scrollView.showsHorizontalScrollIndicator = showsIndicators
        scrollView.delegate = context.coordinator
    
        let hostingController = context.coordinator.hostingController(rootView: content())
        scrollView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        DispatchQueue.main.async {
            // Remove all subviews from UIScrollView
            uiView.subviews.forEach { $0.removeFromSuperview() }
            
            // Create new hosting controller with updated content
            let hostingController = context.coordinator.hostingController(rootView: content())
            
            // Add the new hosting controller's view to UIScrollView
            uiView.addSubview(hostingController.view)
            
            // Set constraints
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
                hostingController.view.topAnchor.constraint(equalTo: uiView.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
                hostingController.view.widthAnchor.constraint(equalTo: uiView.widthAnchor)
            ])
            
            // Check if the content height has changed
            let contentHeightChanged = uiView.contentSize.height != context.coordinator.previousContentHeight
            if contentHeightChanged {
                // Update the content height
                context.coordinator.previousContentHeight = uiView.contentSize.height

                // Set content offset to the bottom if scrolledToTop is true
                if !scrolledToTop {
                    DispatchQueue.main.async {
                        let offsetY = max(0, uiView.contentSize.height - uiView.bounds.size.height)
                        uiView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                    }
                }
            }
        }

        // Update coordinator properties
        context.coordinator.rootView = content()
        context.coordinator.scrolledToTop = scrolledToTop
    }

    class ScrollViewCoordinator: NSObject, UIScrollViewDelegate {
        var scrolledToTop: Bool
        var rootView: Content?
        @Binding var scrolledToTopBinding: Bool
        var previousContentHeight: CGFloat = 0

        init(scrolledToTop: Binding<Bool>) {
            _scrolledToTopBinding = scrolledToTop
            self.scrolledToTop = scrolledToTop.wrappedValue
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrolledToTop = scrollView.contentOffset.y == 0
            scrolledToTopBinding = scrolledToTop
            
//            if scrollView.contentOffset.y == 0 {
//                scrolledToTop = true
//                scrolledToTopBinding = true
//            } else {
//                scrolledToTop = false
//                scrolledToTopBinding = false
//            }
        }

        func hostingController(rootView: Content) -> UIHostingController<Content> {
            let hostingController = UIHostingController(rootView: rootView)
            return hostingController
        }
    }
}
