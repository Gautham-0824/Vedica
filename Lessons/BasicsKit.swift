import SwiftUI

/// Problem used by the Basics lessons (numbers, not strings).
struct BP: Equatable {
    var n: Int
    var m: Int
    init(n: Int, m: Int) { self.n = n; self.m = m }
    init(_ p: Problem) { n = Int(p.n) ?? 0; m = Int(p.m) ?? 0 }
    var p: Problem { Problem(n: String(n), m: String(m)) }
    var prefix: String { "\(n)x\(m)." }
}

struct BTask {
    var cap: String
    var q: String
    var ans: Int
    var ex: [String]? = nil
    var d: Int = 0
}

struct BStep {
    var name: String
    var times: [Double]
    var end: Double
    var P: BP? = nil
    var cap: (BP) -> String = { _ in "" }
    var hl: Color? = nil
    var sum: ((BP) -> [String])? = nil
    var scene: ((inout Scene, BP, Int) -> Void)? = nil
}

/// One Basics lesson, written the way the web build writes them (a list of steps plus a few hooks).
/// `spec` turns it into the shared `LessonSpec`.
struct BLesson {
    var id: String
    var topic: String
    var sutra: String
    var infoTitle: String
    var exQ: String
    var exA: String
    var steps: [BStep]
    var practice: [BP]
    var hintText: (BP) -> String = { _ in "Use the trick from the lesson." }
    var hint: ((inout Scene, BP) -> [String])? = nil
    var tasks: ((BP) -> [BTask])? = nil
    var taskScene: ((inout Scene, BP, Int) -> Void)? = nil
    var pscene: ((inout Scene, BP, Int, Bool, Bool) -> Void)? = nil
    var taskHint: ((BP, Int) -> String)? = nil
    var doneCap: ((BP) -> String)? = nil
    var replayFor: (BP, Int) -> [Int]
    var random: () -> BP

    private func pre(_ p: Problem) -> String { "\(p.n)x\(p.m)." }

    var spec: LessonSpec {
        let L = self
        let defs: [StepDef] = steps.enumerated().map { i, s in
            StepDef(g: String(i), n: s.P.map { String($0.n) } ?? "", m: s.P.map { String($0.m) } ?? "",
                    k: nil, name: s.name, times: s.times, end: s.end)
        }
        let practiceScene: (Problem, Int, Bool, Bool, Int) -> Scene = { p, t, ok, done, wrong in
            var S = Scene(p.n + "x" + p.m + ".")
            let P = BP(p)
            if let ps = L.pscene { ps(&S, P, t, ok, done); return S }
            let r = BK.problemRow(&S, P, 512, 250)
            let T = L.tasks?(P)
            let lastT = (T?.count ?? 1) - 1
            if T != nil && !done && !(ok && t == lastT) { L.taskScene?(&S, P, t) }
            if T == nil && wrong >= 2 && !ok, let hint = L.hint {
                S.mods(r.nIds, c: BK.BLUE)
                let hs = hint(&S, P)
                S.fa(r.nIds + hs)
                S.h(r.nIds[r.nIds.count - 1])
            }
            if (ok && (T == nil || t == lastT)) || done {
                BK.green(&S, r.all)
                S.finale = SFinale(x: 512, y: 250, w: r.x1 - r.x0 + 130, h: 150)
            }
            return S
        }
        return LessonSpec(
            id: id, topTitle: topic, cardTitle: infoTitle, cardBlurb: "",
            sutra: sutra, style: RenderStyle(dur: 0.82),
            steps: defs,
            practice: practice.map { $0.p },
            random: { L.random().p },
            stepScene: { def, ph in
                var S = Scene(def.n + "x" + def.m + ".")
                guard let i = Int(def.g), let f = L.steps[i].scene else { return S }
                f(&S, BP(Problem(n: def.n, m: def.m)), ph)
                return S
            },
            caption: { def in
                guard let i = Int(def.g) else { return ("", Theme.blue) }
                let s = L.steps[i]
                return (s.cap(BP(Problem(n: def.n, m: def.m))), s.hl ?? Theme.blue)
            },
            summary: { _ in nil },
            tasks: { p in
                let P = BP(p)
                if let T = L.tasks {
                    return T(P).enumerated().map { t, x in
                        PTask(g: "", cap: x.cap, q: x.q, ans: String(x.ans), ex: x.ex ?? [],
                              hint: L.taskHint?(P, t) ?? L.hintText(P), hl: t == 1 ? Theme.orange : Theme.blue)
                    }
                }
                return [PTask(g: "", cap: "Your turn. What is **\(P.n) \u{00D7} \(P.m)**?", q: "\(P.n) \u{00D7} \(P.m)",
                              ans: String(P.n * P.m), ex: [], hint: L.hintText(P))]
            },
            practiceScene: { p, t, ok, done in practiceScene(p, t, ok, done, 0) },
            doneCaption: { p in
                let P = BP(p)
                return L.doneCap?(P) ?? "**\(P.n) \u{00D7} \(P.m) = \(P.n * P.m)**. Same trick, every time."
            },
            summaryLines: { def in
                guard let i = Int(def.g), let f = L.steps[i].sum else { return [] }
                let c = L.steps[i].hl ?? Theme.blue
                return f(BP(Problem(n: def.n, m: def.m))).map { ($0, c) }
            },
            practiceFull: practiceScene,
            replaySteps: { p, t in
                L.replayFor(BP(p), t).map { i in
                    var d = defs[i]; d.n = p.n; d.m = p.m; return d
                }
            },
            example: (q: exQ, a: exA)
        )
    }
}

/// Shared toolkit of the Basics lessons (the web build's `mkScene` helpers).
enum BK {
    static let INK = Theme.ink, BLUE = Theme.blue, ORANGE = Theme.orange, GREEN = Theme.green, MUTE = Theme.muted
    static let DASH = Theme.dash
    static let Z = 96.0
    static let RY = 320.0, BY = 530.0
    static let MINUS = "\u{2212}"
    static let TIMES = "\u{00D7}"

    static func digs(_ n: Int) -> [Int] { String(n).compactMap { Int(String($0)) } }
    static func xsOf(_ n: Int, _ cx: Double, _ adv: Double) -> [Double] {
        (0..<n).map { cx + (Double($0) - Double(n - 1) / 2) * adv }
    }
    static func numItems(_ pfx: String, _ n: Int, _ c: Color? = nil) -> [SeqItem] {
        let d = digs(n)
        return d.enumerated().map { i, x in SeqItem(pfx + String(i), String(x), c: c, g: i < d.count - 1 ? 0 : nil) }
    }

    struct Row {
        var nIds: [String]
        var mIds: [String]
        var all: [String]
        var x0: Double
        var x1: Double
    }

    /// `seq` with an opacity / delay applied to every glyph, like the web build's `seq(..., {o, dl})`.
    @discardableResult
    static func kseq(_ S: inout Scene, _ items: [SeqItem], _ cx: Double, _ y: Double, _ z: Double,
                     o: Double? = nil, dl: Double? = nil) -> [Double] {
        let q = S.seq(items, cx, y, z)
        for it in items { S.mod(it.id, o: o, dl: dl) }
        return q.xs
    }

    static func problemRow(_ S: inout Scene, _ P: BP, _ cx: Double, _ y: Double) -> Row {
        let nI = numItems("n", P.n), mI = numItems("m", P.m)
        let xs = S.seq(nI + [SeqItem("op", TIMES, op: true)] + mI, cx, y, Z).xs
        let nIds = nI.map { $0.id }, mIds = mI.map { $0.id }
        return Row(nIds: nIds, mIds: mIds, all: nIds + ["op"] + mIds, x0: xs[0], x1: xs[xs.count - 1])
    }

    static func label(_ S: inout Scene, _ P: BP) {
        S.el("lbl", "\(P.n) \(TIMES) \(P.m)", 512, 168, z: 36, c: MUTE, w: 800)
    }

    static func meet(_ S: inout Scene, _ P: BP, _ ph: Int) {
        let r = problemRow(&S, P, 512, 300)
        if ph == 0 { S.hide(r.all) }
        if ph >= 2 { S.mods(r.mIds, c: BLUE); S.fa(r.mIds); S.h(r.mIds[r.mIds.count - 1]) }
    }

    /// Number digits on a working row, multiplier faded, small label on top.
    @discardableResult
    static func work(_ S: inout Scene, _ P: BP, _ y: Double) -> Row {
        let r = problemRow(&S, P, 512, 300)
        S.mods(["op"] + r.mIds, o: 0, s: 0.6)
        let xs = xsOf(r.nIds.count, 512, 60)
        for (i, id) in r.nIds.enumerated() { S.mod(id, x: xs[i], y: y) }
        label(&S, P)
        return r
    }

    static func green(_ S: inout Scene, _ ids: [String]) { S.mods(ids, c: GREEN) }

    static func win(_ S: inout Scene, _ x: Double, _ y: Double, _ w: Double, _ h: Double) {
        S.finale = SFinale(x: x, y: y, w: w, h: h)
        S.focus = nil; S.hand = nil; S.win = true
    }

    static func hexAlpha(_ hex: UInt32, _ a: Double) -> Color { Color(hex: hex, alpha: a) }
}
