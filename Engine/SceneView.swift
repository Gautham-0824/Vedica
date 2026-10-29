import SwiftUI

// Easing curves from the web build.
enum Ease {
    static let xDur = 1.05
    static func x(_ delayMs: Double, _ dur: Double = xDur) -> Animation {
        .timingCurve(0.55, 0, 0.25, 1, duration: dur).delay(delayMs / 1000)
    }
    static func y(_ delayMs: Double, _ dur: Double = xDur) -> Animation {
        .timingCurve(0.25, 0.9, 0.3, 1.06, duration: dur).delay(delayMs / 1000)
    }
    static func hand() -> Animation { .timingCurve(0.45, 0, 0.2, 1, duration: 1.0) }
    static func ease(_ d: Double, _ delayMs: Double = 0) -> Animation {
        .timingCurve(0.25, 0.1, 0.25, 1, duration: d).delay(delayMs / 1000)
    }
}

struct SceneLayer: View {
    let runner: LessonRunner
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .topLeading) {
            FinaleView(f: runner.finale, on: runner.finaleOn)
            SpotView(s: runner.spot)
            ForEach(runner.boxes, id: \.vid) { b in
                BoxView(d: b, style: runner.spec.style, still: reduceMotion)
            }
            ForEach(runner.lines) { l in
                LineView(d: l)
            }
            ForEach(runner.arrows) { a in
                ArrowView(d: a)
            }
            ForEach(runner.els, id: \.vid) { e in
                GlyphView(d: e, style: runner.spec.style, still: reduceMotion)
            }
            if !runner.ringKey.isEmpty {
                RingView(x: runner.hand.x, y: runner.hand.y).id(runner.ringKey)
            }
            HandView(h: runner.hand, still: reduceMotion)
        }
        .frame(width: Canvas.w, height: Canvas.h, alignment: .topLeading)
        .offset(x: CGFloat(runner.stageShiftNow))
        .animation(reduceMotion ? nil : .timingCurve(0.32, 0.72, 0, 1, duration: 0.62), value: runner.stageShiftNow)
        .allowsHitTesting(false)
    }
}

struct LineView: View {
    let d: DLine
    var body: some View {
        let to: CGFloat = d.l.state == 0 ? 0 : 1
        let op: Double = d.l.state == 1 ? 1 : (d.l.state == 2 ? 0.2 : 0)
        Path { p in
            p.move(to: d.l.p0)
            p.addLine(to: d.l.p1)
        }
        .trim(from: 0, to: to)
        .stroke(d.l.c, style: StrokeStyle(lineWidth: 6, lineCap: .round))
        .opacity(op)
        .animation(.timingCurve(0.45, 0, 0.2, 1, duration: 1.0), value: to)
        .animation(.easeInOut(duration: 0.45), value: op)
    }
}

struct GlyphView: View {
    let d: DEl
    let style: RenderStyle
    let still: Bool
    @State private var shown = false

    var body: some View {
        let e = d.e
        let op = shown ? e.o * (d.dim ? style.dimElement : 1) : 0
        let sc = e.s * (shown ? 1 : style.newElementScale)
        let blur = d.dim ? style.blur : 0
        Text(e.t)
            .font(Theme.round(CGFloat(e.z), Theme.weight(e.w)))
            .monospacedDigit()
            .tracking(CGFloat(-0.03 * e.z))
            .foregroundColor(e.c)
            .animation(still ? nil : Ease.ease(0.42, e.dl), value: e.c)
            .fixedSize()
            .scaleEffect(CGFloat(sc))
            .animation(still ? nil : Ease.y(e.dl, style.dur), value: sc)
            .blur(radius: CGFloat(blur))
            .animation(still ? nil : Ease.ease(0.48), value: blur)
            .opacity(op)
            .animation(Ease.ease(0.62, e.od ?? e.dl), value: op)
            .frame(width: 0, height: 0)
            .offset(x: CGFloat(e.x))
            .animation(still ? nil : Ease.x(e.dl, style.dur), value: e.x)
            .offset(y: CGFloat(e.y))
            .animation(still ? nil : Ease.y(e.dl, style.dur), value: e.y)
            .onAppear { DispatchQueue.main.async { shown = true } }
    }
}

struct BoxView: View {
    let d: DBox
    let style: RenderStyle
    let still: Bool
    @State private var shown = false

    var body: some View {
        let b = d.b
        let op = shown ? b.o * (d.dim ? (b.dimTo ?? style.dimBox) : 1) : 0
        let sc = b.s * (shown ? 1 : style.newBoxScale)
        let pos = [b.x, b.y]
        let shape = RoundedRectangle(cornerRadius: CGFloat(b.r), style: .continuous)
        ZStack {
            shape.fill(b.dashed ? Color.clear : b.fill)
            if b.dashed {
                shape.stroke(b.c, style: StrokeStyle(lineWidth: 2.5, dash: [9, 7]))
            } else {
                shape.stroke(b.c, lineWidth: CGFloat(b.bw ?? 1))
            }
            if !b.q.isEmpty {
                Text(b.q)
                    .font(Theme.round(CGFloat(b.qz ?? b.h * 0.42), .heavy))
                    .foregroundColor(b.qc ?? Theme.ghost)
                    .fixedSize()
            }
        }
        .shadow(color: Theme.shadow.opacity(b.shadow ? 0.10 : 0), radius: 17, x: 0, y: 14)
        .frame(width: CGFloat(b.w), height: CGFloat(b.h))
        .scaleEffect(CGFloat(sc))
        .animation(still ? nil : Ease.y(b.dl, style.dur), value: sc)
        .opacity(op)
        .animation(Ease.ease(0.42, b.dl), value: op)
        .offset(x: CGFloat(b.x - b.w / 2), y: CGFloat(b.y - b.h / 2))
        .animation(still ? nil : Ease.y(b.dl, style.dur), value: pos)
        .onAppear { DispatchQueue.main.async { shown = true } }
    }
}

struct ArrowView: View {
    let d: DArrow
    @State private var drawn: Double

    init(d: DArrow) {
        self.d = d
        _drawn = State(initialValue: d.a.st == 1 ? 0 : 1)
    }

    var body: some View {
        let op: Double = d.a.st == 1 ? 1 : (d.a.st == 2 ? 0.4 : 0)
        d.path
            .trimmedPath(from: 0, to: CGFloat(drawn))
            .stroke(d.a.c, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            .opacity(op)
            .animation(.easeInOut(duration: 0.45), value: op)
            .onAppear {
                withAnimation(.timingCurve(0.45, 0, 0.2, 1, duration: 0.9).delay(d.a.dl / 1000)) { drawn = 1 }
            }
    }
}

struct SpotView: View {
    let s: Spot
    var body: some View {
        Ellipse()
            .fill(RadialGradient(
                colors: [Theme.blue.opacity(0.11), Theme.blue.opacity(0.04), Theme.blue.opacity(0)],
                center: .center, startRadius: 0, endRadius: CGFloat(max(s.w, s.h) / 2)))
            .frame(width: CGFloat(s.w), height: CGFloat(s.h))
            .opacity(s.o)
            .animation(Ease.ease(0.5), value: s.o)
            .offset(x: CGFloat(s.x - s.w / 2), y: CGFloat(s.y - s.h / 2))
            .animation(Ease.x(0), value: s)
    }
}

struct FinaleView: View {
    let f: SFinale
    let on: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 36, style: .continuous)
            .fill(Color.white)
            .shadow(color: Theme.shadow.opacity(0.12), radius: 30, x: 0, y: 24)
            .shadow(color: Theme.shadow.opacity(0.05), radius: 4, x: 0, y: 2)
            .frame(width: CGFloat(f.w), height: CGFloat(f.h))
            .scaleEffect(on ? 1 : 0.88)
            .opacity(on ? 1 : 0)
            .offset(x: CGFloat(f.x - f.w / 2), y: CGFloat(f.y - f.h / 2))
            .animation(.timingCurve(0.3, 1.3, 0.5, 1, duration: 0.7), value: on)
            .animation(.easeInOut(duration: 0.5), value: f)
    }
}

private let handPath = "M-3 11V-11c0-4 6-4 6 0v11-5c0-4 6-4 6 0v7-4c0-4 6-4 6 0v7-2c0-4 6-4 6 1v8c0 11-7 18-18 18-9 0-14-4-18-11l-6-10c-2-4 3-8 6-4z"

struct HandView: View {
    let h: HandState
    let still: Bool
    var body: some View {
        ZStack {
            SVGShape(d: handPath, viewBox: CGRect(x: -30, y: -18, width: 60, height: 64))
                .fill(Color(hex: 0xfff7ee))
            SVGShape(d: handPath, viewBox: CGRect(x: -30, y: -18, width: 60, height: 64))
                .stroke(Color(hex: 0x23324b), style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
        }
        .frame(width: 66, height: 70)
        .shadow(color: Theme.shadow.opacity(0.18), radius: 5, x: 0, y: 6)
        .scaleEffect(h.visible ? 1 : 0.8, anchor: UnitPoint(x: 33.0 / 66.0, y: 4.0 / 70.0))
        .rotationEffect(.degrees(-14), anchor: UnitPoint(x: 33.0 / 66.0, y: 4.0 / 70.0))
        .opacity(h.visible ? 1 : 0)
        .animation(.easeInOut(duration: 0.38), value: h.visible)
        .offset(x: CGFloat(h.x - 33), y: CGFloat(h.y - 4))
        .animation(still ? nil : Ease.hand(), value: h)
    }
}

struct RingView: View {
    let x: Double
    let y: Double
    @State private var t0 = Date()
    var body: some View {
        TimelineView(.animation) { ctx in
            let el = ctx.date.timeIntervalSince(t0) - 1.0
            let p: Double = el < 0 ? 0 : (el.truncatingRemainder(dividingBy: 1.5)) / 1.5
            let eased = 1 - pow(1 - p, 2)
            let sc = 0.35 + (1.8 - 0.35) * eased
            let op: Double = el < 0 ? 0 : (p < 0.25 ? 0.9 * p / 0.25 : 0.9 * (1 - (p - 0.25) / 0.75))
            Circle()
                .stroke(Theme.blue.opacity(0.45), lineWidth: 3)
                .frame(width: 48, height: 48)
                .scaleEffect(sc)
                .opacity(op)
        }
        .frame(width: 48, height: 48)
        .offset(x: CGFloat(x - 24), y: CGFloat(y - 24))
    }
}
