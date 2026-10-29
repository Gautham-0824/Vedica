import SwiftUI

/// Advanced: Sunyam Samyasamuccaye. If the same sum shows up on both sides, that sum is zero.
/// `Problem.n` is the case ("cf", "sm", "dn") and `Problem.m` is "a-b-c-d[-k]".
enum SameSumZeroLesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let EY = 250.0, EZ = 46.0, BY = 530.0
    private static let MINUS = "\u{2212}"

    struct EQ {
        var t: String
        var op = false
        var k = false
        var g: Double? = nil
        var s = ""
    }

    struct ZY {
        var t: String
        var a: Int, b: Int, c: Int, d: Int, k: Int, S: Int, x: Int
        var eq: [EQ]
        var rows: [String: [String]]
        var fin: String
        var tag: String
    }

    static func tm(_ Y: ZY, _ n: Int) -> String { Y.k > 0 ? "\(n)(x\(MINUS)\(Y.k))" : "\(n)x" }

    static func yav(_ t: String, _ vs: String) -> ZY {
        let p = vs.split(separator: "-").map { Int($0) ?? 0 }
        let a = p[0], b = p[1], c = p[2], d = p[3], k = p.count > 4 ? p[4] : 0
        let S = a + b
        var L: [EQ], R: [EQ]
        var rows: [String: [String]]
        var x = 0
        var fin = "zero"
        var tag: String
        func tmk(_ n: Int) -> String { k > 0 ? "\(n)(x\(MINUS)\(k))" : "\(n)x" }
        if t == "cf" {
            let F = k > 0 ? EQ(t: "(x\(MINUS)\(k))", k: true) : EQ(t: "x", k: true)
            func N(_ n: Int) -> EQ { EQ(t: String(n), g: 0) }
            func mkp(_ p: Int, _ q: Int) -> [EQ] { [N(p), F, EQ(t: "+", op: true), N(q), F] }
            L = mkp(a, b); R = mkp(c, d)
            rows = ["left": [tmk(a), "+", tmk(b), "=", tmk(a + b)], "right": [tmk(c), "+", tmk(d), "=", tmk(c + d)]]
            if k > 0 {
                x = k; fin = "solve"
                rows["zero"] = [tmk(a + b), "=", tmk(c + d), "\u{2192}", "x\(MINUS)\(k) = 0"]
                rows["solve"] = ["x\(MINUS)\(k)", "=", "0", "\u{2192}", "x = \(k)"]
                tag = "(x\(MINUS)\(k)) is in every term"
            } else {
                rows["zero"] = [tmk(a + b), "=", tmk(c + d), "\u{2192}", "x = 0"]
                tag = "x is in every term"
            }
        } else {
            func G(_ n: Int) -> EQ { EQ(t: String(n), k: true, g: 0) }
            func P(_ p: Int, _ q: Int) -> [EQ] {
                if t == "sm" {
                    return [EQ(t: "(x\(MINUS)", g: 0), G(p), EQ(t: ")/(x\(MINUS)", g: 0), G(q), EQ(t: ")")]
                }
                return [EQ(t: "1/(x\(MINUS)", g: 0), G(p), EQ(t: ")+1/(x\(MINUS)", g: 0), G(q), EQ(t: ")")]
            }
            L = P(a, b); R = P(c, d)
            x = S / 2; fin = "solve"
            rows = [
                "left": ["(x\(MINUS)\(a))+(x\(MINUS)\(b))", "=", "2x\(MINUS)\(S)"],
                "right": ["(x\(MINUS)\(c))+(x\(MINUS)\(d))", "=", "2x\(MINUS)\(S)"],
                "zero": ["2x\(MINUS)\(S)", "=", "0"],
                "solve": ["2x", "=", String(S), "\u{2192}", "x = \(x)"],
            ]
            tag = t == "sm" ? "Add numerator and denominator on each side" : "Same numerators: add the denominators"
        }
        for i in L.indices { L[i].s = "L" }
        for i in R.indices { R[i].s = "R" }
        let eq = L + [EQ(t: "=", op: true, s: "M")] + R
        return ZY(t: t, a: a, b: b, c: c, d: d, k: k, S: S, x: x, eq: eq, rows: rows, fin: fin, tag: tag)
    }

    private static func opT(_ t: String) -> Bool { t.count == 1 && "+\u{00D7}=\u{2192}\u{00F7}".contains(t) }

    // MARK: scenes

    private struct Row { var xs: [Double]; var total: Double; var ids: [String]; var L: [String]; var R: [String]; var K: [String] }

    private static func eqRow(_ S: inout Scene, _ Y: ZY, _ y: Double, _ z0: Double) -> Row {
        let items = Y.eq.enumerated().map { (i, e) in SeqItem("e\(i)", e.t, op: e.op, g: e.g) }
        var q = S.seq(items, 512, y, z0)
        if q.total > 640 { q = S.seq(items, 512, y, z0 * 640 / q.total) }
        let ids = Y.eq.indices.map { "e\($0)" }
        func pick(_ f: (EQ) -> Bool) -> [String] { ids.enumerated().filter { f(Y.eq[$0.offset]) }.map { $0.element } }
        return Row(xs: q.xs, total: q.total, ids: ids, L: pick { $0.s == "L" }, R: pick { $0.s == "R" }, K: pick { $0.k })
    }

    private static func calc(_ S: inout Scene, _ Y: ZY, _ ph: Int, _ key: String, _ side: String) {
        let r = eqRow(&S, Y, EY, EZ)
        for i in r.K { S.mod(i, c: OR) }
        let T = Y.rows[key]!
        let last = T.count - 1
        let fly = Y.fin == key
        let items = T.enumerated().map { (i, t) in BubItem("c\(i)", t, op: opT(t), res: i == last, c: i == last ? OR : INK) }
        let b = S.bub(items, ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
        if key != "left" {
            S.el("hold", "Left side: " + Y.rows["left"]!.last!, 512, 640, z: 28, c: MU, w: 800, o: fly && ph >= 3 ? 0 : 1)
        }
        let tg = side == "L" ? r.L : (side == "R" ? r.R : r.ids)
        if ph == 0 { S.fa(tg); S.h(tg.last!) }
        if ph == 1 { S.fa(tg); S.f("bub"); S.fa(b.rest); S.h("c1") }
        if ph >= 2 { S.f("bub"); S.fa(b.res); S.h(b.res[0]) }
        if side != "M" && ph >= 1 && ph < 3 {
            let ix = tg.map { Int($0.dropFirst()) ?? 0 }
            let lo = ix.min()!, hi = ix.max()!
            S.arrow(0, ((r.xs[lo] + r.xs[hi]) / 2, EY + 36), (b.xs[0] - 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: 0.25)
        }
        if fly && ph >= 3 {
            S.mod(b.res[0], x: 512, y: 420, o: 1, s: 96.0 / 52.0, c: GR)
            for id in b.rest { S.mod(id, o: 0) }
            S.mod("bub", o: 0, s: 0.9)
            S.finale = SFinale(x: 512, y: 420, w: 400, h: 170)
            S.win = true
            S.focus = nil
            S.hand = nil
        }
    }

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = yav(d.n, d.m)
        var S = Scene("\(d.n)x\(d.m).")
        switch d.g {
        case "meet":
            let r = eqRow(&S, Y, EY, EZ)
            if ph == 0 { S.hide(r.ids) }
            if ph >= 2 { for i in r.ids { S.mod(i, c: BLUE) }; S.fa(r.ids); S.h(r.ids.last!) }
        case "look":
            let r = eqRow(&S, Y, EY, EZ)
            if ph >= 1 { for i in r.K { S.mod(i, c: OR) } }
            S.box("tag", 512, 170, max(300, Double(Y.tag.count) * 15 + 60), 64, o: ph >= 2 ? 1 : 0, s: ph >= 2 ? 1 : 0.9,
                  r: 22, shadow: true, q: Y.tag, qz: 26, qc: OR)
            if ph == 1 { S.fa(r.K); S.h(r.K.last!) }
            if ph >= 2 { S.f("tag"); S.fa(r.K); S.hp(512, 208) }
        case "left": calc(&S, Y, ph, "left", "L")
        case "right": calc(&S, Y, ph, "right", "R")
        case "zero": calc(&S, Y, ph, "zero", "M")
        case "solve": calc(&S, Y, ph, "solve", "M")
        default: break
        }
        return S
    }

    private static func hl(_ g: String) -> Color {
        switch g {
        case "look", "left", "right": return OR
        case "zero", "solve": return GR
        default: return BLUE
        }
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n, d.m)
        switch d.g {
        case "left": return (Y.t == "cf" ? "Left: " + tm(Y, Y.a + Y.b) : "Sum = 2x\(MINUS)\(Y.S)", OR)
        case "right": return (Y.t == "cf" ? "Right: " + tm(Y, Y.c + Y.d) : "Sum = 2x\(MINUS)\(Y.S)", OR)
        case "zero":
            return (Y.t == "cf" ? (Y.k > 0 ? "x\(MINUS)\(Y.k) = 0" : "x = 0") : "2x\(MINUS)\(Y.S) = 0", GR)
        case "solve": return ("x = \(Y.x)", GR)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n, d.m)
        var t = ""
        let cf = Y.t == "cf"
        switch d.g {
        case "meet":
            t = "Solving this looks like a lot of algebra. The sutra says: **if the sum is the same, it is zero.**"
        case "look":
            if cf {
                t = Y.k > 0 ? "Look at every term. The same bracket **(x\(MINUS)\(Y.k))** is in all of them."
                            : "Look at every term. The same **x** is in all of them."
            } else if Y.t == "sm" {
                t = "Each side is a fraction. Look at the numbers inside: **\(Y.a), \(Y.b)** and **\(Y.c), \(Y.d)**."
            } else {
                t = "Every top is 1. Look at the denominators: **\(Y.a), \(Y.b)** and **\(Y.c), \(Y.d)**."
            }
        case "left":
            if cf { t = "Add the left side. **\(tm(Y, Y.a)) + \(tm(Y, Y.b)) = \(tm(Y, Y.a + Y.b))**." }
            else if Y.t == "sm" { t = "Add the numerator and the denominator on the left. **(x\(MINUS)\(Y.a)) + (x\(MINUS)\(Y.b)) = 2x\(MINUS)\(Y.S)**." }
            else { t = "Add the two denominators on the left. **(x\(MINUS)\(Y.a)) + (x\(MINUS)\(Y.b)) = 2x\(MINUS)\(Y.S)**." }
        case "right":
            if cf { t = "Add the right side. **\(tm(Y, Y.c)) + \(tm(Y, Y.d)) = \(tm(Y, Y.c + Y.d))**." }
            else { t = "Now the right side. **(x\(MINUS)\(Y.c)) + (x\(MINUS)\(Y.d)) = 2x\(MINUS)\(Y.S)**. The same as the left!" }
        case "zero":
            if cf {
                t = Y.k > 0 ? "Every term has (x\(MINUS)\(Y.k)), so the equation holds only when that bracket is zero: **x\(MINUS)\(Y.k) = 0**."
                            : "Every term has x, so the equation holds only when **x = 0**."
            } else { t = "The sums are the same, so that sum is zero: **2x\(MINUS)\(Y.S) = 0**." }
        case "solve":
            t = cf ? "So **x = \(Y.k)**. The bracket is zero." : "Solve it. 2x = \(Y.S), so **x = \(Y.x)**."
        default: t = "Your turn."
        }
        return (t, hl(d.g))
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n, p.m)
        let a = Y.a, b = Y.b, c = Y.c, d = Y.d, S = Y.S
        func add(_ p: Int, _ q: Int, _ g: String, _ h: String, _ cap: String) -> PTask {
            PTask(g: g, cap: cap, q: "\(p) + \(q)", ans: String(p + q), ex: [String(p), "+", String(q)], hint: h)
        }
        if Y.t == "cf" {
            let third: PTask = Y.k > 0
                ? PTask(g: "solve", cap: "Every term has (x\(MINUS)\(Y.k)). The bracket must be zero: x \(MINUS) \(Y.k) = 0. What is **x**?",
                        q: "x", ans: String(Y.k), ex: [], hint: "Close! If x \(MINUS) \(Y.k) = 0, then x is \(Y.k).")
                : PTask(g: "zero", cap: "Every term has x, so \(a + b)x = \(c + d)x holds for only one value. What is **x**?",
                        q: "x", ans: "0", ex: [], hint: "Close! A common factor of x means x = 0.")
            return [
                add(a, b, "left", "Close! Add the two numbers in front of " + (Y.k > 0 ? "the bracket." : "x."),
                    "Add the left side. What is **\(a) + \(b)**? That is the number in front of " + (Y.k > 0 ? "(x\(MINUS)\(Y.k))." : "x.")),
                add(c, d, "right", "Close! Add \(c) and \(d).", "Now the right side: **\(c) + \(d)**."),
                third,
            ]
        }
        let w = Y.t == "sm" ? "numbers" : "denominators"
        return [
            add(a, b, "left", "Close! Add the two numbers on the left.", "Add the \(w) on the left: **\(a) + \(b)**."),
            add(c, d, "right", "Close! Add \(c) and \(d).", "Now the right side: **\(c) + \(d)**."),
            PTask(g: "solve", cap: "The sums match, so 2x\(MINUS)\(S) = 0. What is **x**? Half of \(S).", q: "x", ans: String(Y.x),
                  ex: [String(S), "\u{00F7}", "2"], hint: "Close! 2x = \(S), so divide \(S) by 2."),
        ]
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = yav(p.n, p.m)
        var S = Scene("\(p.n)x\(p.m).")
        let T = tasks(p)
        let tt = min(t, T.count - 1)
        let r = eqRow(&S, Y, EY, EZ)
        let fin = done || (ok && tt == T.count - 1)
        if fin {
            for i in r.ids { S.mod(i, c: GR) }
            S.finale = SFinale(x: 512, y: EY, w: r.total + 120, h: 130)
        } else if !T[tt].ex.isEmpty {
            let ex = T[tt].ex
            let ids2 = ex.indices.map { "te\(tt)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids2[$0.offset], $0.element, op: $0.offset == 1) }, 512, 368, 46)
            S.box("tb\(tt)", 512, 368, max(240, q.total + 90), 84, r: 26, shadow: true)
            for i in (tt == 0 ? r.L : (tt == 1 ? r.R : r.ids)) { S.mod(i, c: BLUE) }
            S.fa(r.ids); S.f("tb\(tt)"); S.fa(ids2)
        }
        return S
    }

    // MARK: spec

    private static func timing(_ g: String) -> ([Double], Double) {
        switch g {
        case "meet": return ([0, 800, 2300], 3600)
        case "practice": return ([0, 500], 700)
        default: return ([0, 800, 2300, 3800], 5100)
        }
    }

    private static let steps: [StepDef] = {
        func five(_ t: String, _ v: String, _ n: [String]) -> [(String, String, String, String)] {
            [("look", t, v, n[0]), ("left", t, v, n[1]), ("right", t, v, n[2]), ("zero", t, v, n[3]), ("solve", t, v, n[4])]
        }
        var list: [(String, String, String, String)] = [("meet", "cf", "12-3-4-5", "Meet the equation")]
        list += five("cf", "12-3-4-5", ["Look for the pattern", "Add the left side", "Add the right side", "Common factor: x = 0", ""])
            .prefix(4).map { $0 }
        list += five("cf", "9-2-4-3-3", ["A bracket as common factor", "Add the left side", "Add the right side", "The bracket is zero", "Find x"])
        list += five("sm", "1-7-3-5", ["Fractions: look inside", "Add on the left", "Add on the right", "The sum is zero", "Find x"])
        list += five("dn", "1-5-2-4", ["Same tops: look at bottoms", "Add the bottoms on the left", "Add the bottoms on the right", "The sum is zero", "Find x"])
        list.append(("practice", "", "", "Your turn"))
        return list.map { g, n, m, name in
            let t = timing(g)
            return StepDef(g: g, n: n, m: m, name: name, times: t.0, end: t.1)
        }
    }()

    private static func randomP() -> Problem {
        let t = ["cf", "sm", "dn"][rnd(0, 2)]
        if t == "cf" {
            var a = 0, b = 0, c = 0, d = 0
            repeat { a = rnd(2, 15); b = rnd(2, 9); c = rnd(2, 12); d = rnd(2, 9) } while a + b == c + d
            let k = rnd(0, 9)
            return Problem(n: t, m: [a, b, c, d].map(String.init).joined(separator: "-") + (k > 0 ? "-\(k)" : ""))
        }
        let S = [8, 10, 12, 14, 16][rnd(0, 4)]
        let a = rnd(1, S / 2 - 1)
        var c = a
        repeat { c = rnd(1, S / 2 - 1) } while c == a
        return Problem(n: t, m: [a, S - a, c, S - c].map(String.init).joined(separator: "-"))
    }

    static let spec = LessonSpec(
        id: "ssz",
        topTitle: "Same sum means zero",
        cardTitle: "Same Sum Means Zero",
        cardBlurb: "When the same sum shows up on both sides, that sum is zero. Setting it to zero gives you x. Look out for these three cases.",
        rows: [
            InfoRow(title: "Common factor", sub: "9(x\(MINUS)3) + 2(x\(MINUS)3) = 4(x\(MINUS)3) + 3(x\(MINUS)3)", value: "x = 3"),
            InfoRow(title: "Same sum of top + bottom", sub: "(x\(MINUS)1)/(x\(MINUS)7) = (x\(MINUS)3)/(x\(MINUS)5)", value: "x = 4"),
            InfoRow(title: "Same sum of denominators", sub: "1/(x\(MINUS)1)+1/(x\(MINUS)5) = 1/(x\(MINUS)2)+1/(x\(MINUS)4)", value: "x = 3"),
        ],
        sutra: "Sunyam Samyasamuccaye: if the sum is the same, that sum is zero",
        steps: steps,
        practice: [Problem(n: "cf", m: "7-2-3-4"), Problem(n: "cf", m: "5-4-3-2-6"), Problem(n: "sm", m: "2-8-4-6"),
                   Problem(n: "dn", m: "1-7-3-5"), Problem(n: "sm", m: "3-11-5-9")],
        random: randomP,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { p in "**x = \(yav(p.n, p.m).x)**. Same sum means zero, every time." }
    )
}
