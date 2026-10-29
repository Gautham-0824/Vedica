import SwiftUI
import Observation
import UIKit

// MARK: - Display model (what the renderer draws)

struct DEl: Identifiable {
    var id: String
    var e: SElement
    var dim: Bool
    var gen: Int            // bumped when a glyph should re-enter as brand new
    var present: Bool
    var vid: String { id + "#" + String(gen) }
}

struct DBox: Identifiable {
    var id: String
    var b: SBox
    var dim: Bool
    var gen: Int
    var vid: String { id + "#" + String(gen) }
}

struct DLine: Identifiable {
    var id: Int
    var l: SLine
    var len: Double
}

struct DArrow: Identifiable {
    var id: String          // slot + path, so a new path draws in from scratch
    var slot: Int
    var a: SArrow
    var path: Path
    var length: Double
}

struct Spot: Equatable {
    var x = 0.0, y = 0.0, w = 300.0, h = 200.0, o = 0.0
}

struct HandState: Equatable {
    var x = 512.0, y = 500.0, visible = false
}

struct RailItem: Identifiable, Equatable {
    var id: Int
    var step: Int = 0
    var num: Int = 0
    var lead: String
    var tail: String
    var hl: Color
}

struct Replay: Equatable {
    var step: StepDef
    var ph: Int
    static func == (a: Replay, b: Replay) -> Bool { a.step.g == b.step.g && a.ph == b.ph && a.step.k == b.step.k }
}

struct PracticeState {
    var list: [Problem] = []
    var pi = 0
    var task = 0
    var input = ""
    var wrong = 0
    var ok = false
    var bad = false
    var shake = 0.0
    var replay: Replay? = nil
    var done = false
    var again = false
    var anim = 0          // 0 idle, 1 answer accepted, 2 answer placed (Fraction lesson)
    var tick = 0          // slow heartbeat the Fraction lesson uses to alternate the hand
}

struct Language: Identifiable {
    var id: String
    var english: String
    var native: String
    var locale: String
}

let narrationLanguages: [Language] = [
    Language(id: "en", english: "English", native: "English", locale: "en-IN"),
    Language(id: "hi", english: "Hindi", native: "\u{0939}\u{093F}\u{0928}\u{094D}\u{0926}\u{0940}", locale: "hi-IN"),
    Language(id: "ta", english: "Tamil", native: "\u{0BA4}\u{0BAE}\u{0BBF}\u{0BB4}\u{0BCD}", locale: "ta-IN"),
    Language(id: "te", english: "Telugu", native: "\u{0C24}\u{0C46}\u{0C32}\u{0C41}\u{0C17}\u{0C41}", locale: "te-IN"),
    Language(id: "ml", english: "Malayalam", native: "\u{0D2E}\u{0D32}\u{0D2F}\u{0D3E}\u{0D33}\u{0D02}", locale: "ml-IN"),
]

// MARK: - Arrow geometry (port of the web build's arrowPath)

func arrowGeometry(_ a: SArrow) -> (Path, Double) {
    let x0 = Double(a.p0.x), y0 = Double(a.p0.y), x1 = Double(a.p1.x), y1 = Double(a.p1.y)
    let dx = x1 - x0, dy = y1 - y0
    let L = max(hypot(dx, dy), 0.0001)
    let px = -dy / L, py = dx / L
    let bb = a.bend * L
    let c1 = CGPoint(x: x0 + dx * 0.3 + px * bb * 1.08 - 2, y: y0 + dy * 0.3 + py * bb * 1.08 + 2)
    let c2 = CGPoint(x: x0 + dx * 0.72 + px * bb * 0.9 + 3, y: y0 + dy * 0.72 + py * bb * 0.9 - 2)
    let tx = x1 - Double(c2.x), ty = y1 - Double(c2.y)
    let tl = max(hypot(tx, ty), 0.0001)
    let ux = tx / tl, uy = ty / tl
    let h = 15.0, an = 0.5
    func head(_ s: Double) -> CGPoint {
        CGPoint(x: x1 - h * (ux * cos(an) - s * uy * sin(an)),
                y: y1 - h * (uy * cos(an) + s * ux * sin(an)))
    }
    var len = 0.0
    var prev = CGPoint(x: x0, y: y0)
    for j in 1...24 {
        let t = Double(j) / 24, u = 1 - t
        let bx = u * u * u * x0 + 3 * u * u * t * Double(c1.x) + 3 * u * t * t * Double(c2.x) + t * t * t * x1
        let by = u * u * u * y0 + 3 * u * u * t * Double(c1.y) + 3 * u * t * t * Double(c2.y) + t * t * t * y1
        len += hypot(bx - Double(prev.x), by - Double(prev.y))
        prev = CGPoint(x: bx, y: by)
    }
    var path = Path()
    path.move(to: CGPoint(x: x0, y: y0))
    path.addCurve(to: CGPoint(x: x1, y: y1), control1: c1, control2: c2)
    path.move(to: head(1))
    path.addLine(to: CGPoint(x: x1, y: y1))
    path.addLine(to: head(-1))
    return (path, len + 2 * h + 4)
}

// MARK: - Runner

@MainActor
@Observable
final class LessonRunner {
    let spec: LessonSpec
    var onExit: () -> Void = {}
    var onFinished: () -> Void = {}
    var onContinue: (() -> Void)? = nil
    var continueTitle: String? = nil
    var startStep = 0

    // State (mirrors `st` in the web build)
    var step = 0
    var phase = 0
    var done = false
    var capIn = false
    var pr = PracticeState()
    var info = false
    var infoShow = false
    var menu = false
    var audio = false
    var lang = "en"

    // Display
    var els: [DEl] = []
    var boxes: [DBox] = []
    var arrows: [DArrow] = []
    var lines: [DLine] = []
    var spot = Spot()
    var finale = SFinale(x: 512, y: 320, w: 300, h: 170)
    var finaleOn = false
    var hand = HandState()
    var ringKey = ""
    var rail: [RailItem] = []
    var captionRuns: [(String, Bool)] = []
    var captionColor: Color = Theme.blue
    var captionPlain = ""
    var hintText = ""
    var hintColor: Color = Theme.muted

    // Memory used to diff frames
    @ObservationIgnored private var lastE: [String: SElement] = [:]
    @ObservationIgnored private var lastB: [String: SBox] = [:]
    @ObservationIgnored private var lastA: [Int: SArrow] = [:]
    @ObservationIgnored private var order: [String] = []
    @ObservationIgnored private var orderB: [String] = []
    @ObservationIgnored private var wasGone: [String: Bool] = [:]
    @ObservationIgnored private var wasGoneB: [String: Bool] = [:]
    @ObservationIgnored private var gens: [String: Int] = [:]
    @ObservationIgnored private var gensB: [String: Int] = [:]
    @ObservationIgnored private var lastFinale: SFinale? = nil
    @ObservationIgnored private var lastHand: (Double, Double) = (512, 500)
    @ObservationIgnored private var timers: [Task<Void, Never>] = []
    @ObservationIgnored private var wasWin = false
    @ObservationIgnored private var spoken: String? = nil
    @ObservationIgnored private var pending: (() -> Void)? = nil
    @ObservationIgnored let narrator = Narrator()

    init(spec: LessonSpec) {
        self.spec = spec
        let d = UserDefaults.standard
        if let lg = d.string(forKey: "vedica.narration.lang") { lang = lg }
        audio = d.bool(forKey: "vedica.narration.audio")
        pr = PracticeState(list: spec.practice)
    }

    var last: Int { spec.last }
    var isPractice: Bool { step == last }
    var stageShiftNow: Double { spec.stageShift != 0 && step < last ? spec.stageShift : 0 }
    var practiceLive: Bool { step == last && phase >= 1 }
    var current: Problem { pr.list.isEmpty ? Problem(n: "") : pr.list[min(pr.pi, pr.list.count - 1)] }

    // MARK: timers

    private func later(_ ms: Double, _ f: @escaping @MainActor () -> Void) {
        let t = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(max(0, ms) * 1_000_000))
            if Task.isCancelled { return }
            f()
        }
        timers.append(t)
    }

    private func clear() {
        for t in timers { t.cancel() }
        timers = []
    }

    func stop() {
        clear()
        narrator.stop()
    }

    // MARK: navigation

    func start() {
        pending = { [weak self] in self?.go(self?.startStep ?? 0) }
        openInfo()
    }

    func go(_ s: Int, list: [Problem]? = nil) {
        clear()
        let def = spec.steps[s]
        step = s
        phase = 0
        done = false
        capIn = false
        if s == last { pr = PracticeState(list: list ?? spec.practice) }
        render()
        later(40) { [weak self] in self?.capIn = true; self?.render() }
        for (i, t) in def.times.enumerated() where i > 0 {
            later(t) { [weak self] in self?.phase = i; self?.render() }
        }
        let isLast = s == last
        if isLast, let ms = spec.tickMs { startTick(ms) }
        later(def.end) { [weak self] in self?.done = !isLast; self?.render() }
    }

    private func startTick(_ ms: Double) {
        later(ms) { [weak self] in
            guard let self = self else { return }
            self.pr.tick += 1
            self.render()
            self.startTick(ms)
        }
    }

    func next() { go(step < last ? step + 1 : 0) }
    func back() { go(step > 0 ? step - 1 : 0) }
    func replay() { go(step) }

    func stageTap() {
        if step >= last { return }
        if !done {
            clear()
            phase = spec.steps[step].times.count - 1
            done = true
            capIn = true
            render()
        } else {
            next()
        }
    }

    func exitLesson() {
        stop()
        onExit()
    }

    // MARK: practice

    private func buzz(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func press(_ d: String) {
        guard step == last, phase >= 1, !pr.ok, pr.replay == nil, !pr.done else { return }
        if !spec.replayOnWrong && pr.bad { return }
        let T = spec.tasks(current)
        let t = pr.task
        guard t < T.count else { return }
        let ans = T[t].ans
        var input = (pr.bad ? "" : pr.input) + d
        if input.count > ans.count { input = String(input.prefix(ans.count)) }
        if input.count < ans.count {
            pr.input = input; pr.bad = false; pr.again = false
            render()
            return
        }
        if input == ans {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            pr.input = input; pr.ok = true; pr.bad = false; pr.again = false; pr.anim = 1
            render()
            let lastTask = t >= T.count - 1
            if let ms = spec.okAnimMs { later(ms) { [weak self] in self?.pr.anim = 2; self?.render() } }
            later(lastTask ? spec.okAdvanceMs.1 : spec.okAdvanceMs.0) { [weak self] in
                guard let self = self else { return }
                let end = self.pr.pi >= self.pr.list.count - 1
                if !lastTask {
                    self.pr.task = t + 1; self.pr.input = ""; self.pr.ok = false; self.pr.wrong = 0; self.pr.again = false; self.pr.anim = 0
                } else if end {
                    self.pr.done = true
                    self.onFinished()
                } else {
                    self.pr.pi += 1; self.pr.task = 0; self.pr.input = ""; self.pr.ok = false; self.pr.wrong = 0; self.pr.again = false; self.pr.anim = 0
                }
                self.render()
            }
        } else {
            buzz(.light)
            pr.input = input; pr.bad = true; pr.wrong += 1; pr.again = false
            render()
            let shakes: [Double] = [-12, 10, -7, 5, 0]
            for (i, x) in shakes.enumerated() {
                later(60 * Double(i + 1)) { [weak self] in self?.pr.shake = x; self?.render() }
            }
            if spec.replayOnWrong {
                if pr.wrong >= 3 { later(1100) { [weak self] in self?.startReplay() } }
            } else {
                later(900) { [weak self] in self?.pr.input = ""; self?.pr.bad = false; self?.render() }
            }
        }
    }

    func del() {
        guard step == last, !pr.ok, pr.replay == nil, !pr.done else { return }
        pr.input = pr.bad ? "" : String(pr.input.dropLast())
        pr.bad = false
        render()
    }

    func key(_ k: String) {
        if k == "\u{232B}" { del() } else { press(k) }
    }

    private func startReplay() {
        let T = spec.tasks(current)
        guard pr.task < T.count else { return }
        let tk = T[pr.task]
        let defs = spec.replaySteps?(current, pr.task) ?? [spec.stepFor(current, tk)]
        pr.replay = Replay(step: defs[0], ph: 0)
        pr.input = ""; pr.bad = false
        render()
        var offset = 0.0
        for def in defs {
            for (ph, tt) in def.times.enumerated() {
                later(offset + tt) { [weak self] in self?.pr.replay = Replay(step: def, ph: ph); self?.render() }
            }
            offset += def.end + 700
        }
        later(offset) { [weak self] in
            guard let self = self else { return }
            self.pr.replay = nil; self.pr.wrong = 0; self.pr.input = ""; self.pr.again = true
            self.render()
        }
    }

    func tryAnother() { go(last, list: [spec.random()]) }

    // MARK: info card / narration

    func openInfo() {
        info = true; menu = false
        render()
        later(20) { [weak self] in self?.infoShow = true; self?.render() }
    }

    func closeInfo() {
        infoShow = false
        render()
        later(260) { [weak self] in
            guard let self = self else { return }
            self.info = false
            self.render()
            let p = self.pending
            self.pending = nil
            p?()
        }
    }

    func toggleAudio() {
        audio.toggle()
        menu = true
        saveNarration()
        if audio { spoken = nil } else { narrator.stop() }
        render()
    }

    func chooseLanguage(_ id: String) {
        lang = id; audio = true; spoken = nil
        saveNarration()
        render()
    }

    private func saveNarration() {
        let d = UserDefaults.standard
        d.set(lang, forKey: "vedica.narration.lang")
        d.set(audio, forKey: "vedica.narration.audio")
    }

    // MARK: frame

    private func frame() -> Scene {
        if step < last {
            let d = spec.steps[step]
            return spec.stepScene(d, phase)
        }
        if phase >= 1 {
            let p = current
            if let r = pr.replay { return spec.stepScene(r.step, r.ph) }
            if let pb = spec.practiceByState { return pb(p, pr) }
            if let pf = spec.practiceFull { return pf(p, pr.task, pr.ok, pr.done, pr.wrong) }
            return spec.practiceScene(p, pr.task, pr.ok, pr.done)
        }
        return Scene("x.")
    }

    // MARK: render

    func render() {
        let F = frame()
        let st = spec.style
        let fs: Set<String>? = F.focus.map { Set($0) }
        func dim(_ k: String) -> Bool { fs.map { !$0.contains(k) } ?? false }

        // glyphs
        for k in F.eOrder where !order.contains(k) { order.append(k) }
        var newEls: [DEl] = []
        for id in order {
            var e: SElement
            let gone = F.E[id] == nil
            if let cur = F.E[id] { e = cur; lastE[id] = cur }
            else if var old = lastE[id] { old.o = 0; old.dl = 0; old.od = nil; e = old }
            else { continue }
            var gen = gens[id] ?? 0
            if st.reappearFresh, let g = wasGone[id], g, !gone { gen += 1; gens[id] = gen }
            wasGone[id] = gone
            newEls.append(DEl(id: id, e: e, dim: dim(id), gen: gen, present: !gone))
        }
        els = newEls

        // boxes
        for k in F.bOrder where !orderB.contains(k) { orderB.append(k) }
        var newBoxes: [DBox] = []
        for id in orderB {
            var b: SBox
            let gone = F.B[id] == nil
            if let cur = F.B[id] { b = cur; lastB[id] = cur }
            else if var old = lastB[id] { old.o = 0; old.dl = 0; b = old }
            else { continue }
            var gen = gensB[id] ?? 0
            if st.reappearFresh, let g = wasGoneB[id], g, !gone { gen += 1; gensB[id] = gen }
            wasGoneB[id] = gone
            newBoxes.append(DBox(id: id, b: b, dim: dim(id), gen: gen))
        }
        boxes = newBoxes

        // arrows
        var newArrows: [DArrow] = []
        for i in 0..<3 {
            var a: SArrow
            if let cur = F.A[i] { a = cur; lastA[i] = cur }
            else if var old = lastA[i] { old.st = 3; a = old }
            else { continue }
            let (p, len) = arrowGeometry(a)
            let key = "\(i):\(Int(a.p0.x)),\(Int(a.p0.y)),\(Int(a.p1.x)),\(Int(a.p1.y)),\(Int(a.bend * 100))"
            newArrows.append(DArrow(id: key, slot: i, a: a, path: p, length: len))
        }
        arrows = newArrows

        // straight lines
        var newLines: [DLine] = []
        for i in F.Ls.keys.sorted() {
            guard let l = F.Ls[i] else { continue }
            newLines.append(DLine(id: i, l: l, len: Double(hypot(l.p1.x - l.p0.x, l.p1.y - l.p0.y)) + 2))
        }
        lines = newLines

        // spotlight
        var sp = Spot()
        if let focus = F.focus {
            var x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9
            for k in focus {
                if let e = F.E[k], e.o != 0 {
                    let hh = e.z * e.s / 2 + 10
                    let ww = hh * max(1, Double(e.t.count) * 0.6)
                    x0 = min(x0, e.x - ww); x1 = max(x1, e.x + ww)
                    y0 = min(y0, e.y - hh); y1 = max(y1, e.y + hh)
                }
                if let b = F.B[k], b.o != 0 {
                    x0 = min(x0, b.x - b.w / 2); x1 = max(x1, b.x + b.w / 2)
                    y0 = min(y0, b.y - b.h / 2); y1 = max(y1, b.y + b.h / 2)
                }
            }
            if x1 > x0 {
                let sw = x1 - x0 + 200, sh = y1 - y0 + 170
                sp = Spot(x: (x0 + x1) / 2, y: (y0 + y1) / 2, w: sw, h: sh, o: 1)
            }
        }
        if sp.o == 0 { sp.x = spot.x; sp.y = spot.y; sp.w = spot.w; sp.h = spot.h }
        spot = sp

        // finale + haptic
        if let f = F.finale { lastFinale = f }
        finale = lastFinale ?? SFinale(x: 512, y: 320, w: 300, h: 170)
        finaleOn = F.finale != nil
        if F.win && !wasWin { buzz(.medium) }
        wasWin = F.win

        // hand
        var hx = 512.0, hy = 500.0, hv = false
        if let h = F.hand {
            switch h {
            case .element(let k):
                if let e = F.E[k] { hx = e.x + 10; hy = e.y + e.z * e.s * 0.42; hv = true }
            case .point(let x, let y):
                hx = x; hy = y; hv = true
            }
            if hv { lastHand = (hx, hy) }
        }
        if !hv { hx = lastHand.0; hy = lastHand.1 }
        hand = HandState(x: hx, y: hy, visible: hv)
        ringKey = hv ? "\(Int(hx.rounded()))-\(Int(hy.rounded()))-\(step)" : ""

        // recap rail
        var items: [RailItem] = []
        let rc = spec.steps[step]
        if step < last {
            for (i, s) in spec.steps.enumerated() {
                if i > step { break }
                if s.n != rc.n || s.m != rc.m { continue }
                if i == step && !done { continue }
                let sms: [Styled]
                if let many = spec.summaryLines { sms = many(s) }
                else if let one = spec.summary(s) { sms = [one] }
                else { continue }
                for (j, sm) in sms.enumerated() {
                    var lead = sm.text, tail = ""
                    let r1 = sm.text.range(of: ": ", options: .backwards)
                    let r2 = sm.text.range(of: "= ", options: .backwards)
                    var cut: Range<String.Index>? = r1 ?? r2
                    if let a = r1, let b = r2 { cut = a.lowerBound > b.lowerBound ? a : b }
                    if let r = cut, r.upperBound < sm.text.endIndex {
                        lead = String(sm.text[sm.text.startIndex..<r.upperBound])
                        tail = String(sm.text[r.upperBound...])
                    }
                    let num = spec.summaryLines != nil ? items.count + 1 : i + 1
                    items.append(RailItem(id: i * 100 + j, step: i, num: num, lead: lead, tail: tail, hl: sm.color))
                }
            }
        }
        rail = items

        // caption + hint
        var capStr = ""
        var hl = Theme.blue
        let prac = practiceLive
        if step < last {
            let c = spec.caption(spec.steps[step]); capStr = c.text; hl = c.color
        } else if !prac {
            capStr = "Your turn."
        } else if let r = pr.replay {
            let c = spec.caption(r.step); capStr = c.text; hl = c.color
        } else if pr.done {
            capStr = spec.doneCaption(current); hl = Theme.green
        } else {
            let T = spec.tasks(current)
            if pr.task < T.count {
                let t = T[pr.task]
                if pr.ok { capStr = "**Yes!** " + (t.ok ?? (t.q + " = " + t.ans)) + "."; hl = Theme.green }
                else { capStr = t.cap; hl = t.hl ?? Theme.blue }
            }
        }
        captionPlain = plain(capStr)
        captionRuns = styledRuns(capStr)
        captionColor = hl

        var ht = spec.defaultHint
        if prac && pr.wrong > 0 {
            let T = spec.tasks(current)
            if pr.task < T.count { ht = T[pr.task].hint }
        }
        if pr.again { ht = "Your turn again." }
        if pr.ok { ht = spec.okHint }
        hintText = ht
        hintColor = (pr.wrong > 0 && !pr.ok && !pr.again) ? Color(hex: 0xa8662a) : (pr.ok ? Theme.green : Color(hex: 0x8a97aa))

        // narration
        if audio && capIn && captionPlain != spoken && !info {
            spoken = captionPlain
            narrator.speak(captionPlain, localeId: narrationLanguages.first(where: { $0.id == lang })?.locale ?? "en-IN")
        }
    }

    // MARK: progress bars

    /// Fill (0...1) and the animation to reach it, for the progress bar of step `i`.
    func barFill(_ i: Int) -> (Double, Animation?) {
        if i < step { return (1, nil) }
        if i > step { return (0, nil) }
        if step < last {
            if done { return (1, .easeOut(duration: 0.3)) }
            if capIn { return (1, .linear(duration: spec.steps[i].end / 1000)) }
            return (0, nil)
        }
        if spec.taskProgress {
            let tc = max(spec.tasks(current).count, 1)
            return (pr.done ? 1 : Double(pr.task) / Double(tc), .timingCurve(0.32, 0.72, 0, 1, duration: 0.6))
        }
        let n = Double(max(pr.list.count, 1))
        let v = (Double(pr.pi) + ((pr.done || pr.ok) ? 1 : 0)) / n
        return (v, .timingCurve(0.32, 0.72, 0, 1, duration: 0.6))
    }
}
