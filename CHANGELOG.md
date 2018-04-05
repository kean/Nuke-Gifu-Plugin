# Nuke Gifu Plugin 3.0

A primary focus of this release is to update the project to Swift 4.1.  **Requires a few small migrations steps**. See the list of changes for more info:

## Updated to Swift 4.1

Removed `AnimatedImage` class which was `UIImage` subclass and caused [all sorts of problems](https://github.com/kean/Nuke-Gifu-Plugin/issues/7) while upgrading to new Swift versions.

<hr/>

Removed:

```swift
public class AnimatedImage: UIImage {
    public let data: Data
    public init(data: Data, poster: CGImage)
}
```

Added (please use instead):

```swift
extension UIImage {
    // Animated image data. Only not `nil` when image data actually contains
    // an animated image.
    public var animatedImageData: Data? { get set }
}
```

<hr/>

Removed:

```swift
extension AnimatedImage {
    /// Default `Nuke.Manager` with animated GIF support.
    public let manager: Nuke.Manager { get }
}
```

Added (please use instead):

```swift
extension Nuke.Manager {
    /// Default `Nuke.Manager` with animated GIF support.
    public let animatedImageManager: Nuke.Manager { get }
}
```

## Other Changes

- Update demo to Swift 4.1
- Replace `Nuke.Cache` method `func preparedForAnimatedImages() -> Self` with `func prepareForAnimatedImages()` which makes it clear that the API doesn't return a new instance.
- Add `Nuke.Loader.Options` method `func prepareForAnimatedImages()` symmetric to existing cache extension.


# Nuke Gifu Plugin 2.0

- Updated to Nuke 6, Gifu 3

# Nuke Gifu Plugin 1.0

- Updated to Nuke 5.0

# Nuke Gifu Plugin 0.2

- Updated to Gifu 2.0

# Nuke Gifu Plugin 0.1

- Initial version
