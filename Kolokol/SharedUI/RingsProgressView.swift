import UIKit

public final class LoadingRingsView: UIView {
    public var lineWidth: CGFloat = 3 { didSet { rings.forEach { $0.lineWidth = lineWidth } } }
    public var colors: [UIColor] = [
        .red.withAlphaComponent(0.95),
        .red.withAlphaComponent(0.7),
        .red.withAlphaComponent(0.5)
    ] { didSet { applyColors() } }
    public var cycleDuration: CFTimeInterval = 2.0 { didSet { if isAnimating { stop(); start() } } }
    public var spinDurations: (outer: CFTimeInterval, middle: CFTimeInterval, inner: CFTimeInterval) = (2.0, 1.0, 0.5) {
        didSet { if isAnimating { startSpins() } }
    }

    public private(set) var isAnimating = false

    // MARK: Layers
    private let outer = CAShapeLayer()
    private let middle = CAShapeLayer()
    private let inner = CAShapeLayer()
    private var rings: [CAShapeLayer] { [outer, middle, inner] }

    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        rings.forEach { l in
            l.fillColor = UIColor.clear.cgColor
            l.strokeColor = UIColor.label.cgColor
            l.lineCap = .round
            l.lineJoin = .round
            l.strokeStart = 0
            l.strokeEnd = 0
            l.lineWidth = lineWidth
            layer.addSublayer(l)
        }
        applyColors()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutRings()
    }

    private func layoutRings() {
        let side = min(bounds.width, bounds.height)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let maxR = side * 0.5
        let radii: [CGFloat] = [0.95, 0.72, 0.49].map { $0 * maxR }
        for (r, l) in zip(radii, rings) {
            l.frame = bounds
            l.path = UIBezierPath(arcCenter: center,
                                  radius: r,
                                  startAngle: 0, endAngle: 2 * .pi,
                                  clockwise: true).cgPath
        }
    }

    private func applyColors() {
        for (i, l) in rings.enumerated() {
            let c = colors.indices.contains(i) ? colors[i] : colors[i % max(1, colors.count)]
            l.strokeColor = c.cgColor
        }
    }

    // MARK: Control
    public func start() {
        guard !isAnimating else { return }
        isAnimating = true
        reset()
        startTimeline()
        startSpins()
    }

    public func stop() {
        guard isAnimating else { return }
        isAnimating = false
        rings.forEach { $0.removeAllAnimations() }
        reset()
    }

    private func reset() {
        rings.forEach { l in
            l.strokeStart = 0
            l.strokeEnd = 0
        }
    }

    // MARK: Animations
    private func startTimeline() {
        let T = max(0.1, cycleDuration)

        let t0: CGFloat = 0.00
        let t1: CGFloat = 0.15
        let tOuterFill80End: CGFloat = 0.25
        let t2: CGFloat = 0.45
        let t3: CGFloat = 0.65
        let t4: CGFloat = 0.80
        let t5: CGFloat = 1.00

        let outerEnd = CAKeyframeAnimation(keyPath: "strokeEnd")
        outerEnd.values   = [0.0, 0.5, 0.8, 0.8]
        outerEnd.keyTimes = [t0,  t1,  tOuterFill80End, t5] as [NSNumber]
        outerEnd.calculationMode = .linear
        outerEnd.duration = T
        outerEnd.repeatCount = .infinity
        outerEnd.isRemovedOnCompletion = false
        outerEnd.fillMode = .forwards

        let outerStart = CAKeyframeAnimation(keyPath: "strokeStart")
        outerStart.values   = [0.0, 0.0, 0.8, 0.8]
        outerStart.keyTimes = [t0,  t2,  t2 + 0.25,    t5] as [NSNumber]
        outerStart.calculationMode = .linear
        outerStart.duration = T
        outerStart.repeatCount = .infinity
        outerStart.isRemovedOnCompletion = false
        outerStart.fillMode = .forwards

        outer.add(outerEnd, forKey: "outer_end")
        outer.add(outerStart, forKey: "outer_start")

        let midEnd = CAKeyframeAnimation(keyPath: "strokeEnd")
        midEnd.values   = [0.0, 0.0, 0.8, 0.8]
        midEnd.keyTimes = [t0,  t1,  t2,  t5] as [NSNumber]
        midEnd.calculationMode = .linear
        midEnd.duration = T
        midEnd.repeatCount = .infinity
        midEnd.isRemovedOnCompletion = false
        midEnd.fillMode = .forwards

        let midStart = CAKeyframeAnimation(keyPath: "strokeStart")
        midStart.values   = [0.0, 0.0, 0.8, 0.8]
        midStart.keyTimes = [t0,  t3,  t3 + 0.30,   t5] as [NSNumber]
        midStart.calculationMode = .linear
        midStart.duration = T
        midStart.repeatCount = .infinity
        midStart.isRemovedOnCompletion = false
        midStart.fillMode = .forwards

        middle.add(midEnd, forKey: "mid_end")
        middle.add(midStart, forKey: "mid_start")

        let innerEnd = CAKeyframeAnimation(keyPath: "strokeEnd")
        innerEnd.values   = [0.0, 0.0, 0.8, 0.8]
        innerEnd.keyTimes = [t0,  t2,  t3,  t5] as [NSNumber]
        innerEnd.calculationMode = .linear
        innerEnd.duration = T
        innerEnd.repeatCount = .infinity
        innerEnd.isRemovedOnCompletion = false
        innerEnd.fillMode = .forwards

        let innerStart = CAKeyframeAnimation(keyPath: "strokeStart")
        innerStart.values   = [0.0, 0.0, 0.8, 0.8]
        innerStart.keyTimes = [t0,  t4,  t4 + 0.20,   t5] as [NSNumber]
        innerStart.calculationMode = .linear
        innerStart.duration = T
        innerStart.repeatCount = .infinity
        innerStart.isRemovedOnCompletion = false
        innerStart.fillMode = .forwards

        inner.add(innerEnd, forKey: "inner_end")
        inner.add(innerStart, forKey: "inner_start")
    }

    private func startSpins() {
        [outer, middle, inner].forEach { $0.removeAnimation(forKey: "spin") }

        func spinAnimation(period: CFTimeInterval) -> CABasicAnimation {
            let a = CABasicAnimation(keyPath: "transform.rotation")
            a.fromValue = 0
            a.toValue = 2 * Double.pi
            a.duration = max(0.05, period)
            a.timingFunction = CAMediaTimingFunction(name: .linear)
            a.repeatCount = .infinity
            a.isRemovedOnCompletion = false
            return a
        }

        outer.add(spinAnimation(period: spinDurations.outer), forKey: "spin")
        middle.add(spinAnimation(period: spinDurations.middle), forKey: "spin")
        inner.add(spinAnimation(period: spinDurations.inner), forKey: "spin")
    }
}
