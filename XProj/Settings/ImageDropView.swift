import SwiftUI
import AppKit
import ImageIO

struct ImageDropView: View {
    @State private var droppedImage: NSImage? = nil
    @State private var imageMetadata: [(key: String, value: String)] = []
    @State private var isTargeted = false
    
    var body: some View {
        VStack {
            if let droppedImage {
                Image(nsImage: droppedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(8)
                    .padding()
            } else {
                Rectangle()
                    .fill(isTargeted ? .gray.opacity(0.4) : .gray.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .cornerRadius(8)
                    .padding()
            }
            
            List {
                Text("Metadata count: \(imageMetadata.count)")
                
                ForEach(imageMetadata, id: \.key) { item in
                    VStack(alignment: .leading) {
                        Text("Key: \(item.key)")
                        Text("Value: \(item.value)")
                    }
                    .padding(.bottom, 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
        }
        .onDrop(of: ["public.file-url"], isTargeted: $isTargeted) { providers in
            guard let item = providers.first else {
                return false
            }
            
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { data, error in
                guard
                    let data = data as? Data,
                    let url = URL(dataRepresentation: data, relativeTo: nil),
                    let image = NSImage(contentsOf: url)
                else {
                    return
                }
                
                droppedImage = image
                imageMetadata = extractMetadata(from: url)
            }
            
            return true
        }
        .frame(width: 400, height: 600)
        .padding()
    }
    
    private func extractMetadata(from url: URL) -> [(key: String, value: String)] {
        guard
            let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any]
        else {
            return []
        }
        
        return imageProperties.map { key, value in
            (key as String, String(describing: value))
        }
    }
}

#Preview {
    ImageDropView()
}
