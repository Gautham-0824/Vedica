import SwiftUI

/// Scales a 1024 x 768 design canvas to fit whatever space it is given (iPad or iPhone, any orientation).
struct CanvasFit<Content: View>: View {
    var background: Color = Theme.page
    var corner: CGFloat = 24
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let k = min(geo.size.width / Canvas.w, geo.size.height / Canvas.h)
            ZStack {
                background.ignoresSafeArea()
                content()
                    .frame(width: Canvas.w, height: Canvas.h)
                    .background(Theme.canvas)
                    .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                    .scaleEffect(k)
                    .frame(width: Canvas.w * k, height: Canvas.h * k)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Shared controls

struct RoundIconButton: View {
    var d: String
    var size: CGFloat = 48
    var icon: CGFloat = 24
    var stroke: CGFloat = 2.4
    var fg: Color = Color(hex: 0x3a4860)
    var bg: Color = .white
    var border: Color = Theme.line
    var shadowOn = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Icon(d: d, size: icon, stroke: stroke, color: fg)
                .frame(width: size, height: size)
                .background(Circle().fill(bg))
                .overlay(Circle().stroke(border, lineWidth: 1))
                .shadow(color: Theme.shadow.opacity(shadowOn ? 0.05 : 0), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(PressStyle(scale: 0.92))
    }
}

struct PressStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.timingCurve(0.3, 0.7, 0.4, 1, duration: 0.14), value: configuration.isPressed)
    }
}

struct PrimaryPill: View {
    var title: String
    var minWidth: CGFloat = 0
    var height: CGFloat = 56
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.text(17, .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .frame(minWidth: minWidth, minHeight: height)
                .background(Capsule().fill(Theme.blue))
                .shadow(color: Theme.blue.opacity(0.3), radius: 12, x: 0, y: 10)
        }
        .buttonStyle(PressStyle())
    }
}

struct SecondaryPill: View {
    var title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.text(17, .semibold))
                .foregroundColor(Color(hex: 0x3a4860))
                .padding(.horizontal, 26)
                .frame(minHeight: 56)
                .background(Capsule().fill(Color.white))
                .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
                .shadow(color: Theme.shadow.opacity(0.05), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(PressStyle())
    }
}

struct VedicaLogo: View {
    var size: CGFloat = 28
    var body: some View {
        Text("V")
            .font(.system(size: size * 0.57, weight: .heavy, design: .rounded).italic())
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: size * 0.32, bottomLeadingRadius: size * 0.11,
                                       bottomTrailingRadius: size * 0.32, topTrailingRadius: size * 0.32,
                                       style: .continuous)
                    .fill(Theme.blue))
            .shadow(color: Theme.blue.opacity(0.22), radius: 6, x: 0, y: 5)
    }
}

enum IconPath {
    static let close = "M6 6l12 12M18 6 6 18"
    static let back = "m14.5 6-6 6 6 6"
    static let forward = "m9.5 6 6 6-6 6"
    static let replay = "M4 12a8 8 0 1 0 2.3-5.7M4 5v5h5"
    static let restart = "M20 12a8 8 0 1 1-2.3-5.7M20 5v5h-5"
    static let speaker = "M4 9.5h3.2L12 5.5v13l-4.8-4H4z"
    static let wavesOn = "M15.5 9a4 4 0 0 1 0 6M18 6.5a7.5 7.5 0 0 1 0 11"
    static let wavesOff = "m16 9.5 5 5m0-5-5 5"
    static let info = "M12 12v0"
    static let check = "m5 12.5 4.5 4.5L19 7.5"
}

// MARK: - Lesson screen

struct LessonView: View {
    @State private var runner: LessonRunner
    var onExit: () -> Void
    var onFinished: () -> Void

    init(spec: LessonSpec, startStep: Int = 0, continueTitle: String? = nil, onContinue: (() -> Void)? = nil,
         onExit: @escaping () -> Void, onFinished: @escaping () -> Void = {}) {
        let r = LessonRunner(spec: spec)
        r.startStep = startStep
        r.continueTitle = continueTitle
        r.onContinue = onContinue
        _runner = State(initialValue: r)
        self.onExit = onExit
        self.onFinished = onFinished
    }

    var body: some View {
        CanvasFit {
            LessonCanvas(runner: runner)
        }
        .statusBarHidden(true)
        .onAppear {
            runner.onExit = onExit
            runner.onFinished = onFinished
            runner.start()
        }
        .onDisappear { runner.stop() }
    }
}

struct LessonCanvas: View {
    let runner: LessonRunner
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let spec = runner.spec
        ZStack(alignment: .topLeading) {
            Color.clear

            progressBars(spec)
            SceneLayer(runner: runner)

            // Tap anywhere on the stage to skip ahead.
            if runner.step < runner.last && !runner.info {
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: Canvas.w, height: Canvas.h - 110 - 120)
                    .offset(y: 110)
                    .onTapGesture { runner.stageTap() }
            }

            railView
            topBar(spec)
            sideButtons
            if runner.practiceLive && !runner.pr.done && runner.pr.replay == nil { practiceArea(spec) }
            if runner.practiceLive && runner.pr.done { donePanel(spec) }
            bottomBar
            if runner.info { infoCard(spec) }
        }
        .frame(width: Canvas.w, height: Canvas.h, alignment: .topLeading)
        .foregroundColor(Theme.ink)
    }

    // MARK: top bar + progress

    private func topBar(_ spec: LessonSpec) -> some View {
        HStack {
            HStack(spacing: 8) {
                VedicaLogo()
                Text("Vedica").font(Theme.round(21, .heavy)).tracking(-0.6)
            }
            Spacer()
            HStack(spacing: 14) {
                HStack(spacing: 8) {
                    if !spec.topTitle.isEmpty {
                        Text(spec.topTitle).foregroundColor(Theme.muted)
                        Text("\u{00B7}").foregroundColor(Color(hex: 0xd3dbe4))
                    }
                    Text(runner.isPractice ? "Practice" : "Step \(runner.step + 1) of \(runner.last)")
                        .foregroundColor(Theme.blue).fontWeight(.bold)
                    Text(spec.steps[runner.step].name).foregroundColor(Color(hex: 0x8290a8)).lineLimit(1)
                }
                .font(Theme.text(15, .semibold))
                RoundIconButton(d: IconPath.close, size: 40, icon: 18, stroke: 2.6) { runner.exitLesson() }
            }
        }
        .padding(.horizontal, 36)
        .frame(width: Canvas.w, height: 40)
        .offset(y: 22)
    }

    private func progressBars(_ spec: LessonSpec) -> some View {
        let w: CGFloat = spec.steps.count > 14 ? 34 : 42
        return HStack(spacing: 6) {
            ForEach(0..<spec.steps.count, id: \.self) { i in
                let (fill, anim) = runner.barFill(i)
                Button { runner.go(i) } label: {
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.line).frame(width: w, height: 5)
                        Capsule().fill(Theme.blue).frame(width: w * CGFloat(fill), height: 5)
                            .animation(anim, value: fill)
                    }
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Go to \(spec.steps[i].name)")
            }
        }
        .frame(width: Canvas.w)
        .offset(y: 62)
    }

    // MARK: recap rail

    private var railView: some View {
        let big = runner.spec.bigRail
        let w: CGFloat = big ? 190 : 184
        return VStack(alignment: big ? .leading : .trailing, spacing: big ? 8 : 7) {
            Text("STEPS")
                .font(Theme.text(big ? 13 : 12, .bold)).tracking(1)
                .foregroundColor(Theme.muted)
                .padding(.trailing, 2).padding(.leading, big ? 4 : 0)
                .opacity(runner.rail.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: runner.rail.isEmpty)
            ForEach(runner.rail) { item in
                Button { runner.go(item.step) } label: {
                    HStack(spacing: 8) {
                        Text("\(item.num)")
                            .font(Theme.round(big ? 14 : 12, .heavy)).foregroundColor(Theme.blue)
                            .frame(width: big ? 26 : 22, height: big ? 26 : 22)
                            .background(Circle().fill(Theme.soft))
                        (Text(item.lead).foregroundColor(Theme.ink) + Text(item.tail).foregroundColor(item.hl))
                            .font(Theme.round(big ? 19 : 15, .heavy)).tracking(-0.15)
                            .lineLimit(1).minimumScaleFactor(0.7)
                        if big { Spacer(minLength: 0) }
                    }
                    .padding(.leading, big ? 8 : 7).padding(.trailing, big ? 16 : 14)
                    .frame(width: big ? w : nil, height: big ? 44 : 36)
                    .background(Capsule().fill(Color.white))
                    .overlay(Capsule().stroke(Color(hex: 0xedf1f5), lineWidth: 1))
                    .shadow(color: Theme.shadow.opacity(0.06), radius: 8, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .offset(x: big ? -12 : 12)).combined(with: .opacity),
                    removal: .opacity))
            }
        }
        .frame(width: w, alignment: big ? .leading : .trailing)
        .animation(reduceMotion ? nil : .timingCurve(0.3, 1.3, 0.5, 1, duration: 0.52), value: runner.rail)
        .offset(x: big ? Canvas.w - 30 - w : Canvas.w - 20 - w, y: big ? 236 : 216)
    }

    // MARK: info + narration buttons

    private var sideButtons: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .trailing, spacing: 10) {
                RoundIconButton(d: IconPath.info, size: 48, icon: 24, stroke: 2.4) { runner.openInfo() }
                    .overlay(infoDots)
                    .accessibilityLabel("About this sutra")
                speakerButton
            }
            if runner.menu { languageMenu.offset(x: -58, y: 58) }
        }
        .frame(width: 200, height: 200, alignment: .topTrailing)
        .offset(x: Canvas.w - 30 - 200, y: 100)
    }

    private var infoDots: some View {
        ZStack {
            Circle().stroke(Color(hex: 0x3a4860), lineWidth: 2).frame(width: 18, height: 18)
            Capsule().fill(Color(hex: 0x3a4860)).frame(width: 2.4, height: 5.5).offset(y: 2.2)
            Circle().fill(Color(hex: 0x3a4860)).frame(width: 2.5, height: 2.5).offset(y: -4.4)
        }
        .allowsHitTesting(false)
    }

    private var speakerButton: some View {
        let on = runner.audio
        return Button { runner.toggleAudio() } label: {
            ZStack {
                SVGShape(d: IconPath.speaker).fill(on ? Color.white : Color(hex: 0x3a4860)).frame(width: 24, height: 24)
                SVGShape(d: on ? IconPath.wavesOn : IconPath.wavesOff)
                    .stroke(on ? Color.white : Color(hex: 0x3a4860), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 24, height: 24)
            }
            .frame(width: 48, height: 48)
            .background(Circle().fill(on ? Theme.blue : Color.white))
            .overlay(Circle().stroke(on ? Theme.blue : Theme.line, lineWidth: 1))
            .shadow(color: (on ? Theme.blue : Theme.shadow).opacity(on ? 0.28 : 0.06), radius: 9, x: 0, y: 8)
        }
        .buttonStyle(PressStyle(scale: 0.92))
        .accessibilityLabel(on ? "Narration on" : "Narration off")
        .onHover { runner.menu = $0 }
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.45).onEnded { _ in runner.menu.toggle() })
    }

    private var languageMenu: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("NARRATION").font(Theme.text(12, .bold)).tracking(0.7).foregroundColor(Theme.muted)
                .padding(.horizontal, 12).padding(.top, 6).padding(.bottom, 8)
            ForEach(narrationLanguages) { l in
                let sel = l.id == runner.lang
                Button { runner.chooseLanguage(l.id) } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(l.native).font(Theme.text(15, .bold))
                            Text(l.english).font(Theme.text(12, .medium)).foregroundColor(Theme.muted)
                        }
                        Spacer()
                        Icon(d: IconPath.check, size: 18, stroke: 2.6, color: Theme.blue).opacity(sel ? 1 : 0)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(sel ? Theme.soft : .clear))
                    .foregroundColor(sel ? Theme.blue : Theme.ink)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .frame(width: 200)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.regularMaterial))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color(hex: 0xe6ecf2), lineWidth: 1))
        .shadow(color: Theme.shadow.opacity(0.16), radius: 22, x: 0, y: 18)
        .transition(.opacity.combined(with: .offset(x: 8)))
    }

    // MARK: practice

    private func practiceArea(_ spec: LessonSpec) -> some View {
        let pr = runner.pr
        let col: Color = pr.ok ? Theme.green : (pr.bad ? Theme.orange : Theme.blue)
        let bg: Color = pr.ok ? Color(hex: 0xeefaf3) : (pr.bad ? Color(hex: 0xfff5eb) : Color(hex: 0xf4f9ff))
        return ZStack(alignment: .topLeading) {
            VStack(spacing: 10) {
                HStack(spacing: 16) {
                    Text(promptText(spec)).font(Theme.round(44, .heavy))
                    Text(pr.input.isEmpty ? "?" : pr.input)
                        .font(Theme.round(46, .heavy)).tracking(0.9)
                        .foregroundColor(pr.input.isEmpty ? Color(hex: 0xb5c3d2) : col)
                        .frame(minWidth: 100, minHeight: 78)
                        .padding(.horizontal, 18)
                        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(bg))
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(col, lineWidth: 3))
                        .scaleEffect(pr.ok ? 1.06 : 1)
                        .offset(x: CGFloat(pr.shake))
                        .animation(.easeOut(duration: 0.11), value: pr.shake)
                        .animation(.easeOut(duration: 0.2), value: pr.ok)
                        .animation(.easeOut(duration: 0.2), value: pr.bad)
                }
                Text(runner.hintText)
                    .font(Theme.text(16, .semibold))
                    .foregroundColor(runner.hintColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 560)
            }
            .frame(width: Canvas.w)
            .offset(y: 444)

            HStack(spacing: 8) {
                ForEach(spec.keys, id: \.self) { k in
                    Button { runner.key(k) } label: {
                        Group {
                            if k == "\u{232B}" {
                                Image(systemName: "delete.left").font(.system(size: 24, weight: .semibold))
                            } else {
                                Text(k).font(Theme.round(28, .heavy))
                            }
                        }
                        .foregroundColor(Theme.ink)
                        .frame(width: 62, height: 62)
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: 0xe3eaf1), lineWidth: 1))
                        .shadow(color: Theme.shadow.opacity(0.06), radius: 7, x: 0, y: 6)
                    }
                    .buttonStyle(PressStyle(scale: 0.9))
                    .accessibilityLabel(k == "\u{232B}" ? "Delete" : (k == "\u{2212}" ? "Minus" : k))
                }
            }
            .frame(width: Canvas.w)
            .offset(y: 572)
        }
    }

    private func promptText(_ spec: LessonSpec) -> String {
        let T = spec.tasks(runner.current)
        guard !T.isEmpty else { return "=" }
        return T[min(runner.pr.task, T.count - 1)].prompt ?? "="
    }

    private func donePanel(_ spec: LessonSpec) -> some View {
        VStack(spacing: 12) {
            Text("You did it!").font(Theme.round(40, .black)).tracking(-1.2)
            if let sub = spec.doneSub {
                Text(sub(runner.current)).font(Theme.text(18, .medium)).foregroundColor(Theme.sub)
            } else {
                Text(spec.sutra)
                    .font(Theme.text(15, .bold)).foregroundColor(Theme.blue)
                    .padding(.horizontal, 16).frame(height: 34)
                    .background(Capsule().fill(Theme.soft))
            }
            HStack(spacing: 12) {
                SecondaryPill(title: "Watch the lesson again") { runner.go(0) }
                if let title = runner.continueTitle, let go = runner.onContinue {
                    SecondaryPill(title: "Try another") { runner.tryAnother() }
                    PrimaryPill(title: title) { go() }
                } else {
                    PrimaryPill(title: "Try another") { runner.tryAnother() }
                }
            }
            .padding(.top, 12)
        }
        .frame(width: Canvas.w)
        .offset(y: 400)
    }

    // MARK: bottom bar

    private var bottomBar: some View {
        let exp = runner.done && runner.step < runner.last
        return HStack(spacing: 20) {
            Button { runner.back() } label: {
                Icon(d: IconPath.back, size: 24, stroke: 2.4, color: runner.step == 0 ? Color(hex: 0xc3ccd6) : Color(hex: 0x3a4860))
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(.white))
                    .overlay(Circle().stroke(Theme.line, lineWidth: 1))
                    .shadow(color: Theme.shadow.opacity(0.05), radius: 6, x: 0, y: 4)
            }
            .buttonStyle(PressStyle(scale: 0.92))
            .accessibilityLabel("Previous step")

            captionView
                .frame(maxWidth: .infinity)

            HStack(spacing: 10) {
                Button { runner.replay() } label: {
                    HStack(spacing: 7) {
                        Icon(d: IconPath.replay, size: 20, stroke: 2.3, color: Color(hex: 0x3a4860))
                        Text("Replay").font(Theme.text(15, .semibold)).foregroundColor(Color(hex: 0x3a4860))
                    }
                    .padding(.leading, 14).padding(.trailing, 18).frame(height: 56)
                    .background(Capsule().fill(.white))
                    .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
                    .shadow(color: Theme.shadow.opacity(0.05), radius: 6, x: 0, y: 4)
                }
                .buttonStyle(PressStyle(scale: 0.92))
                .accessibilityLabel("Replay this step")

                Button { runner.next() } label: {
                    HStack(spacing: exp ? 6 : 0) {
                        Text("Next")
                            .font(Theme.text(17, .bold))
                            .lineLimit(1)
                            .frame(maxWidth: exp ? 60 : 0)
                            .opacity(exp ? 1 : 0)
                            .clipped()
                        Icon(d: runner.step == runner.last ? IconPath.restart : IconPath.forward, size: 24, stroke: 2.4,
                             color: exp ? .white : Theme.blue)
                    }
                    .foregroundColor(exp ? .white : Theme.blue)
                    .frame(width: exp ? 124 : 56, height: 56)
                    .background(Capsule().fill(exp ? Theme.blue : Color(hex: 0xe7f1fd)))
                    .shadow(color: Theme.blue.opacity(exp ? 0.3 : 0), radius: 12, x: 0, y: 10)
                    .animation(.timingCurve(0.32, 0.72, 0, 1, duration: 0.52), value: exp)
                }
                .buttonStyle(PressStyle(scale: 0.96))
                .accessibilityLabel(runner.step == runner.last ? "Start the lesson again" : "Next step")
            }
        }
        .padding(.horizontal, 36)
        .frame(width: Canvas.w)
        .offset(y: Canvas.h - 30 - 56)
    }

    private var captionView: some View {
        var t = Text("")
        for (s, bold) in runner.captionRuns {
            t = t + Text(s).foregroundColor(bold ? runner.captionColor : Theme.body).fontWeight(bold ? .heavy : .bold)
        }
        let on = runner.capIn
        return t
            .font(Theme.round(23, .bold))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .minimumScaleFactor(0.8)
            .opacity(on ? 1 : 0)
            .offset(y: on ? 0 : 8)
            .blur(radius: on ? 0 : 4)
            .animation(on ? .easeOut(duration: 0.5) : nil, value: on)
            .accessibilityLabel(runner.captionPlain)
    }

    // MARK: info card

    private func infoCard(_ spec: LessonSpec) -> some View {
        let show = runner.infoShow
        return ZStack {
            Color(hex: 0x17233a, alpha: 0.32).background(.ultraThinMaterial.opacity(0.4))
                .onTapGesture { runner.closeInfo() }
            VStack(spacing: 0) {
                if spec.example != nil || spec.fractionExample {
                    exampleCard(spec, show)
                } else {
                Text(spec.cardTitle)
                    .font(Theme.round(30, .black)).tracking(-0.9)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 44).padding(.top, 8)
                Text(spec.cardBlurb)
                    .font(Theme.text(15, .semibold)).foregroundColor(Theme.sub)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                if let teaser = spec.teaser {
                    HStack(spacing: 14) {
                        ForEach(Array(teaser.enumerated()), id: \.offset) { _, part in
                            HStack(spacing: 0) {
                                ForEach(Array(part.enumerated()), id: \.offset) { _, run in
                                    Text(run.text)
                                        .font(Theme.round(CGFloat(spec.teaserSize) * CGFloat(run.scale), .black))
                                        .tracking(-1.4)
                                        .foregroundColor(run.color)
                                        .fixedSize()
                                        .scaleEffect(run.pop ? (show ? 1 : 0.8) : 1)
                                        .opacity(run.pop ? (show ? 1 : 0) : 1)
                                        .offset(y: run.pop ? (show ? 0 : 8) : 0)
                                        .animation(.timingCurve(0.3, 1.3, 0.5, 1, duration: 0.6).delay(0.4), value: show)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 130)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Theme.panel))
                    .padding(.top, 20)
                } else {
                    VStack(spacing: 10) {
                        ForEach(Array(spec.rows.enumerated()), id: \.offset) { i, r in
                            HStack(spacing: 14) {
                                Text("\(i + 1)")
                                    .font(Theme.round(14, .heavy)).foregroundColor(Theme.blue)
                                    .frame(width: 28, height: 28).background(Circle().fill(Theme.soft))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(r.title).font(Theme.round(17, .heavy))
                                    Text(r.sub).font(Theme.text(14, .medium)).foregroundColor(Theme.sub)
                                }
                                Spacer(minLength: 8)
                                Text(r.value)
                                    .font(Theme.round(20, .black)).foregroundColor(Theme.blue)
                                    .fixedSize()
                                    .scaleEffect(show ? 1 : 0.8)
                                    .opacity(show ? 1 : 0)
                                    .offset(y: show ? 0 : 8)
                                    .animation(.timingCurve(0.3, 1.3, 0.5, 1, duration: 0.6).delay(0.4 + Double(i) * 0.1), value: show)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Theme.panel))
                        }
                    }
                    .padding(.top, 20)
                }
                }
                PrimaryPill(title: "Start", minWidth: 160, height: 50) { runner.closeInfo() }
                    .padding(.top, 26)
            }
            .padding(.top, 30).padding(.horizontal, 32).padding(.bottom, 28)
            .frame(width: 560)
            .background(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(.white))
            .shadow(color: Theme.shadow.opacity(0.24), radius: 40, x: 0, y: 30)
            .overlay(alignment: .topTrailing) {
                Button { runner.closeInfo() } label: {
                    Icon(d: IconPath.close, size: 18, stroke: 2.6, color: Color(hex: 0x3a4860))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color(hex: 0xf1f4f8)))
                }
                .buttonStyle(PressStyle(scale: 0.92))
                .padding(18)
                .accessibilityLabel("Close")
            }
            .scaleEffect(show ? 1 : 0.92)
            .offset(y: show ? 0 : 14)
            .opacity(show ? 1 : 0)
            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.38), value: show)
        }
        .frame(width: Canvas.w, height: Canvas.h)
        .opacity(show ? 1 : 0)
        .animation(.easeOut(duration: 0.26), value: show)
    }

    // MARK: info card with a worked example (Basics lessons)

    private func exampleCard(_ spec: LessonSpec, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            titleView(spec.cardTitle, show)
                .padding(.horizontal, 44).padding(.top, 8)
            Group {
                if spec.fractionExample {
                    FractionExampleBox(show: show)
                } else if let ex = spec.example {
                    exampleBox(ex.q, ex.a, show)
                }
            }
            .padding(.top, 24)
        }
    }

    private func titleView(_ title: String, _ show: Bool) -> some View {
        let ns = title as NSString
        var hi = ns.range(of: "[0-9]+", options: .regularExpression)
        if hi.location == NSNotFound { hi = ns.range(of: "Unlike") }
        let size = CGFloat(min(32, floor(430 / (Double(title.count) * 0.6))))
        let found = hi.location != NSNotFound
        let a = found ? ns.substring(to: hi.location) : title
        let h = found ? ns.substring(with: hi) : ""
        let b = found ? ns.substring(from: hi.location + hi.length) : ""
        return HStack(spacing: 0) {
            Text(a)
            Text(h)
                .font(Theme.round(size * 1.3, .black))
                .foregroundColor(Theme.blue)
                .scaleEffect(show ? 1 : 0.7)
                .opacity(show ? 1 : 0)
                .offset(y: show ? 0 : 6)
                .animation(.timingCurve(0.3, 1.3, 0.5, 1, duration: 0.6).delay(0.26), value: show)
            Text(b)
        }
        .font(Theme.round(size, .black)).tracking(-size * 0.03)
        .lineLimit(1).fixedSize()
    }

    /// Splits the example question into plain and highlighted pieces, like the web build.
    private func exampleSegments(_ q: String) -> [(String, Bool)] {
        let ch = Array(q)
        var ranges: [(Int, Int)] = []
        if let i = ch.firstIndex(of: "\u{00D7}") {
            ranges = [(i + 2, ch.count)]
        } else if q.contains("\u{00B2}") {
            ranges = [(ch.count - 2, ch.count - 1)]
        } else {
            var i = 0
            while i < ch.count {
                if ch[i] == "/" {
                    var j = i + 1
                    while j < ch.count, ch[j].isNumber { j += 1 }
                    if j > i + 1 { ranges.append((i + 1, j)) }
                    i = j
                } else { i += 1 }
            }
        }
        var out: [(String, Bool)] = []
        var c = 0
        for (a, b) in ranges where a < ch.count {
            if a > c { out.append((String(ch[c..<a]), false)) }
            out.append((String(ch[a..<min(b, ch.count)]), true))
            c = min(b, ch.count)
        }
        if c < ch.count { out.append((String(ch[c...]), false)) }
        return out
    }

    private func exampleBox(_ q: String, _ a: String, _ show: Bool) -> some View {
        let fs: CGFloat = (q + a).count > 12 ? 40 : 52
        let segs = exampleSegments(q)
        return HStack(spacing: 14) {
            HStack(spacing: 0) {
                ForEach(Array(segs.enumerated()), id: \.offset) { i, seg in
                    if seg.1 {
                        Text(seg.0)
                            .font(Theme.round(fs * 1.3, .black)).foregroundColor(Theme.blue)
                            .scaleEffect(show ? 1 : 0.8).opacity(show ? 1 : 0).offset(y: show ? 0 : 8)
                            .animation(.timingCurve(0.3, 1.3, 0.5, 1, duration: 0.6).delay(0.62 + Double(segs[0..<i].filter { $0.1 }.count) * 0.12), value: show)
                    } else {
                        Text(seg.0).font(Theme.round(fs, .black))
                    }
                }
            }
            Text("=").font(Theme.round(fs, .black))
            Text(a).font(Theme.round(fs, .black))
        }
        .tracking(-fs * 0.03)
        .lineLimit(1).fixedSize()
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Theme.panel))
    }
}

/// The intro card's example for the Fraction lesson: 8/3 + 9/4 with the two bottoms pulsing.
struct FractionExampleBox: View {
    let show: Bool

    private func frac(_ top: String, _ bottom: String, _ col: Color, _ k: Double) -> some View {
        VStack(spacing: 0) {
            Text(top)
            Capsule().fill(Theme.ink).frame(height: 4).padding(.horizontal, -4).padding(.vertical, 6)
            PulseText(text: bottom, color: col, show: show, delay: 0.62 + k * 0.12)
        }
        .font(Theme.round(40, .black))
        .foregroundColor(Theme.ink)
        .fixedSize()
    }

    var body: some View {
        HStack(spacing: 22) {
            frac("8", "3", Theme.blue, 0)
            Text("+").font(Theme.round(40, .black))
            frac("9", "4", Theme.orange, 1)
        }
        .frame(maxWidth: .infinity, minHeight: 170)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Theme.panel))
    }
}

struct PulseText: View {
    let text: String
    let color: Color
    let show: Bool
    let delay: Double
    @State private var pulse = false

    var body: some View {
        Text(text)
            .foregroundColor(color)
            .scaleEffect(pulse ? 1.12 : 1)
            .animation(show ? .easeInOut(duration: 1.6).delay(1.5).repeatForever(autoreverses: true) : .default, value: pulse)
            .scaleEffect(show ? 1 : 0.8)
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 8)
            .animation(.timingCurve(0.3, 1.3, 0.5, 1, duration: 0.6).delay(delay), value: show)
            .onChange(of: show) { _, on in pulse = on }
            .onAppear { if show { pulse = true } }
    }
}
