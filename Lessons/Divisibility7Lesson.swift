import SwiftUI

/// Advanced: Vestanam. Chop the last digit, subtract double it from the rest, repeat; then check the 7 times table.
enum Divisibility7Lesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let Z = 96.0, ADV = 60.0, RY = 320.0, BY = 530.0, SP = 26.0
    private static let DASH = Color(hex: 0xcbd7e3)
    private static let MINUS = "\u{2212}"

    struct Round { var ld: Int, rest: Int, dbl: Int, res: Int }

    struct VY {
        var n: Int
        var vals: [Int]
        var rounds: [Round]
        var K: Int
        var fin: Int
        var yes: Bool
        var ok: Bool
    }

    static func v7(_ n: Int) -> VY {
        var vals = [n], rounds: [Round] = []
        var v = n, ok = true
        while v >= 100 {
            let s = String(v)
            let ld = Int(String(s.last!))!, rest = Int(s.dropLast())!
            let dbl = ld * 2, raw = rest - dbl
            if raw < 0 { ok = false }
            let res = abs(raw)
            rounds.append(Round(ld: ld, rest: rest, dbl: dbl, res: res))
            v = res
            vals.append(v)
        }
        return VY(n: n, vals: vals, rounds: rounds, K: rounds.count, fin: v, yes: v % 7 == 0, ok: ok)
    }

    // MARK: helpers

    private static func digs(_ n: Int) -> [String] { String(n).map { String($0) } }
    private static func xsOf(_ n: Int, _ cx: Double, _ a: Double) -> [Double] {
        (0..<n).map { cx + (Double($0) - Double(n - 1) / 2) * a }
    }

    private struct Row { var ids: [String]; var xs: [Double]; var n: Int; var rest: [String]; var last: String }

    private static func rowOf(_ S: inout Scene, _ Y: VY, _ k: Int, _ split: Bool, _ y: Double = RY, _ base: Color = BLUE) -> Row {
        let d = digs(Y.vals[k]), n = d.count, xs = xsOf(n, 512, ADV)
        var ids: [String] = []
        for (i, ch) in d.enumerated() {
            let l = i == n - 1
            S.el("r\(k)_\(i)", ch, xs[i] + (split ? (l ? SP : -SP) : 0), y, c: split && l ? OR : base)
            ids.append("r\(k)_\(i)")
        }
        return Row(ids: ids, xs: xs, n: n, rest: Array(ids.dropLast()), last: ids[n - 1])
    }

    private static func dvd(_ S: inout Scene, _ r: Row, _ id: String, _ y: Double, _ o: Double) {
        S.box(id, (r.xs[r.n - 2] + r.xs[r.n - 1]) / 2, y, 5, 128, o: o, r: 3, c: DASH, fill: DASH)
    }

    private static func multsOf7(_ f: Int) -> String {
        var a: [Int] = []
        var m = f == 0 ? 0 : 7
        while m <= f + 7 { a.append(m); m += 7 }
        let t = Array(a.suffix(6))
        return (t.count < a.count ? "\u{2026} " : "") + t.map(String.init).joined(separator: " \u{00B7} ")
    }

    // MARK: scenes

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = v7(Int(d.n) ?? 2527)
        let k = d.k ?? 0
        var S = Scene("\(Y.n).")
        switch d.g {
        case "meet":
            let r = rowOf(&S, Y, 0, false, RY, ph >= 2 ? BLUE : INK)
            S.el("lbl", "\(Y.n) \u{00F7} 7 ?", 512, 168, z: 36, c: MU, w: 800)
            if ph == 0 { S.hide(r.ids + ["lbl"]) }
            if ph >= 2 { S.fa(r.ids); S.h(r.last) }
        case "rule":
            let r = rowOf(&S, Y, 0, false)
            let b = S.bub([BubItem("wr", "rest", c: BLUE, o: ph >= 1 ? 1 : 0), BubItem("wm", MINUS, op: true, o: ph >= 2 ? 1 : 0),
                           BubItem("w2", "2 \u{00D7}", op: true, c: OR, o: ph >= 2 ? 1 : 0),
                           BubItem("wl", "last digit", c: OR, o: ph >= 3 ? 1 : 0)], ph >= 1 ? 1 : 0, 0, 0)
            S.el("nt", "Repeat until you have 2 digits or fewer", 512, 640, z: 26, c: MU, w: 800, o: ph >= 3 ? 1 : 0)
            if ph >= 1 { S.arrow(0, (512, RY + 56), (b.xs[0] - 6, BY - 62), st: ph >= 3 ? 2 : 1, bend: 0.25) }
            if ph == 0 { S.fa(r.ids); S.h(r.last) }
            if ph == 1 { S.f("bub", "wr"); S.h("wr") }
            if ph == 2 { S.f("bub", "wr", "wm", "w2"); S.h("w2") }
            if ph >= 3 { S.f("bub"); S.fa(b.ids); S.f("nt"); S.h("wl") }
        case "split":
            let R = Y.rounds[k]
            let r = rowOf(&S, Y, k, ph >= 1)
            S.el("rl", "Round \(k + 1)", 512, 140, z: 32, c: MU, w: 800)
            dvd(&S, r, "dv", RY, ph >= 1 ? 1 : 0)
            let rx = r.xs.dropLast().reduce(0, +) / Double(r.n - 1) - SP
            S.el("lr", "rest", rx, RY - 92, z: 24, c: BLUE, w: 800, o: ph == 2 ? 1 : 0)
            S.el("ll", "last digit", r.xs[r.n - 1] + SP, RY - 92, z: 24, c: OR, w: 800, o: ph == 2 ? 1 : 0)
            S.box("tag", 512, 210, 350, 64, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 22, shadow: true,
                  q: "Last digit = \(R.ld)", qz: 28, qc: OR)
            if ph == 1 { S.fa(r.ids); S.f("dv"); S.h(r.last) }
            if ph == 2 { S.fa(r.ids); S.f("dv", "lr", "ll"); S.h(r.last) }
            if ph >= 3 { S.f("tag", r.last); S.hp(512, 250) }
        case "dbl":
            let R = Y.rounds[k]
            let r = rowOf(&S, Y, k, true)
            S.el("rl", "Round \(k + 1)", 512, 140, z: 32, c: MU, w: 800)
            dvd(&S, r, "dv", RY, 1)
            let b = S.bub([BubItem("ba", String(R.ld), c: OR), BubItem("bx", "\u{00D7}", op: true), BubItem("b2", "2", op: true, c: OR),
                           BubItem("be", "=", op: true), BubItem("br", String(R.dbl), res: true, c: OR)],
                          ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
            S.el("zl", "\(R.ld) + \(R.ld) = \(R.dbl)", 512, 640, z: 26, c: MU, w: 800, o: ph >= 3 ? 1 : 0)
            if ph >= 1 { S.arrow(0, (r.xs[r.n - 1] + SP, RY + 56), (b.xs[0] - 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: 0.25) }
            if ph == 0 { S.fa(r.ids); S.f("dv"); S.h(r.last) }
            if ph == 1 { S.f(r.last, "bub"); S.fa(b.rest); S.h("ba") }
            if ph == 2 { S.f("bub"); S.fa(b.res); S.h("br") }
            if ph >= 3 { S.f("bub"); S.fa(b.ids); S.f("zl"); S.h("br") }
        case "sub":
            let R = Y.rounds[k]
            let r = rowOf(&S, Y, k, true)
            let ns = String(R.res).count
            func nid(_ i: Int) -> String { "r\(k + 1)_\(i)" }
            S.el("rl", "Round \(k + 1)", 512, 140, z: 32, c: MU, w: 800)
            dvd(&S, r, "dv", RY, ph < 4 ? 1 : 0)
            S.el("gd", String(R.dbl), 512, 196, z: 54, c: OR, o: ph >= 1 && ph < 4 ? 1 : 0)
            let on = ph >= 2 && ph < 4 ? 1.0 : 0.0
            var items = [BubItem("sa", String(R.rest), c: BLUE), BubItem("so", MINUS, op: true), BubItem("sb", String(R.dbl), c: OR),
                         BubItem("se", "=", op: true)]
            for (i, ch) in digs(R.res).enumerated() { items.append(BubItem(nid(i), ch, res: true, c: BLUE, g: i < ns - 1 ? 0 : nil)) }
            let b = S.bub(items, on, on, ph >= 3 ? 1 : 0)
            if ph >= 1 { S.mod(r.last, o: 0.28) }
            if ph >= 2 && ph < 4 { S.arrow(0, (512, RY + 56), (b.xs[0] - 6, BY - 62), st: ph >= 3 ? 2 : 1, bend: 0.25) }
            if ph == 0 { S.fa(r.ids); S.f("dv"); S.h(r.last) }
            if ph == 1 { S.f("gd"); S.fa(r.rest); S.h("gd") }
            if ph == 2 { S.f("bub"); S.fa(b.rest); S.h("sb") }
            if ph == 3 { S.f("bub"); S.fa(b.res); S.h(b.res[ns - 1]) }
            if ph >= 4 {
                let nx = xsOf(ns, 512, ADV)
                for (i, id) in b.res.enumerated() { S.mod(id, x: nx[i], y: RY, o: 1, s: Z / 52) }
                for id in b.rest { S.mod(id, o: 0) }
                S.mod("bub", o: 0, s: 0.9)
                for i in r.ids { S.mod(i, o: 0) }
                S.fa(b.res); S.h(b.res[ns - 1])
            }
        case "verdict":
            let col = Y.yes ? GR : OR
            let r = rowOf(&S, Y, Y.K, false, RY, ph >= 2 ? col : BLUE)
            S.el("rl", "Is it in the 7 times table?", 512, 140, z: 32, c: MU, w: 800)
            S.el("mt", "Multiples of 7:  " + multsOf7(Y.fin), 512, 560, z: 26, c: MU, w: 800, o: ph >= 1 && ph < 3 ? 1 : 0)
            S.el("ck", Y.yes ? "Check: 7 \u{00D7} \(Y.n / 7) = \(Y.n)" : "\(Y.n) \u{00F7} 7 = \(Y.n / 7) remainder \(Y.n % 7)",
                 512, 560, z: 26, c: col, w: 800, o: ph >= 3 ? 1 : 0)
            S.box("tag", 512, 210, Y.yes ? 400 : 380, 64, o: ph >= 2 ? 1 : 0, s: ph >= 2 ? 1 : 0.9, r: 22, shadow: true,
                  q: Y.yes ? "Yes \u{2713}  Multiple of 7" : "No \u{2717}  Not a multiple of 7", qz: 26, qc: col)
            if ph == 0 { S.fa(r.ids); S.h(r.last) }
            if ph == 1 { S.fa(r.ids); S.f("mt") }
            if ph >= 2 {
                S.finale = SFinale(x: 512, y: RY, w: max(300, Double(r.n) * ADV + 140), h: 160)
                S.win = Y.yes
            }
            if ph == 2 { S.f("tag"); S.fa(r.ids); S.hp(512, 250) }
            if ph >= 3 { S.f("ck", "tag"); S.fa(r.ids); S.h("ck") }
        default: break
        }
        return S
    }

    private static func hl(_ g: String, _ Y: VY) -> Color {
        switch g {
        case "verdict": return Y.yes ? GR : OR
        case "split", "dbl": return OR
        default: return BLUE
        }
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = v7(Int(d.n) ?? 2527)
        let k = d.k ?? 0
        switch d.g {
        case "split": return ("Last digit: \(Y.rounds[k].ld)", OR)
        case "dbl": return ("\(Y.rounds[k].ld) \u{00D7} 2 = \(Y.rounds[k].dbl)", OR)
        case "sub": return ("\(Y.rounds[k].rest) \(MINUS) \(Y.rounds[k].dbl) = \(Y.rounds[k].res)", BLUE)
        case "verdict": return ("Answer: " + (Y.yes ? "Yes" : "No"), Y.yes ? GR : OR)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = v7(Int(d.n) ?? 2527)
        let k = d.k ?? 0
        var t = ""
        switch d.g {
        case "meet": t = "Is **\(Y.n)** a multiple of 7? Vestanam gives a quick test. **Watch this.**"
        case "rule": t = "The rule: chop off the **last digit**, then subtract **double** it from the **rest**."
        case "split":
            let R = Y.rounds[k]
            t = (k > 0 ? "Round \(k + 1). " : "") + "Chop off the last digit of \(Y.vals[k]): **\(R.ld)** is the last digit and **\(R.rest)** is the rest."
        case "dbl":
            let R = Y.rounds[k]
            t = "Double the last digit: **\(R.ld) \u{00D7} 2 = \(R.dbl)**."
        case "sub":
            let R = Y.rounds[k], ns = String(R.res).count
            t = "Subtract it from the rest: **\(R.rest) \(MINUS) \(R.dbl) = \(R.res)**. "
                + (k < Y.K - 1 ? "\(R.res) still has \(ns) digits, so go again." : "\(R.res) is small enough to check.")
        case "verdict":
            if Y.fin == 0 { t = "**0** counts as a multiple of 7. So **\(Y.n)** is a **multiple of 7**!" }
            else if Y.yes { t = "**\(Y.fin)** is in the 7 times table. So **\(Y.n)** is a **multiple of 7**!" }
            else { t = "**\(Y.fin)** is not in the 7 times table. So **\(Y.n)** is **not** a multiple of 7." }
        default: t = "Your turn."
        }
        return (t, hl(d.g, Y))
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = v7(Int(p.n) ?? 2527)
        var T: [PTask] = []
        for (k, R) in Y.rounds.enumerated() {
            T.append(PTask(g: "dbl", cap: "Round \(k + 1): the number is **\(Y.vals[k])**. Double the last digit: **\(R.ld) \u{00D7} 2**.",
                           q: "\(R.ld) \u{00D7} 2", ans: String(R.dbl), ex: [String(R.ld), "\u{00D7}", "2"], hint: "Close! Doubling means times 2.", k: k))
            T.append(PTask(g: "sub", cap: "Now subtract: **\(R.rest) \(MINUS) \(R.dbl)**. The rest is everything except the last digit.",
                           q: "\(R.rest) \(MINUS) \(R.dbl)", ans: String(R.res), ex: [String(R.rest), MINUS, String(R.dbl)],
                           hint: "Close! Take the doubled digit away from the rest.", k: k))
        }
        T.append(PTask(g: "verdict", cap: "We end at **\(Y.fin)**. Is it a multiple of 7? Type **1** for Yes or **0** for No.",
                       q: "1 = Yes, 0 = No", ans: Y.yes ? "1" : "0", ex: [], hint: "Close! Check the 7 times table: 7, 14, 21, 28\u{2026}",
                       ok: "\(Y.fin)" + (Y.yes ? " is a multiple of 7" : " is not a multiple of 7"), k: Y.K))
        return T
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = v7(Int(p.n) ?? 2527)
        var S = Scene("\(Y.n).")
        let T = tasks(p)
        let tt = min(t, T.count - 1)
        let tk = T[tt]
        let fin = done || (ok && tt == T.count - 1)
        let k = tk.k ?? 0
        let last = k == Y.K
        if fin {
            let r = rowOf(&S, Y, Y.K, false, 250)
            for i in r.ids { S.mod(i, c: Y.yes ? GR : OR) }
            S.finale = SFinale(x: 512, y: 250, w: max(300, Double(r.n) * ADV + 140), h: 150)
            return S
        }
        let r = rowOf(&S, Y, k, !last, 250)
        S.el("prl", last ? "Final check" : "Round \(k + 1)", 512, 140, z: 32, c: MU, w: 800)
        if !last { dvd(&S, r, "dv", 250, 1) }
        if !tk.ex.isEmpty {
            let ex = tk.ex
            let ids = ex.indices.map { "te\(tt)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids[$0.offset], $0.element, op: $0.offset == 1) }, 512, 368, 46)
            S.box("tb\(tt)", 512, 368, max(240, q.total + 90), 84, r: 26, shadow: true)
            S.fa(r.ids); S.f("prl", "dv", "tb\(tt)"); S.fa(ids)
        } else {
            S.fa(r.ids); S.f("prl")
        }
        return S
    }

    // MARK: spec

    private static func timing(_ g: String) -> ([Double], Double) {
        switch g {
        case "meet": return ([0, 800, 2300], 3600)
        case "sub": return ([0, 800, 2300, 3800, 5300], 6600)
        case "practice": return ([0, 500], 700)
        default: return ([0, 800, 2300, 3800], 5100)
        }
    }

    private static let steps: [StepDef] = {
        let list: [(String, Int, String, Int?)] = [
            ("meet", 2527, "Meet the problem", nil), ("rule", 2527, "The Vestanam rule", nil),
            ("split", 2527, "Round 1 \u{00B7} last digit", 0), ("dbl", 2527, "Round 1 \u{00B7} double it", 0), ("sub", 2527, "Round 1 \u{00B7} subtract", 0),
            ("split", 2527, "Round 2 \u{00B7} last digit", 1), ("dbl", 2527, "Round 2 \u{00B7} double it", 1), ("sub", 2527, "Round 2 \u{00B7} subtract", 1),
            ("verdict", 2527, "Read the answer", nil),
            ("meet", 2528, "A \u{201C}No\u{201D} example", nil),
            ("split", 2528, "Round 1 \u{00B7} last digit", 0), ("dbl", 2528, "Round 1 \u{00B7} double it", 0), ("sub", 2528, "Round 1 \u{00B7} subtract", 0),
            ("split", 2528, "Round 2 \u{00B7} last digit", 1), ("dbl", 2528, "Round 2 \u{00B7} double it", 1), ("sub", 2528, "Round 2 \u{00B7} subtract", 1),
            ("verdict", 2528, "Not a multiple", nil),
            ("meet", 343, "A shorter one", nil), ("split", 343, "Last digit", 0), ("dbl", 343, "Double it", 0), ("sub", 343, "Subtract", 0),
            ("verdict", 343, "Read the answer", nil),
            ("practice", 0, "Your turn", nil),
        ]
        return list.map { g, n, name, k in
            let t = timing(g)
            return StepDef(g: g, n: String(n), name: name, times: t.0, end: t.1) .withK(k)
        }
    }()

    private static func randomN() -> Problem {
        for _ in 0..<200 {
            let n = Bool.random() ? 7 * rnd(15, 1400) : rnd(100, 9999)
            if v7(n).ok { return Problem(n: String(n)) }
        }
        return Problem(n: "2527")
    }

    static let spec = LessonSpec(
        id: "d7",
        topTitle: "Divisibility by 7",
        cardTitle: "Divisibility by 7",
        cardBlurb: "Vestanam: a quick test for 7. Chop off the last digit, subtract double it from the rest, and repeat until the number is small.",
        teaser: [[TeaserRun(text: "2527")], [TeaserRun(text: "\u{2192}", color: Theme.muted)],
                 [TeaserRun(text: "7 \u{2713}", color: Theme.green, pop: true)]],
        sutra: "Vestanam: chop the last digit, subtract double it from the rest",
        steps: steps,
        practice: [Problem(n: "3185"), Problem(n: "4622"), Problem(n: "1736"), Problem(n: "6049")],
        random: randomN,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { p in
            let Y = v7(Int(p.n) ?? 2527)
            return "**\(Y.n)** is " + (Y.yes ? "" : "not ") + "a multiple of 7. Same rule, every time."
        }
    )
}

private extension StepDef {
    func withK(_ k: Int?) -> StepDef { var s = self; s.k = k; return s }
}
