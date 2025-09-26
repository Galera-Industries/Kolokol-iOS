//
//  Adjusted.swift
//  Kolokol
//
//  Created by Tom Tim on 25.09.2025.
//

import UIKit

// MARK: - UILabel
public final class AdjustedLabel: UILabel {
    public var verticalShift: CGFloat {
        didSet { setNeedsDisplay() }
    }

    public var extraTopPadding: CGFloat { didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() } }
    public var extraBottomPadding: CGFloat { didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() } }

    public init(verticalShift: CGFloat = 0, extraTopPadding: CGFloat = 0, extraBottomPadding: CGFloat = 0) {
        self.verticalShift = verticalShift
        self.extraTopPadding = extraTopPadding
        self.extraBottomPadding = extraBottomPadding
        super.init(frame: .zero)
        isOpaque = false
        contentMode = .redraw
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("Use init(verticalShift:)") }

    public override func drawText(in rect: CGRect) {
        let padded = rect.inset(by: UIEdgeInsets(top: extraTopPadding, left: 0, bottom: extraBottomPadding, right: 0))
        let shifted = padded.offsetBy(dx: 0, dy: verticalShift)
        super.drawText(in: shifted)
    }

    public override var intrinsicContentSize: CGSize {
        var sz = super.intrinsicContentSize
        sz.height += (extraTopPadding + extraBottomPadding)
        return sz
    }
}

import UIKit

public final class AdjustedTextField: UITextField {
    public var glyphShift: CGFloat {
        didSet { setNeedsLayout(); setNeedsDisplay() }
    }

    public var caretShift: CGFloat? {
        didSet { setNeedsLayout() }
    }

    /// Доп. инкеты внутри поля (влияют на text/placeholder/editing rect).
    public var contentInsets: UIEdgeInsets {
        didSet { invalidateIntrinsicContentSize(); setNeedsLayout() }
    }

    /// Сдвигать ли leftView/rightView вертикально вместе с текстом (по умолчанию true)
    public var accessoriesFollowGlyph: Bool {
        didSet { setNeedsLayout() }
    }

    /// Сдвигать ли кнопку очистки вместе с текстом (по умолчанию true)
    public var clearButtonFollowsGlyph: Bool {
        didSet { setNeedsLayout() }
    }

    /// При желании можно задать отдельный сдвиг для плейсхолдера (если nil — = glyphShift)
    public var placeholderGlyphShift: CGFloat? {
        didSet { setNeedsLayout(); setNeedsDisplay() }
    }

    // MARK: - Init
    public init(glyphShift: CGFloat = 0,
                caretShift: CGFloat? = nil,
                contentInsets: UIEdgeInsets = .zero,
                accessoriesFollowGlyph: Bool = true,
                clearButtonFollowsGlyph: Bool = true) {
        self.glyphShift = glyphShift
        self.caretShift = caretShift
        self.contentInsets = contentInsets
        self.accessoriesFollowGlyph = accessoriesFollowGlyph
        self.clearButtonFollowsGlyph = clearButtonFollowsGlyph
        super.init(frame: .zero)
        contentVerticalAlignment = .center
        borderStyle = .roundedRect
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("Use init(...) without storyboard") }

    // MARK: - Geometry helpers
    private func applyInsetsAndShift(_ rect: CGRect, shiftY: CGFloat) -> CGRect {
        rect.inset(by: contentInsets).offsetBy(dx: 0, dy: shiftY)
    }

    private var effectiveCaretShift: CGFloat { caretShift ?? -glyphShift }
    private var effectivePlaceholderShift: CGFloat { placeholderGlyphShift ?? glyphShift }

    // MARK: - Text/placeholder rects
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        applyInsetsAndShift(super.textRect(forBounds: bounds), shiftY: glyphShift)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        applyInsetsAndShift(super.editingRect(forBounds: bounds), shiftY: glyphShift)
    }

    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        applyInsetsAndShift(super.placeholderRect(forBounds: bounds), shiftY: effectivePlaceholderShift)
    }

    // MARK: - Caret
    public override func caretRect(for position: UITextPosition) -> CGRect {
        super.caretRect(for: position).offsetBy(dx: 0, dy: effectiveCaretShift)
    }

    // MARK: - Accessories (left/right/clear)
    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var r = super.leftViewRect(forBounds: bounds)
        if accessoriesFollowGlyph { r.origin.y += glyphShift }
        return r
    }

    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var r = super.rightViewRect(forBounds: bounds)
        if accessoriesFollowGlyph { r.origin.y += glyphShift }
        return r
    }

    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var r = super.clearButtonRect(forBounds: bounds)
        if clearButtonFollowsGlyph { r.origin.y += glyphShift }
        return r
    }

    // MARK: - Intrinsic size (учитываем contentInsets по высоте)
    public override var intrinsicContentSize: CGSize {
        var s = super.intrinsicContentSize
        s.height += contentInsets.top + contentInsets.bottom
        return s
    }
}

private final class OffsetLayoutManager: NSLayoutManager {
    var glyphYOffset: CGFloat = 0

    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let o = CGPoint(x: origin.x, y: origin.y + glyphYOffset)
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: o)
    }

    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let o = CGPoint(x: origin.x, y: origin.y + glyphYOffset)
        super.drawBackground(forGlyphRange: glyphsToShow, at: o)
    }
}

public final class AdjustedTextView: UITextView {
    public var glyphShift: CGFloat {
        didSet { offsetLM.glyphYOffset = glyphShift; setNeedsDisplay() }
    }

    public var caretShift: CGFloat {
        didSet { setNeedsLayout() }
    }

    private let offsetLM: OffsetLayoutManager

    public init(glyphShift: CGFloat = 0, caretShift: CGFloat = 0) {
        let storage = NSTextStorage()
        let lm = OffsetLayoutManager()
        let container = NSTextContainer(size: .zero)
        container.widthTracksTextView = true
        container.heightTracksTextView = true
        storage.addLayoutManager(lm)
        lm.addTextContainer(container)

        self.glyphShift = glyphShift
        self.caretShift = caretShift
        self.offsetLM = lm

        super.init(frame: .zero, textContainer: container)

        lm.glyphYOffset = glyphShift
        backgroundColor = .clear
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("Use init(glyphShift:caretShift:)") }

    public override func caretRect(for position: UITextPosition) -> CGRect {
        super.caretRect(for: position).offsetBy(dx: 0, dy: caretShift)
    }
}
