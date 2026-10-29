import SwiftUI

/// Advanced: Purana-Apuranabhyam. Complete the cube, then fix the difference.
enum CompletingCubeLesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let R1 = 235.0, R2 = 335.0, HY = 440.0
    private static let HX: [String: Double] = ["A": 340, "C": 512, "L": 684]
    private static let ORDER = ["A", "C", "L"]
    private static let SRC: [String: [String]] = ["A": ["r2"], "M": ["bA", "vA", "r4"], "C": ["bA", "vA"], "L": ["r6", "bC", "vC"]]
    private static let GRY: Set<String> = ["r1", "r3", "r5", "g0", "g2", "g5"]

    private static func sg(_ v: Int) -> String { v < 0 ? "\u{2212}" : "+" }
    private static func fm(_ v: Int) -> String { v < 0 ? "\u{2212}\(-v)" : String(v) }
    private static func isOpC(_ t: String) -> Bool { ["+", "\u{00D7}", "=", "\u{2212}", "\u{00F7}"].contains(t) }

    struct CY {
        var n: String
        var a: Int, c: Int, B: Int, M: Int, cube: Int, L: Int
        var v: [String: Int]
    }

    static func yav(_ n: String) -> CY {
        let p = n.split(separator: ".").map { Int($0) ?? 0 }
        let a = p[0], c = p[1]
        let B = 3 * a, M = 3 * a * a, cube = a * a * a, L = c - cube
        return CY(n: n, a: a, c: c, B: B, M: M, cube: cube, L: L, v: ["A": a, "C": cube, "L": L])
    }

    private static func lhs(_ Y: CY) -> String { "x\u{00B3} " + sg(Y.B) + " \(abs(Y.B))x\u{00B2} + \(Y.M)x + \(Y.c)" }
    private static func brk(_ Y: CY) -> String { "(x " + sg(Y.a) + " \(abs(Y.a)))\u{00B3}" }
    private static func full(_ Y: CY) -> String { brk(Y) + " " + sg(Y.L) + " \(abs(Y.L))" }

    private static func rows(_ S: inout Scene, _ Y: CY, _ y1: Double, _ y2: Double, _ sb: Double, _ sl: Double) -> [String] {
        S.seq([SeqItem("r0", "x\u{00B3}"), SeqItem("r1", sg(Y.B), op: true, c: MU), SeqItem("r2", "\(abs(Y.B))x\u{00B2}"),
               SeqItem("r3", "+", op: true, c: MU), SeqItem("r4", "\(Y.M)x"), SeqItem("r5", "+", op: true, c: MU),
               SeqItem("r6", String(Y.c))], 512, y1, 62)
        S.seq([SeqItem("g0", "=", op: true, c: MU, o: sb), SeqItem("g1", "(x", o: sb), SeqItem("g2", sg(Y.a), op: true, c: MU, o: sb),
               SeqItem("g3", String(abs(Y.a)), o: sb), SeqItem("g4", ")\u{00B3}", o: sb),
               SeqItem("g5", sg(Y.L), op: true, c: MU, o: sl), SeqItem("g6", String(abs(Y.L)), o: sl)], 512, y2, 62)
        return ["r0", "r1", "r2", "r3", "r4", "r5", "r6", "g0", "g1", "g2", "g3", "g4", "g5", "g6"]
    }

    private static func hold(_ S: inout Scene, _ Y: CY, _ k: String, _ hy: Double) {
        S.box("b" + k, HX[k]!, hy, 80, 66, r: 18, shadow: true)
        S.el("v" + k, fm(Y.v[k]!), HX[k]!, hy, z: 40, c: OR)
    }

    private static func stage(_ S: inout Scene, _ Y: CY, _ ph: Int, _ k: String) {
        let mt = k == "M"
        _ = rows(&S, Y, R1, R2, k == "A" ? (ph >= 3 ? 1 : 0) : 1, k == "L" ? (ph >= 3 ? 1 : 0) : 0)
        let upto = mt ? 1 : ORDER.firstIndex(of: k)!
        for q in ORDER.prefix(upto) { hold(&S, Y, q, HY) }
        let T: [String]
        switch k {
        case "A": T = [fm(Y.B), "\u{00F7}", "3", "="]
        case "M": T = ["3", "\u{00D7}", fm(Y.a), "\u{00D7}", fm(Y.a), "="]
        case "C": T = [fm(Y.a), "\u{00D7}", fm(Y.a), "\u{00D7}", fm(Y.a), "="]
        default: T = [String(Y.c), "\u{2212}", fm(Y.cube), "="]
        }
        let rv = mt ? Y.M : Y.v[k]!
        var items: [BubItem] = T.enumerated().map { BubItem("c\($0.offset)", $0.element, op: isOpC($0.element), c: INK) }
        items.append(BubItem("v" + k, fm(rv), res: true, c: mt ? GR : OR))
        let b = S.bub(items, ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
        let src = SRC[k]!
        if ph < 3 && !mt && k != "C" { S.mods(src, c: BLUE) }
        if mt && ph < 3 { S.mod("r4", c: BLUE) }
        if mt && ph >= 3 { S.mod("r4", c: GR) }
        if !mt { S.box("b" + k, HX[k]!, HY, 80, 66, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 18, shadow: true) }
        if ph == 0 { S.fa(src); S.h(src[0]) }
        if ph == 1 { S.fa(src); S.f("bub"); S.fa(b.rest); S.h("c1") }
        if ph == 2 { S.f("bub"); S.fa(b.res); S.h("v" + k) }
        if ph >= 3 {
            for id in b.rest { S.mod(id, o: 0) }
            S.mod("bub", o: 0, s: 0.9)
            if mt {
                S.mod("v" + k, o: 0); S.f("r2", "r4", "vA", "bA"); S.h("r4")
            } else {
                S.mod("v" + k, x: HX[k]!, y: HY, o: 1, s: 40.0 / 52.0); S.f("b" + k, "v" + k); S.h("v" + k)
            }
        }
    }

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = yav(d.n)
        var S = Scene(Y.n + ".")
        switch d.g {
        case "meet":
            let ids = rows(&S, Y, R1, R2, 0, 0)
            if ph == 0 { S.hide(Array(ids.prefix(7))) }
            if ph >= 2 { S.fa(Array(ids.prefix(7))); S.h("r2") }
        case "third": stage(&S, Y, ph, "A")
        case "match": stage(&S, Y, ph, "M")
        case "cube": stage(&S, Y, ph, "C")
        case "left": stage(&S, Y, ph, "L")
        case "result":
            let ids = rows(&S, Y, R1, R2, 1, 1)
            for q in ORDER { hold(&S, Y, q, HY) }
            if ph == 0 { S.f("g0", "g1", "g2", "g3", "g4"); S.h("g3") }
            if ph == 1 { S.f("g5", "g6"); S.h("g6") }
            if ph >= 2 { S.fa(ids) }
            if ph >= 3 {
                for i in ids { S.mod(i, c: GRY.contains(i) ? MU : GR) }
                S.finale = SFinale(x: 512, y: 285, w: 640, h: 230)
                S.win = true
            }
        default: break
        }
        return S
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n)
        switch d.g {
        case "third": return ("Bracket: " + fm(Y.a), OR)
        case "match": return ("x number: \(Y.M) ok", GR)
        case "cube": return ("Cube: " + fm(Y.cube), OR)
        case "left": return ("Leftover: " + fm(Y.L), OR)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n)
        var col = BLUE
        var t = ""
        switch d.g {
        case "meet": t = "Write **" + lhs(Y) + "** as a perfect cube plus a small leftover. **Watch this.**"
        case "third": col = OR; t = "In a cube, the x\u{00B2} number is 3 times the bracket number: **" + fm(Y.B) + " \u{00F7} 3 = " + fm(Y.a) + "**. The bracket is **" + brk(Y) + "**."
        case "match": col = GR; t = "Check the x number: **3 \u{00D7} " + fm(Y.a) + " \u{00D7} " + fm(Y.a) + " = \(Y.M)**. It matches, so the cube fits!"
        case "cube": col = OR; t = "A perfect cube would end with **" + fm(Y.a) + " \u{00D7} " + fm(Y.a) + " \u{00D7} " + fm(Y.a) + " = " + fm(Y.cube) + "**. But our number is **\(Y.c)**."
        case "left": col = OR; t = "Fix the difference: **\(Y.c) \u{2212} " + fm(Y.cube) + " = " + fm(Y.L) + "**. So the leftover is **" + sg(Y.L) + " \(abs(Y.L))**."
        case "result": t = "So **" + lhs(Y) + " = " + full(Y) + "**."
        default: t = "Your turn."
        }
        return (t, col)
    }

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n)
        let h = abs(Y.a)
        return [
            PTask(g: "third", cap: "The x\u{00B2} number is **\(abs(Y.B))**. Divide by 3 to get the bracket number.", q: "bracket", ans: String(h),
                  ex: [String(abs(Y.B)), "\u{00F7}", "3"], hint: "Close! Divide \(abs(Y.B)) by 3.", ok: "\(abs(Y.B)) \u{00F7} 3 = \(h)"),
            PTask(g: "cube", cap: "Cube it: **\(h) \u{00D7} \(h) \u{00D7} \(h)**.", q: "cube", ans: String(abs(Y.cube)),
                  ex: [String(h), "\u{00D7}", String(h), "\u{00D7}", String(h)], hint: "Close! Multiply \(h) by itself three times.",
                  ok: "\(h) \u{00D7} \(h) \u{00D7} \(h) = \(abs(Y.cube))"),
            PTask(g: "left", cap: "Our number is **\(Y.c)**. The cube brings **" + fm(Y.cube) + "**. How far apart? Type the gap.", q: "gap",
                  ans: String(abs(Y.L)), ex: [String(Y.c), "vs", fm(Y.cube)],
                  hint: "Close! Subtract " + fm(Y.cube) + " from \(Y.c) and drop the sign.", ok: "The gap is \(abs(Y.L))"),
            PTask(g: "left", cap: "Is **\(Y.c)** bigger or smaller than **" + fm(Y.cube) + "**? Type **1** if the leftover is **+**, **2** if it is **\u{2212}**.",
                  q: "sign", ans: Y.L > 0 ? "1" : "2", ex: [String(Y.c), "vs", fm(Y.cube)],
                  hint: "Close! Bigger than the cube means plus. Smaller means minus.", ok: "The leftover is " + sg(Y.L) + " \(abs(Y.L))"),
        ]
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = yav(p.n)
        var S = Scene(Y.n + ".")
        let T = tasks(p)
        let fin = done || (ok && t == T.count - 1)
        let ids = rows(&S, Y, 160, 245, (t >= 1 || fin) ? 1 : 0, fin ? 1 : 0)
        if t >= 1 || fin { hold(&S, Y, "A", 330) }
        if t >= 2 || fin { hold(&S, Y, "C", 330) }
        if fin {
            hold(&S, Y, "L", 330)
            for i in ids { S.mod(i, c: GRY.contains(i) ? MU : GR) }
            S.finale = SFinale(x: 512, y: 202, w: 640, h: 200)
        } else {
            let ex = T[min(t, T.count - 1)].ex
            let ids2 = ex.indices.map { "te\(t)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids2[$0.offset], $0.element, op: $0.offset % 2 == 1) }, 512, 410, 46)
            S.box("tb\(t)", 512, 410, max(240, q.total + 90), 72, r: 26, shadow: true)
            S.fa(ids); S.f("tb\(t)"); S.fa(ids2)
        }
        return S
    }

    private static let TM: [String: ([Double], Double)] = [
        "meet": ([0, 800, 2300], 3600), "third": ([0, 800, 2300, 3800], 5100), "match": ([0, 800, 2300, 3800], 5100),
        "cube": ([0, 800, 2300, 3800], 5100), "left": ([0, 800, 2300, 3800], 5100), "result": ([0, 800, 2300, 3800], 5100),
        "practice": ([0, 500], 700),
    ]

    private static let steps: [StepDef] = {
        let E1 = "2.5", E3 = "-2.3"
        let list: [(String, String, String)] = [
            ("meet", E1, "Meet the problem"), ("third", E1, "Find the bracket"), ("match", E1, "Check the x number"),
            ("cube", E1, "Cube it"), ("left", E1, "Fix the difference"), ("result", E1, "The result"),
            ("third", E3, "A minus: x\u{00B3} \u{2212} 6x\u{00B2} + 12x + 3"), ("match", E3, "Check the x number"),
            ("cube", E3, "Cube it"), ("left", E3, "Fix the difference"), ("result", E3, "The result"), ("practice", "", "Your turn"),
        ]
        return list.map { StepDef(g: $0.0, n: $0.1, name: $0.2, times: TM[$0.0]!.0, end: TM[$0.0]!.1) }
    }()

    private static func randomP() -> Problem {
        while true {
            let a = rnd(1, 4) * (Bool.random() ? -1 : 1), c = rnd(1, 40)
            if c == a * a * a { continue }
            return Problem(n: "\(a).\(c)")
        }
    }

    static let spec = LessonSpec(
        id: "cube",
        topTitle: "Completing the cube",
        cardTitle: "Completing the Cube",
        cardBlurb: "Turn x\u{00B3} + 6x\u{00B2} + 12x + 5 into a perfect cube plus a small leftover. Complete it, then fix the difference.",
        rows: [InfoRow(title: "Find the bracket", sub: "6 \u{00F7} 3 = 2, so (x + 2)\u{00B3}", value: "2"),
               InfoRow(title: "Cube it", sub: "2 \u{00D7} 2 \u{00D7} 2 = 8", value: "8"),
               InfoRow(title: "Fix the difference", sub: "5 \u{2212} 8 = \u{2212}3", value: "\u{2212}3")],
        sutra: "Purana-Apuranabhyam: complete the cube, then fix the difference",
        steps: steps,
        practice: [Problem(n: "2.5"), Problem(n: "-2.3"), Problem(n: "1.4"), Problem(n: "3.20"), Problem(n: "-1.9")],
        random: randomP,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { _ in "**Completing the cube** takes three small moves." }
    )
}
