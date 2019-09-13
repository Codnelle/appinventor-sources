// -*- mode: swift; swift-mode:basic-offset: 2; -*-
// Copyright © 2016-2019 Massachusetts Institute of Technology, All rights reserved.

import Foundation

private let kHorizontalCenterLeadingConstraint = "HCenterLeadingConstraint"
private let kHorizontalCenterTrailingConstraint = "HCenterTrailingConstraint"
private let kVerticalCenterLeadingConstraint = "VCenterLeadingConstraint"
private let kVerticalCenterTrailingConstraint = "VCenterTrailingConstraint"
private let kComponentKitConstraint = "AIComponentKitConstraint"

open class HVArrangement: ViewComponent, ComponentContainer, AbstractMethodsForViewComponent {
  fileprivate var _components: [ViewComponent] = [ViewComponent]()
  fileprivate var _view = LinearView()
  fileprivate var _orientation = HVOrientation.vertical
  fileprivate var _horizontalAlign = HorizontalGravity.left
  fileprivate var _verticalAlign = VerticalGravity.top
  fileprivate var _backgroundColor = UIColor.white
  fileprivate var _imagePath = ""
  fileprivate var _lastConstraint: NSLayoutConstraint! = nil
  private var _dimensions = [Int:NSLayoutConstraint]()

  public init(_ parent: ComponentContainer, orientation: HVOrientation, scrollable: Bool) {
    _orientation = orientation
    super.init(parent)
    _view.translatesAutoresizingMaskIntoConstraints = false
    _view.orientation = orientation
    _view.scrollEnabled = scrollable
    super.setDelegate(self)
    parent.add(self)
    Width = -1
    Height = -1
  }

  // MARK: AbstractMethodsForViewComponent protocol implementation
  open override var view: UIView {
    get {
      return _view
    }
  }

  // MARK: ComponentContainer protocol implementation
  open var form: Form {
    get {
      return _container.form
    }
  }

  open func add(_ component: ViewComponent) {
    _components.append(component)
    _view.addItem(LinearViewItem(component.view))
  }

  open func setChildWidth(of component: ViewComponent, to width: Int32) {
    if width <= kLengthPercentTag {
      _view.setWidth(of: component.view, to: Length(percent: width, of: form.scaleFrameLayout))
    } else if width == kLengthPreferred {
      _view.setWidth(of: component.view, to: .Automatic)
    } else if width == kLengthFillParent {
      _view.setWidth(of: component.view, to: .FillParent)
    } else {
      _view.setWidth(of: component.view, to: Length(pixels: width))
    }
    _view.setNeedsLayout()
  }

  open func setChildHeight(of component: ViewComponent, to height: Int32) {
    if height <= kLengthPercentTag {
      _view.setHeight(of: component.view, to: Length(percent: height, of: form.scaleFrameLayout))
    } else if height == kLengthPreferred {
      _view.setHeight(of: component.view, to: .Automatic)
    } else if height == kLengthFillParent {
      _view.setHeight(of: component.view, to: .FillParent)
    } else {
      _view.setHeight(of: component.view, to: Length(pixels: height))
    }
    _view.setNeedsLayout()
  }

  // MARK: HVArrangement Properties
  @objc open var AlignHorizontal: Int32 {
    get {
      return _horizontalAlign.rawValue
    }
    set(align) {
      if let align = HorizontalGravity(rawValue: align) {
        _horizontalAlign = align
        _view.horizontalAlignment = align
        _view.setNeedsUpdateConstraints()
        _view.setNeedsLayout()
      }
    }
  }

  @objc open var AlignVertical: Int32 {
    get {
      return _verticalAlign.rawValue
    }
    set(align) {
      if let align = VerticalGravity(rawValue: align) {
        _verticalAlign = align
        _view.verticalAlignment = align
        _view.setNeedsUpdateConstraints()
        _view.setNeedsLayout()
      }
    }
  }

  @objc open var BackgroundColor: Int32 {
    get {
      return colorToArgb(_backgroundColor)
    }
    set(argb) {
      _backgroundColor = argbToColor(argb)
      if _imagePath == "" {
        _view.backgroundColor = _backgroundColor
      }
    }
  }

  @objc open var Image: String {
    get {
      return _imagePath
    }
    set(path) {
      if path == _imagePath {
        // Already using this image
        return
      } else if path != "" {
        if let image = AssetManager.shared.imageFromPath(path: path) {
          _view.backgroundColor = UIColor(patternImage: image)
          return
        }
      }
      _imagePath = ""
      _view.backgroundColor = _backgroundColor
    }
  }
}
