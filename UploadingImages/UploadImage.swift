import UIKit

enum DownloadOptions: Hashable {
    enum From: Hashable {
        case disk
        case memory
    }

    case circle
    case cached(From)
    case resize
}

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

protocol Downloadable {
    func loadImage(from url: URL, withOptions options: [DownloadOptions])
}

extension Downloadable where Self: UIImageView {
    func loadImage(from url: URL, withOptions options: [DownloadOptions]) {
        let uniqueOptions = Array(Set(options))
        
        let viewModel = ImageViewModel(downloadOptions: uniqueOptions)
        
        viewModel.fetchImage(for: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
}
