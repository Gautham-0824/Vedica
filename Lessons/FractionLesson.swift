import SwiftUI

/// Basics: adding unlike fractions crosswise (Urdhva-Tiryagbhyam).
/// This one has its own scene builder (the web build's `frame()`), but runs on the shared runner.
enum FractionLesson {
    private static let INK = Theme.ink, BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted
    private static let TIMES = "\u{00D7}"

    struct FP { var a: Int, b: Int, c: Int, d: Int }
    static let DEMO = FP(a: 8, b: 3, c: 9, d: 4)
    static let PROBS = [FP(a: 2, b: 5, c: 1, d: 3), FP(a: 1, b: 2, c: 1, d: 3), FP(a: 3, b: 4, c: 1, d: 5)]

    static func problem(_ f: FP) -> Problem { Problem(n: "\(f.a)/\(f.b)", m: "\(f.c)/\(f.d)") }
    static func parse(_ p: Problem) -> FP {
        let x = p.n.split(separator: "/").map { Int($0) ?? 1 }, y = p.m.split(separator: "/").map { Int($0) ?? 1 }
        guard x.count == 2, y.count == 2 else { return PROBS[0] }
        return FP(a: x[0], b: x[1], c: y[0], d: y[1])
    }

    struct Lay { var Ax, Px, Bx, Ex, Nx, topY, barY, botY, rY: Double }
    static let L1 = Lay(Ax: 392, Px: 512, Bx: 632, Ex: 512, Nx: 740, topY: 330, barY: 385, botY: 440, rY: 212)
    static let L2 = Lay(Ax: 230, Px: 335, Bx: 440, Ex: 560, Nx: 740, topY: 330, barY: 385, botY: 440, rY: 212)
    static let L3 = Lay(Ax: 230, Px: 335, Bx: 440, Ex: 560, Nx: 740, topY: 262, barY: 316, botY: 370, rY: 166)

    static let times: [[Double]] = [[0, 450, 1700, 2600], [0, 450, 1650, 2600], [0, 450, 1650, 2600],
                                    [0, 80, 1150, 2150], [0, 450, 1450, 2450], [0, 500]]
    static let ends: [Double] = [3200, 3300, 3300, 2900, 3300, 700]
    static let names = ["Meet the problem", "Cross multiply", "The other way", "Add the tops", "Multiply the bottoms", "Your turn"]
    static let recap: [(String, Color)] = [("Bottoms: 3 and 4", BLUE), ("8 \(TIMES) 4 = 32", BLUE), ("9 \(TIMES) 3 = 27", OR),
                                           ("32 + 27 = 59", BLUE), ("3 \(TIMES) 4 = 12", BLUE)]

    // MARK: frame builder

    struct Ek {
        var x: Double, y: Double, o: Double, s: Double
        var c: Color?
    }

    enum Hand { case key(String), pt(Double, Double) }

    final class Frame {
        var E: [String: Ek] = [:]
        var T: [String: String] = [:]
        var focus: [String]? = nil
        var l1 = 0, l2 = 0
        var hand: Hand? = nil
        var finale = false
        var activeSlot: String? = nil
        let L: Lay
        let P: FP

        init(_ L: Lay, _ P: FP) {
            self.L = L; self.P = P
            func set(_ k: String, _ x: Double, _ y: Double, _ o: Double = 1, _ s: Double = 1, _ c: Color? = nil) {
                E[k] = Ek(x: x, y: y, o: o, s: s, c: c)
            }
            set("aT", L.Ax, L.topY); set("aB", L.Ax, L.botY); set("bT", L.Bx, L.topY); set("bB", L.Bx, L.botY)
            set("barA", L.Ax, L.barY); set("barB", L.Bx, L.barY); set("plus", L.Px, L.barY, 1, 1, FractionLesson.BLUE)
            set("eq", L.Ex, L.barY, 0, 0.6, FractionLesson.MU); set("ansBar", L.Nx, L.barY, 0, 0)
            set("r1", L.Ax, L.rY, 0, 0.5, FractionLesson.BLUE); set("r2", L.Bx, L.rY, 0, 0.5, FractionLesson.OR)
            set("num", L.Nx, L.topY, 0, 0.6); set("den", L.Nx, L.botY, 0, 0.6)
            set("gA", L.Nx, L.barY, 0); set("gB", L.Nx, L.barY, 0); set("gOp", L.Nx, L.barY, 0, 0.3)
            set("sR1", L.Ax, L.rY, 0, 0.8); set("sR2", L.Bx, L.rY, 0, 0.8); set("sN", L.Nx, L.topY, 0, 0.8); set("sD", L.Nx, L.botY, 0, 0.8)
            let r1v = P.a * P.d, r2v = P.c * P.b
            T = ["aT": String(P.a), "aB": String(P.b), "bT": String(P.c), "bB": String(P.d), "plus": "+", "eq": "=",
                 "r1": String(r1v), "r2": String(r2v), "num": String(r1v + r2v), "den": String(P.b * P.d),
                 "gA": "", "gB": "", "gOp": FractionLesson.TIMES]
        }

        func show(_ ks: String...) { for k in ks { E[k]?.o = 1; E[k]?.s = 1 } }

        func lineEnds(_ one: Bool) -> ((Double, Double), (Double, Double)) {
            one ? ((L.Ax + 34, L.topY + 24), (L.Bx - 34, L.botY - 24))
                : ((L.Bx - 34, L.topY + 24), (L.Ax + 34, L.botY - 24))
        }

        func cross(_ one: Bool, _ stage: Int, _ col: Color) {
            let s1 = one ? "aT" : "bT", s2 = one ? "bB" : "aB", rk = one ? "r1" : "r2"
            let (p0, p1) = lineEnds(one)
            T["gA"] = T[s1]; T["gB"] = T[s2]; T["gOp"] = FractionLesson.TIMES
            E[s1]?.c = col; E[s2]?.c = col
            var ga = E[s1]!; ga.o = 0; ga.c = col; E["gA"] = ga
            var gb = E[s2]!; gb.o = 0; gb.c = col; E["gB"] = gb
            E["gOp"] = Ek(x: E[rk]!.x, y: L.rY, o: 0, s: 0.3, c: col)
            focus = [s1, s2]
            if stage == 0 { hand = .pt(p0.0, p0.1) }
            if stage >= 1 { if one { l1 = 1 } else { l2 = 1 }; hand = .pt(p1.0, p1.1) }
            if stage == 2 {
                E["gA"] = Ek(x: E[rk]!.x - 46, y: L.rY, o: 1, s: 0.64, c: col)
                E["gB"] = Ek(x: E[rk]!.x + 46, y: L.rY, o: 1, s: 0.64, c: col)
                E["gOp"] = Ek(x: E[rk]!.x, y: L.rY, o: 1, s: 0.5, c: col)
                focus! += ["gA", "gB", "gOp"]; hand = .key(rk)
            }
            if stage >= 3 {
                let g = Ek(x: E[rk]!.x, y: L.rY, o: 0, s: 0.4, c: col)
                E["gA"] = g; E["gB"] = g
                E["gOp"]?.o = 0; show(rk); focus = [rk, s1, s2]; hand = .key(rk)
            }
        }

        func toNum(_ stage: Int) {
            if stage == 2 {
                E["r1"] = Ek(x: L.Nx - 64, y: L.topY, o: 1, s: 1.3, c: FractionLesson.BLUE)
                E["r2"] = Ek(x: L.Nx + 64, y: L.topY, o: 1, s: 1.3, c: FractionLesson.OR)
                E["gOp"] = Ek(x: L.Nx, y: L.topY, o: 1, s: 0.55, c: FractionLesson.INK); T["gOp"] = "+"
                focus = ["r1", "r2", "gOp", "ansBar"]; hand = .pt(L.Nx, L.topY + 8)
            }
        }

        func merged() {
            E["r1"] = Ek(x: L.Nx, y: L.topY, o: 0, s: 0.9, c: FractionLesson.BLUE)
            E["r2"] = Ek(x: L.Nx, y: L.topY, o: 0, s: 0.9, c: FractionLesson.OR)
            E["gOp"]?.o = 0; T["gOp"] = "+"
        }

        func toDen(_ stage: Int) {
            T["gA"] = T["aB"]; T["gB"] = T["bB"]; T["gOp"] = FractionLesson.TIMES
            var ga = E["aB"]!; ga.o = 0; E["gA"] = ga
            var gb = E["bB"]!; gb.o = 0; E["gB"] = gb
            E["gOp"] = Ek(x: L.Nx, y: L.botY, o: 0, s: 0.3, c: nil)
            if stage == 1 {
                E["gA"] = Ek(x: L.Nx - 58, y: L.botY, o: 1, s: 0.9, c: nil)
                E["gB"] = Ek(x: L.Nx + 58, y: L.botY, o: 1, s: 0.9, c: nil)
                E["gOp"] = Ek(x: L.Nx, y: L.botY, o: 1, s: 0.5, c: FractionLesson.BLUE)
                focus = ["aB", "bB", "gA", "gB", "gOp", "ansBar"]; hand = .pt(L.Nx, L.botY + 10)
            }
            if stage >= 2 {
                let g = Ek(x: L.Nx, y: L.botY, o: 0, s: 0.5, c: nil)
                E["gA"] = g; E["gB"] = g; show("den")
            }
        }

        func steps(_ step: Int, _ phase: Int) {
            switch step {
            case 0:
                if phase == 0 { for k in ["aT", "aB", "bT", "bB", "barA", "barB", "plus"] { E[k]?.o = 0; E[k]?.y += 26 } }
                if phase >= 2 { focus = ["aB", "bB"]; E["aB"]?.c = FractionLesson.BLUE; E["bB"]?.c = FractionLesson.BLUE; hand = .key(phase == 2 ? "aB" : "bB") }
            case 1:
                cross(true, phase, FractionLesson.BLUE)
            case 2:
                show("r1"); l1 = 2; cross(false, phase, FractionLesson.OR)
            case 3:
                show("r1", "r2"); focus = ["r1", "r2"]
                l1 = 3; l2 = 3
                if phase >= 1 { show("eq", "ansBar"); hand = .key("r1") }
                toNum(phase)
                if phase >= 3 { merged(); show("num"); focus = ["num", "ansBar"]; hand = .key("num") }
            default:
                show("eq", "ansBar", "num"); merged()
                focus = ["aB", "bB"]; E["aB"]?.c = FractionLesson.BLUE; E["bB"]?.c = FractionLesson.BLUE; hand = .key("aB")
                toDen(phase)
                if phase == 2 { focus = ["num", "den", "ansBar"]; hand = .key("den") }
                if phase >= 3 { focus = nil; hand = nil; finale = true }
            }
            finish()
        }

        func practice(_ pr: PracticeState) {
            let t = pr.task, a = pr.anim, tick = pr.tick
            func filled(_ i: Int) -> Bool { t > i || (t == i && a == 2) }
            show("eq", "ansBar")
            for (i, k) in ["sR1", "sR2", "sN", "sD"].enumerated() where !filled(i) { show(k) }
            if filled(0) { show("r1") }
            if filled(1) { show("r2") }
            if filled(2) { merged(); show("num") }
            if filled(3) { show("den") }
            if t == 0 || t == 1 {
                let one = t == 0, col = one ? FractionLesson.BLUE : FractionLesson.OR
                activeSlot = one ? "sR1" : "sR2"
                if !one { l1 = 2 }
                cross(one, a == 0 ? 1 : a == 1 ? 2 : 3, col)
                if a == 0 {
                    let (p0, p1) = lineEnds(one)
                    hand = tick % 2 == 1 ? .pt(p1.0, p1.1) : .pt(p0.0, p0.1)
                }
                focus!.append(activeSlot!)
                if a == 2 { focus = [one ? "r1" : "r2"] }
            } else if t == 2 {
                activeSlot = "sN"; l1 = 3; l2 = 3
                focus = ["r1", "r2", "sN", "ansBar"]; hand = .key(tick % 2 == 1 ? "r2" : "r1")
                if a == 1 { toNum(2) }
                if a == 2 { focus = ["num", "ansBar"]; hand = .key("num") }
            } else if t == 3 {
                activeSlot = "sD"
                focus = ["aB", "bB", "sD", "ansBar"]; E["aB"]?.c = FractionLesson.BLUE; E["bB"]?.c = FractionLesson.BLUE
                hand = .key(tick % 2 == 1 ? "bB" : "aB")
                toDen(a)
                if a == 2 { focus = ["num", "den", "ansBar"]; hand = .key("den") }
            } else {
                finale = true
            }
            finish()
        }

        func finish() {
            if finale { E["num"]?.c = FractionLesson.BLUE; E["den"]?.c = FractionLesson.BLUE; E["ansBar"]?.c = FractionLesson.BLUE }
        }

        // MARK: to Scene

        func scene() -> Scene {
            var S = Scene("")
            let base: Set<String> = ["aT", "aB", "bT", "bB"]
            func size(_ k: String) -> Double { (k == "r1" || k == "r2") ? 52 : (k == "plus" || k == "eq") ? 64 : 80 }
            let fs = focus.map { Set($0) }
            // slots + bars first so glyphs sit on top
            for (k, w) in [("barA", 92.0), ("barB", 92.0), ("ansBar", 224.0)] {
                let e = E[k]!
                let o = k == "ansBar" ? (e.s > 0 ? 1.0 : 0.0) : e.o
                S.box(k, e.x, e.y, w, 7, o: o, s: k == "ansBar" ? max(e.s, 0.05) : 1, r: 99, c: e.c ?? INK, fill: e.c ?? INK, dimTo: 0.14)
            }
            for k in ["sR1", "sR2", "sN", "sD"] {
                let e = E[k]!, act = activeSlot == k
                let sz: Double = (k == "sR1" || k == "sR2") ? 70 : 88
                S.box(k, e.x, e.y, sz, sz, o: e.o, s: e.s * (act ? 1.06 : 1), r: 22, dashed: !act,
                      c: act ? BLUE : Theme.dash, fill: act ? Color(hex: 0x0a84ff, alpha: 0.07) : .clear,
                      q: "?", qz: sz * 0.42, qc: act ? BLUE : Theme.ghost, bw: 2.5, dimTo: 0.35)
            }
            for k in ["aT", "aB", "bT", "bB", "plus", "eq", "r1", "r2", "num", "den", "gA", "gB", "gOp"] {
                let e = E[k]!
                let emph = (fs?.contains(k) ?? false) && base.contains(k) ? 1.08 : 1.0
                S.el(k, T[k] ?? "", e.x, e.y, z: size(k), c: e.c ?? INK,
                     w: (k == "plus" || k == "eq" || k == "gOp") ? 700 : 800, o: e.o, s: e.s * emph)
            }
            let (a0, a1) = lineEnds(true), (b0, b1) = lineEnds(false)
            S.line(0, a0, a1, c: BLUE, state: l1)
            S.line(1, b0, b1, c: OR, state: l2)
            S.focus = focus
            if let h = hand {
                switch h {
                case .pt(let x, let y): S.hp(x, y)
                case .key(let k):
                    let e = E[k]!
                    S.hp(e.x + 10, e.y + ((k == "r1" || k == "r2") ? 30 : 40))
                }
            }
            if finale { S.finale = SFinale(x: L.Nx, y: L.barY, w: 264, h: 268) }
            return S
        }
    }

    // MARK: tasks

    static func tasks(_ P: FP) -> [PTask] {
        let a1 = P.a * P.d, a2 = P.c * P.b
        let caps = ["Your turn. Multiply crosswise: **\(P.a) \(TIMES) \(P.d)**.",
                    "Now the other way: **\(P.c) \(TIMES) \(P.b)**.",
                    "Add the two results: **\(a1) + \(a2)**.",
                    "Multiply the bottoms: **\(P.b) \(TIMES) \(P.d)**."]
        let qs = ["\(P.a) \(TIMES) \(P.d)", "\(P.c) \(TIMES) \(P.b)", "\(a1) + \(a2)", "\(P.b) \(TIMES) \(P.d)"]
        let ans = [a1, a2, a1 + a2, P.b * P.d]
        let pairs: [(Int, Int)?] = [(P.a, P.d), (P.c, P.b), nil, (P.b, P.d)]
        return (0..<4).map { i in
            var hint = "Not quite. Start at \(a1) and count on \(a2)."
            if let (x, n) = pairs[i] {
                hint = n <= 6 ? "Not quite. \(n) groups of \(x): " + Array(repeating: String(x), count: n).joined(separator: " + ")
                              : "Not quite. Try \(x) \(TIMES) \(n) again."
            }
            return PTask(g: "", cap: caps[i], q: qs[i], ans: String(ans[i]), ex: [], hint: hint,
                         hl: i == 1 ? OR : BLUE, prompt: qs[i] + " =")
        }
    }

    final class Cycle { var i = 0 }
    static let cycle = Cycle()

    static var spec: LessonSpec {
        let defs: [StepDef] = (0..<6).map { i in
            StepDef(g: String(i), n: "demo", m: "", k: nil, name: names[i], times: times[i], end: ends[i])
        }
        return LessonSpec(
            id: "frac", topTitle: "", cardTitle: "Adding Unlike Fractions",
            cardBlurb: "When adding two fractions whose bottom numbers are different.",
            sutra: "Urdhva-Tiryagbhyam",
            defaultHint: "Look where the hand is pointing.",
            style: RenderStyle(dur: 0.82),
            steps: defs,
            practice: [problem(PROBS[0])],
            random: {
                cycle.i = (cycle.i + 1) % PROBS.count
                return problem(PROBS[cycle.i])
            },
            stepScene: { def, ph in
                let i = Int(def.g) ?? 0
                let lay = (i <= 2 || (i == 3 && ph == 0)) ? L1 : L2
                let f = Frame(lay, DEMO)
                f.steps(i, ph)
                return f.scene()
            },
            caption: { def in
                switch Int(def.g) ?? 0 {
                case 0: return ("Two fractions with **different bottoms**: 3 and 4.", BLUE)
                case 1: return ("Multiply crosswise: **8 \(TIMES) 4 = 32**.", BLUE)
                case 2: return ("Now the other way: **9 \(TIMES) 3 = 27**.", OR)
                case 3: return ("Add the two results: **32 + 27 = 59**. That\u{2019}s the new top.", BLUE)
                default: return ("Multiply the bottoms: **3 \(TIMES) 4 = 12**. Answer: **59/12**.", BLUE)
                }
            },
            summary: { def in
                let i = Int(def.g) ?? 0
                return i >= 1 && i <= 4 ? recap[i] : nil
            },
            tasks: { p in tasks(parse(p)) },
            practiceScene: { p, t, ok, done in
                var pr = PracticeState(); pr.task = t; pr.ok = ok; pr.done = done; pr.anim = ok ? 2 : 0
                let f = Frame(L3, parse(p)); f.practice(pr); return f.scene()
            },
            doneCaption: { p in
                let P = parse(p)
                return "**\(P.a)/\(P.b) + \(P.c)/\(P.d) = \(P.a * P.d + P.c * P.b)/\(P.b * P.d)**. Same trick, every time."
            },
            summaryLines: { def in
                let i = Int(def.g) ?? 0
                return i >= 1 && i <= 4 ? [recap[i]] : []
            },
            practiceByState: { p, pr in
                let f = Frame(L3, parse(p))
                var s = pr
                if s.done { s.task = 4 }
                f.practice(s)
                return f.scene()
            },
            okAdvanceMs: (1900, 1900), okAnimMs: 850, tickMs: 1250,
            replayOnWrong: false, taskProgress: true,
            okHint: "Watch it move into place.",
            doneSub: { p in
                let P = parse(p)
                return "\(P.a)/\(P.b) + \(P.c)/\(P.d) = \(P.a * P.d + P.c * P.b)/\(P.b * P.d), solved crosswise."
            },
            bigRail: true, stageShift: -110, fractionExample: true
        )
    }
}
