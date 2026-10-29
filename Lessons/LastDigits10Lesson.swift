import SwiftUI

/// Advanced: Ekadhikena Purvena. Same front part F, last digits add to 10: answer is F(F+1) then ab.
enum LastDigits10Lesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let Z = 96.0, ADV = 60.0, RY = 320.0, BY = 530.0
    private static let DASH = Color(hex: 0xcbd7e3)

    struct LY {
        var n: Int, m: Int, F: Int, a: Int, b: Int, F1: Int, L: Int, R: Int
        var Rs: String
        var ans: Int
    }

    static func yav(_ n: String, _ m: String) -> LY {
        let n = Int(n) ?? 43, m = Int(m) ?? 47
        let F = n / 10, a = n % 10, b = m % 10, F1 = F + 1, L = F * F1, R = a * b
        let rs = String(R)
        return LY(n: n, m: m, F: F, a: a, b: b, F1: F1, L: L, R: R, Rs: rs.count < 2 ? "0" + rs : rs, ans: n * m)
    }

    // MARK: helpers

    private static func digs(_ s: String) -> [String] { s.map { String($0) } }
    private static func digs(_ n: Int) -> [String] { digs(String(n)) }
    private static func xsOf(_ n: Int, _ cx: Double, _ a: Double) -> [Double] {
        (0..<n).map { cx + (Double($0) - Double(n - 1) / 2) * a }
    }
    private static func rowXs(_ nl: Int, _ k: Int) -> [Double] {
        let t = nl + k
        return (0..<t).map { 512 + (Double($0) - Double(t - 1) / 2) * ADV + ($0 >= nl ? 14 : -14) }
    }
    private static func GE(_ Y: LY) -> (nl: Int, xs: [Double]) {
        let nl = String(Y.L).count
        return (nl, rowXs(nl, 2))
    }
    private static func diS(_ id: String, _ s: String, _ c: Color) -> [SeqItem] {
        let d = digs(s)
        return d.enumerated().map { SeqItem(id + String($0.offset), $0.element, c: c, g: $0.offset < d.count - 1 ? 0 : nil) }
    }
    private static func diB(_ id: String, _ s: String, _ c: Color, _ res: Bool = false) -> [BubItem] {
        let d = digs(s)
        return d.enumerated().map { BubItem(id + String($0.offset), $0.element, res: res, c: c, g: $0.offset < d.count - 1 ? 0 : nil) }
    }
    private static func ids(_ id: String, _ s: String) -> [String] { digs(s).indices.map { id + String($0) } }

    private struct Prob {
        var xs: [Double]; var total: Double
        var nI: [String]; var mI: [String]; var all: [String]
        var fn: [String]; var fm: [String]; var ln: String; var lm: String
    }

    private static func prob(_ S: inout Scene, _ Y: LY, _ y: Double, _ z: Double = Z) -> Prob {
        let items = diS("n", String(Y.n), INK) + [SeqItem("op", "\u{00D7}", op: true)] + diS("m", String(Y.m), INK)
        let q = S.seq(items, 512, y, z)
        let nI = ids("n", String(Y.n)), mI = ids("m", String(Y.m))
        return Prob(xs: q.xs, total: q.total, nI: nI, mI: mI, all: nI + ["op"] + mI,
                    fn: Array(nI.dropLast()), fm: Array(mI.dropLast()), ln: nI.last!, lm: mI.last!)
    }

    private static func rb2(_ S: inout Scene, _ Y: LY, _ o: Double) {
        let g = GE(Y)
        for j in 0..<2 {
            S.box("rb\(j)", g.xs[g.nl + j], RY, 58, 84, o: o, r: 18, dashed: true, c: DASH, fill: .clear, q: "?")
        }
    }

    private static func arrTo(_ S: inout Scene, _ i: Int, _ x: Double, _ ph: Int, _ a: Int, _ bend: Double, _ xb: Double) {
        if ph >= a { S.arrow(i, (x, RY + 54), (xb, BY - 62), st: ph >= a + 1 && ph < 9 ? 2 : 1, bend: bend) }
    }

    // MARK: scenes

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = yav(d.n, d.m)
        var S = Scene("\(d.n)x\(d.m).")
        switch d.g {
        case "meet":
            let r = prob(&S, Y, RY)
            if ph == 0 { S.hide(r.all) }
            if ph >= 2 { for i in r.all { S.mod(i, c: BLUE) }; S.fa(r.all); S.h(r.lm) }
        case "check":
            let r = prob(&S, Y, RY)
            if ph >= 1 { for i in r.fn + r.fm { S.mod(i, c: BLUE) } }
            if ph >= 2 { for i in [r.ln, r.lm] { S.mod(i, c: OR) } }
            let items = [BubItem("ca", String(Y.a), c: OR), BubItem("cp", "+", op: true), BubItem("cb", String(Y.b), c: OR),
                         BubItem("ce", "=", op: true)] + diB("T", "10", GR, true)
            let b = S.bub(items, ph >= 2 ? 1 : 0, ph >= 2 ? 1 : 0, ph >= 3 ? 1 : 0)
            S.box("tag", 512, 196, 480, 64, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 22, shadow: true,
                  q: "Same front \u{00B7} Last digits make 10", qz: 26, qc: GR)
            if ph >= 2 {
                arrTo(&S, 0, r.xs[r.nI.count - 1], ph, 2, 0.22, b.xs[0] - 4)
                arrTo(&S, 1, r.xs[r.xs.count - 1], ph, 2, -0.22, b.xs[2] + 4)
            }
            if ph == 1 { S.fa(r.fn); S.fa(r.fm); S.h(r.fn.last!) }
            if ph == 2 { S.f(r.ln, r.lm, "bub"); S.fa(b.rest); S.h("cp") }
            if ph >= 3 { S.f("tag", "bub"); S.fa(b.res); S.h("T1") }
        case "succ":
            let r = prob(&S, Y, RY)
            for i in r.fn + r.fm { S.mod(i, c: BLUE) }
            for i in [r.ln, r.lm, "op"] { S.mod(i, o: 0.25) }
            let items = diB("F", String(Y.F), BLUE) + [BubItem("sp", "+", op: true), BubItem("s1", "1"), BubItem("se", "=", op: true)]
                + diB("G", String(Y.F1), OR, true)
            let b = S.bub(items, ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
            if ph >= 1 { arrTo(&S, 0, r.xs[0], ph, 1, 0.25, b.xs[0] - 6) }
            if ph == 0 { S.fa(r.fn); S.h(r.fn.last!) }
            if ph == 1 { S.fa(r.fn); S.f("bub"); S.fa(b.rest); S.h("s1") }
            if ph >= 2 { S.f("bub"); S.fa(b.res); S.h(b.res.last!) }
        case "left":
            let r = prob(&S, Y, ph >= 3 ? 196 : RY, ph >= 3 ? 54 : Z)
            let g = GE(Y)
            for i in r.fn + r.fm { S.mod(i, c: BLUE) }
            for i in [r.ln, r.lm, "op"] { S.mod(i, o: 0.25) }
            let items = diB("F", String(Y.F), BLUE) + [BubItem("lx", "\u{00D7}", op: true)] + diB("G", String(Y.F1), OR)
                + [BubItem("le", "=", op: true)] + diB("L", String(Y.L), OR, true)
            let b = S.bub(items, ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
            if ph >= 1 && ph < 3 { arrTo(&S, 0, r.xs[0], ph, 1, 0.25, b.xs[0] - 6) }
            if ph == 0 { S.fa(r.fn); S.h(r.fn.last!) }
            if ph == 1 { S.fa(r.fn); S.f("bub"); S.fa(b.rest); S.h("lx") }
            if ph == 2 { S.f("bub"); S.fa(b.res); S.h(b.res.last!) }
            if ph >= 3 {
                for (i, id) in b.res.enumerated() { S.mod(id, x: g.xs[i], y: RY, o: 1, s: Z / 52) }
                for id in b.rest { S.mod(id, o: 0) }
                S.mod("bub", o: 0, s: 0.9)
                for i in [r.ln, r.lm] { S.mod(i, o: 1, c: OR) }
                S.mod("op", o: 1, c: MU)
                rb2(&S, Y, 1)
                S.fa(b.res); S.f("rb0", "rb1"); S.fa(r.all); S.h(b.res.last!)
            }
        case "right":
            let g = GE(Y), nz = 2 - String(Y.R).count
            let r = prob(&S, Y, 196, 54)
            for i in r.fn + r.fm { S.mod(i, c: BLUE) }
            for i in [r.ln, r.lm] { S.mod(i, c: OR) }
            S.mod("op", c: MU)
            for (i, d) in digs(Y.L).enumerated() { S.el("L\(i)", d, g.xs[i], RY, c: OR) }
            rb2(&S, Y, ph < 4 ? 1 : 0)
            let res = digs(Y.Rs).enumerated().map { (i, d) in
                BubItem("R\(i)", d, res: true, c: OR, o: i < nz ? (ph >= 3 ? 1 : 0) : (ph >= 2 ? 1 : 0), g: i < 1 ? 0 : nil)
            }
            let on = ph >= 1 && ph < 4 ? 1.0 : 0.0
            let items = [BubItem("ra", String(Y.a), c: OR), BubItem("rx", "\u{00D7}", op: true), BubItem("rq", String(Y.b), c: OR),
                         BubItem("re", "=", op: true)] + res
            let b = S.bub(items, on, on, 0)
            if ph == 0 { S.f("rb0", "rb1"); S.hp(g.xs[g.nl] + 20, RY + 46) }
            if ph == 1 { S.f("bub", "ra", "rx", "rq", "re"); S.h("rx") }
            if ph == 2 { S.f("bub"); S.fa(Array(b.res.dropFirst(nz))); S.h(b.res.last!) }
            if ph == 3 { S.f("bub"); S.fa(b.res); S.h(b.res[0]) }
            if ph >= 4 {
                for (i, id) in b.res.enumerated() { S.mod(id, x: g.xs[g.nl + i], y: RY, o: 1, s: Z / 52) }
                S.fa(b.res); S.h(b.res[1])
            }
            S.fa(r.all)
        case "join":
            let g = GE(Y), ls = String(Y.L), tot = ls.count + 2, xs2 = xsOf(tot, 512, ADV)
            var all: [String] = []
            for (i, d) in digs(ls).enumerated() {
                S.el("L\(i)", d, ph >= 1 ? xs2[i] : g.xs[i], RY, c: ph >= 1 ? GR : OR); all.append("L\(i)")
            }
            for (i, d) in digs(Y.Rs).enumerated() {
                S.el("R\(i)", d, ph >= 1 ? xs2[ls.count + i] : g.xs[g.nl + i], RY, c: ph >= 1 ? GR : OR); all.append("R\(i)")
            }
            if ph >= 1 {
                S.finale = SFinale(x: 512, y: RY, w: Double(tot) * ADV + 130, h: 160)
                S.win = true
            } else { S.fa(all); S.h(all.last!) }
        default: break
        }
        return S
    }

    private static func hl(_ g: String) -> Color {
        switch g {
        case "check", "join": return GR
        case "succ", "left", "right": return OR
        default: return BLUE
        }
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n, d.m)
        switch d.g {
        case "check": return ("\(Y.a) + \(Y.b) = 10", GR)
        case "succ": return ("\(Y.F) + 1 = \(Y.F1)", OR)
        case "left": return ("\(Y.F) \u{00D7} \(Y.F1) = \(Y.L)", OR)
        case "right": return ("\(Y.a) \u{00D7} \(Y.b) = \(Y.Rs)", OR)
        case "join": return ("\(Y.n) \u{00D7} \(Y.m) = \(Y.ans)", GR)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n, d.m)
        var t = ""
        switch d.g {
        case "meet": t = "Look at **\(Y.n) \u{00D7} \(Y.m)**. It looks like long work, but there is a neat trick. **Watch this.**"
        case "check": t = "The front part is the same, **\(Y.F)**. The last digits add to 10: **\(Y.a) + \(Y.b) = 10**."
        case "succ": t = "Take the front part **\(Y.F)** and find its successor. **\(Y.F) + 1 = \(Y.F1)**."
        case "left": t = "Multiply the front part by its successor. **\(Y.F) \u{00D7} \(Y.F1) = \(Y.L)**. That is the left part."
        case "right":
            t = "Multiply the last digits, kept at the top. **\(Y.a) \u{00D7} \(Y.b) = \(Y.R)**. "
                + (Y.R < 10 ? "The right part has 2 digits, so pad with a zero: " : "The right part has 2 digits: ") + "**\(Y.Rs)**."
        case "join": t = "Join the left part **\(Y.L)** and the right part **\(Y.Rs)**. \(Y.n) \u{00D7} \(Y.m) = **\(Y.ans)**."
        default: t = "Your turn."
        }
        return (t, hl(d.g))
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n, p.m)
        return [
            PTask(g: "check", cap: "Do the last digits make 10? What is **\(Y.a) + \(Y.b)**?", q: "\(Y.a) + \(Y.b)", ans: "10",
                  ex: [String(Y.a), "+", String(Y.b)], hint: "Close! Add the two last digits."),
            PTask(g: "succ", cap: "The front part is **\(Y.F)**. What is its successor, **\(Y.F) + 1**?", q: "\(Y.F) + 1", ans: String(Y.F1),
                  ex: [String(Y.F), "+", "1"], hint: "Close! The successor is the next number. Add 1."),
            PTask(g: "left", cap: "Multiply the front part by its successor: **\(Y.F) \u{00D7} \(Y.F1)**.", q: "\(Y.F) \u{00D7} \(Y.F1)", ans: String(Y.L),
                  ex: [String(Y.F), "\u{00D7}", String(Y.F1)], hint: "Close! Multiply \(Y.F) by \(Y.F1)."),
            PTask(g: "right", cap: "Multiply the last digits: **\(Y.a) \u{00D7} \(Y.b)**. Write it with 2 digits.", q: "\(Y.a) \u{00D7} \(Y.b)", ans: Y.Rs,
                  ex: [String(Y.a), "\u{00D7}", String(Y.b)], hint: "Close! If the product is one digit, put a 0 in front.",
                  ok: "\(Y.a) \u{00D7} \(Y.b) = \(Y.Rs)"),
            PTask(g: "join", cap: "Join the parts. What is **\(Y.n) \u{00D7} \(Y.m)**?", q: "\(Y.n) \u{00D7} \(Y.m)", ans: String(Y.ans), ex: [],
                  hint: "Close! Write the left part, then the right part."),
        ]
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = yav(p.n, p.m)
        var S = Scene("\(p.n)x\(p.m).")
        let T = tasks(p)
        let tt = min(t, T.count - 1)
        let r = prob(&S, Y, 250)
        let fin = done || (ok && tt == T.count - 1)
        if fin {
            for i in r.all { S.mod(i, c: GR) }
            S.finale = SFinale(x: 512, y: 250, w: r.total + 140, h: 150)
        } else if !T[tt].ex.isEmpty {
            let ex = T[tt].ex
            let ids2 = ex.indices.map { "te\(tt)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids2[$0.offset], $0.element, op: $0.offset == 1) }, 512, 368, 46)
            S.box("tb\(tt)", 512, 368, max(240, q.total + 90), 84, r: 26, shadow: true)
            for i in r.all { S.mod(i, c: BLUE) }
            S.fa(r.all); S.f("tb\(tt)"); S.fa(ids2)
        }
        return S
    }

    // MARK: spec

    private static func timing(_ g: String) -> ([Double], Double) {
        switch g {
        case "meet": return ([0, 800, 2300], 3600)
        case "right": return ([0, 800, 2300, 3800, 5300], 6600)
        case "join": return ([0, 800], 2100)
        case "practice": return ([0, 500], 700)
        default: return ([0, 800, 2300, 3800], 5100)
        }
    }

    private static let steps: [StepDef] = {
        func mid(_ n: String, _ m: String, _ t: String) -> [(String, String, String, String)] {
            [("succ", n, m, t), ("left", n, m, "Multiply the front"), ("right", n, m, "Multiply the ends"), ("join", n, m, "Read the answer")]
        }
        var list: [(String, String, String, String)] = [
            ("meet", "43", "47", "Meet the problem"), ("check", "43", "47", "Check the digits"), ("succ", "43", "47", "Find the successor"),
            ("left", "43", "47", "Multiply the front"), ("right", "43", "47", "Multiply the ends"), ("join", "43", "47", "Read the answer"),
        ]
        list += mid("41", "49", "A zero to pad: 41 \u{00D7} 49")
        list += mid("123", "127", "Longer numbers: 123 \u{00D7} 127")
        list.append(("practice", "0", "0", "Your turn"))
        return list.map { g, n, m, name in
            let t = timing(g)
            return StepDef(g: g, n: n, m: m, name: name, times: t.0, end: t.1)
        }
    }()

    private static func randomP() -> Problem {
        let F = rnd(1, 99), a = rnd(1, 9)
        return Problem(n: String(F * 10 + a), m: String(F * 10 + 10 - a))
    }

    static let spec = LessonSpec(
        id: "ld10",
        topTitle: "Last digits add to 10",
        cardTitle: "Last Digits Add to 10",
        cardBlurb: "When two numbers share the same front part and their last digits add to 10. Multiply the front by its successor, then write the product of the last digits.",
        teaser: [[TeaserRun(text: "43 \u{00D7} 4"), TeaserRun(text: "7", color: Theme.blue, scale: 1.3, pop: true)],
                 [TeaserRun(text: "=")], [TeaserRun(text: "2021")]],
        sutra: "Ekadhikena Purvena: by one more than the previous one",
        steps: steps,
        practice: [Problem(n: "43", m: "47"), Problem(n: "62", m: "68"), Problem(n: "81", m: "89"),
                   Problem(n: "125", m: "125"), Problem(n: "137", m: "133")],
        random: randomP,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { p in
            let Y = yav(p.n, p.m)
            return "**\(Y.n) \u{00D7} \(Y.m) = \(Y.ans)**. Same trick, every time."
        }
    )
}
