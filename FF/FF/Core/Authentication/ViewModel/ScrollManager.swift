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
        context.coordinator.rootView = content()
        context.coordinator.scrolledToTop = scrolledToTop
    }

    class ScrollViewCoordinator: NSObject, UIScrollViewDelegate {
        var scrolledToTop: Bool
        var rootView: Content?
        @Binding var scrolledToTopBinding: Bool

        init(scrolledToTop: Binding<Bool>) {
            _scrolledToTopBinding = scrolledToTop
            self.scrolledToTop = scrolledToTop.wrappedValue
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrolledToTop = scrollView.contentOffset.y == 0
            scrolledToTopBinding = scrolledToTop
        }

        func hostingController(rootView: Content) -> UIHostingController<Content> {
            let hostingController = UIHostingController(rootView: rootView)
            return hostingController
        }
    }
}
