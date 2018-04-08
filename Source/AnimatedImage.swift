// The MIT License (MIT)
//
// Copyright (c) 2016-2018 Alexander Grebenyuk (github.com/kean).

import UIKit
import Gifu
import Nuke

private var _animatedImageDataAK = "Manager.Context.AssociatedKey"

extension UIImage {
    // Animated image data. Only not `nil` when image data actually contains
    // an animated image.
    public var animatedImageData: Data? {
        get { return objc_getAssociatedObject(self, &_animatedImageDataAK) as? Data }
        set { objc_setAssociatedObject(self, &_animatedImageDataAK, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension Nuke.Manager {
    /// `Nuke.Manager` with animated GIF support.
    public static let animatedImageManager: Nuke.Manager = {
        // Make a decoder which supports animated GIFs.
        let decoder = Nuke.DataDecoderComposition(decoders: [AnimatedImageDecoder(), Nuke.DataDecoder()])

        let cache = Nuke.Cache()
        cache.prepareForAnimatedImages()

        var options = Nuke.Loader.Options()
        options.prepareForAnimatedImages()

        let loader = Nuke.Loader(loader: Nuke.DataLoader(), decoder: decoder, options: options)

        return Manager(loader: loader, cache: cache)
    }()
}

/// Creates instances of `AnimatedImage` class from the given data.
/// Returns `nil` is data doesn't contain an animated GIF.
public class AnimatedImageDecoder: Nuke.DataDecoding {
    public init() {}
    
    public func decode(data: Data, response: URLResponse) -> Nuke.Image? {
        guard self.isAnimatedGIFData(data), let image = UIImage(data: data) else {
            return nil
        }
        image.animatedImageData = data
        return image
    }
    
    public func isAnimatedGIFData(_ data: Data) -> Bool {
        let sigLength = 3
        if data.count < sigLength {
            return false
        }
        var sig = [UInt8](repeating: 0, count: sigLength)
        (data as NSData).getBytes(&sig, length:sigLength)
        return sig[0] == 0x47 && sig[1] == 0x49 && sig[2] == 0x46
    }
}

/// Simple `Gifu.GIFImageView` wrapper that implement `Nuke.Target` protocol.
///
/// The reason why this is a standalone class and not a simple overridden method
/// from `UIImageView` extension is because declarations from extensions
/// cannot be overridden in Swift (yet).
open class AnimatedImageView: UIView, Nuke.Target {
    public let imageView: Gifu.GIFImageView
    
    public init(imageView: Gifu.GIFImageView = Gifu.GIFImageView()) {
        self.imageView = imageView
        super.init(frame: CGRect.zero)
        prepare()
    }

    required public init?(coder aDecoder: NSCoder) {
        self.imageView = Gifu.GIFImageView()
        super.init(coder: aDecoder)
        prepare()
    }

    /// Common init.
    private func prepare() {
        addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        for attr in [.top, .leading, .bottom, .trailing] as [NSLayoutAttribute] {
            addConstraint(NSLayoutConstraint(item: imageView, attribute: attr, relatedBy: .equal, toItem: self, attribute: attr, multiplier: 1, constant: 0))
        }
    }

    public func prepareForReuse() {
        imageView.prepareForReuse()
        imageView.image = nil
    }
    
    /// Displays an image on success. Runs `opacity` transition if
    /// the response was not from the memory cache.
    public func handle(response: Result<Image>, isFromMemoryCache: Bool) {
        guard let image = response.value else { return }
        imageView.prepareForReuse()
        if let data = image.animatedImageData {
            imageView.animate(withGIFData: data)
        } else {
            imageView.image = image
        }
        if !isFromMemoryCache {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 0.25
            animation.fromValue = 0
            animation.toValue = 1
            let layer: CALayer? = imageView.layer // Make compiler happy on OSX
            layer?.add(animation, forKey: "imageTransition")
        }
    }
}

public extension Nuke.Loader.Options {
    /// Disables processing of animated images by setting `processor` closure.
    public mutating func prepareForAnimatedImages () {
        // Disable processing of animated images.
        processor = { image, request in
            return (image.animatedImageData != nil) ? nil : request.processor
        }
    }
}

public extension Nuke.Cache {
    /// Updates `Cache` cost closure by adding special handling of `AnimatedImage`.
    public func prepareForAnimatedImages () {
        let cost = self.cost
        self.cost = {
            guard let data = $0.animatedImageData else {
                return cost($0) // Simply return default cost.
            }
            return cost($0) + data.count // Return cost + animated image data size.
        }
    }
}
