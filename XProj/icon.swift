import Foundation

func icon(_ platform: String) -> String {
    switch platform {
    case "iOS": "iphone"
    case "macOS": "macbook"
    case "watchOS": "applewatch"
    case "tvOS": "tv"
    case "visionOS": "vision.pro"
    default: ""
    }
}
