//
//  Copyright © 2020 An Tran. All rights reserved.
//

import SwiftUI
import FeedKit

struct NewsItem: Hashable {
    let title: String
    let link: URL
}

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}

struct ContentView: View {

    class ViewModel: ObservableObject {
        static let feedURL = URL(string: "https://swiftvietnam.com/feed.rss")!

        @Published private(set) var newsItems: [NewsItem] = []
        @Published private(set) var link: URL? = nil

        func select(_ link: URL?) {
            self.link = link
        }

        func loadFeed() {
            let parser = FeedParser(URL: Self.feedURL)

            // Parse asynchronously, not to block the UI.
            parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { result in
                switch result {
                case .success(let feed):
                    guard let rssFeed = feed.rssFeed else {
                        print("Feed ist empty")
                        return
                    }
                    self.parseFeed(rssFeed)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }

        private func parseFeed(_ feed: RSSFeed) {
            let newsItems = feed.items?.compactMap { rssFeedItem -> NewsItem? in
                guard let title = rssFeedItem.title,
                    let link = rssFeedItem.link,
                    let url = URL(string: link) else {
                        return nil
                }

                return NewsItem(
                    title: title,
                    link: url
                )
            }

            // Go back the the main thread to update the UI.
            DispatchQueue.main.async {
                self.newsItems = newsItems ?? []
            }
        }
    }

    @ObservedObject private var viewModel = ViewModel()

    init() {
        viewModel.loadFeed()
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.newsItems, id: \.self) { item in
                    Button(action: {
                        self.viewModel.select(item.link)
                    }) {
                        NewsItemView(item: item)
                    }
                }
            }
            .sheet(item: .init(
                get: {
                    self.viewModel.link
            },
                set: {
                    self.viewModel.select($0)
            }
                ), content: { link in
                    SafariView(url: link)
            })
                .navigationBarTitle(Text("Swift Việt Nam"))
                .navigationBarItems(
                    trailing: Button(action: {
                        self.viewModel.loadFeed()
                    }) {
                        Text("Load")
                    }
            )
        }
    }
}

struct NewsItemView: View {
    var item: NewsItem

    var body: some View {
        Text(item.title)
            .font(.headline)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
