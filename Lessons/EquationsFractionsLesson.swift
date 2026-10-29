import SwiftUI

/// Advanced: Sopantyadvayamantyam. 1/(AB) + 1/(AC) = 1/(AD) + 1/(BC) with equally spaced factors,
/// solved in one line: ultimate + twice the penultimate = 0.
enum EquationsFractionsLesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let BU = 618.0, BCX = 575.0, Q = 52.0 / 96.0, CHY = 500.0, FW = 256.0
    private static let CXs: [Double] = [335, 495, 655, 815]
    private static let T4: [[Int]] = [[0, 1], [0, 2], [0, 3], [1, 2]]

    struct FY {
        var n: Int
        var a: Int, k: Int
        var f: [Int]
        var u: Int, p: Int, num: Int
        var int: Bool
        var whole: Int, rem: Int
    }

    static func M(_ nIn: Int) -> FY {
        let n = nIn == 0 ? 251 : nIn
        let a = n / 100, k = n % 100 - 50
        let f = [a, a + k, a + 2 * k, a + 3 * k]
        let u = f[3], p = f[2], num = u + 2 * p
        return FY(n: n, a: a, k: k, f: f, u: u, p: p, num: num, int: num % 3 == 0, whole: num / 3, rem: num % 3)
    }

    // MARK: layout helpers

    private static func lay(_ ws: [Double], _ cx: Double, _ g: Double) -> [Double] {
        let t = ws.reduce(0, +) + g * Double(ws.count - 1)
        var x = cx - t / 2
        return ws.map { w in let c = x + w / 2; x += w + g; return c }
    }

    private static func est(_ t: String) -> Double {
        t.reduce(0.0) { $0 + ($1 == "(" || $1 == ")" ? 16 : ($1 == "x" ? 24 : 26)) }
    }

    private static func bw(_ t: String) -> Double {
        if !t.isEmpty && t.allSatisfy({ $0.isASCII && $0.isNumber }) { return Double(t.count) * 32 }
        if t.count == 1, ["+", "\u{00D7}", "\u{00F7}", "="].contains(t) { return 30 }
        return Double(t.count) * 28
    }

    private struct BI {
        var id: String; var t: String; var c: Color? = nil; var dl: Double = 0
        init(_ id: String, _ t: String, c: Color? = nil, dl: Double = 0) { self.id = id; self.t = t; self.c = c; self.dl = dl }
    }

    @discardableResult
    private static func bub(_ S: inout Scene, _ items: [BI]) -> [String] {
        let G = 14.0
        var tot = 0.0
        for (i, it) in items.enumerated() { tot += bw(it.t) + (i < items.count - 1 ? G : 0) }
        var x = BCX - tot / 2
        for it in items {
            let w = bw(it.t), c = x + w / 2
            S.el(it.id, it.t, c, BU, z: 96, c: it.c ?? INK, s: Q, dl: it.dl)
            x += w + G
        }
        S.box("bub", BCX, BU, 560, 84, r: 28, shadow: true)
        return items.map { $0.id }
    }

    /// The long equation: two rows, every factor its own piece so it can be coloured.
    private static func eqn(_ S: inout Scene, _ Y: FY, _ upto: Int, _ hl: [Int: Color]) {
        let f = Y.f
        let r1 = lay([FW, 44, FW], 575, 16), r2 = lay([44, FW, 44, FW], 575, 16)
        let cxs = [r1[0], r1[2], r2[1], r2[3]]
        let Ys: [Double] = [215, 215, 355, 355]
        for i in 0..<upto {
            let x = cxs[i], y = Ys[i]
            let ps = T4[i].map { "(x+\(f[$0]))" }
            let w = ps.map(est)
            var s = x - (w[0] + w[1] + 4) / 2
            S.el("o\(i)", "1", x, y - 34, z: 48)
            S.box("v\(i)", x, y + 4, FW, 5, r: 3, c: INK, fill: INK)
            for (m, t) in ps.enumerated() {
                S.el("t\(i)" + (m == 1 ? "b" : "a"), t, s + w[m] / 2, y + 44, z: 44, c: hl[f[T4[i][m]]] ?? INK)
                s += w[m] + 4
            }
        }
        if upto >= 2 { S.el("p1", "+", r1[1], 215, z: 56, c: MU) }
        if upto >= 3 { S.el("e2", "=", r2[0], 355, z: 56, c: MU) }
        if upto >= 4 { S.el("p2", "+", r2[2], 355, z: 56, c: MU) }
    }

    private static func pcs(_ Y: FY, _ v: Int) -> [String] {
        var r: [String] = []
        for (i, t) in T4.enumerated() {
            for (m, j) in t.enumerated() where Y.f[j] == v { r.append("t\(i)" + (m == 1 ? "b" : "a")) }
        }
        return r
    }

    private static func chips(_ S: inout Scene, _ Y: FY, u uo: Bool = false, p po: Bool = false, st: Bool = false, gaps: Bool = false) {
        for i in 0..<4 {
            let u = uo && i == 3, p = po && i == 2
            let dl = st ? Double(i) * 170 : 0
            S.box("cb\(i)", CXs[i], CHY, 118, 58, r: 20, c: u ? Color(hex: 0xf4c79a) : (p ? Color(hex: 0x9cc8ff) : Theme.line),
                  fill: u ? Color(hex: 0xfff1e3) : (p ? Theme.soft : .white), shadow: true, dl: dl)
            S.el("cf\(i)", "x+\(Y.f[i])", CXs[i], CHY, z: 48, c: u ? OR : (p ? BLUE : INK), dl: dl)
        }
        if gaps {
            for i in 0..<3 {
                S.el("cg\(i)", (Y.k > 0 ? "+" : "\u{2212}") + "\(abs(Y.k))", (CXs[i] + CXs[i + 1]) / 2, CHY, z: 26, c: MU, w: 800)
            }
        }
        if uo { S.el("lu", "ultimate", CXs[3], CHY + 52, z: 24, c: OR, w: 800) }
        if po { S.el("lp", "penultimate", CXs[2], CHY + 52, z: 24, c: BLUE, w: 800) }
    }

    private static func sfrac(_ S: inout Scene, _ P: Double, _ y: Double, _ top: String, _ bot: String, _ col: Color) {
        S.el("fn", top, P, y - 38, z: 64, c: col)
        S.el("fd", bot, P, y + 42, z: 64, c: col)
        S.box("fb", P, y + 3, max(90, Double(top.count) * 38 + 24), 6, r: 3, c: col, fill: col)
    }

    // MARK: scenes

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = M(Int(d.n) ?? 0)
        var S = Scene(d.n + ".")
        switch d.g {
        case "meet":
            eqn(&S, Y, ph + 1, [:])
        case "factors":
            eqn(&S, Y, 4, [:])
            chips(&S, Y, st: ph == 0, gaps: ph >= 1)
            S.fa((0..<4).flatMap { ["cb\($0)", "cf\($0)"] })
            if ph >= 1 { S.f("cg0", "cg1", "cg2") }
        case "ultpen":
            var hl: [Int: Color] = [Y.u: OR]
            if ph >= 1 { hl[Y.p] = BLUE }
            eqn(&S, Y, 4, hl)
            chips(&S, Y, u: true, p: ph >= 1)
            S.f("cb3", "cf3", "lu"); S.fa(pcs(Y, Y.u))
            if ph >= 1 { S.f("cb2", "cf2", "lp") }
        case "combine":
            eqn(&S, Y, 4, [Y.u: OR, Y.p: BLUE])
            chips(&S, Y, u: true, p: true)
            let bids: [String]
            if ph == 0 {
                bids = bub(&S, [BI("ua", "(x+\(Y.u))", c: OR), BI("ub", "+", dl: 200), BI("uc", "2", dl: 400),
                                BI("ud", "(x+\(Y.p))", c: BLUE, dl: 600), BI("ue", "=", dl: 800), BI("uf", "0", dl: 1000)])
            } else {
                bids = bub(&S, [BI("q1", "3x", c: BLUE), BI("q2", "+"), BI("q3", String(Y.num), c: OR), BI("q4", "="), BI("q5", "0")])
            }
            S.f("cb3", "cf3", "cb2", "cf2", "lu", "lp"); S.fa(pcs(Y, Y.u)); S.fa(pcs(Y, Y.p)); S.fa(bids); S.f("bub")
        case "solve":
            let WY = 290.0
            let nm = String(Y.num)
            let wn = Double(nm.count) * 60 + 30
            if ph == 0 {
                let P = lay([130, 64, wn, 64, 60], 575, 16)
                S.el("q1", "3x", P[0], WY, c: BLUE); S.el("q2", "+", P[1], WY); S.el("q3", nm, P[2], WY, c: OR)
                S.el("q4", "=", P[3], WY); S.el("q5", "0", P[4], WY); S.h("q3")
            }
            if ph == 1 {
                let P = lay([130, 64, wn + 60], 575, 16)
                S.el("q1", "3x", P[0], WY, c: BLUE); S.el("q4", "=", P[1], WY); S.el("q6", "\u{2212}" + nm, P[2], WY, c: OR); S.h("q6")
            }
            if ph >= 2 {
                let fw = Double(nm.count) * 36 + 50
                let fin = ph == 3
                let ww = Double(("\u{2212}\(Y.whole)").count) * 56
                let rw = Y.int ? Double(("\u{2212}\(Y.num / 3)").count) * 58 + 30 : ww + 60
                let P = fin ? lay([70, 64, fw, 64, rw], 575, 16) : lay([70, 64, fw], 575, 16)
                S.el("x1", "x", P[0], WY); S.el("q4", "=", P[1], WY)
                sfrac(&S, P[2], WY, "\u{2212}" + nm, "3", OR)
                if fin {
                    S.el("q7", "=", P[3], WY)
                    if Y.int {
                        S.el("rv", "\u{2212}\(Y.num / 3)", P[4], WY, c: GR)
                    } else {
                        let R = lay([ww, 44], P[4], 4)
                        S.el("rw", "\u{2212}\(Y.whole)", R[0], WY, c: GR)
                        S.el("mn", String(Y.rem), R[1], WY - 30, z: 44, c: GR)
                        S.el("md", "3", R[1], WY + 30, z: 44, c: GR)
                        S.box("mb", R[1], WY + 2, 40, 5, r: 3, c: GR, fill: GR)
                    }
                    S.finale = SFinale(x: 575, y: WY, w: 70 + 64 + fw + 64 + rw + 110, h: 150)
                    S.win = true
                }
                S.h(fin ? (Y.int ? "rv" : "rw") : "fn")
            }
        default: break
        }
        return S
    }

    private static func hl(_ g: String) -> Color {
        switch g {
        case "ultpen": return OR
        case "solve": return GR
        default: return BLUE
        }
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = M(Int(d.n) ?? 0)
        switch d.g {
        case "factors": return ("Gap = " + (Y.k > 0 ? "" : "\u{2212}") + "\(abs(Y.k))", hl(d.g))
        case "ultpen": return ("Last two: \(Y.u), \(Y.p)", hl(d.g))
        case "combine": return ("3x + \(Y.num) = 0", hl(d.g))
        case "solve": return ("x = \u{2212}\(Y.num)/3", hl(d.g))
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = M(Int(d.n) ?? 0)
        var t = ""
        switch d.g {
        case "meet":
            t = d.n == "251" ? "Solve this long equation with **Sopantyadvayamantyam**: the ultimate and twice the penultimate."
                             : "Another one. This time the factors go **downwards**."
        case "factors":
            t = "The factors, in order: **" + Y.f.map { "x+\($0)" }.joined(separator: ", ") + "**. Each is **\(abs(Y.k))** " + (Y.k > 0 ? "more" : "less") + " than the last."
        case "ultpen":
            t = "The **ultimate** is the last factor: **x+\(Y.u)**. The **penultimate** is the one before it: **x+\(Y.p)**."
        case "combine":
            t = "Ultimate + twice penultimate: **(x+\(Y.u)) + 2(x+\(Y.p)) = 0**, which is **3x + \(Y.num) = 0**."
        case "solve":
            t = Y.int ? "**3x = \u{2212}\(Y.num)**, so **x = \u{2212}\(Y.num)/3 = \u{2212}\(Y.num / 3)**."
                      : "**3x = \u{2212}\(Y.num)**, so **x = \u{2212}\(Y.num)/3**, which is **\u{2212}\(Y.whole) \(Y.rem)/3**."
        default: t = "Your turn."
        }
        return (t, hl(d.g))
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = M(Int(p.n) ?? 0)
        return [
            PTask(g: "ultpen", cap: "The **ultimate** is the last factor, **x + ?**. Type the number.", q: "ultimate", ans: String(Y.u),
                  ex: ["ultimate"], hint: "Close! The ultimate is the last factor in the list."),
            PTask(g: "ultpen", cap: "The **penultimate** is the one before it, **x + ?**. Type the number.", q: "penultimate", ans: String(Y.p),
                  ex: ["penultimate"], hint: "Close! Take the second-to-last factor."),
            PTask(g: "combine", cap: "**Ultimate + twice penultimate** gives **3x + ?**. Type the number.", q: "\(Y.u) + 2 \u{00D7} \(Y.p)",
                  ans: String(Y.num), ex: [String(Y.u), "+", "2", "\u{00D7}", String(Y.p)], hint: "Close! Add \(Y.u) and twice \(Y.p)."),
            PTask(g: "solve", cap: "**3x + \(Y.num) = 0**, so **x = \u{2212}?** Type the number after the minus.", q: "\(Y.num) \u{00F7} 3",
                  ans: String(Y.num / 3), ex: [String(Y.num), "\u{00F7}", "3"], hint: "Close! Divide \(Y.num) by 3."),
        ]
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = M(Int(p.n) ?? 0)
        var S = Scene("p" + p.n + ".")
        let T = tasks(p)
        let tk = T[min(t, T.count - 1)]
        let fin = done || (ok && t == T.count - 1)
        let d = t + (ok ? 1 : 0)
        let PY = 170.0
        for i in 0..<4 {
            let x = 575 + (Double(i) - 1.5) * 130
            let u = i == 3 && d >= 1, pn = i == 2 && d >= 2
            S.box("cb\(i)", x, PY, 100, 50, r: 18, c: u ? Color(hex: 0xf4c79a) : (pn ? Color(hex: 0x9cc8ff) : Theme.line),
                  fill: u ? Color(hex: 0xfff1e3) : (pn ? Theme.soft : .white), shadow: true)
            S.el("cf\(i)", "x+\(Y.f[i])", x, PY, z: 40, c: u ? OR : (pn ? BLUE : INK))
        }
        if fin {
            S.el("wf", "x = \u{2212}\(Y.num / 3)", 575, 290, z: 64, c: GR)
            S.finale = SFinale(x: 575, y: 290, w: 340, h: 100)
            return S
        }
        let WK = ["", "ultimate = x+\(Y.u)", "(x+\(Y.u)) + 2(x+\(Y.p))", "3x + \(Y.num) = 0"]
        if d >= 1 && d <= 3 { S.el("w\(d)", WK[d], 575, 290, z: 48, c: d == 1 ? OR : INK) }
        let items = tk.ex.enumerated().map { (i, x) -> SeqItem in
            let isOpX = x.hasPrefix("+") || x.hasPrefix("\u{00D7}") || x.hasPrefix("\u{00F7}") || x.hasPrefix("=") || x.hasPrefix(",") || x.hasPrefix("(")
                || x.hasPrefix("ultimate") || x.hasPrefix("penultimate")
            return SeqItem("te\(t)_\(i)", x, op: isOpX)
        }
        let total = S.seqFlat(items, 575, 396, 40)
        S.box("tb\(t)", 575, 396, max(240, total + 70), 62, r: 22, shadow: true)
        return S
    }

    // MARK: spec

    private static func timing(_ g: String) -> ([Double], Double) {
        let base: ([Double], Double)
        switch g {
        case "meet": base = ([0, 600, 1200, 1800], 3000)
        case "factors": base = ([0, 1500], 2900)
        case "ultpen": base = ([0, 1400], 2800)
        case "combine": base = ([0, 2000], 3300)
        case "solve": base = ([0, 900, 2000, 3200], 4400)
        default: base = ([0, 500], 700)
        }
        if g == "practice" { return base }
        let nt: [Double] = base.0.enumerated().map { $0.offset == 0 ? 0 : 800 + Double($0.offset - 1) * 1500 }
        return (nt, nt[nt.count - 1] + 1300)
    }

    private static let steps: [StepDef] = {
        var list: [(String, Int, String)] = []
        for (j, n) in [251, 1047].enumerated() {
            list += [("meet", n, j == 1 ? "A downward one" : "Meet the problem"), ("factors", n, "List the factors"),
                     ("ultpen", n, "Ultimate & penultimate"), ("combine", n, "Ultimate + 2 \u{00D7} penultimate"), ("solve", n, "Solve for x")]
        }
        list.append(("practice", 0, "Your turn"))
        return list.map { item in
            let t = timing(item.0)
            return StepDef(g: item.0, n: String(item.1), name: item.2, times: t.0, end: t.1)
        }
    }()

    private static func randomN() -> Problem {
        let k = [3, 6, -3, -6][rnd(0, 3)]
        let a = k > 0 ? rnd(1, 9) : rnd(1 - 3 * k, 9 - 3 * k)
        return Problem(n: String(a * 100 + k + 50))
    }

    static let spec = LessonSpec(
        id: "eqf",
        topTitle: "Ultimate + twice penultimate",
        cardTitle: "Ultimate + twice penultimate",
        cardBlurb: "Sopantyadvayamantyam: the ultimate and twice the penultimate. Add the last factor to twice the one before it, set it to zero, and solve.",
        teaser: [[TeaserRun(text: "3x + 13 = 0")], [TeaserRun(text: "\u{2192}", color: Theme.muted)],
                 [TeaserRun(text: "x = \u{2212}13/3", color: Theme.green, pop: true)]],
        teaserSize: 32,
        sutra: "Sopantyadvayamantyam: the ultimate and twice the penultimate",
        defaultHint: "Use the sutra from the lesson.",
        style: RenderStyle(dimElement: 0.3, dimBox: 0.35, blur: 1.5, newElementScale: 0.55, newBoxScale: 0.8, reappearFresh: true),
        steps: steps,
        practice: [Problem(n: "153"), Problem(n: "253"), Problem(n: "1047"), Problem(n: "356")],
        random: randomN,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { p in
            let Y = M(Int(p.n) ?? 0)
            return "**x = \u{2212}\(Y.num / 3)**. Same one-line trick, every time."
        }
    )
}
