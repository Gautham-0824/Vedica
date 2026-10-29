import SwiftUI

/// Advanced: Urdhva-Tiryagbhyam on two-digit x two-digit, with carries.
enum TwoDigitMultLesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let CX: [Double] = [640, 520, 400, 280]
    private static let OY = 198.0, BO = 338.0, LY = 396.0, CY = 428.0, RY2 = 492.0, LB = 562.0, BU = 618.0, BCX = 520.0
    private static let Q = 52.0 / 96.0
    private static let rule = Color(hex: 0xcbd7e3)

    struct MY {
        var n: Int
        var a: Int, b: Int, a1: Int, a0: Int, b1: Int, b0: Int
        var p0: Int, c0: Int, x1: Int, x2: Int, cr: Int, s1: Int, c1: Int, p2: Int, s2: Int
        var r: [Int]
        var big: Bool
        var ans: Int
    }

    static func M(_ n: Int) -> MY {
        let a = n / 100, b = n % 100
        let a1 = a / 10, a0 = a % 10, b1 = b / 10, b0 = b % 10
        let p0 = a0 * b0, c0 = p0 / 10, x1 = a1 * b0, x2 = a0 * b1, cr = x1 + x2, s1 = cr + c0, c1 = s1 / 10
        let p2 = a1 * b1, s2 = p2 + c1
        let r = [p0 % 10, s1 % 10, s2 % 10, s2 / 10]
        let ans = r[3] * 1000 + r[2] * 100 + r[1] * 10 + r[0]
        return MY(n: n, a: a, b: b, a1: a1, a0: a0, b1: b1, b0: b0, p0: p0, c0: c0, x1: x1, x2: x2, cr: cr, s1: s1,
                  c1: c1, p2: p2, s2: s2, r: r, big: r[3] > 0, ans: ans)
    }

    // MARK: lesson-local scene helpers (this lesson lays digits out by place value)

    private static func isOperand(_ id: String) -> Bool {
        let c = Array(id)
        return c.count == 2 && (c[0] == "a" || c[0] == "b") && (c[1] == "0" || c[1] == "1")
    }

    /// Dim only the operand digits that are not part of the current move.
    private static func keep(_ S: inout Scene, _ act: [String]) {
        var ids: [String] = []
        for k in S.eOrder + S.bOrder {
            let id = String(k.dropFirst(S.pre.count))
            if !isOperand(id) || act.contains(id) { ids.append(id) }
        }
        S.fa(ids)
    }

    private struct BI {
        var id: String; var t: String; var c: Color? = nil; var g: Double? = nil
        init(_ id: String, _ t: Any, c: Color? = nil, g: Double? = nil) { self.id = id; self.t = String(describing: t); self.c = c; self.g = g }
    }

    private static func bw(_ t: String) -> Double {
        t.allSatisfy({ $0.isASCII && $0.isNumber }) && !t.isEmpty ? Double(t.count) * 32 : 30
    }

    private static func bub(_ S: inout Scene, _ items: [BI]) {
        let G = 14.0
        func gp(_ it: BI) -> Double { it.g ?? G }
        var tot = 0.0
        for (i, it) in items.enumerated() { tot += bw(it.t) + (i < items.count - 1 ? gp(it) : 0) }
        var x = BCX - tot / 2
        for (i, it) in items.enumerated() {
            let w = bw(it.t), c = x + w / 2
            S.el(it.id, it.t, c, BU, z: 96, c: it.c ?? INK, s: Q)
            x += w + (i < items.count - 1 ? gp(it) : 0)
        }
        S.box("bub", BCX, BU, 520, 84, r: 28, shadow: true)
    }

    private static func split(_ v: Int, _ cid: String, _ rid: String, _ cc: Color) -> [BI] {
        v >= 10 ? [BI(cid, v / 10, c: cc, g: 0), BI(rid, v % 10, c: GR)] : [BI(rid, v, c: GR)]
    }

    private static func ops(_ S: inout Scene, _ Y: MY, _ hl: [String: Color], _ lvIn: Int? = nil) {
        let lv = lvIn ?? 2
        func c(_ id: String) -> Color { hl[id] ?? INK }
        S.el("a1", String(Y.a1), CX[1], OY, z: 80, c: c("a1")); S.el("a0", String(Y.a0), CX[0], OY, z: 80, c: c("a0"))
        if lv < 1 { return }
        S.el("b1", String(Y.b1), CX[1], BO, z: 80, c: c("b1")); S.el("b0", String(Y.b0), CX[0], BO, z: 80, c: c("b0"))
        S.el("op", "\u{00D7}", CX[2], BO, z: 64, c: MU)
        if lv < 2 { return }
        S.box("ln", 520, LY, 380, 5, r: 3, c: rule, fill: rule)
        for (i, t) in ["1s", "10s", "100s", "1000s"].enumerated() where i < 3 || Y.big {
            S.el("pl\(i)", t, CX[i], LB, z: 22, c: MU, w: 800)
        }
    }

    private static func R0(_ S: inout Scene, _ Y: MY, _ chip: Bool) {
        S.el("r0", String(Y.r[0]), CX[0], RY2, c: GR)
        if Y.c0 > 0 && chip { S.el("c0", String(Y.c0), CX[1], CY, c: OR, s: 0.36) }
    }

    // MARK: scenes

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = M(Int(d.n) ?? 0)
        var S = Scene(d.n + ".")
        switch d.g {
        case "meet":
            ops(&S, Y, [:], ph)
        case "ones":
            ops(&S, Y, ph < 2 ? ["a0": OR, "b0": OR] : [:])
            if ph < 2 { S.arrow(0, (CX[0], OY + 46), (CX[0], BO - 50), c: OR, bend: 0) }
            if ph == 1 {
                bub(&S, [BI("oa", Y.a0, c: OR), BI("ox", "\u{00D7}"), BI("ob", Y.b0, c: OR), BI("oe", "=")] + split(Y.p0, "c0", "r0", OR))
            }
            if ph >= 2 { R0(&S, Y, true) }
            S.h(ph == 0 ? "a0" : "r0")
            keep(&S, ph < 2 ? ["a0", "b0"] : [])
        case "cross":
            let W = Y.c0 > 0 ? 5 : 4
            var hl: [String: Color] = [:]
            if ph < W {
                hl["a1"] = BLUE; hl["b0"] = BLUE
                if ph >= 2 { hl["a0"] = OR; hl["b1"] = OR }
            }
            ops(&S, Y, hl)
            R0(&S, Y, ph < W)
            if ph < W { S.arrow(0, (CX[1] + 16, OY + 46), (CX[0] - 20, BO - 50), c: BLUE, st: ph >= 3 ? 2 : 1, bend: 0) }
            if ph >= 2 && ph < W { S.arrow(1, (CX[0] - 16, OY + 46), (CX[1] + 20, BO - 50), c: OR, st: ph >= 3 ? 2 : 1, bend: 0) }
            if ph == 1 { bub(&S, [BI("g1a", Y.a1, c: BLUE), BI("g1x", "\u{00D7}"), BI("g1b", Y.b0, c: BLUE), BI("g1e", "="), BI("g1p", Y.x1, c: BLUE)]) }
            if ph == 2 { bub(&S, [BI("g2a", Y.a0, c: OR), BI("g2x", "\u{00D7}"), BI("g2b", Y.b1, c: OR), BI("g2e", "="), BI("g2p", Y.x2, c: OR)]) }
            if ph == 3 {
                let tail: [BI] = Y.c0 > 0 ? [BI("sr", Y.cr)] : split(Y.s1, "c1", "r1", OR)
                bub(&S, [BI("sa", Y.x1, c: BLUE), BI("sp", "+"), BI("sb", Y.x2, c: OR), BI("se", "=")] + tail)
            }
            if ph == 4 && Y.c0 > 0 {
                bub(&S, [BI("ta", Y.cr), BI("tp", "+"), BI("tc", Y.c0, c: OR), BI("te", "=")] + split(Y.s1, "c1", "r1", OR))
            }
            if ph >= W {
                S.el("r1", String(Y.r[1]), CX[1], RY2, c: GR)
                if Y.c1 > 0 { S.el("c1", String(Y.c1), CX[2], CY, c: OR, s: 0.36) }
            }
            S.h(ph == 0 ? "a1" : (ph == 1 ? "g1p" : (ph == 2 ? "a0" : ((ph == 3 && Y.c0 > 0) ? "sr" : "r1"))))
            keep(&S, ph >= W ? [] : (ph < 2 ? ["a1", "b0"] : ["a1", "b0", "a0", "b1"]))
        case "left":
            let W = Y.c1 > 0 ? 3 : 2
            ops(&S, Y, ph < W ? ["a1": OR, "b1": OR] : [:])
            S.el("r0", String(Y.r[0]), CX[0], RY2, c: GR); S.el("r1", String(Y.r[1]), CX[1], RY2, c: GR)
            if Y.c1 > 0 && ph < W { S.el("c1", String(Y.c1), CX[2], CY, c: OR, s: 0.36) }
            if ph < 2 { S.arrow(0, (CX[1], OY + 46), (CX[1], BO - 50), c: OR, bend: 0) }
            if ph == 1 {
                let tail: [BI] = Y.c1 > 0 ? [BI("lp", Y.p2)] : split(Y.s2, "r3", "r2", GR)
                bub(&S, [BI("la", Y.a1, c: OR), BI("lx", "\u{00D7}"), BI("lb", Y.b1, c: OR), BI("le", "=")] + tail)
            }
            if ph == 2 && Y.c1 > 0 {
                bub(&S, [BI("ka", Y.p2), BI("kp", "+"), BI("kc", Y.c1, c: OR), BI("ke", "=")] + split(Y.s2, "r3", "r2", GR))
            }
            if ph >= W {
                S.el("r2", String(Y.r[2]), CX[2], RY2, c: GR)
                if Y.big { S.el("r3", String(Y.r[3]), CX[3], RY2, c: GR) }
            }
            S.h(ph == 0 ? "a1" : ((ph == 1 && Y.c1 > 0) ? "lp" : "r2"))
            keep(&S, ph < W ? ["a1", "b1"] : [])
        case "ans":
            ops(&S, Y, [:])
            let n = Y.big ? 4 : 3
            for i in 0..<n { S.el("r\(i)", String(Y.r[i]), CX[i], RY2, c: GR) }
            for i in 0..<4 { if S.E[S.pre + "pl\(i)"] != nil { S.E[S.pre + "pl\(i)"]!.o = 0 } }
            S.finale = SFinale(x: (CX[0] + CX[n - 1]) / 2, y: RY2, w: Double(n) * 118 + 60, h: 140)
            S.win = true
            if ph >= 1 {
                S.box("tag", BCX, BU, 440, 72, r: 24, shadow: true, q: "\(Y.a) \u{00D7} \(Y.b) = \(Y.ans)", qz: 34, qc: GR)
            }
            S.h("r\(n - 1)")
            keep(&S, [])
        default: break
        }
        return S
    }

    private static func hlOf(_ g: String) -> Color {
        switch g {
        case "ans": return GR
        case "ones": return OR
        default: return BLUE
        }
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = M(Int(d.n) ?? 0)
        switch d.g {
        case "ones": return ("\(Y.a0) \u{00D7} \(Y.b0) = \(Y.p0)", hlOf(d.g))
        case "cross": return ("Cross: \(Y.s1)", hlOf(d.g))
        case "left": return ("\(Y.a1) \u{00D7} \(Y.b1)" + (Y.c1 > 0 ? " + \(Y.c1)" : "") + " = \(Y.s2)", hlOf(d.g))
        case "ans": return ("Answer: \(Y.ans)", hlOf(d.g))
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = M(Int(d.n) ?? 0)
        var t = ""
        switch d.g {
        case "meet":
            t = d.n == "2341" ? "Let\u{2019}s multiply **\(Y.a) \u{00D7} \(Y.b)** with Urdhva-Tiryagbhyam: **vertically and crosswise**."
                              : "Now **\(Y.a) \u{00D7} \(Y.b)**. Same steps, but watch the **carries**."
        case "ones":
            t = "Ones, straight down: **\(Y.a0) \u{00D7} \(Y.b0) = \(Y.p0)**. " + (Y.c0 > 0 ? "Write **\(Y.r[0])**, carry **\(Y.c0)**." : "Write **\(Y.r[0])**.")
        case "cross":
            t = "Crosswise: **\(Y.a1)\u{00D7}\(Y.b0) + \(Y.a0)\u{00D7}\(Y.b1) = \(Y.cr)**. " + (Y.c0 > 0 ? "Add carry \(Y.c0): **\(Y.s1)**. " : "")
                + (Y.c1 > 0 ? "Write **\(Y.r[1])**, carry **\(Y.c1)**." : "Write **\(Y.r[1])**.")
        case "left":
            t = "Left side, straight down: **\(Y.a1) \u{00D7} \(Y.b1) = \(Y.p2)**" + (Y.c1 > 0 ? ", plus carry \(Y.c1) = **\(Y.s2)**." : ".") + " Write **\(Y.s2)**."
        case "ans":
            let digits = Array(Y.r.prefix(Y.big ? 4 : 3).reversed()).map(String.init).joined(separator: " ")
            t = "Read the digits left to right: **" + digits + "**. So **\(Y.a) \u{00D7} \(Y.b) = \(Y.ans)**!"
        default: t = "Your turn."
        }
        return (t, hlOf(d.g))
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = M(Int(p.n) ?? 0)
        let crossEx: [String] = [String(Y.a1), "\u{00D7}", String(Y.b0), "+", String(Y.a0), "\u{00D7}", String(Y.b1)] + (Y.c0 > 0 ? ["+", String(Y.c0)] : [])
        let leftEx: [String] = [String(Y.a1), "\u{00D7}", String(Y.b1)] + (Y.c1 > 0 ? ["+", String(Y.c1)] : [])
        return [
            PTask(g: "ones", cap: "Ones, straight down: **\(Y.a0) \u{00D7} \(Y.b0)**.", q: "\(Y.a0) \u{00D7} \(Y.b0)", ans: String(Y.p0),
                  ex: [String(Y.a0), "\u{00D7}", String(Y.b0)], hint: "Close! Multiply the two ones digits."),
            PTask(g: "cross", cap: "Crosswise, then add" + (Y.c0 > 0 ? " the carry **\(Y.c0)**" : "") + ".",
                  q: "\(Y.a1)\u{00D7}\(Y.b0) + \(Y.a0)\u{00D7}\(Y.b1)" + (Y.c0 > 0 ? " + \(Y.c0)" : ""), ans: String(Y.s1), ex: crossEx,
                  hint: "Close! Multiply both crosswise pairs and add them" + (Y.c0 > 0 ? ", plus the carry." : ".")),
            PTask(g: "left", cap: "Left side, straight down" + (Y.c1 > 0 ? ", plus the carry **\(Y.c1)**" : "") + ".",
                  q: "\(Y.a1) \u{00D7} \(Y.b1)" + (Y.c1 > 0 ? " + \(Y.c1)" : ""), ans: String(Y.s2), ex: leftEx,
                  hint: "Close! Multiply the tens digits" + (Y.c1 > 0 ? " and add the carry." : ".")),
            PTask(g: "ans", cap: "Read the written digits left to right and type the **answer**.", q: "\(Y.a) \u{00D7} \(Y.b)",
                  ans: String(Y.ans), ex: [], hint: "Close! Read the digits from left to right."),
        ]
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = M(Int(p.n) ?? 0)
        var S = Scene("p" + p.n + ".")
        let T = tasks(p)
        let tk = T[min(t, T.count - 1)]
        let fin = done || (ok && t == T.count - 1)
        let d = fin ? 4 : t + (ok ? 1 : 0)
        let Zp = 60.0
        let Po = 158.0, Pb = 226.0, Pl = 268.0, Pc = 290.0, Pr = 332.0
        S.el("a1", String(Y.a1), CX[1], Po, z: Zp); S.el("a0", String(Y.a0), CX[0], Po, z: Zp)
        S.el("b1", String(Y.b1), CX[1], Pb, z: Zp); S.el("b0", String(Y.b0), CX[0], Pb, z: Zp)
        S.el("op", "\u{00D7}", CX[2], Pb, z: 48, c: MU)
        S.box("ln", 520, Pl, 380, 4, r: 2, c: rule, fill: rule)
        func R(_ i: Int) { S.el("r\(i)", String(Y.r[i]), CX[i], Pr, z: Zp, c: GR) }
        if d >= 1 { R(0) }
        if d >= 2 { R(1) }
        if d >= 3 { R(2); if Y.big { R(3) } }
        if Y.c0 > 0 && d == 1 { S.el("c0", String(Y.c0), CX[1], Pc, z: Zp, c: OR, s: 0.5) }
        if Y.c1 > 0 && d == 2 { S.el("c1", String(Y.c1), CX[2], Pc, z: Zp, c: OR, s: 0.5) }
        if fin {
            let n = Y.big ? 4 : 3
            S.finale = SFinale(x: (CX[0] + CX[n - 1]) / 2, y: Pr, w: Double(n) * 118 + 40, h: 104)
            return S
        }
        if !tk.ex.isEmpty {
            let items = tk.ex.enumerated().map { (i, x) in
                SeqItem("te\(t)_\(i)", x, op: !x.allSatisfy { $0.isASCII && $0.isNumber })
            }
            let q = seqPlain(&S, items, 520, 396, 40)
            S.box("tb\(t)", 520, 396, max(240, q + 70), 62, r: 22, shadow: true)
        }
        return S
    }

    /// This lesson's `seq`: fixed gaps, operators drawn muted.
    private static func seqPlain(_ S: inout Scene, _ items: [SeqItem], _ cx: Double, _ y: Double, _ z: Double) -> Double {
        func w(_ it: SeqItem) -> Double { (it.t.count == 1 && it.t.first!.isASCII && it.t.first!.isNumber) ? z * 0.62 : z * 0.6 * Double(it.t.count) }
        var gaps: [Double] = []
        for i in items.indices { gaps.append(i == items.count - 1 ? 0 : z * 0.24) }
        var total = 0.0
        for (i, it) in items.enumerated() { total += w(it) + gaps[i] }
        var x = cx - total / 2
        for (i, it) in items.enumerated() {
            S.el(it.id, it.t, x + w(it) / 2, y, z: z, c: it.op ? MU : INK)
            x += w(it) + gaps[i]
        }
        return total
    }

    // MARK: spec

    private static func timing(_ g: String, _ Y: MY) -> ([Double], Double) {
        let base: ([Double], Double)
        switch g {
        case "meet": base = ([0, 700, 1500], 2700)
        case "ones": base = ([0, 600, 1700], 2900)
        case "cross": base = Y.c0 > 0 ? ([0, 600, 1700, 2800, 3900, 5000], 6200) : ([0, 600, 1700, 2800, 3900], 5100)
        case "left": base = Y.c1 > 0 ? ([0, 600, 1700, 2800], 4000) : ([0, 600, 1700], 2900)
        case "ans": base = ([0, 900], 2400)
        default: base = ([0, 500], 700)
        }
        if g == "practice" { return base }
        let nt: [Double] = base.0.enumerated().map { $0.offset == 0 ? 0 : 800 + Double($0.offset - 1) * 1500 }
        return (nt, nt[nt.count - 1] + 1300)
    }

    private static let steps: [StepDef] = {
        let list: [(String, Int, String)] = [
            ("meet", 2341, "Meet the problem"), ("ones", 2341, "Ones \u{00B7} straight down"), ("cross", 2341, "Tens \u{00B7} crosswise"),
            ("left", 2341, "Hundreds \u{00B7} straight down"), ("ans", 2341, "Read the answer"),
            ("meet", 4637, "A trickier one"), ("ones", 4637, "Ones \u{00B7} straight down"), ("cross", 4637, "Tens \u{00B7} crosswise"),
            ("left", 4637, "Hundreds \u{00B7} straight down"), ("ans", 4637, "Read the answer"), ("practice", 0, "Your turn"),
        ]
        return list.map { item in
            let t = timing(item.0, M(item.1))
            return StepDef(g: item.0, n: String(item.1), name: item.2, times: t.0, end: t.1)
        }
    }()

    private static func randomN() -> Problem {
        let n = (rnd(1, 9) * 10 + rnd(0, 9)) * 100 + rnd(1, 9) * 10 + rnd(0, 9)
        return Problem(n: String(n))
    }

    static let spec = LessonSpec(
        id: "tdm",
        topTitle: "Two-digit \u{00D7} two-digit",
        cardTitle: "Two-digit \u{00D7} two-digit",
        cardBlurb: "Urdhva-Tiryagbhyam: multiply two-digit numbers in one line. Go vertically and crosswise, write a digit, carry the rest.",
        teaser: [[TeaserRun(text: "23 \u{00D7} 41")], [TeaserRun(text: "\u{2192}", color: Theme.muted)],
                 [TeaserRun(text: "943 \u{2713}", color: Theme.green, pop: true)]],
        sutra: "Urdhva-Tiryagbhyam: vertically and crosswise",
        defaultHint: "Use the sutra from the lesson.",
        style: RenderStyle(dimElement: 0.3, dimBox: 0.35, blur: 1.5, newElementScale: 0.55, newBoxScale: 0.8, reappearFresh: true),
        steps: steps,
        practice: [Problem(n: "1234"), Problem(n: "5237"), Problem(n: "3142"), Problem(n: "6425")],
        random: randomN,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { p in
            let Y = M(Int(p.n) ?? 0)
            return "**\(Y.a) \u{00D7} \(Y.b) = \(Y.ans)**. Same trick, every time."
        },
        replayStep: { p, tk in
            let Y = M(Int(p.n) ?? 0)
            let t = timing(tk.g, Y)
            return StepDef(g: tk.g, n: p.n, name: "", times: t.0, end: t.1)
        }
    )
}
