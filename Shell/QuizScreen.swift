import SwiftUI
import Observation

enum AnswerBox { case top, bot }
enum Part { case top, bot, both }
enum AnsStatus { case none, ok, bad }

struct QuizRecord {
    var qi: Int; var top: String; var bot: String; var ok: Bool; var part: Part?; var ms: Int
}

@MainActor
@Observable
final class QuizSession {
    var id = "frac"
    var qs: [Question] = QuizData.questions("frac")
    var qi = 0
    var top = ""
    var bot = ""
    var active = AnswerBox.top
    var status = AnsStatus.none
    var part: Part? = nil
    var records: [QuizRecord] = []
    var done = false
    var badgeIn = false
    var shake: CGFloat = 0
    var started = Date()
    var padStrokes: [[CGPoint]] = []
    var padEmpty: Bool { padStrokes.isEmpty }

    var q: Question { qs[min(qi, qs.count - 1)] }
    var score: Int { records.filter { $0.ok }.count }
    var totalMs: Int { records.reduce(0) { $0 + $1.ms } }

    func begin(_ quizId: String) {
        id = quizId; qs = QuizData.questions(quizId)
        reset()
    }
    func reset() {
        qi = 0; records = []; done = false; badgeIn = false
        blank(); started = Date()
    }
    func blank() {
        top = ""; bot = ""; active = .top; status = .none; part = nil; padStrokes = []
    }
    var locked: Bool { status != .none }
    var ready: Bool { q.isFraction ? (!top.isEmpty && !bot.isEmpty) : !top.isEmpty }
    private var maxLen: Int { q.isFraction ? 3 : 6 }

    func setBox(_ b: AnswerBox) { if !locked { active = q.isFraction ? b : .top } }
    func append(_ s: String, to box: AnswerBox? = nil) {
        guard !locked else { return }
        let b = q.isFraction ? (box ?? active) : .top
        active = b
        let cur = b == .top ? top : bot
        let n = String((cur + s).prefix(maxLen))
        if b == .top { top = n } else { bot = n }
    }
    func del() {
        guard !locked else { return }
        if active == .top { top = String(top.dropLast()) } else { bot = String(bot.dropLast()) }
    }

    func check() {
        let t = Int(top) ?? 0, b = Int(bot) ?? 0
        var ok: Bool
        var p: Part? = nil
        if !q.isFraction { ok = t == q.solNum }
        else {
            ok = b > 0 && t * q.solDen == q.solNum * b
            if !ok { p = b == q.solDen ? .top : (t == q.solNum ? .bot : .both) }
        }
        status = ok ? .ok : .bad
        part = p
        records.append(QuizRecord(qi: qi, top: top, bot: bot, ok: ok, part: p, ms: Int(Date().timeIntervalSince(started) * 1000)))
        if !ok { shakeIt() }
    }

    private func shakeIt() {
        Task { @MainActor in
            for x: CGFloat in [-12, 10, -7, 5, 0] {
                withAnimation(.easeInOut(duration: 0.06)) { shake = x }
                try? await Task.sleep(nanoseconds: 60_000_000)
            }
        }
    }

    func action(store: Store) {
        if status != .none {
            if qi < qs.count - 1 {
                qi += 1; blank(); started = Date()
            } else {
                finish(store: store)
            }
        } else if ready {
            check()
        }
    }

    func finish(store: Store) {
        let sc = score, tot = totalMs
        done = true
        if id == "frac" { store.frac = .done } else if id == "sq5" { store.sq5 = .done }
        store.scores[id] = sc
        let prev = store.times[id]
        store.times[id] = TimeRec(last: tot, best: prev.map { min($0.best, tot) } ?? tot, prevBest: prev?.best)
        store.save()
        badgeIn = false
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 420_000_000)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { badgeIn = true }
        }
    }
}

// MARK: - Quiz / results

struct QuizScreen: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        let z = nav.quiz
        ZStack {
            if z.done { ResultsView() } else { WorkView() }
        }
        .frame(width: Canvas.w, height: Canvas.h)
    }
}

struct WorkView: View {
    @Environment(Nav.self) private var nav
    @State private var padMode = PadMode.pen

    var body: some View {
        let z = nav.quiz
        let q = z.q
        VStack(alignment: .leading, spacing: 0) {
            // header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quiz: \(QuizData.names[z.id] ?? "")").font(Theme.round(24, .black)).tracking(-0.5)
                    Text("Question \(z.qi + 1) of \(z.qs.count)").font(Theme.text(15, .semibold)).foregroundColor(Theme.sub)
                }
                Spacer()
                TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                    let live = z.status == .none ? Int(Date().timeIntervalSince(z.started) * 1000) : 0
                    Label(clockText(z.totalMs + live), systemImage: "timer")
                        .font(Theme.round(20, .heavy)).monospacedDigit().foregroundColor(Theme.blue)
                        .padding(.horizontal, 16).frame(height: 40)
                        .background(Capsule().fill(Theme.soft))
                }
                RoundIconButton(d: IconPath.close, size: 40, icon: 18, stroke: 2.6) { nav.closeQuiz() }
            }
            .padding(.horizontal, 36).padding(.top, 26)

            HStack(spacing: 6) {
                ForEach(0..<z.qs.count, id: \.self) { i in
                    let full = i < z.qi || (i == z.qi && z.status != .none)
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.line)
                        Capsule().fill(Theme.blue).frame(width: full ? 52 : 0)
                    }
                    .frame(width: 52, height: 5).animation(.easeOut(duration: 0.6), value: full)
                }
            }
            .padding(.horizontal, 36).padding(.top, 14)

            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(q.text).font(Theme.round(60, .black)).tracking(-2).monospacedDigit()
                        .padding(.top, 10)
                    answerArea(z, q)
                    caption(z, q).frame(height: 56, alignment: .topLeading)
                    Spacer(minLength: 0)
                    keypad(z)
                }
                .frame(width: 520)
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Text("Scratch pad").font(Theme.text(15, .bold)).foregroundColor(Theme.sub)
                        Spacer()
                        modeButton(.pen, "pencil.tip")
                        modeButton(.scroll, "hand.draw")
                        padButton("arrow.uturn.backward") { if !z.padStrokes.isEmpty { z.padStrokes.removeLast() } }
                        padButton("trash") { z.padStrokes = [] }
                    }
                    ScratchPad(strokes: Binding(get: { z.padStrokes }, set: { z.padStrokes = $0 }), mode: padMode)
                        .frame(maxHeight: .infinity)
                        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.white))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Theme.line, lineWidth: 1))
                        .overlay {
                            if z.padEmpty {
                                Text("Work it out here").font(Theme.text(16, .semibold)).foregroundColor(Color(hex: 0xb5c3d2))
                                    .allowsHitTesting(false)
                            }
                        }
                }
                .frame(width: 408).padding(.bottom, 30)
            }
            .padding(.horizontal, 36).padding(.top, 8)
        }
        .frame(width: Canvas.w, height: Canvas.h, alignment: .topLeading)
    }

    private func modeButton(_ m: PadMode, _ sym: String) -> some View {
        Button { padMode = m } label: {
            Image(systemName: sym).font(.system(size: 16, weight: .semibold))
                .foregroundColor(padMode == m ? Theme.blue : Theme.sub)
                .frame(width: 34, height: 34)
                .background(Circle().fill(padMode == m ? Color.white : Color.clear))
                .shadow(color: Theme.shadow.opacity(padMode == m ? 0.12 : 0), radius: 2, x: 0, y: 1)
        }.buttonStyle(.plain)
    }
    private func padButton(_ sym: String, _ a: @escaping () -> Void) -> some View {
        Button(action: a) {
            Image(systemName: sym).font(.system(size: 16, weight: .semibold)).foregroundColor(Color(hex: 0x3a4860))
                .frame(width: 38, height: 38).background(Circle().fill(.white))
                .overlay(Circle().stroke(Theme.line, lineWidth: 1))
        }.buttonStyle(PressStyle(scale: 0.92))
    }

    // MARK: answer boxes

    @ViewBuilder
    private func answerArea(_ z: QuizSession, _ q: Question) -> some View {
        if q.isFraction {
            HStack(spacing: 18) {
                Text("=").font(Theme.round(50, .heavy)).foregroundColor(Theme.sub)
                VStack(spacing: 8) {
                    box(z, .top, z.top, w: 116)
                    Rectangle().fill(Theme.ink).frame(width: 96, height: 4).clipShape(Capsule())
                    box(z, .bot, z.bot, w: 116)
                }
            }
        } else {
            HStack(spacing: 18) {
                Text("=").font(Theme.round(50, .heavy)).foregroundColor(Theme.sub)
                box(z, .top, z.top, w: 170)
            }
        }
    }

    private func box(_ z: QuizSession, _ which: AnswerBox, _ value: String, w: CGFloat) -> some View {
        let isActive = z.active == which && z.status == .none
        let wrong = z.status == .bad && (z.part == .both || (z.part == .top && which == .top) || (z.part == .bot && which == .bot) || !z.q.isFraction)
        let col: Color = z.status == .ok ? Theme.green : wrong ? Theme.orange : isActive ? Theme.blue : Theme.line
        let bg: Color = z.status == .ok ? Color(hex: 0xeefaf3) : wrong ? Color(hex: 0xfff5eb) : isActive ? Color(hex: 0xf4f9ff) : .white
        return ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(bg)
            RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(col, lineWidth: 3)
            Text(value.isEmpty ? "?" : value)
                .font(Theme.round(z.q.isFraction ? 44 : 40, .heavy)).monospacedDigit()
                .foregroundColor(value.isEmpty ? Color(hex: 0xb5c3d2) : (z.status == .ok ? Theme.green : wrong ? Theme.orange : isActive ? Theme.blue : Theme.ink))
            InkBox(enabled: !z.locked, onTouch: { z.setBox(which) }) { digits in z.append(digits, to: which) }
        }
        .frame(width: w, height: 74)
        .scaleEffect(z.status == .ok ? 1.05 : isActive ? 1.03 : 1)
        .offset(x: wrong ? z.shake : 0)
        .animation(.easeOut(duration: 0.2), value: isActive)
        .onTapGesture { z.setBox(which) }
    }

    private func caption(_ z: QuizSession, _ q: Question) -> some View {
        let (lead, tail, col): (String, String, Color) = {
            switch z.status {
            case .none: return ("", "Your time is being recorded. Get it right first.", Theme.blue)
            case .ok: return ("Nice! ", "\(q.text) = \(q.answer).", Theme.green)
            case .bad: return ("Not quite. ", "It\u{2019}s \(q.answer).", Theme.orange)
            }
        }()
        return (Text(lead).fontWeight(.heavy).foregroundColor(col) + Text(tail).foregroundColor(Theme.body))
            .font(Theme.round(22, .bold))
    }

    private func keypad(_ z: QuizSession) -> some View {
        let rows: [[String]] = [["1", "2", "3", "4", "5", "\u{232B}"], ["6", "7", "8", "9", "0"]]
        let label = z.status == .none ? "Check" : (z.qi < z.qs.count - 1 ? "Next" : "See results")
        let on = z.status != .none || z.ready
        return VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { r in
                HStack(spacing: 8) {
                    ForEach(rows[r], id: \.self) { k in
                        Button { k == "\u{232B}" ? z.del() : z.append(k) } label: {
                            Text(k).font(Theme.round(26, .heavy))
                                .frame(width: 62, height: 62)
                                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white))
                                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(hex: 0xe3eaf1), lineWidth: 1))
                                .shadow(color: Theme.shadow.opacity(0.06), radius: 5, x: 0, y: 5)
                        }
                        .buttonStyle(PressStyle(scale: 0.9))
                    }
                    if r == 1 {
                        Button { z.action(store: nav.store) } label: {
                            Text(label).font(Theme.text(17, .bold))
                                .foregroundColor(on ? .white : Color(hex: 0xa9b5c4))
                                .frame(minWidth: 124, minHeight: 62)
                                .background(Capsule().fill(on ? Theme.blue : Color(hex: 0xeef2f6)))
                        }
                        .buttonStyle(PressStyle())
                        .disabled(!on)
                    }
                }
            }
        }
        .padding(.bottom, 30)
    }
}

// MARK: - Results

struct ResultsView: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        let z = nav.quiz
        let store = nav.store
        let n = max(z.records.count, 1)
        let tot = z.totalMs
        let T = store.times[z.id]
        let best = (T?.prevBest != nil && tot < T!.prevBest!) ? "New best" : clockText(T?.best ?? tot)
        let wrongs = z.records.filter { !$0.ok }
        ScrollView {
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Theme.blue).frame(width: 112, height: 112)
                    Icon(d: "M12 3.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8L12 16.9l-5.2 2.7 1-5.8-4.3-4.1 5.9-.9z", size: 52, color: .white, filled: true)
                }
                .scaleEffect(z.badgeIn ? 1 : 0.4).opacity(z.badgeIn ? 1 : 0)
                .shadow(color: Theme.blue.opacity(z.badgeIn ? 0.45 : 0), radius: 30)
                .padding(.top, 34)
                Text("\(z.score)/\(z.qs.count)").font(Theme.round(60, .black)).tracking(-2)
                Text(QuizData.doneLines[z.id] ?? "").font(Theme.text(19, .semibold)).foregroundColor(Theme.sub)
                HStack(spacing: 14) {
                    stat(clockText(tot), "Total time")
                    stat(secsText(Double(tot) / Double(n)), "Per question")
                    stat(best, "Best time")
                }
                if wrongs.isEmpty {
                    Text("No mistakes. Brilliant.").font(Theme.round(22, .heavy)).foregroundColor(Theme.green).padding(.top, 8)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("To review").font(Theme.text(14, .bold)).tracking(1).foregroundColor(Theme.muted)
                        ForEach(0..<wrongs.count, id: \.self) { i in
                            let r = wrongs[i]
                            let qq = z.qs[r.qi]
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(qq.text).font(Theme.round(20, .heavy))
                                    Text("You wrote \(qq.isFraction ? "\(r.top)/\(r.bot)" : r.top). Answer: \(qq.answer) \u{00B7} \(secsText(Double(r.ms)))")
                                        .font(Theme.text(15, .medium)).foregroundColor(Theme.sub)
                                }
                                Spacer()
                                if qq.isFraction {
                                    Button("Review") {
                                        let start = r.part == .bot ? 4 : r.part == .top ? 3 : 1
                                        nav.go(.lesson("frac", review: true, start: start))
                                    }
                                    .font(Theme.text(15, .bold)).foregroundColor(Theme.blue)
                                    .padding(.horizontal, 18).frame(height: 38).background(Capsule().fill(Theme.soft))
                                }
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white))
                        }
                    }
                    .frame(width: 640)
                }
                HStack(spacing: 12) {
                    SecondaryPill(title: "Retake") { z.reset() }
                    PrimaryPill(title: "Done") { nav.closeQuiz() }
                }
                .padding(.vertical, 20)
            }
            .frame(width: Canvas.w)
        }
    }

    private func stat(_ v: String, _ l: String) -> some View {
        VStack(spacing: 2) {
            Text(v).font(Theme.round(24, .black)).monospacedDigit()
            Text(l).font(Theme.text(14, .semibold)).foregroundColor(Theme.sub)
        }
        .frame(width: 180, height: 84)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.white))
        .shadow(color: Theme.shadow.opacity(0.05), radius: 8, x: 0, y: 6)
    }
}

// MARK: - Drawing

enum PadMode { case pen, scroll }

/// Free scratch area: a tall canvas inside a scroll view. Pen mode draws, scroll mode scrolls.
struct ScratchPad: View {
    @Binding var strokes: [[CGPoint]]
    var mode: PadMode
    @State private var current: [CGPoint] = []

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            SwiftUI.Canvas { ctx, _ in
                for s in strokes + (current.isEmpty ? [] : [current]) { draw(&ctx, s) }
            }
            .frame(height: 1152)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { v in current.append(v.location) }
                .onEnded { _ in
                    if current.count > 0 { strokes.append(current) }
                    current = []
                }, including: mode == .pen ? .all : .none)
        }
        .scrollDisabled(mode == .pen)
    }

    private func draw(_ ctx: inout GraphicsContext, _ s: [CGPoint]) {
        guard let f = s.first else { return }
        var p = Path()
        p.move(to: f)
        if s.count == 1 { p.addLine(to: CGPoint(x: f.x + 0.1, y: f.y)) }
        for pt in s.dropFirst() { p.addLine(to: pt) }
        ctx.stroke(p, with: .color(Color(hex: 0x23324b)), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
    }
}

/// Transparent writing layer over an answer box. Pauses for 650 ms, then recognises the digits.
struct InkBox: View {
    var enabled: Bool
    var onTouch: () -> Void
    var onDigits: (String) -> Void
    @State private var strokes: [[CGPoint]] = []
    @State private var current: [CGPoint] = []
    @State private var commit: Task<Void, Never>?

    var body: some View {
        SwiftUI.Canvas { ctx, _ in
            for s in strokes + (current.isEmpty ? [] : [current]) {
                guard let f = s.first else { continue }
                var p = Path(); p.move(to: f)
                for pt in s.dropFirst() { p.addLine(to: pt) }
                ctx.stroke(p, with: .color(Color(hex: 0x23324b)), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            }
        }
        .padding(-14)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { v in
                guard enabled else { return }
                if current.isEmpty { onTouch(); commit?.cancel() }
                current.append(v.location)
            }
            .onEnded { _ in
                guard enabled else { current = []; return }
                if current.count >= 3 { strokes.append(current) }
                current = []
                guard !strokes.isEmpty else { return }
                commit?.cancel()
                commit = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 650_000_000)
                    if Task.isCancelled { return }
                    let s = InkRecognizer.recognize(strokes)
                    strokes = []
                    if !s.isEmpty { onDigits(s) }
                }
            })
    }
}
