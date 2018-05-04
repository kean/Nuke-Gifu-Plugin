# Nuke Gifu Plugin

<p align="left">
<img src="https://img.shields.io/badge/platforms-iOS-lightgrey.svg">
</p>


[Gifu](https://github.com/kaishin/Gifu) plugin for [Nuke](https://github.com/kean/Nuke) that allows you to load and display animated GIFs. You can see it for yourself in a demo, included in the project.

> **Deprecated:** Gifu is still supported, but the plugin itself is no longer necessary - you can configure Nuke to work with Gifu with 8 lines of code.

## Usage

All you need to do to enable GIF support is set `isAnimatedImageDataEnabled` to `true` and override `display(image:)` method on `Gifu.GIFImageView`:

```swift
ImagePipeline.Configuration.isAnimatedImageDataEnabled = true

extension Gifu.GIFImageView {
    public override func display(image: Image?) {
        prepareForReuse()
        if let data = image?.animatedImageData {
            animate(withGIFData: data)
        } else {
            self.image = image
        }
    }
}
```

After you do that, you can start using `Gifu.GIFImageView`:

```swift
let view = Gifu.GIFImageView()
Nuke.loadImage(with: URL(string: "http://.../cat.gif")!, into: view)
```

## Installation

There is no installation required.

## Requirements

- iOS 9
- Xcode 9.3
- Swift 4.1

## Dependencies

- [Nuke 7](https://github.com/kean/Nuke)
- [Gifu 3](https://github.com/kaishin/Gifu)

## License

Nuke is available under the MIT license. See the LICENSE file for more info.
