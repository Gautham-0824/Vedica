import SwiftUI

/// Advanced: n² = 50 × (n + d) + d², where d = n − 50.
enum Squares50to100Lesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let Z = 96.0, ADV = 60.0, RY = 320.0, BY = 530.0
    private static let MINUS = "\u{2212}", SQ = "\u{00B2}", TIMES = "\u{00D7}"

    struct SY { var n: Int, d: Int, s: Int, m: Int, sq: Int, ans: Int }

    static func yav(_ n: String) -> SY {
        let n = Int(n) ?? 56
        let d = n - 50, s = n + d
        return SY(n: n, d: d, s: s, m: s * 50, sq: d * d, ans: n * n)
    }

    // MARK: helpers

    private static func digs(_ s: String) -> [String] { s.map { String($0) } }
    private static func digs(_ n: Int) -> [String] { digs(String(n)) }
    private static func xsOf(_ n: Int, _ cx: Double, _ a: Double) -> [Double] {
        (0..<n).map { cx + (Double($0) - Double(n - 1) / 2) * a }
    }
    private static func di(_ id: String, _ n: Int, _ c: Color, _ res: Bool = false) -> [BubItem] {
        let d = digs(n)
        return d.enumerated().map { BubItem(id + String($0.offset), $0.element, res: res, c: c, g: $0.offset < d.count - 1 ? 0 : nil) }
    }
    private static func ids(_ id: String, _ n: Int) -> [String] { digs(n).indices.map { id + String($0) } }

    @discardableResult
    private static func dg(_ S: inout Scene, _ id: String, _ n: Int, _ cx: Double, _ y: Double,
                           z: Double = Z, c: Color = INK) -> [Double] {
        let d = digs(n), xs = xsOf(d.count, cx, ADV)
        for (i, ch) in d.enumerated() { S.el(id + String(i), ch, xs[i], y, z: z, c: c) }
        return xs
    }

    private static func work(_ S: inout Scene, _ Y: SY, _ y: Double) -> (xs: [Double], ids: [String]) {
        let d = digs(Y.n), xs = xsOf(d.count, 512, ADV)
        var out: [String] = []
        for (i, ch) in d.enumerated() { S.el("n\(i)", ch, xs[i], y); out.append("n\(i)") }
        S.el("pw", SQ, xs[xs.count - 1] + 46, y - 46, z: 46, c: MU, w: 800)
        return (xs, out)
    }

    private static func arr(_ S: inout Scene, _ b: BubResult, _ ph: Int, _ a: Int, _ z: Int) {
        if ph >= a && ph < z { S.arrow(0, (512, RY + 56), (b.xs[0] - 6, BY - 62), st: ph >= a + 1 ? 2 : 1, bend: 0.25) }
    }

    private static func bubble(_ S: inout Scene, _ items: [BubItem], _ bo: Double, _ to: Double, _ ro: Double) -> BubResult {
        S.bub(items, bo, to, ro, sq: true)
    }

    // MARK: scenes

    private static func scene(_ dd: StepDef, _ ph: Int) -> Scene {
        let Y = yav(dd.n)
        var S = Scene("\(Y.n).")
        let on1 = ph >= 1 ? 1.0 : 0.0
        switch dd.g {
        case "meet":
            let r = work(&S, Y, RY)
            S.el("lbl", "\(Y.n) \(TIMES) \(Y.n)", 512, 168, z: 36, c: MU, w: 800)
            if ph == 0 { S.hide(r.ids + ["pw", "lbl"]) }
            if ph >= 2 { for i in r.ids { S.mod(i, c: BLUE) }; S.fa(r.ids); S.h(r.ids.last!) }
        case "ref":
            let r = work(&S, Y, RY)
            S.el("g50", "50", 512, 196, z: 64, c: OR, o: on1)
            let on2 = ph >= 2 ? 1.0 : 0.0
            let b = bubble(&S, [BubItem("fa", String(Y.n)), BubItem("fe", "=", op: true), BubItem("fb", "50", c: OR),
                                BubItem("fp", "+", op: true)] + di("D", Y.d, BLUE), on2, on2, 1)
            if ph >= 3 { for i in r.ids { S.mod(i, c: BLUE) } }
            if ph == 1 { S.f("g50"); S.fa(r.ids); S.h("g50") }
            if ph >= 2 { S.f("bub"); S.fa(b.ids); S.f("g50"); S.h("fb") }
        case "diff":
            let r = work(&S, Y, RY)
            S.el("g50", "50", 512, 196, z: 54, c: OR)
            let b = bubble(&S, [BubItem("da", String(Y.n)), BubItem("dop", MINUS, op: true), BubItem("db", "50", c: OR),
                                BubItem("de", "=", op: true)] + di("D", Y.d, BLUE, true), on1, on1, ph >= 2 ? 1 : 0)
            arr(&S, b, ph, 1, 9)
            if ph == 0 { S.f("g50"); S.fa(r.ids); S.h("g50") }
            if ph == 1 { S.fa(r.ids); S.f("bub"); S.fa(b.rest); S.h("db") }
            if ph >= 2 { S.f("bub"); S.fa(b.res); S.h(b.res.last!) }
        case "add":
            let r = work(&S, Y, RY)
            let xs = xsOf(String(Y.s).count, 512, ADV)
            let b = bubble(&S, [BubItem("aa", String(Y.n)), BubItem("ap", "+", op: true)] + di("D", Y.d, BLUE)
                           + [BubItem("ae", "=", op: true)] + di("S", Y.s, OR, true), on1, on1, ph >= 2 ? 1 : 0)
            if ph == 0 { S.fa(r.ids); S.h("n\(r.ids.count - 1)") }
            if ph == 1 { S.fa(r.ids); S.f("bub"); S.fa(b.rest); S.h(ids("D", Y.d).last!) }
            if ph == 2 { S.f("bub"); S.fa(b.res); S.h(b.res.last!) }
            arr(&S, b, ph, 1, 3)
            if ph >= 3 {
                for (i, id) in b.res.enumerated() { S.mod(id, x: xs[i], y: RY, o: 1, s: Z / 52) }
                for id in b.rest { S.mod(id, o: 0) }
                S.mod("bub", o: 0, s: 0.9)
                for i in r.ids { S.mod(i, o: 0) }
                S.mod("pw", o: 0)
                S.fa(b.res); S.h(b.res.last!)
            }
        case "mult":
            dg(&S, "S", Y.s, 512, RY, c: OR)
            let b = bubble(&S, di("sb", Y.s, OR) + [BubItem("mx", TIMES, op: true), BubItem("m5", "50", c: BLUE), BubItem("me", "=", op: true)]
                           + di("M", Y.m, OR, true), on1, on1, ph >= 2 ? 1 : 0)
            S.el("hn", "\(Y.s) \(TIMES) 100 = \(Y.s * 100), and half of that is \(Y.m)", 512, 640, z: 26, c: MU, w: 800, o: ph >= 3 ? 1 : 0)
            arr(&S, b, ph, 1, 3)
            let sIds = ids("S", Y.s)
            if ph == 0 { S.fa(sIds); S.h(sIds.last!) }
            if ph == 1 { S.fa(sIds); S.f("bub"); S.fa(b.rest); S.h("m5") }
            if ph == 2 { S.f("bub"); S.fa(b.res); S.h(b.res.last!) }
            if ph >= 3 { S.f("bub"); S.fa(b.res); S.f("hn"); S.h(b.res.last!) }
        case "sq":
            dg(&S, "M", Y.m, 512, 196, z: 54, c: OR)
            let xs = dg(&S, "D", Y.d, 512, RY, c: BLUE)
            S.el("pw", SQ, xs[xs.count - 1] + 46, RY - 46, z: 46, c: MU, w: 800, o: on1)
            let b = bubble(&S, di("db", Y.d, BLUE) + [BubItem("sp", SQ, op: true, g: 0), BubItem("se", "=", op: true)]
                           + di("Q", Y.sq, OR, true), on1, on1, ph >= 2 ? 1 : 0)
            S.el("kp", "Keep both: \(Y.m) and \(Y.sq)", 512, 640, z: 26, c: MU, w: 800, o: ph >= 3 ? 1 : 0)
            arr(&S, b, ph, 1, 3)
            let dIds = ids("D", Y.d)
            if ph == 0 { S.fa(dIds); S.h(dIds.last!) }
            if ph == 1 { S.fa(dIds); S.f("bub"); S.fa(b.rest); S.h("sp") }
            if ph == 2 { S.f("bub"); S.fa(b.res); S.h(b.res.last!) }
            if ph >= 3 { S.fa(ids("M", Y.m)); S.fa(b.res); S.f("kp"); S.h(b.res.last!) }
        case "join":
            let xs = xsOf(String(Y.ans).count, 512, ADV)
            let early = ph < 2 ? 1.0 : 0.0
            let b = bubble(&S, di("M", Y.m, OR) + [BubItem("jp", "+", op: true)] + di("Q", Y.sq, OR) + [BubItem("je", "=", op: true)]
                           + di("A", Y.ans, INK, true), early, early, ph >= 1 ? 1 : 0)
            if ph == 0 { S.f("bub"); S.fa(b.rest); S.h("jp") }
            if ph == 1 { S.f("bub"); S.fa(b.res); S.h(b.res.last!) }
            if ph >= 2 {
                for (i, id) in b.res.enumerated() { S.mod(id, x: xs[i], y: RY, o: 1, s: Z / 52, c: GR) }
                for id in b.rest { S.mod(id, o: 0) }
                S.mod("bub", o: 0, s: 0.9)
                S.finale = SFinale(x: 512, y: RY, w: Double(xs.count) * ADV + 130, h: 160)
                S.win = true
            }
        default: break
        }
        return S
    }

    private static func hl(_ g: String) -> Color {
        switch g {
        case "ref", "add", "mult": return OR
        case "join": return GR
        default: return BLUE
        }
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n)
        switch d.g {
        case "ref": return ("Reference: 50", OR)
        case "diff": return ("\(Y.n) \(MINUS) 50 = \(Y.d)", BLUE)
        case "add": return ("\(Y.n) + \(Y.d) = \(Y.s)", OR)
        case "mult": return ("\(Y.s) \(TIMES) 50 = \(Y.m)", OR)
        case "sq": return ("\(Y.d)\(SQ) = \(Y.sq)", BLUE)
        case "join": return ("\(Y.n)\(SQ) = \(Y.ans)", GR)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n)
        var t = ""
        switch d.g {
        case "meet": t = "To square \(Y.n), we can use **50** as a helper. **Watch this.**"
        case "ref": t = "Use **50** as the reference point. \(Y.n) is 50 plus **\(Y.d)**."
        case "diff": t = "Subtract 50 to find the difference. **\(Y.n) \(MINUS) 50 = \(Y.d)**."
        case "add": t = "Add the difference to the number. **\(Y.n) + \(Y.d) = \(Y.s)**."
        case "mult": t = "Now multiply by 50. **\(Y.s) \(TIMES) 50 = \(Y.m)**."
        case "sq": t = "Square the difference. **\(Y.d)\(SQ) = \(Y.sq)**."
        case "join": t = "Add both parts. **\(Y.m) + \(Y.sq) = \(Y.ans)**. So \(Y.n)\(SQ) = **\(Y.ans)**."
        default: t = "Your turn."
        }
        return (t, hl(d.g))
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n)
        return [
            PTask(g: "diff", cap: "Your turn. Subtract 50 to find the difference: **\(Y.n) \(MINUS) 50**.", q: "\(Y.n) \(MINUS) 50", ans: String(Y.d),
                  ex: [String(Y.n), MINUS, "50"], hint: "Close! Take 50 away from \(Y.n)."),
            PTask(g: "add", cap: "Add the difference to the number. What is **\(Y.n) + \(Y.d)**?", q: "\(Y.n) + \(Y.d)", ans: String(Y.s),
                  ex: [String(Y.n), "+", String(Y.d)], hint: "Close! Add \(Y.d) to \(Y.n)."),
            PTask(g: "mult", cap: "Multiply by 50. What is **\(Y.s) \(TIMES) 50**?", q: "\(Y.s) \(TIMES) 50", ans: String(Y.m),
                  ex: [String(Y.s), TIMES, "50"], hint: "Close! Multiply by 100, then halve: \(Y.s) \(TIMES) 100 = \(Y.s * 100)."),
            PTask(g: "sq", cap: "Square the difference. What is **\(Y.d)\(SQ)**?", q: "\(Y.d)\(SQ)", ans: String(Y.sq),
                  ex: [String(Y.d), SQ], hint: "Close! Multiply \(Y.d) by itself."),
            PTask(g: "join", cap: "Add both parts. What is **\(Y.m) + \(Y.sq)**?", q: "\(Y.m) + \(Y.sq)", ans: String(Y.ans),
                  ex: [String(Y.m), "+", String(Y.sq)], hint: "Close! Add \(Y.m) and \(Y.sq).", ok: "\(Y.n)\(SQ) = \(Y.ans)"),
        ]
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
        } else {
            let ex = T[tt].ex
            let ids2 = ex.indices.map { "te\(tt)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids2[$0.offset], $0.element, op: $0.offset == 1) }, 512, 368, 46, sq: true)
            S.box("tb\(tt)", 512, 368, max(240, q.total + 90), 84, r: 26, shadow: true)
            for i in r.ids { S.mod(i, c: BLUE) }
            S.fa(r.ids); S.f("tb\(tt)"); S.fa(ids2)
        }
        return S
    }

    // MARK: spec

    private static let steps: [StepDef] = {
        func mid(_ n: Int, _ t: String) -> [(String, Int, String)] {
            [("diff", n, t), ("add", n, "Add it to the number"), ("mult", n, "Multiply by 50"),
             ("sq", n, "Square the difference"), ("join", n, "Read the answer")]
        }
        var list: [(String, Int, String)] = [
            ("meet", 56, "Meet the problem"), ("ref", 56, "Pick 50"), ("diff", 56, "Find the difference"),
            ("add", 56, "Add it to the number"), ("mult", 56, "Multiply by 50"), ("sq", 56, "Square the difference"),
            ("join", 56, "Read the answer"),
        ]
        list += mid(73, "A bigger difference: 73")
        list += mid(89, "A big one: 89")
        list.append(("practice", 0, "Your turn"))
        return list.map { g, n, name in
            let times: [Double] = g == "meet" ? [0, 800, 2300] : (g == "practice" ? [0, 500] : [0, 800, 2300, 3800])
            let end: Double = g == "meet" ? 3600 : (g == "practice" ? 700 : 5100)
            return StepDef(g: g, n: String(n), name: name, times: times, end: end)
        }
    }()

    static let spec = LessonSpec(
        id: "sq50",
        topTitle: "Squares from 50 to 100",
        cardTitle: "Squaring Numbers 50 to 100",
        cardBlurb: "For numbers between 50 and 100. Find the difference from 50, add it to the number, multiply by 50, then add the difference squared.",
        teaser: [[TeaserRun(text: "56"), TeaserRun(text: SQ, color: Theme.blue, scale: 1.3, pop: true)],
                 [TeaserRun(text: "=")], [TeaserRun(text: "3136")]],
        sutra: "Shortcut: n\(SQ) = 50 \(TIMES) (n + d) + d\(SQ), where d = n \(MINUS) 50",
        steps: steps,
        practice: [52, 64, 78, 85, 96].map { Problem(n: String($0)) },
        random: { Problem(n: String(rnd(51, 99))) },
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
