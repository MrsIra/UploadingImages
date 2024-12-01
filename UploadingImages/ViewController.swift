import UIKit

class ViewController: UIViewController {
    private let viewModel = ImageViewModel(downloadOptions: [.circle, .cached(.memory), .resize])
    private let lock = NSLock()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

private extension ViewController {
    func setupView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let imageModel = viewModel.images[indexPath.item]
        
        lock.lock()
        viewModel.fetchImage(for: imageModel.url) { image in
            DispatchQueue.main.async {
                cell.configure(with: image)
            }
        }
        lock.unlock()
        return cell
    }
}

extension UIImage {
    func rounded() -> UIImage {
        let imageRectangle = CGRect(origin: .zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let roundedPath = UIBezierPath(ovalIn: imageRectangle)
        roundedPath.addClip()
        self.draw(in: imageRectangle)
        let imageWithRoundedCorners = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithRoundedCorners ?? self
    }
    
    func resized(to targetSize: CGSize) -> UIImage {
        let imageRenderer = UIGraphicsImageRenderer(size: targetSize)
        return imageRenderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
