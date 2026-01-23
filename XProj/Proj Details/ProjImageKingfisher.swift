import SwiftUI
import Kingfisher

struct ProjImageKingfisher: View {
    private let url: URL?
    
    init(_ url: URL?) {
        self.url = url
    }
    
    var body: some View {
        KFImage(url)
            .resizable()
            .clipShape(.rect(cornerRadius: 10))
    }
}
