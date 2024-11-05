import SwiftUI
import UniformTypeIdentifiers

struct ImageDropView: View {
    @State private var droppedImage: NSImage? = nil
    @State private var imageMetadata: [String: Any] = [:]
    @State private var isTargeted = false
    
    var body: some View {
        VStack {
            Group {
                if let droppedImage {
                    Image(nsImage: droppedImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Rectangle()
                        .fill(isTargeted ? .gray.opacity(0.4) : .gray.opacity(0.2))
                }
            }
            .frame(width: 300, height: 300)
            .cornerRadius(8)
            .padding()
            
            List {
                Text("Metadata count: \(flattenMetadata(imageMetadata).count)")
                
                ForEach(flattenMetadata(imageMetadata), id: \.key) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Key: \(item.key)")
                            Text("Value: \(item.value)")
                        }
                        
                        Spacer()
                        
                        Button {
                            deleteMetadata(item.key)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            
            Button("Export Image with New Metadata") {
                if let droppedImage {
                    exportImageWithMetadata(droppedImage, metadata: imageMetadata)
                } else {
                    print("Could not export image with new metadata")
                }
            }
            .padding()
            .disabled(droppedImage == nil)
        }
        .onDrop(of: ["public.file-url"], isTargeted: $isTargeted) { providers in
            guard let item = providers.first else {
                return false
            }
            
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { data, error in
                if let error {
                    print("Error loading item: \(error.localizedDescription)")
                    return
                }
                
                guard
                    let data = data as? Data,
                    let url = URL(dataRepresentation: data, relativeTo: nil),
                    let image = NSImage(contentsOf: url)
                else {
                    print("Invalid file URL or unable to load image")
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
    
    private func deleteMetadata(_ key: String) {
        var keys = key.components(separatedBy: ".")
        
        guard !keys.isEmpty else {
            return
        }
        
        deleteMetadataKey(&imageMetadata, keys: &keys)
    }
    
    // Recursive helper function to delete a key from nested dictionaries
    private func deleteMetadataKey(_ dict: inout [String: Any], keys: inout [String]) {
        let currentKey = keys.removeFirst()
        
        if keys.isEmpty {
            dict.removeValue(forKey: currentKey)
        } else {
            if var nestedDict = dict[currentKey] as? [String: Any] {
                deleteMetadataKey(&nestedDict, keys: &keys)
                dict[currentKey] = nestedDict
            }
        }
    }
    
    // Function to flatten metadata dictionary
    private func flattenMetadata(_ metadata: [String: Any], parentKey: String = "") -> [(key: String, value: String)] {
        var flatMetadata: [(key: String, value: String)] = []
        
        for (key, value) in metadata {
            let newKey = parentKey.isEmpty ? key : "\(parentKey).\(key)"
            
            if let dict = value as? [String: Any] {
                flatMetadata.append(contentsOf: flattenMetadata(dict, parentKey: newKey))
            } else {
                flatMetadata.append((key: newKey, value: String(describing: value)))
            }
        }
        
        return flatMetadata
    }
    
    // Extract metadata from image URL
    private func extractMetadata(from url: URL) -> [String: Any] {
        guard
            let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any]
        else {
            return [:]
        }
        
        return imageProperties
    }
    
    private func exportImageWithMetadata(_ image: NSImage, metadata: [String: Any]) {
        let savePanel = NSSavePanel()
        
        savePanel.allowedContentTypes = [.jpeg] // Only allow JPEG files
        savePanel.nameFieldStringValue = "ModifiedImage.jpg" // Default name
        
        // Show the save panel to the user
        savePanel.begin { result in
            if result == .OK, let destinationURL = savePanel.url {
                // Ensure the file has a .jpg extension
                var destinationURLWithExtension = destinationURL
                
                if destinationURL.pathExtension.lowercased() != "jpg" && destinationURL.pathExtension.lowercased() != "jpeg" {
                    destinationURLWithExtension = destinationURL.appendingPathExtension("jpg")
                }
                
                // Get CGImage from NSImage
                guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    print("Failed to get CGImage from NSImage")
                    return
                }
                
                // Create image destination
                guard let imageDestination = CGImageDestinationCreateWithURL(destinationURLWithExtension as CFURL, kUTTypeJPEG, 1, nil) else {
                    print("Failed to create image destination")
                    return
                }
                
                // Add the image to the destination with the new metadata
                CGImageDestinationAddImage(imageDestination, cgImage, metadata as CFDictionary)
                
                // Finalize and save the file
                if CGImageDestinationFinalize(imageDestination) {
                    print("Image successfully saved with new metadata to \(destinationURLWithExtension.path)")
                } else {
                    print("Failed to finalize the image destination")
                }
            } else {
                print("User canceled the save panel or invalid URL")
            }
        }
    }
}

#Preview {
    ImageDropView()
}
