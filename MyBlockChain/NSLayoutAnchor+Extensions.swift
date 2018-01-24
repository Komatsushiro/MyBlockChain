import UIKit

extension UIView {
    public func anchor() -> Anchor { return Anchor(view: self) }
}

public struct Anchor {
    public let view: UIView
    public let top: NSLayoutConstraint?
    public let left: NSLayoutConstraint?
    public let bottom: NSLayoutConstraint?
    public let right: NSLayoutConstraint?
    public let height: NSLayoutConstraint?
    public let width: NSLayoutConstraint?
    public let centerX: NSLayoutConstraint?
    public let centerY: NSLayoutConstraint?

    fileprivate init(view: UIView) {
        self.view = view
        top = nil
        left = nil
        bottom = nil
        right = nil
        height = nil
        width = nil
        centerX = nil
        centerY = nil
    }

    private init(
        view: UIView,
        top: NSLayoutConstraint?,
        left: NSLayoutConstraint?,
        bottom: NSLayoutConstraint?,
        right: NSLayoutConstraint?,
        height: NSLayoutConstraint?,
        width: NSLayoutConstraint?,
        centerX: NSLayoutConstraint?,
        centerY: NSLayoutConstraint?) {
        self.view = view
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
        self.height = height
        self.width = width
        self.centerX = centerX
        self.centerY = centerY
    }

    private func update(
        edge: NSLayoutAttribute,
        constraint: NSLayoutConstraint?,
        priority: UILayoutPriority? = nil) -> Anchor {
        var top = self.top
        var left = self.left
        var bottom = self.bottom
        var right = self.right
        var height = self.height
        var width = self.width
        var centerX = self.centerX
        var centerY = self.centerY

        constraint?.priority = priority ?? .defaultHigh

        switch edge {
        case .top: top = constraint
        case .left: left = constraint
        case .bottom: bottom = constraint
        case .right: right = constraint
        case .height: height = constraint
        case .width: width = constraint
        case .centerX: centerX = constraint
        case .centerY: centerY = constraint
        default: return self
        }

        return Anchor(
            view: self.view,
            top: top,
            left: left,
            bottom: bottom,
            right: right,
            height: height,
            width: width,
            centerX: centerX,
            centerY: centerY)
    }

    private func insert(anchor: Anchor) -> Anchor {
        return Anchor(
            view: self.view,
            top: anchor.top ?? top,
            left: anchor.left ?? left,
            bottom: anchor.bottom ?? bottom,
            right: anchor.right ?? right,
            height: anchor.height ?? height,
            width: anchor.width ?? width,
            centerX: anchor.centerX ?? centerX,
            centerY: anchor.centerY ?? centerY)
    }

    // MARK: Anchor to superview edges
    public func topToSuperview(constant c: CGFloat = 0) -> Anchor {
        guard let superview = view.superview else {
            return self
        }
        return top(to: superview.topAnchor, constant: c)
    }

    public func leftToSuperview(constant c: CGFloat = 0) -> Anchor {
        guard let superview = view.superview else {
            return self
        }
        return left(to: superview.leftAnchor, constant: c)
    }

    public func bottomToSuperview(constant c: CGFloat = 0) -> Anchor {
        guard let superview = view.superview else {
            return self
        }
        return bottom(to: superview.bottomAnchor, constant: c)
    }

    public func rightToSuperview(constant c: CGFloat = 0) -> Anchor {
        guard let superview = view.superview else {
            return self
        }
        return right(to: superview.rightAnchor, constant: c)
    }

    public func edgesToSuperview(
        omitEdge e: NSLayoutAttribute = .notAnAttribute,
        insets: UIEdgeInsets = .zero) -> Anchor {
        let superviewAnchors = topToSuperview(constant: insets.top)
            .leftToSuperview(constant: insets.left)
            .bottomToSuperview(constant: insets.bottom)
            .rightToSuperview(constant: insets.right)
            .update(edge: e, constraint: nil)
        return self.insert(anchor: superviewAnchors)
    }

    // MARK: Anchor to superview axises
    public func centerXToSuperview() -> Anchor {
        guard let superview = view.superview else {
            return self
        }
        return centerX(to: superview.centerXAnchor)
    }

    public func centerYToSuperview() -> Anchor {
        guard let superview = view.superview else {
            return self
        }
        return centerY(to: superview.centerYAnchor)
    }

    public func centerToSuperview() -> Anchor {
        guard let superview = view.superview else {
            return self
        }
        return centerX(to: superview.centerXAnchor)
            .centerY(to: superview.centerYAnchor)
    }

    // MARK: Anchor to
    public func top(to anchor: NSLayoutYAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .top, constraint: view.topAnchor.constraint(
            equalTo: anchor, constant: c))
    }

    public func left(to anchor: NSLayoutXAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .left, constraint: view.leftAnchor.constraint(
            equalTo: anchor, constant: c))
    }

    public func bottom(to anchor: NSLayoutYAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .bottom, constraint: view.bottomAnchor.constraint(
            equalTo: anchor, constant: c))
    }

    public func right(to anchor: NSLayoutXAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .right, constraint: view.rightAnchor.constraint(
            equalTo: anchor, constant: c))
    }

    // MARK: Anchor greaterOrEqual
    public func top(greaterOrEqual anchor: NSLayoutYAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .top, constraint: view.topAnchor.constraint(
            greaterThanOrEqualTo: anchor, constant: c))
    }

    public func left(greaterOrEqual anchor: NSLayoutXAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .left, constraint: view.leftAnchor.constraint(
            greaterThanOrEqualTo: anchor, constant: c))
    }

    public func bottom(greaterOrEqual anchor: NSLayoutYAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .bottom, constraint: view.bottomAnchor.constraint(
            greaterThanOrEqualTo: anchor, constant: c))
    }

    public func right(greaterOrEqual anchor: NSLayoutXAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .right, constraint: view.rightAnchor.constraint(
            greaterThanOrEqualTo: anchor, constant: c))
    }

    // MARK: Anchor lessOrEqual
    public func top(lesserOrEqual anchor: NSLayoutYAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .top, constraint: view.topAnchor.constraint(
            lessThanOrEqualTo: anchor, constant: c))
    }

    public func left(lesserOrEqual anchor: NSLayoutXAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .left, constraint: view.leftAnchor.constraint(
            lessThanOrEqualTo: anchor, constant: c))
    }

    public func bottom(lesserOrEqual anchor: NSLayoutYAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .bottom, constraint: view.bottomAnchor.constraint(
            lessThanOrEqualTo: anchor, constant: c))
    }

    public func right(lesserOrEqual anchor: NSLayoutXAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .right, constraint: view.rightAnchor.constraint(
            lessThanOrEqualTo: anchor, constant: c))
    }

    // MARK: Dimension anchors
    public func height(constant c: CGFloat, priority: UILayoutPriority? = nil) -> Anchor {
        return update(edge: .height, constraint: view.heightAnchor.constraint(equalToConstant: c), priority: priority)
    }

    public func height(to dimension: NSLayoutDimension, multiplier m: CGFloat = 1) -> Anchor {
        return update(edge: .height, constraint: view.heightAnchor.constraint(equalTo: dimension, multiplier: m))
    }

    public func width(constant c: CGFloat, priority: UILayoutPriority? = nil) -> Anchor {
        return update(edge: .width, constraint: view.widthAnchor.constraint(equalToConstant: c), priority: priority)
    }

    public func width(to dimension: NSLayoutDimension, multiplier m: CGFloat = 1) -> Anchor {
        return update(edge: .width, constraint: view.widthAnchor.constraint(
            equalTo: dimension, multiplier: m))
    }

    // MARK: Axis anchors
    public func centerX(to axis: NSLayoutXAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .centerX, constraint: view.centerXAnchor.constraint(
            equalTo: axis, constant: c))
    }

    public func centerY(to axis: NSLayoutYAxisAnchor, constant c: CGFloat = 0) -> Anchor {
        return update(edge: .centerY, constraint: view.centerYAnchor.constraint(
            equalTo: axis, constant: c))
    }

    // MARK: Activation
    public func activate(priority: UILayoutPriority? = nil) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [top, left, bottom, right, height, width, centerX, centerY].flatMap { constraint -> NSLayoutConstraint? in
            let _constraint = constraint
            if priority != nil {
                _constraint?.priority = priority!
            }
            return _constraint
        }
        NSLayoutConstraint.activate(constraints)
    }
}

