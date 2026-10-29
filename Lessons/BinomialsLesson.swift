import SwiftUI

/// Advanced: Urdhva Tiryagbhyam on (ax+b)(cx+d) = ac x² + (ad+bc) x + bd.
enum BinomialsLesson {
    private static let EY = 215.0, EZ = 58.0, SY = 390.0, BY = 530.0
    private static let SX: [Double] = [302, 512, 722]
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green

    // MARK: maths

    private static func term(_ n: Int, _ p: Int, _ first: Bool = false) -> String {
        let ab = abs(n)
        let body = p == 0 ? String(ab) : (ab == 1 ? "" : String(ab)) + (p == 1 ? "x" : "x\u{00B2}")
        return n < 0 ? "\u{2212}" + body : (first ? "" : "+") + body
    }
    private static func sp(_ n: Int, _ p: Int) -> String {
        (n < 0 ? "\u{2212} " : "+ ") + term(abs(n), p, true)
    }

    struct BinY {
        var n: String, m: String
        var a: Int, b: Int, c: Int, d: Int
        var A: Int, B: Int, C: Int
        var ta: String, tc: String, sb: String, sd: String
        var ab: Int, ad: Int
        var tA: String, tB: String, tC: String, tBa: String, tCa: String
        var total: Int
        var str: String, full: String, full2: String
    }

    static func yav(_ n: String, _ m: String) -> BinY {
        let nn = n.split(separator: ",").map { num(String($0)) }
        let mm = m.split(separator: ",").map { num(String($0)) }
        let a = nn[0], b = nn[1], c = mm[0], d = mm[1]
        let A = a * c, B = a * d + b * c, C = b * d
        func cx(_ k: Int) -> String { k == 1 ? "x" : "\(k)x" }
        return BinY(n: n, m: m, a: a, b: b, c: c, d: d, A: A, B: B, C: C,
                 ta: cx(a), tc: cx(c), sb: b < 0 ? "\u{2212}" : "+", sd: d < 0 ? "\u{2212}" : "+",
                 ab: abs(b), ad: abs(d),
                 tA: term(A, 2, true), tB: term(B, 1, true), tC: term(C, 0, true),
                 tBa: term(abs(B), 1, true), tCa: term(abs(C), 0, true),
                 total: (a + b) * (c + d),
                 str: "(" + cx(a) + (b < 0 ? "\u{2212}" : "+") + "\(abs(b))" + ")(" + cx(c) + (d < 0 ? "\u{2212}" : "+") + "\(abs(d))" + ")",
                 full: term(A, 2, true) + term(B, 1) + term(C, 0),
                 full2: term(A, 2, true) + " " + sp(B, 1) + " " + sp(C, 0))
    }

    // MARK: scene helpers

    private struct Row { var xs: [Double]; var total: Double; var ids: [String] }

    private static func eqRow(_ S: inout Scene, _ Y: BinY, _ y: Double, _ z0: Double) -> Row {
        let items: [SeqItem] = [
            SeqItem("o1", "(", op: true, g: 0), SeqItem("TA", Y.ta), SeqItem("s1", Y.sb, op: true), SeqItem("TB", String(Y.ab), g: 0),
            SeqItem("c1", ")", op: true, g: 4),
            SeqItem("o2", "(", op: true, g: 0), SeqItem("TC", Y.tc), SeqItem("s2", Y.sd, op: true), SeqItem("TD", String(Y.ad), g: 0),
            SeqItem("c2", ")", op: true),
        ]
        let q = S.seq(items, 512, y, z0)
        return Row(xs: q.xs, total: q.total, ids: items.map { $0.id })
    }
    private static func X(_ r: Row, _ id: String) -> Double { r.xs[r.ids.firstIndex(of: id) ?? 0] }

    private static func slots(_ S: inout Scene, _ f: [Bool]) {
        for (k, x) in SX.enumerated() {
            if f[k] { S.box("sl\(k)", x, SY, 180, 84, r: 24, shadow: true) }
            else { S.box("sl\(k)", x, SY, 180, 84, r: 24, dashed: true, c: Theme.dash, fill: .clear, q: "?") }
        }
    }
    private static func put(_ S: inout Scene, _ Y: BinY, _ k: Int) {
        let v = [Y.tA, Y.tB, Y.tC][k]
        S.el("R\(k + 1)", v, SX[k], SY, z: 52, c: OR)
    }

    private struct Bub { var xs: [Double]; var ids: [String]; var res: [String]; var rest: [String] }
    private static func bub(_ S: inout Scene, _ items: [(id: String, t: String, op: Bool, res: Bool, c: Color?)],
                            _ bo: Double, _ to: Double, _ ro: Double) -> Bub {
        let its: [SeqItem] = items.map { SeqItem($0.id, $0.t, op: $0.op, c: $0.c, o: $0.res ? ro : to) }
        let q = S.seq(its, 512, BY, 52)
        S.box("bub", 512, BY, max(300, q.total + 90), 104, o: bo, r: 28, shadow: true)
        return Bub(xs: q.xs, ids: items.map { $0.id }, res: items.filter { $0.res }.map { $0.id },
                   rest: items.filter { !$0.res }.map { $0.id })
    }
    private typealias BI = (id: String, t: String, op: Bool, res: Bool, c: Color?)

    // MARK: scenes

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = yav(d.n, d.m)
        var S = Scene(Y.n + "x" + Y.m + ".")
        switch d.g {
        case "meet":
            let r = eqRow(&S, Y, 300, EZ)
            if ph == 0 { S.hide(r.ids) }
            if ph >= 2 { S.mods(r.ids, c: BLUE); S.fa(r.ids); S.h("TD") }
        case "look":
            let r = eqRow(&S, Y, EY, EZ)
            if ph >= 1 { S.mod("TA", c: BLUE); S.mod("TC", c: BLUE) }
            if ph >= 2 { S.mod("TB", c: OR); S.mod("TD", c: OR) }
            let msg = "x-terms \(Y.a), \(Y.c) \u{00B7} numbers \(N2(Y.b)), \(N2(Y.d))"
            S.box("tag", 512, 128, max(380, Double(msg.count) * 14 + 60), 60, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9,
                  r: 22, shadow: true, q: msg, qz: 22, qc: OR)
            if ph == 1 { S.f("TA", "TC"); S.h("TC") }
            if ph == 2 { S.f("TA", "TB", "TC", "TD"); S.h("TD") }
            if ph >= 3 { S.f("tag"); S.fa(r.ids); S.h("TD") }
        case "left":
            let r = eqRow(&S, Y, EY, EZ)
            slots(&S, [ph >= 3, false, false])
            S.mod("TA", c: BLUE); S.mod("TC", c: BLUE)
            let live = ph >= 1 && ph < 3
            let items: [BI] = [("ca", String(Y.a), false, false, BLUE), ("cx", "\u{00D7}", true, false, nil),
                               ("cc", String(Y.c), false, false, BLUE), ("ce", "=", true, false, nil),
                               ("R1", Y.tA, false, true, OR)]
            let b = bub(&S, items, live ? 1 : 0, live ? 1 : 0, ph >= 2 ? 1 : 0)
            if live {
                S.arrow(0, (X(r, "TA"), EY + 40), (b.xs[0] - 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: 0.25)
                S.arrow(1, (X(r, "TC"), EY + 40), (b.xs[2] + 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: -0.25)
            }
            if ph >= 3 { S.mod("R1", x: SX[0], y: SY) }
            if ph == 0 { S.f("TA", "TC"); S.h("TC") }
            if ph == 1 { S.f("TA", "TC", "bub"); S.fa(b.rest); S.h("cx") }
            if ph == 2 { S.f("bub", "R1"); S.h("R1") }
            if ph >= 3 { S.f("sl0", "R1"); S.h("R1") }
        case "cross":
            let r = eqRow(&S, Y, EY, EZ)
            slots(&S, [true, ph >= 4, false]); put(&S, Y, 0)
            S.mod("TA", c: BLUE); S.mod("TD", c: BLUE)
            if ph >= 1 { S.mod("TB", c: OR); S.mod("TC", c: OR) }
            let as_ = ph >= 3 ? 3 : (ph >= 2 ? 2 : 1)
            S.arrow(0, (X(r, "TA"), EY - 44), (X(r, "TD"), EY - 44), st: as_, bend: -0.3)
            if ph >= 1 { S.arrow(1, (X(r, "TB"), EY + 44), (X(r, "TC"), EY + 44), c: OR, st: as_, bend: 0.3) }
            let live = ph >= 2 && ph < 4
            let items: [BI] = [("x1", fmt(Y.a) + "\u{00D7}" + fmt(Y.d), false, false, BLUE), ("xp", "+", true, false, nil),
                               ("x2", fmt(Y.b) + "\u{00D7}" + fmt(Y.c), false, false, OR), ("xe", "=", true, false, nil),
                               ("R2", Y.tB, false, true, OR)]
            let b = bub(&S, items, live ? 1 : 0, live ? 1 : 0, ph >= 3 ? 1 : 0)
            if ph >= 4 { S.mod("R2", x: SX[1], y: SY) }
            if ph == 0 { S.f("TA", "TD", "sl0", "R1"); S.h("TD") }
            if ph == 1 { S.f("TA", "TB", "TC", "TD", "sl0", "R1"); S.h("TC") }
            if ph == 2 { S.f("bub"); S.fa(b.rest); S.f("sl0", "R1"); S.h("xp") }
            if ph == 3 { S.f("bub", "R2", "sl0", "R1"); S.h("R2") }
            if ph >= 4 { S.f("sl0", "R1", "sl1", "R2"); S.h("R2") }
        case "right":
            let r = eqRow(&S, Y, EY, EZ)
            slots(&S, [true, true, ph >= 3]); put(&S, Y, 0); put(&S, Y, 1)
            S.mod("TB", c: BLUE); S.mod("TD", c: BLUE)
            let live = ph >= 1 && ph < 3
            let items: [BI] = [("rb", fmt(Y.b), false, false, BLUE), ("rx", "\u{00D7}", true, false, nil),
                               ("rd", fmt(Y.d), false, false, BLUE), ("re", "=", true, false, nil),
                               ("R3", Y.tC, false, true, OR)]
            let b = bub(&S, items, live ? 1 : 0, live ? 1 : 0, ph >= 2 ? 1 : 0)
            if live {
                S.arrow(0, (X(r, "TB"), EY + 40), (b.xs[0] - 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: 0.25)
                S.arrow(1, (X(r, "TD"), EY + 40), (b.xs[2] + 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: -0.25)
            }
            if ph >= 3 { S.mod("R3", x: SX[2], y: SY) }
            if ph == 0 { S.f("TB", "TD", "sl0", "sl1", "R1", "R2"); S.h("TD") }
            if ph == 1 { S.f("TB", "TD", "bub"); S.fa(b.rest); S.f("sl0", "sl1", "R1", "R2"); S.h("rx") }
            if ph == 2 { S.f("bub", "R3", "sl0", "sl1", "R1", "R2"); S.h("R3") }
            if ph >= 3 { S.f("sl0", "sl1", "sl2", "R1", "R2", "R3"); S.h("R3") }
        case "join":
            let r = eqRow(&S, Y, EY, EZ)
            var tmp = Scene("t.")
            let q = tmp.seq([SeqItem("R1", Y.tA), SeqItem("P2", sgn(Y.B), op: true), SeqItem("R2", Y.tBa),
                             SeqItem("P3", sgn(Y.C), op: true), SeqItem("R3", Y.tCa)], 512, SY, 64)
            let fx = q.xs
            if ph == 0 {
                slots(&S, [true, true, true]); put(&S, Y, 0); put(&S, Y, 1); put(&S, Y, 2)
                S.el("P2", sgn(Y.B), fx[1], SY, z: 52, c: GR, w: 700, o: 0, s: 64.0 / 52.0)
                S.el("P3", sgn(Y.C), fx[3], SY, z: 52, c: GR, w: 700, o: 0, s: 64.0 / 52.0)
                S.f("sl0", "sl1", "sl2", "R1", "R2", "R3"); S.h("R3")
            } else {
                S.el("R1", Y.tA, fx[0], SY, z: 52, c: GR, s: 64.0 / 52.0)
                S.el("R2", Y.tBa, fx[2], SY, z: 52, c: GR, s: 64.0 / 52.0)
                S.el("R3", Y.tCa, fx[4], SY, z: 52, c: GR, s: 64.0 / 52.0)
                S.el("P2", sgn(Y.B), fx[1], SY, z: 52, c: GR, w: 700, s: 64.0 / 52.0)
                S.el("P3", sgn(Y.C), fx[3], SY, z: 52, c: GR, w: 700, s: 64.0 / 52.0)
                S.mods(r.ids, c: GR)
                S.finale = SFinale(x: 512, y: SY, w: q.total + 130, h: 150)
                S.win = true
            }
        default:
            break
        }
        return S
    }

    // MARK: captions

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n, d.m)
        switch d.g {
        case "left": return ("Left: " + Y.tA, OR)
        case "cross": return ("Middle: " + Y.tB, OR)
        case "right": return ("Right: " + Y.tC, OR)
        case "join": return ("= " + Y.full, GR)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n, d.m)
        let col: Color = (d.g == "join") ? GR : ((["left", "cross", "right"].contains(d.g)) ? OR : BLUE)
        switch d.g {
        case "meet": return ("Look at **" + Y.str + "**. Expanding it looks long, but there is a neat trick. **Watch this.**", col)
        case "look": return ("Name the parts. The x-terms are **" + Y.ta + "** and **" + Y.tc + "**. The numbers are **" + N2(Y.b) + "** and **" + N2(Y.d) + "**.", col)
        case "left": return ("Multiply the x-terms, straight down the left. **\(Y.a) \u{00D7} \(Y.c) = \(Y.A)**. That gives the **" + Y.tA + "** part.", col)
        case "cross": return ("Now go crosswise and add. **" + fmt(Y.a) + " \u{00D7} " + fmt(Y.d) + " + " + fmt(Y.b) + " \u{00D7} " + fmt(Y.c) + " = " + N2(Y.B) + "**. That gives the **" + Y.tB + "** part.", col)
        case "right": return ("Multiply the numbers, straight down the right. **" + fmt(Y.b) + " \u{00D7} " + fmt(Y.d) + " = " + N2(Y.C) + "**. That is the last part.", col)
        case "join": return ("Write the three parts in order. **" + Y.str + " = " + Y.full2 + "**.", col)
        default: return ("Your turn.", col)
        }
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n, p.m)
        let a = Y.a, b = Y.b, c = Y.c, d = Y.d
        return [
            PTask(g: "left", cap: "Multiply the x-terms: **\(a) \u{00D7} \(c)**. That is the number in front of x\u{00B2}.",
                  q: "\(a) \u{00D7} \(c)", ans: String(Y.A), ex: [String(a), "\u{00D7}", String(c)],
                  hint: "Close! Multiply \(a) by \(c)."),
            PTask(g: "cross", cap: "Go crosswise and add: **" + fmt(a) + " \u{00D7} " + fmt(d) + " + " + fmt(b) + " \u{00D7} " + fmt(c) + "**. That is the number in front of x.",
                  q: fmt(a) + " \u{00D7} " + fmt(d) + " + " + fmt(b) + " \u{00D7} " + fmt(c), ans: N2(Y.B),
                  ex: [fmt(a), "\u{00D7}", fmt(d), "+", fmt(b), "\u{00D7}", fmt(c)],
                  hint: "Close! Work out each product, then add them. Mind the signs."),
            PTask(g: "right", cap: "Multiply the numbers: **" + fmt(b) + " \u{00D7} " + fmt(d) + "**. That is the last part.",
                  q: fmt(b) + " \u{00D7} " + fmt(d), ans: N2(Y.C), ex: [fmt(b), "\u{00D7}", fmt(d)],
                  hint: "Close! Multiply " + fmt(b) + " by " + fmt(d) + ". Two minus signs make a plus."),
            PTask(g: "join", cap: "Check with x = 1. The parts add up: **\(Y.A) + " + fmt(Y.B) + " + " + fmt(Y.C) + "**. What is the total?",
                  q: "\(Y.A) + " + fmt(Y.B) + " + " + fmt(Y.C), ans: N2(Y.total),
                  ex: [String(Y.A), "+", fmt(Y.B), "+", fmt(Y.C)], hint: "Close! Add the three numbers. Mind the signs."),
        ]
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = yav(p.n, p.m)
        var S = Scene(Y.n + "x" + Y.m + ".")
        let T = tasks(p)
        let r = eqRow(&S, Y, 190, EZ)
        let fin = done || (ok && t == T.count - 1)
        let nf = fin ? 3 : min(t + (ok ? 1 : 0), 3)
        let CY = 292.0
        let vals = [Y.tA, Y.tB, Y.tC]
        for k in 0..<3 {
            if k < nf {
                S.box("cp\(k)", SX[k], CY, 180, 72, r: 22, shadow: true)
                S.el("R\(k + 1)", vals[k], SX[k], CY, z: 46, c: fin ? GR : OR)
            } else {
                S.box("cp\(k)", SX[k], CY, 180, 72, r: 22, dashed: true, c: Theme.dash, fill: .clear, q: "?")
            }
        }
        if fin {
            S.mods(r.ids, c: GR)
            S.finale = SFinale(x: 512, y: 240, w: 780, h: 220)
        } else {
            let ex = T[t].ex
            let ids2 = ex.indices.map { "te\(t)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids2[$0.offset], $0.element, op: isOp($0.element)) }, 512, 385, 46)
            S.box("tb\(t)", 512, 385, max(240, q.total + 90), 84, r: 26, shadow: true)
            let hl: [String] = t == 0 ? ["TA", "TC"] : (t == 1 ? ["TA", "TB", "TC", "TD"] : (t == 2 ? ["TB", "TD"] : []))
            S.mods(hl, c: BLUE)
            S.fa(r.ids); S.f("cp0", "cp1", "cp2", "R1", "R2", "R3", "tb\(t)"); S.fa(ids2)
        }
        return S
    }

    // MARK: spec

    private static let TM: [String: ([Double], Double)] = [
        "meet": ([0, 800, 2300], 3600), "look": ([0, 800, 2300, 3800], 5100), "left": ([0, 800, 2300, 3800], 5100),
        "cross": ([0, 800, 2300, 3800, 5300], 6600), "right": ([0, 800, 2300, 3800], 5100),
        "join": ([0, 800], 2100), "practice": ([0, 500], 700),
    ]

    private static func four(_ n: String, _ m: String, _ t: String) -> [(String, String, String, String)] {
        [("left", n, m, t), ("cross", n, m, "Crosswise in the middle"), ("right", n, m, "Down the right"), ("join", n, m, "Read the answer")]
    }

    private static let steps: [StepDef] = {
        var list: [(String, String, String, String)] = [("meet", "2,3", "4,5", "Meet the problem"), ("look", "2,3", "4,5", "Name the parts")]
        list += four("2,3", "4,5", "Down the left")
        list += four("3,\u{2212}2", "2,5", "A minus sign: (3x\u{2212}2)(2x+5)")
        list += four("5,\u{2212}3", "2,\u{2212}4", "Two minus signs: (5x\u{2212}3)(2x\u{2212}4)")
        list.append(("practice", "", "", "Your turn"))
        return list.map { StepDef(g: $0.0, n: $0.1, m: $0.2, name: $0.3, times: TM[$0.0]!.0, end: TM[$0.0]!.1) }
    }()

    private static func randomP() -> Problem {
        var a = 0, b = 0, c = 0, d = 0
        repeat {
            a = rnd(1, 5); c = rnd(1, 5)
            b = rnd(1, 9) * (Bool.random() ? -1 : 1)
            d = rnd(1, 9) * (Bool.random() ? -1 : 1)
        } while a * d + b * c == 0
        return Problem(n: "\(a),\(b)", m: "\(c),\(d)")
    }

    static let spec = LessonSpec(
        id: "bin",
        topTitle: "Multiplying two binomials",
        cardTitle: "Multiplying Two Binomials",
        cardBlurb: "Expand (2x+3)(4x+5) in one line. Go down the left, crosswise in the middle, then down the right.",
        rows: [InfoRow(title: "Down the left", sub: "2x \u{00D7} 4x", value: "8x\u{00B2}"),
               InfoRow(title: "Crosswise in the middle", sub: "2x \u{00D7} 5 + 3 \u{00D7} 4x", value: "22x"),
               InfoRow(title: "Down the right", sub: "3 \u{00D7} 5", value: "15")],
        sutra: "Urdhva Tiryagbhyam: vertically and crosswise",
        keys: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "\u{2212}", "\u{232B}"],
        steps: steps,
        practice: [Problem(n: "1,6", m: "1,2"), Problem(n: "4,\u{2212}1", m: "3,2"), Problem(n: "2,5", m: "3,\u{2212}4"),
                   Problem(n: "5,\u{2212}3", m: "2,\u{2212}4"), Problem(n: "3,7", m: "2,\u{2212}5")],
        random: randomP,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { "**" + yav($0.n, $0.m).full2 + "**. Vertically and crosswise, every time." }
    )
}
