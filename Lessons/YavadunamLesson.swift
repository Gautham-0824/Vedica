import SwiftUI

/// Advanced: Yavadunam. Square a number near a base by lessening it by its gap and adding the gap squared.
enum YavadunamLesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let Z = 96.0, ADV = 60.0, RY = 320.0, BY = 530.0
    private static let DASH = Color(hex: 0xcbd7e3)
    private static let MINUS = "\u{2212}", SQ = "\u{00B2}", TIMES = "\u{00D7}"

    struct YY {
        var n: Int, B: Int, k: Int, e: Int, d: Int, over: Bool
        var L0: Int, sq: Int, c: Int, r: Int
        var rs: String
        var L: Int, ans: Int
    }

    static func yav(_ ns: String) -> YY {
        let n = Int(ns) ?? 97
        let l = String(n).count
        var p5 = 5
        for _ in 1..<max(l, 1) { p5 *= 10 }
        let k = n >= p5 ? l : l - 1
        var B = 1
        for _ in 0..<k { B *= 10 }
        let e = n - B, d = abs(e), sq = d * d
        let c = sq / B, r = sq % B, L0 = n + e
        var rs = String(r)
        while rs.count < k { rs = "0" + rs }
        return YY(n: n, B: B, k: k, e: e, d: d, over: e > 0, L0: L0, sq: sq, c: c, r: r, rs: rs, L: L0 + c, ans: n * n)
    }

    private static func colOf(_ Y: YY) -> Color { Y.over ? BLUE : OR }
    private static func wordOf(_ Y: YY) -> String { Y.over ? "excess" : "deficiency" }

    // MARK: helpers

    private static func digs(_ s: String) -> [String] { s.map { String($0) } }
    private static func xsOf(_ n: Int, _ cx: Double, _ a: Double) -> [Double] {
        (0..<n).map { cx + (Double($0) - Double(n - 1) / 2) * a }
    }
    private static func rowXs(_ nl: Int, _ k: Int) -> [Double] {
        let t = nl + k
        return (0..<t).map { 512 + (Double($0) - Double(t - 1) / 2) * ADV + ($0 >= nl ? 14 : -14) }
    }
    private static func geom(_ Y: YY) -> (nl: Int, xs: [Double]) {
        let nl = String(Y.L).count
        return (nl, rowXs(nl, Y.k))
    }
    private static func rbx(_ S: inout Scene, _ Y: YY, _ o: Double) {
        let g = geom(Y)
        for j in 0..<Y.k {
            S.box("rb\(j)", g.xs[g.nl + j], RY, 58, 84, o: o, r: 18, dashed: true, c: DASH, fill: .clear, q: "?")
        }
    }
    private static func boxIds(_ Y: YY) -> [String] { (0..<Y.k).map { "rb\($0)" } }
    private static func leftRow(_ S: inout Scene, _ Y: YY, _ id: String, _ str: String, c: Color, o: Double = 1, s: Double = 1) {
        let g = geom(Y)
        for (i, d) in digs(str).enumerated() { S.el(id + String(i), d, g.xs[g.nl - str.count + i], RY, c: c, o: o, s: s) }
    }
    private static func work(_ S: inout Scene, _ Y: YY, _ y: Double) -> (xs: [Double], ids: [String]) {
        let d = digs(String(Y.n)), xs = xsOf(d.count, 512, ADV)
        var out: [String] = []
        for (i, ch) in d.enumerated() { S.el("n\(i)", ch, xs[i], y); out.append("n\(i)") }
        S.el("pw", "2", xs[xs.count - 1] + 46, y - 46, z: 46, c: MU, w: 800)
        return (xs, out)
    }

    // MARK: scenes

    private static func scene(_ dd: StepDef, _ ph: Int) -> Scene {
        let Y = yav(dd.n)
        var S = Scene("\(Y.n).")
        switch dd.g {
        case "meet":
            let r = work(&S, Y, RY)
            S.el("lbl", "\(Y.n) \(TIMES) \(Y.n)", 512, 168, z: 36, c: MU, w: 800)
            if ph == 0 { S.hide(r.ids + ["pw", "lbl"]) }
            if ph >= 2 { for i in r.ids { S.mod(i, c: BLUE) }; S.fa(r.ids); S.h(r.ids.last!) }
        case "base":
            let r = work(&S, Y, RY)
            let b = S.bub([BubItem("bw", "Base"), BubItem("be", "=", op: true), BubItem("bv", String(Y.B), c: OR)],
                          ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0, 1)
            S.el("zl", "\(Y.B) has \(Y.k) zeros", 512, 640, z: 26, c: MU, w: 800, o: ph >= 3 ? 1 : 0)
            if ph >= 1 { S.arrow(0, (512, RY + 56), (b.xs[0] - 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: 0.25) }
            if ph == 1 { S.fa(r.ids); S.f("bub"); S.h("n\(r.ids.count - 1)") }
            if ph == 2 { S.f("bub"); S.fa(b.ids); S.h("bv") }
            if ph >= 3 { S.f("bub"); S.fa(b.ids); S.f("zl"); S.h("bv") }
        case "diff":
            let r = work(&S, Y, RY)
            let hi = Y.over ? Y.n : Y.B, lo = Y.over ? Y.B : Y.n
            S.el("gb", String(Y.B), 512, 196, z: 54, c: OR, o: ph >= 1 ? 1 : 0)
            let on = ph >= 2 ? 1.0 : 0.0
            let b = S.bub([BubItem("da", String(hi)), BubItem("dop", MINUS, op: true), BubItem("db", String(lo)),
                           BubItem("de", "=", op: true), BubItem("dr", String(Y.d), res: true, c: OR)], on, on, ph >= 3 ? 1 : 0)
            if ph == 1 { S.f("gb"); S.fa(r.ids); S.h("gb") }
            if ph >= 2 { S.arrow(0, (512, RY + 56), (b.xs[0] - 6, BY - 62), st: ph >= 3 ? 2 : 1, bend: 0.25) }
            if ph == 2 { S.f("bub"); S.fa(b.rest); S.h("db") }
            if ph >= 3 { S.f("bub"); S.fa(b.res); S.h("dr") }
        case "kind":
            let r = work(&S, Y, RY)
            let col = colOf(Y)
            let on = ph >= 1 ? 1.0 : 0.0
            let b = S.bub([BubItem("ka", String(Y.n)), BubItem("kc", Y.over ? ">" : "<", op: true), BubItem("kb", String(Y.B))], on, on, 1)
            S.box("tag", 512, 196, 350, 64, o: ph >= 2 ? 1 : 0, s: ph >= 2 ? 1 : 0.9, r: 22, shadow: true,
                  q: (Y.over ? "Excess +" : "Deficiency \(MINUS)") + String(Y.d), qz: 28, qc: col)
            S.el("kn", Y.over ? "Above the base: we will add" : "Below the base: we will subtract", 512, 640, z: 26, c: MU, w: 800,
                 o: ph >= 3 ? 1 : 0)
            if ph >= 2 { for i in r.ids { S.mod(i, c: col) } }
            if ph == 1 { S.fa(r.ids); S.f("bub"); S.fa(b.ids); S.h("kc") }
            if ph == 2 { S.f("tag"); S.fa(r.ids); S.h("n\(r.ids.count - 1)") }
            if ph >= 3 { S.f("tag", "kn"); S.hp(512, 196 + 40) }
        case "left":
            let r = work(&S, Y, RY), g = geom(Y)
            let lid = Y.c > 0 ? "A" : "L", ls = String(Y.L0)
            for i in r.ids { S.mod(i, c: colOf(Y)) }
            var items = [BubItem("ln", String(Y.n)), BubItem("lo", Y.over ? "+" : MINUS, op: true), BubItem("ld", String(Y.d), c: OR),
                         BubItem("le", "=", op: true)]
            for (i, d) in digs(ls).enumerated() {
                items.append(BubItem(lid + String(i), d, res: true, c: OR, g: i < ls.count - 1 ? 0 : nil))
            }
            let on = ph >= 1 ? 1.0 : 0.0
            let b = S.bub(items, on, on, ph >= 2 ? 1 : 0)
            if ph == 0 { S.fa(r.ids); S.h("n\(r.ids.count - 1)") }
            if ph == 1 { S.fa(r.ids); S.f("bub"); S.fa(b.rest); S.h("ld") }
            if ph == 2 { S.f("bub"); S.fa(b.res); S.h(b.res.last!) }
            if ph >= 1 && ph < 3 { S.arrow(0, (512, RY + 56), (b.xs[0] - 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: 0.25) }
            if ph >= 3 {
                for (i, id) in b.res.enumerated() { S.mod(id, x: g.xs[g.nl - ls.count + i], y: RY, o: 1, s: Z / 52) }
                for id in b.rest { S.mod(id, o: 0) }
                S.mod("bub", o: 0, s: 0.9)
                for i in r.ids { S.mod(i, o: 0) }
                S.mod("pw", o: 0)
                rbx(&S, Y, 1)
                S.fa(b.res); S.fa(boxIds(Y)); S.h(b.res.last!)
            }
        case "right":
            let g = geom(Y), sqs = String(Y.sq), nz = Y.rs.count - sqs.count
            leftRow(&S, Y, "L", String(Y.L), c: OR)
            rbx(&S, Y, ph < 4 ? 1 : 0)
            let res = digs(Y.rs).enumerated().map { (i, d) in
                BubItem("R\(i)", d, res: true, c: OR, o: i < nz ? (ph >= 3 ? 1 : 0) : (ph >= 2 ? 1 : 0), g: i < Y.rs.count - 1 ? 0 : nil)
            }
            let on = ph >= 1 && ph < 4 ? 1.0 : 0.0
            let b = S.bub([BubItem("rd", String(Y.d), c: OR), BubItem("rp", SQ, op: true, g: 0), BubItem("re", "=", op: true)] + res, on, on, 0)
            if ph == 0 { S.fa(boxIds(Y)); S.hp(g.xs[g.nl] + 20, RY + 46) }
            if ph == 1 { S.f("bub", "rd", "rp", "re"); S.h("rd") }
            if ph == 2 { S.f("bub"); S.fa(Array(b.res.dropFirst(nz))); S.h(b.res.last!) }
            if ph == 3 { S.f("bub"); S.fa(b.res); S.h(b.res[0]) }
            if ph >= 4 {
                for (i, id) in b.res.enumerated() { S.mod(id, x: g.xs[g.nl + i], y: RY, o: 1, s: Z / 52) }
                S.fa(b.res); S.h(b.res.last!)
            }
        case "carry":
            let g = geom(Y), l0 = String(Y.L0), sqs = String(Y.sq), nc = sqs.count - Y.k
            let cx = (g.xs[0] + g.xs[g.nl - 1]) / 2
            leftRow(&S, Y, "A", l0, c: OR, o: ph >= 4 ? 0 : 1, s: ph >= 4 ? 0.7 : 1)
            leftRow(&S, Y, "L", String(Y.L), c: OR, o: ph >= 4 ? 1 : 0)
            rbx(&S, Y, ph < 3 ? 1 : 0)
            S.el("cc", "+\(Y.c)", cx, RY - 96, z: 48, c: BLUE, o: ph == 3 ? 1 : 0)
            let q = digs(sqs).enumerated().map { (i, d) in
                BubItem(i < nc ? "Q\(i)" : "R\(i - nc)", d, res: true, c: i < nc ? BLUE : OR, o: ph >= 1 ? 1 : 0, g: i < sqs.count - 1 ? 0 : nil)
            }
            let on = ph >= 1 && ph < 3 ? 1.0 : 0.0
            let b = S.bub([BubItem("cd", String(Y.d), c: OR), BubItem("cp", SQ, op: true, g: 0), BubItem("ce", "=", op: true)] + q, on, on, 1)
            let Q = Array(b.res.prefix(nc)), R = Array(b.res.dropFirst(nc)), all = boxIds(Y)
            if ph == 0 { S.fa(all); S.hp(g.xs[g.nl] + 20, RY + 46) }
            if ph == 1 { S.f("bub"); S.fa(b.res); S.h(b.res.last!) }
            if ph == 2 { S.f("bub"); S.fa(Q); S.fa(R); S.h(Q[0]) }
            if ph >= 3 {
                for (i, id) in R.enumerated() { S.mod(id, x: g.xs[g.nl + i], y: RY, o: 1, s: Z / 52) }
                for id in Q { S.mod(id, x: cx, y: RY - 96, o: 0) }
            }
            if ph == 3 { S.f("cc"); S.fa(R); S.fa(all); S.hp(cx + 24, RY - 60) }
            if ph >= 4 {
                S.fa((0..<String(Y.L).count).map { "L\($0)" }); S.fa(R); S.h("L\(String(Y.L).count - 1)")
            }
        case "join":
            let ls = String(Y.L), g = geom(Y), tot = ls.count + Y.rs.count, xs2 = xsOf(tot, 512, ADV)
            var all: [String] = []
            for (i, d) in digs(ls).enumerated() {
                S.el("L\(i)", d, ph >= 1 ? xs2[i] : g.xs[i], RY, c: ph >= 1 ? GR : OR); all.append("L\(i)")
            }
            for (i, d) in digs(Y.rs).enumerated() {
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

    private static func hl(_ g: String, _ Y: YY) -> Color {
        switch g {
        case "base", "diff", "left", "right": return OR
        case "carry": return BLUE
        case "join": return GR
        case "kind": return colOf(Y)
        default: return BLUE
        }
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n)
        switch d.g {
        case "base": return ("Base: \(Y.B)", OR)
        case "diff": return ((Y.over ? "\(Y.n) \(MINUS) \(Y.B)" : "\(Y.B) \(MINUS) \(Y.n)") + " = \(Y.d)", OR)
        case "kind": return ((Y.over ? "Excess: +" : "Deficiency: \(MINUS)") + String(Y.d), colOf(Y))
        case "left": return ("\(Y.n) \(Y.over ? "+" : MINUS) \(Y.d) = \(Y.L0)", OR)
        case "right": return ("\(Y.d)\(SQ) = \(Y.rs)", OR)
        case "carry": return ("Carry \(Y.c): \(Y.L0) + \(Y.c) = \(Y.L)", BLUE)
        case "join": return ("\(Y.n)\(SQ) = \(Y.ans)", GR)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n)
        var t = ""
        switch d.g {
        case "meet": t = "Squaring a number close to \(Y.B) is easy with Yavadunam. **Watch this.**"
        case "base": t = "Pick a friendly base close to \(Y.n): **\(Y.B)**. It has **\(Y.k) zeros**."
        case "diff":
            t = "How far is \(Y.n) from the base? **" + (Y.over ? "\(Y.n) \(MINUS) \(Y.B)" : "\(Y.B) \(MINUS) \(Y.n)") + " = \(Y.d)**."
        case "kind":
            t = Y.over ? "\(Y.n) is **above** the base, so \(Y.d) is an **excess**." : "\(Y.n) is **below** the base, so \(Y.d) is a **deficiency**."
        case "left":
            t = "\(Y.n) is \(Y.d) \(Y.over ? "above" : "below") \(Y.B). \(Y.over ? "Add" : "Subtract") it: **\(Y.n) \(Y.over ? "+" : MINUS) \(Y.d) = \(Y.L0)**. That is the left part."
        case "right":
            let z = Y.rs.count - String(Y.sq).count
            t = "Square the \(wordOf(Y)): **\(Y.d)\(SQ) = \(Y.sq)**. The base has \(Y.k) zeros, so the right part has **\(Y.k) digits**"
                + (z > 0 ? ". Pad with \(z) zero\(z > 1 ? "s" : ""): **\(Y.rs)**." : ": **\(Y.rs)**.")
        case "carry":
            t = "**\(Y.d)\(SQ) = \(Y.sq)** is too long. Only \(Y.k) digits fit, so keep **\(Y.rs)** and carry **\(Y.c)** to the left: \(Y.L0) + \(Y.c) = **\(Y.L)**."
        case "join": t = "Join the left part **\(Y.L)** and the right part **\(Y.rs)**. \(Y.n)\(SQ) = **\(Y.ans)**."
        default: t = "Your turn."
        }
        return (t, hl(d.g, Y))
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n)
        let hi = Y.over ? Y.n : Y.B, lo = Y.over ? Y.B : Y.n, op = Y.over ? "+" : MINUS, w = wordOf(Y)
        var T: [PTask] = [
            PTask(g: "diff", cap: "Your turn. How far is **\(Y.n)** from the base **\(Y.B)**?", q: "\(hi) \(MINUS) \(lo)", ans: String(Y.d),
                  ex: [String(hi), MINUS, String(lo)], hint: "Close! Subtract the smaller number from the bigger one."),
            PTask(g: "left", cap: "Left part: \(Y.over ? "add" : "subtract") the \(w). What is **\(Y.n) \(op) \(Y.d)**?", q: "\(Y.n) \(op) \(Y.d)",
                  ans: String(Y.L0), ex: [String(Y.n), op, String(Y.d)],
                  hint: Y.over ? "Close! Above the base, add the excess to the number." : "Close! Below the base, subtract the deficiency from the number."),
        ]
        if Y.c > 0 {
            T.append(PTask(g: "carry", cap: "Right part: **\(Y.d)\(SQ) = \(Y.sq)**, but only **\(Y.k) digits** fit. Type the last \(Y.k) digits.",
                           q: "\(Y.d)\(SQ) = \(Y.sq)", ans: Y.rs, ex: [String(Y.d), SQ], hint: "Close! Keep only the last \(Y.k) digits of \(Y.sq).",
                           ok: "Keep \(Y.rs) on the right, carry \(Y.c)."))
        } else {
            T.append(PTask(g: "right", cap: "Right part: square the \(w). Write **\(Y.d)\(SQ)** with **\(Y.k) digits**.", q: "\(Y.d)\(SQ)", ans: Y.rs,
                           ex: [String(Y.d), SQ], hint: "Close! Square it, then add zeros in front until you have \(Y.k) digits."))
        }
        if Y.c > 0 {
            T.append(PTask(g: "carry", cap: "Carry the **\(Y.c)** to the left part. What is **\(Y.L0) + \(Y.c)**?", q: "\(Y.L0) + \(Y.c)", ans: String(Y.L),
                           ex: [String(Y.L0), "+", String(Y.c)], hint: "Close! Add the carry to the left part."))
        }
        T.append(PTask(g: "join", cap: "Join the parts. What is **\(Y.n)\(SQ)**?", q: "\(Y.n)\(SQ)", ans: String(Y.ans), ex: [],
                       hint: "Close! Write the left part, then the right part."))
        return T
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = yav(p.n)
        var S = Scene("\(Y.n).")
        let T = tasks(p)
        let tt = min(t, T.count - 1)
        let r = work(&S, Y, 250)
        let fin = done || (ok && tt == T.count - 1)
        if fin {
            for i in r.ids { S.mod(i, c: GR) }
            S.mod("pw", c: GR)
            S.finale = SFinale(x: 512, y: 250, w: Double(r.xs.count) * ADV + 140, h: 150)
        } else if !T[tt].ex.isEmpty {
            let ex = T[tt].ex
            let ids = ex.indices.map { "te\(tt)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids[$0.offset], $0.element, op: $0.offset == 1) }, 512, 368, 46)
            S.box("tb\(tt)", 512, 368, max(240, q.total + 90), 84, r: 26, shadow: true)
            for i in r.ids { S.mod(i, c: BLUE) }
            S.fa(r.ids); S.f("tb\(tt)"); S.fa(ids)
        }
        return S
    }

    // MARK: spec

    private static func timing(_ g: String) -> ([Double], Double) {
        switch g {
        case "meet": return ([0, 800, 2300], 3600)
        case "right", "carry": return ([0, 800, 2300, 3800, 5300], 6600)
        case "join": return ([0, 800], 2100)
        case "practice": return ([0, 500], 700)
        default: return ([0, 800, 2300, 3800], 5100)
        }
    }

    private static let steps: [StepDef] = {
        let list: [(String, Int, String)] = [
            ("meet", 97, "Meet the problem"), ("base", 97, "Pick the base"), ("diff", 97, "Find the difference"),
            ("kind", 97, "Deficiency or excess"), ("left", 97, "Left part"), ("right", 97, "Right part"), ("join", 97, "Read the answer"),
            ("diff", 104, "Above the base: 104"), ("kind", 104, "It is an excess"), ("left", 104, "Add the excess"),
            ("right", 104, "Square the excess"), ("join", 104, "Read the answer"),
            ("diff", 88, "A bigger deficiency: 88"), ("left", 88, "Left part"), ("carry", 88, "When the square is long"),
            ("join", 88, "Read the answer"),
            ("base", 997, "A bigger base: 1000"), ("diff", 997, "Find the difference"), ("left", 997, "Left part"),
            ("right", 997, "Zeros fill the gap"), ("join", 997, "Read the answer"),
            ("practice", 0, "Your turn"),
        ]
        return list.map { g, n, name in
            let t = timing(g)
            return StepDef(g: g, n: String(n), name: name, times: t.0, end: t.1)
        }
    }()

    private static func randomN() -> Problem {
        let B = Double.random(in: 0..<1) < 0.6 ? 100 : 1000
        let d = rnd(2, B == 100 ? 14 : 24)
        return Problem(n: String(Bool.random() ? Int(B) - d : Int(B) + d))
    }

    static let spec = LessonSpec(
        id: "yav",
        topTitle: "Squaring near a base",
        cardTitle: "Squaring Near a Base",
        cardBlurb: "Yavadunam: for numbers close to 10, 100 or 1000. Lessen the number by its gap from the base, then add the square of that gap.",
        teaser: [[TeaserRun(text: "97"), TeaserRun(text: SQ, color: Theme.blue, scale: 1.3, pop: true)],
                 [TeaserRun(text: "=")], [TeaserRun(text: "9409")]],
        sutra: "Yavadunam: lessen the number by its gap, then add the gap squared",
        steps: steps,
        practice: [96, 107, 87, 1006].map { Problem(n: String($0)) },
        random: randomN,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { p in
            let Y = yav(p.n)
            return "**\(Y.n)\(SQ) = \(Y.ans)**. Same sutra, every time."
        }
    )
}
