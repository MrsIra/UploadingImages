import Foundation
import UIKit

class ImageViewModel {
    private let downloadOptions: [DownloadOptions]
    private var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var images: [ImageModel] = []
    
    init(downloadOptions: [DownloadOptions]) {
        self.downloadOptions = downloadOptions
        loadRandomImages {
            
        }
    }
    
    func loadRandomImages(completion: @escaping () -> Void) {
        let imageUrls = [
            "https://meradog.ru/upload/pictures/2105111304509753_big.jpg",
            "https://i.pinimg.com/736x/f2/7e/e3/f27ee343b5c565993cea14f35fe77c11.jpg",
            "https://avatars.mds.yandex.net/i?id=620a34cebc3874fce678f6eece507df2_l-5173410-images-thumbs&n=13",
            "https://i.pinimg.com/originals/8f/8a/6f/8f8a6f34b79c9b925a9592ede75a6d95.jpg",
            "https://i.pinimg.com/originals/5f/13/25/5f132534cabaf9f1ad0a78adb981d549.jpg",
            "https://mylomaniya.ru/wp-content/uploads/2021/06/1612566098_1-p-yabloki-fon-zelenie-1.jpg",
            "https://avatars.mds.yandex.net/i?id=110ad05278b20951731a185464a35089_l-5435026-images-thumbs&n=13",
            "https://m.media-amazon.com/images/M/MV5BMzQ4YTkxYWMtMTE0Yy00ZDBhLTg2YzAtNjE2YjVlZGM5OTUwXkEyXkFqcGdeQXVyNTc5OTMwOTQ@._V1_.jpg"
        ]
        
        self.images = (0..<64).map { _ in
            let url = imageUrls.randomElement()!
            return ImageModel(url: URL(string: url)!, options: downloadOptions)
        }
        completion()
    }

    func fetchImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data, let image = UIImage(data: data) else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let processedImage = self.processImage(image)
            
            self.imageCache.setObject(processedImage, forKey: url.absoluteString as NSString)
            
            completion(processedImage)
        }.resume()
    }
    
    private func processImage(_ image: UIImage) -> UIImage {
        var processedImage = image
        for option in self.downloadOptions {
            switch option {
            case .circle:
                processedImage = processedImage.rounded()
            case .resize:
                processedImage = processedImage.resized(to: CGSize(width: 80, height: 80))
            default:
                break
            }
        }
        return processedImage
    }
}
