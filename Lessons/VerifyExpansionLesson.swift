import SwiftUI

/// Advanced: Gunita Samuccayah on algebra. Put x = 1 on both sides and compare.
enum VerifyExpansionLesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let RY1 = 235.0, RY2 = 325.0, HY = 440.0
    private static let HX: [String: Double] = ["A": 300, "B": 420, "M": 540, "R": 700]
    private static let ORDER = ["A", "B", "M", "R"]
    private static let SRC: [String: [String]] = [
        "A": ["p1", "p2", "p3"], "B": ["q1", "q2", "q3"], "R": ["r1", "r2", "r3", "r4", "r5"],
    ]

    private static func sg(_ v: Int) -> String { v < 0 ? "\u{2212}" : "+" }
    private static func fm(_ v: Int) -> String { v < 0 ? "\u{2212}\(-v)" : String(v) }
    private static func cf(_ v: Int) -> String { abs(v) == 1 ? "" : String(abs(v)) }
    private static func br(_ p: Int, _ a: Int) -> String { (p == 1 ? "x" : "\(p)x") + " " + sg(a) + " \(abs(a))" }
    private static func terms(_ a: [Int]) -> String {
        a.enumerated().map { $0.offset > 0 ? sg($0.element) + " \(abs($0.element))" : String(abs($0.element)) }.joined(separator: " ")
    }
    private static func tk(_ a: [Int]) -> [String] {
        var out: [String] = []
        for (i, v) in a.enumerated() {
            if i > 0 { out.append(sg(v)) }
            out.append(String(abs(v)))
        }
        return out
    }
    private static func isOpV(_ t: String) -> Bool { ["+", "\u{00D7}", "=", "\u{2212}", "\u{2260}"].contains(t) }

    struct VY {
        var n: String, m: String
        var p: Int, a: Int, q: Int, b: Int, A: Int, B: Int, C: Int
        var sA: Int, sB: Int, prod: Int, sR: Int
        var ok: Bool, correct: Bool
        var truth: String
        var v: [String: Int]
    }

    static func yav(_ n: String, _ m: String) -> VY {
        let x = n.split(separator: ".").map { Int($0) ?? 0 }
        let y = m.split(separator: ".").map { Int($0) ?? 0 }
        let p = x[0], a = x[1], q = x[2], b = x[3], A = y[0], B = y[1], C = y[2]
        let sA = p + a, sB = q + b, prod = sA * sB, sR = A + B + C
        let tA = p * q, tB = p * b + a * q, tC = a * b
        let truth = (tA == 1 ? "" : String(tA)) + "x\u{00B2} " + sg(tB) + " " + (abs(tB) == 1 ? "" : String(abs(tB))) + "x " + sg(tC) + " \(abs(tC))"
        return VY(n: n, m: m, p: p, a: a, q: q, b: b, A: A, B: B, C: C, sA: sA, sB: sB, prod: prod, sR: sR,
                  ok: prod == sR, correct: A == tA && B == tB && C == tC, truth: truth,
                  v: ["A": sA, "B": sB, "M": prod, "R": sR])
    }

    private static func lhs(_ Y: VY) -> String { "(" + br(Y.p, Y.a) + ")(" + br(Y.q, Y.b) + ")" }
    private static func rhs(_ Y: VY) -> String {
        cf(Y.A) + "x\u{00B2} " + sg(Y.B) + " " + cf(Y.B) + "x " + sg(Y.C) + " \(abs(Y.C))"
    }

    // MARK: scene

    private static func rows(_ S: inout Scene, _ Y: VY, _ y1: Double, _ y2: Double) -> [String] {
        func f(_ p: Int, _ a: Int, _ d: String) -> [SeqItem] {
            [SeqItem(d + "0", "(", g: 3), SeqItem(d + "1", p == 1 ? "x" : "\(p)x"), SeqItem(d + "2", sg(a), op: true, c: MU),
             SeqItem(d + "3", String(abs(a))), SeqItem(d + "4", ")", g: 3)]
        }
        S.seq(f(Y.p, Y.a, "p") + f(Y.q, Y.b, "q"), 512, y1, 62)
        S.seq([SeqItem("r0", "=", op: true, c: MU), SeqItem("r1", cf(Y.A) + "x\u{00B2}"), SeqItem("r2", sg(Y.B), op: true, c: MU),
               SeqItem("r3", cf(Y.B) + "x"), SeqItem("r4", sg(Y.C), op: true, c: MU), SeqItem("r5", String(abs(Y.C)))], 512, y2, 62)
        return ["p0", "p1", "p2", "p3", "p4", "q0", "q1", "q2", "q3", "q4", "r0", "r1", "r2", "r3", "r4", "r5"]
    }

    private static func hold(_ S: inout Scene, _ Y: VY, _ k: String, _ hy: Double) {
        S.box("b" + k, HX[k]!, hy, 80, 66, r: 18, shadow: true)
        S.el("v" + k, fm(Y.v[k]!), HX[k]!, hy, z: 40, c: OR)
    }

    private static func stage(_ S: inout Scene, _ Y: VY, _ ph: Int, _ k: String) {
        _ = rows(&S, Y, RY1, RY2)
        for q in ORDER.prefix(ORDER.firstIndex(of: k)!) { hold(&S, Y, q, HY) }
        let nums: [Int] = k == "A" ? [Y.p, Y.a] : (k == "B" ? [Y.q, Y.b] : [Y.A, Y.B, Y.C])
        let T: [String] = k == "M" ? [fm(Y.sA), "\u{00D7}", fm(Y.sB), "="] : tk(nums) + ["="]
        var items: [BubItem] = T.enumerated().map { BubItem("c\($0.offset)", $0.element, op: isOpV($0.element), c: INK) }
        items.append(BubItem("v" + k, fm(Y.v[k]!), res: true, c: OR))
        let b = S.bub(items, ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
        let src: [String] = k == "M" ? ["bA", "vA", "bB", "vB"] : SRC[k]!
        if k != "M" && ph < 3 { S.mods(src, c: BLUE) }
        S.box("b" + k, HX[k]!, HY, 80, 66, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 18, shadow: true)
        if ph == 0 { S.fa(src); S.h(src[0]) }
        if ph == 1 { S.fa(src); S.f("bub"); S.fa(b.rest); S.h("c1") }
        if ph == 2 { S.f("bub"); S.fa(b.res); S.h("v" + k) }
        if ph >= 3 {
            S.mod("v" + k, x: HX[k]!, y: HY, o: 1, s: 40.0 / 52.0)
            for id in b.rest { S.mod(id, o: 0) }
            S.mod("bub", o: 0, s: 0.9)
            S.f("b" + k, "v" + k); S.h("v" + k)
        }
    }

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = yav(d.n, d.m)
        var S = Scene(Y.n + "x" + Y.m + ".")
        switch d.g {
        case "meet":
            let ids = rows(&S, Y, RY1, RY2)
            if ph == 0 { S.hide(ids) }
            if ph >= 2 {
                let tail = Array(ids[10...])
                S.fa(tail); S.h("r1")
                for i in tail { S.mod(i, c: (i == "r0" || i == "r2" || i == "r4") ? MU : BLUE) }
            }
        case "sumA": stage(&S, Y, ph, "A")
        case "sumB": stage(&S, Y, ph, "B")
        case "mul": stage(&S, Y, ph, "M")
        case "sumR": stage(&S, Y, ph, "R")
        case "cmp":
            let ids = rows(&S, Y, RY1, RY2)
            let col = Y.ok ? GR : OR
            for q in ORDER { hold(&S, Y, q, HY) }
            let b = S.bub([BubItem("k0", fm(Y.prod), c: OR), BubItem("k1", Y.ok ? "=" : "\u{2260}", op: true, c: col),
                           BubItem("k2", fm(Y.sR), c: OR)], ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, 1)
            let msg = Y.ok ? "Match: looks right" : "Mismatch: definitely wrong"
            S.box("tag", 512, 140, max(320, Double(msg.count) * 15 + 60), 64, o: ph >= 2 ? 1 : 0, s: ph >= 2 ? 1 : 0.9,
                  r: 22, shadow: true, q: msg, qz: 26, qc: col)
            S.el("hold", Y.ok ? "A match means probably right." : "A mismatch always means a mistake.", 512, 640,
                 z: 26, c: MU, w: 800, o: ph >= 3 ? 1 : 0)
            if ph >= 2 { S.mod("bM", c: col); S.mod("bR", c: col) }
            if ph >= 3 { S.mods(ids, c: col); if Y.ok { S.win = true } }
            if ph == 0 { S.f("bM", "vM", "bR", "vR"); S.h("vR") }
            if ph == 1 { S.f("bub"); S.fa(b.ids); S.h("k1") }
            if ph >= 2 { S.f("tag", "bM", "vM", "bR", "vR", "bub"); S.fa(b.ids); S.f("hold"); S.h("k2") }
            if ph >= 3 && Y.ok { S.fa(ids) }
        default: break
        }
        return S
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n, d.m)
        switch d.g {
        case "sumA": return ("Bracket 1: " + fm(Y.sA), OR)
        case "sumB": return ("Bracket 2: " + fm(Y.sB), OR)
        case "mul": return ("Expected: " + fm(Y.prod), OR)
        case "sumR": return ("Answer: " + fm(Y.sR), OR)
        case "cmp": return ("Check: " + (Y.ok ? "Match" : "Mismatch"), BLUE)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n, d.m)
        let col: Color = ["sumA", "sumB", "mul", "sumR"].contains(d.g) ? OR : BLUE
        var t = ""
        switch d.g {
        case "meet": t = "Is **" + rhs(Y) + "** the right expansion of " + lhs(Y) + "? Check it without redoing the multiplication. **Watch this.**"
        case "sumA": t = "Put **x = 1** in the first bracket. **" + terms([Y.p, Y.a]) + " = " + fm(Y.sA) + "**."
        case "sumB": t = "Do the same for the second bracket. **" + terms([Y.q, Y.b]) + " = " + fm(Y.sB) + "**."
        case "mul": t = "Multiply the two results. **" + fm(Y.sA) + " \u{00D7} " + fm(Y.sB) + " = " + fm(Y.prod) + "**. The answer should also give this."
        case "sumR": t = "Now put **x = 1** in the claimed answer. **" + terms([Y.A, Y.B, Y.C]) + " = " + fm(Y.sR) + "**."
        case "cmp":
            t = Y.ok ? "**" + fm(Y.prod) + "** and **" + fm(Y.sR) + "** match. The expansion looks **right**."
                     : "**" + fm(Y.prod) + "** and **" + fm(Y.sR) + "** are different, so it is **definitely wrong**. The real answer is **" + Y.truth + "**."
        default: t = "Your turn."
        }
        return (t, col)
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n, p.m)
        return [
            PTask(g: "sumA", cap: "Put **x = 1** in **(" + br(Y.p, Y.a) + ")**. Add the numbers.", q: "bracket 1",
                  ans: String(Y.sA), ex: tk([Y.p, Y.a]), hint: "Close! x counts as 1. Add the numbers in the bracket.",
                  ok: terms([Y.p, Y.a]) + " = \(Y.sA)"),
            PTask(g: "sumB", cap: "Now **(" + br(Y.q, Y.b) + ")**. Put **x = 1** and add.", q: "bracket 2",
                  ans: String(Y.sB), ex: tk([Y.q, Y.b]), hint: "Close! x counts as 1. Add the numbers in the bracket.",
                  ok: terms([Y.q, Y.b]) + " = \(Y.sB)"),
            PTask(g: "mul", cap: "Multiply the two results: **\(Y.sA) \u{00D7} \(Y.sB)**.", q: "product",
                  ans: String(Y.prod), ex: [String(Y.sA), "\u{00D7}", String(Y.sB)], hint: "Close! Just multiply the two numbers.",
                  ok: "\(Y.sA) \u{00D7} \(Y.sB) = \(Y.prod)"),
            PTask(g: "sumR", cap: "Put **x = 1** in the claimed answer **" + rhs(Y) + "**. Add the numbers.", q: "answer",
                  ans: String(Y.sR), ex: tk([Y.A, Y.B, Y.C]), hint: "Close! Add all three numbers. Watch the signs.",
                  ok: terms([Y.A, Y.B, Y.C]) + " = \(Y.sR)"),
            PTask(g: "cmp", cap: "Compare **\(Y.prod)** and **\(Y.sR)**. Type **1** if they match, **0** if they do not.", q: "compare",
                  ans: Y.ok ? "1" : "0", ex: [String(Y.prod), "vs", String(Y.sR)],
                  hint: "Close! 1 means the two numbers are the same, 0 means they differ.",
                  ok: Y.ok ? "They match, so it looks right" : "They differ, so it is wrong"),
        ]
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = yav(p.n, p.m)
        var S = Scene(Y.n + "x" + Y.m + ".")
        let T = tasks(p)
        let fin = done || (ok && t == T.count - 1)
        let ids = rows(&S, Y, 150, 232)
        for q in ORDER.prefix(fin ? 4 : min(t, 4)) { hold(&S, Y, q, 318) }
        if fin {
            S.mods(ids, c: Y.ok ? GR : OR)
            if Y.ok { S.finale = SFinale(x: 512, y: 191, w: 700, h: 200) }
        } else {
            let tk_ = T[min(t, T.count - 1)]
            let ex = tk_.ex
            let ids2 = ex.indices.map { "te\(t)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids2[$0.offset], $0.element, op: $0.offset == 1) }, 512, 400, 46)
            S.box("tb\(t)", 512, 400, max(240, q.total + 90), 84, r: 26, shadow: true)
            let src: [String] = tk_.g == "sumA" ? SRC["A"]! : (tk_.g == "sumB" ? SRC["B"]! : (tk_.g == "sumR" ? SRC["R"]! : []))
            S.mods(src, c: BLUE)
            S.fa(ids); S.f("tb\(t)"); S.fa(ids2)
        }
        return S
    }

    // MARK: spec

    private static let TM: [String: ([Double], Double)] = [
        "meet": ([0, 800, 2300], 3600), "sumA": ([0, 800, 2300, 3800], 5100), "sumB": ([0, 800, 2300, 3800], 5100),
        "mul": ([0, 800, 2300, 3800], 5100), "sumR": ([0, 800, 2300, 3800], 5100), "cmp": ([0, 800, 2300, 3800], 5100),
        "practice": ([0, 500], 700),
    ]

    private static let steps: [StepDef] = {
        let E1n = "2.3.1.4", E1m = "2.11.12", E2m = "2.10.12", E3n = "1.-2.1.5", E3m = "1.3.-10"
        let list: [(String, String, String, String)] = [
            ("meet", E1n, E1m, "Meet the problem"), ("sumA", E1n, E1m, "Put x = 1: bracket 1"), ("sumB", E1n, E1m, "Put x = 1: bracket 2"),
            ("mul", E1n, E1m, "Multiply the results"), ("sumR", E1n, E1m, "Put x = 1 in the answer"), ("cmp", E1n, E1m, "Compare: a match"),
            ("sumR", E1n, E2m, "A wrong answer"), ("cmp", E1n, E2m, "Compare: a mismatch"),
            ("sumA", E3n, E3m, "With a minus: bracket 1"), ("sumB", E3n, E3m, "Bracket 2"), ("mul", E3n, E3m, "Multiply the results"),
            ("sumR", E3n, E3m, "Put x = 1 in the answer"), ("cmp", E3n, E3m, "Compare: a match"), ("practice", "", "", "Your turn"),
        ]
        return list.map { StepDef(g: $0.0, n: $0.1, m: $0.2, name: $0.3, times: TM[$0.0]!.0, end: TM[$0.0]!.1) }
    }()

    private static func randomP() -> Problem {
        while true {
            let p = rnd(1, 4), q = rnd(1, 4), a = rnd(-3, 6), b = rnd(-3, 6)
            if a == 0 || b == 0 || p + a < 1 || q + b < 1 { continue }
            let A = p * q, B = p * b + a * q, C = a * b
            if B == 0 || C == 0 { continue }
            var cB = B, cC = C
            if Bool.random() {
                let d = rnd(1, 4) * (Bool.random() ? -1 : 1)
                if Bool.random() { cB += d } else { cC += d }
            }
            if cB == 0 || cC == 0 || A + cB + cC < 1 { continue }
            return Problem(n: [p, a, q, b].map(String.init).joined(separator: "."), m: [A, cB, cC].map(String.init).joined(separator: "."))
        }
    }

    static let spec = LessonSpec(
        id: "vex",
        topTitle: "Verifying an expansion",
        cardTitle: "Verify an Expansion",
        cardBlurb: "Not sure an expansion is right? Put x = 1 on both sides and compare. A mismatch always means a mistake.",
        rows: [InfoRow(title: "Put x = 1 in each bracket", sub: "2 + 3 = 5 and 1 + 4 = 5", value: "5, 5"),
               InfoRow(title: "Multiply the results", sub: "5 \u{00D7} 5 = 25", value: "25"),
               InfoRow(title: "Put x = 1 in the answer", sub: "2 + 11 + 12 = 25", value: "Match")],
        sutra: "Gunita Samuccayah: put x = 1 on both sides and compare",
        steps: steps,
        practice: [Problem(n: "3.2.1.5", m: "3.17.10"), Problem(n: "2.1.3.4", m: "6.10.4"), Problem(n: "3.-1.1.4", m: "3.11.-4"),
                   Problem(n: "1.6.2.3", m: "2.13.18"), Problem(n: "4.-1.2.3", m: "8.10.-3")],
        random: randomP,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { _ in "**x = 1** is a quick check for any expansion." }
    )
}
