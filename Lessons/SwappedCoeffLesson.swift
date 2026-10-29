import SwiftUI

/// Advanced: Sankalana-Vyavakalanabhyam. Add the equations, then subtract them.
enum SwappedCoeffLesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let COL: [String: Double] = ["a": 298, "x": 364, "p": 428, "b": 496, "y": 570, "e": 634, "c": 714]
    private static let R1 = 250.0, R2 = 330.0, R3 = 415.0, TY = 150.0

    struct SY {
        var n: String, m: String
        var a: Int, b: Int, x: Int, y: Int, c: Int, d: Int
        var A: Int, D: Int, cs: Int, cd: Int, s: Int, t: Int
    }

    static func yav(_ n: String, _ m: String) -> SY {
        let p = n.split(separator: ".").map { Int($0) ?? 0 }
        let q = m.split(separator: ".").map { Int($0) ?? 0 }
        let a = p[0], b = p[1], x = q[0], y = q[1]
        let c = a * x + b * y, d = b * x + a * y
        return SY(n: n, m: m, a: a, b: b, x: x, y: y, c: c, d: d, A: a + b, D: a - b, cs: c + d, cd: c - d, s: x + y, t: x - y)
    }

    private static func isOpS(_ t: String) -> Bool { ["+", "\u{00D7}", "=", "\u{2212}", "\u{00F7}", "(", ")"].contains(t) }
    private static func fe(_ Y: SY, _ k: Int) -> String {
        "\(k == 1 ? Y.a : Y.b)x + \(k == 1 ? Y.b : Y.a)y = \(k == 1 ? Y.c : Y.d)"
    }

    @discardableResult
    private static func row(_ S: inout Scene, _ k: Int, _ y: Double, _ t: [String], _ o: Double? = nil) -> [String] {
        let cells: [(String, String)] = [("a", t[0]), ("x", "x"), ("p", t[1]), ("b", t[2]), ("y", "y"), ("e", "="), ("c", t[3])]
        for (c, s) in cells {
            let op = c == "p" || c == "e"
            S.el(c + String(k), s, COL[c]!, y, z: op ? 50 : 62, c: op ? MU : INK, w: op ? 700 : 900, o: o ?? 1)
        }
        return ["a", "x", "p", "b", "y", "e", "c"].map { $0 + String(k) }
    }

    private static func eqs(_ S: inout Scene, _ Y: SY, _ y1: Double? = nil, _ y2: Double? = nil) -> [String] {
        let r1 = row(&S, 1, y1 ?? R1, [String(Y.a), "+", String(Y.b), String(Y.c)])
        let r2 = row(&S, 2, y2 ?? R2, [String(Y.b), "+", String(Y.a), String(Y.d)])
        return r1 + r2
    }

    @discardableResult
    private static func row3(_ S: inout Scene, _ Y: SY, _ add: Bool, _ o: Double) -> [String] {
        add ? row(&S, 3, R3, [String(Y.A), "+", String(Y.A), String(Y.cs)], o)
            : row(&S, 3, R3, [String(Y.D), "\u{2212}", String(Y.D), String(Y.cd)], o)
    }

    private static func tags(_ S: inout Scene, _ Y: SY, _ ty: Double, _ which: String) {
        if which.contains("S") { S.box("tagS", 392, ty, 200, 64, r: 22, shadow: true, q: "x + y = \(Y.s)", qz: 28, qc: OR) }
        if which.contains("D") { S.box("tagD", 632, ty, 200, 64, r: 22, shadow: true, q: "x \u{2212} y = \(Y.t)", qz: 28, qc: OR) }
    }

    private static func toks(_ arr: [String], _ res: String) -> [BubItem] {
        var items: [BubItem] = arr.enumerated().map { BubItem("u\($0.offset)", $0.element, op: isOpS($0.element), c: INK) }
        items.append(BubItem("vv", res, res: true, c: OR))
        return items
    }

    private static func div(_ S: inout Scene, _ Y: SY, _ ph: Int, _ m: String) {
        let add = m == "S"
        _ = eqs(&S, Y)
        row3(&S, Y, add, 1)
        if !add { tags(&S, Y, TY, "S") }
        let num = add ? Y.cs : Y.cd, den = add ? Y.A : Y.D, val = add ? Y.s : Y.t
        let x = add ? 392.0 : 632.0
        let bb = S.bub(toks([String(num), "\u{00F7}", String(den), "="], String(val)), ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
        let src = ["c3", "a3"]
        if ph < 3 { S.mods(src, c: BLUE) }
        S.box("tag" + m, x, TY, 200, 64, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 22, shadow: true,
              q: (add ? "x + y = " : "x \u{2212} y = ") + String(val), qz: 28, qc: OR)
        if ph == 0 { S.fa(src); S.h("c3") }
        if ph == 1 { S.fa(src); S.f("bub"); S.fa(bb.rest); S.h("u1") }
        if ph == 2 { S.f("bub"); S.fa(bb.res); S.h("vv") }
        if ph >= 3 {
            for i in bb.ids { S.mod(i, o: 0) }
            S.mod("bub", o: 0, s: 0.9)
            S.f("tag" + m); S.hp(x, 190)
        }
    }

    private static func sol(_ S: inout Scene, _ Y: SY, _ ph: Int, _ k: String) {
        let X = k == "x"
        let val = X ? Y.x : Y.y
        _ = eqs(&S, Y)
        tags(&S, Y, TY, "SD")
        if !X { S.box("ansx", 392, R3, 200, 64, r: 22, shadow: true, q: "x = \(Y.x)", qz: 28, qc: GR) }
        let bb = S.bub(toks(["(", String(Y.s), X ? "+" : "\u{2212}", String(Y.t), ")", "\u{00F7}", "2", "="], String(val)),
                       ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
        S.box("ans" + k, X ? 392 : 632, R3, 200, 64, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 22, shadow: true,
              q: k + " = \(val)", qz: 28, qc: GR)
        if ph == 0 { S.f("tagS", "tagD"); S.hp(512, TY + 30) }
        if ph == 1 { S.f("bub"); S.fa(bb.rest); S.h("u2") }
        if ph == 2 { S.f("bub"); S.fa(bb.res); S.h("vv") }
        if ph >= 3 {
            for i in bb.ids { S.mod(i, o: 0) }
            S.mod("bub", o: 0, s: 0.9)
            S.f("ans" + k)
            if !X { S.f("ansx") }
            S.hp(X ? 392 : 632, R3 + 18)
            if !X { S.finale = SFinale(x: 512, y: R3, w: 540, h: 120); S.win = true }
        }
    }

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = yav(d.n, d.m)
        var S = Scene(Y.n + "x" + Y.m + ".")
        switch d.g {
        case "meet":
            let ids = eqs(&S, Y)
            if ph == 0 { S.hide(ids) }
            if ph >= 2 {
                S.mods(["a1", "b2"], c: BLUE); S.mods(["b1", "a2"], c: OR)
                S.fa(ids); S.h("a1")
            }
        case "add":
            let ids = eqs(&S, Y)
            let r = row3(&S, Y, true, ph >= 1 ? 1 : 0)
            if ph == 0 { S.fa(ids); S.h("a1") }
            if ph >= 1 { S.fa(r); S.h("c3") }
        case "divS": div(&S, Y, ph, "S")
        case "sub":
            let ids = eqs(&S, Y)
            let r = row3(&S, Y, false, ph >= 1 ? 1 : 0)
            tags(&S, Y, TY, "S")
            if ph == 0 { S.fa(ids); S.f("tagS"); S.h("a1") }
            if ph >= 1 { S.fa(r); S.f("tagS"); S.h("c3") }
        case "divD": div(&S, Y, ph, "D")
        case "solx": sol(&S, Y, ph, "x")
        case "soly": sol(&S, Y, ph, "y")
        default: break
        }
        return S
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n, d.m)
        switch d.g {
        case "add": return ("Add: \(Y.A)(x + y)", OR)
        case "divS": return ("x + y = \(Y.s)", OR)
        case "sub": return ("Subtract: \(Y.D)(x \u{2212} y)", OR)
        case "divD": return ("x \u{2212} y = \(Y.t)", OR)
        case "solx": return ("x = \(Y.x)", GR)
        case "soly": return ("y = \(Y.y)", GR)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n, d.m)
        var col = OR
        var t = ""
        switch d.g {
        case "meet": col = BLUE; t = "Look at **" + fe(Y, 1) + "** and **" + fe(Y, 2) + "**. The numbers are **swapped**. **Watch this.**"
        case "add": t = "Add the equations. \(Y.a) + \(Y.b) = \(Y.A) for both x and y, and \(Y.c) + \(Y.d) = \(Y.cs). So **\(Y.A)x + \(Y.A)y = \(Y.cs)**."
        case "divS": t = "Divide by **\(Y.A)**. **x + y = \(Y.cs) \u{00F7} \(Y.A) = \(Y.s)**."
        case "sub": t = "Now subtract. x gets \(Y.a) \u{2212} \(Y.b) = \(Y.D), y gets \(Y.b) \u{2212} \(Y.a) = \u{2212}\(Y.D), and \(Y.c) \u{2212} \(Y.d) = \(Y.cd). So **\(Y.D)x \u{2212} \(Y.D)y = \(Y.cd)**."
        case "divD": t = "Divide by **\(Y.D)**. **x \u{2212} y = \(Y.cd) \u{00F7} \(Y.D) = \(Y.t)**."
        case "solx": col = GR; t = "Add the two results and halve: **x = (\(Y.s) + \(Y.t)) \u{00F7} 2 = \(Y.x)**."
        case "soly": col = GR; t = "Subtract and halve: **y = (\(Y.s) \u{2212} \(Y.t)) \u{00F7} 2 = \(Y.y)**. Solved!"
        default: col = BLUE; t = "Your turn."
        }
        return (t, col)
    }

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n, p.m)
        return [
            PTask(g: "divS", cap: "Add the equations: **(\(Y.c) + \(Y.d)) \u{00F7} (\(Y.a) + \(Y.b))**. Type **x + y**.", q: "x + y", ans: String(Y.s),
                  ex: ["(\(Y.c)+\(Y.d))", "\u{00F7}", "(\(Y.a)+\(Y.b))"], hint: "Close! Add the tops, add the bottoms, then divide.", ok: "x + y = \(Y.s)"),
            PTask(g: "divD", cap: "Subtract: **(\(Y.c) \u{2212} \(Y.d)) \u{00F7} (\(Y.a) \u{2212} \(Y.b))**. Type **x \u{2212} y**.", q: "x \u{2212} y", ans: String(Y.t),
                  ex: ["(\(Y.c)\u{2212}\(Y.d))", "\u{00F7}", "(\(Y.a)\u{2212}\(Y.b))"], hint: "Close! Subtract the tops, subtract the bottoms, then divide.", ok: "x \u{2212} y = \(Y.t)"),
            PTask(g: "solx", cap: "Now **x = (\(Y.s) + \(Y.t)) \u{00F7} 2**. Type **x**.", q: "x", ans: String(Y.x),
                  ex: ["(\(Y.s)+\(Y.t))", "\u{00F7}", "2"], hint: "Close! Add the two results, then halve.", ok: "x = \(Y.x)"),
            PTask(g: "soly", cap: "And **y = (\(Y.s) \u{2212} \(Y.t)) \u{00F7} 2**. Type **y**.", q: "y", ans: String(Y.y),
                  ex: ["(\(Y.s)\u{2212}\(Y.t))", "\u{00F7}", "2"], hint: "Close! Subtract the two results, then halve.", ok: "y = \(Y.y)"),
        ]
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = yav(p.n, p.m)
        var S = Scene(Y.n + "x" + Y.m + ".")
        let T = tasks(p)
        let fin = done || (ok && t == T.count - 1)
        let ids = eqs(&S, Y, 175, 255)
        if fin {
            S.box("ansx", 392, 335, 200, 64, r: 22, shadow: true, q: "x = \(Y.x)", qz: 28, qc: GR)
            S.box("ansy", 632, 335, 200, 64, r: 22, shadow: true, q: "y = \(Y.y)", qz: 28, qc: GR)
            S.finale = SFinale(x: 512, y: 335, w: 540, h: 120)
            for i in ids { S.mod(i, c: (i.hasPrefix("p") || i.hasPrefix("e")) ? MU : GR) }
        } else {
            tags(&S, Y, 335, t >= 2 ? "SD" : (t >= 1 ? "S" : ""))
            let ex = T[min(t, T.count - 1)].ex
            let ids2 = ex.indices.map { "te\(t)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids2[$0.offset], $0.element, op: $0.offset == 1) }, 512, 410, 40)
            S.box("tb\(t)", 512, 410, max(240, q.total + 90), 72, r: 26, shadow: true)
            S.fa(ids); S.f("tb\(t)"); S.fa(ids2)
        }
        return S
    }

    private static let TM: [String: ([Double], Double)] = [
        "meet": ([0, 800, 2300], 3600), "add": ([0, 800, 2300], 3600), "divS": ([0, 800, 2300, 3800], 5100),
        "sub": ([0, 800, 2300], 3600), "divD": ([0, 800, 2300, 3800], 5100), "solx": ([0, 800, 2300, 3800], 5100),
        "soly": ([0, 800, 2300, 3800], 5100), "practice": ([0, 500], 700),
    ]

    private static let steps: [StepDef] = {
        let E1n = "7.3", E1m = "5.2", E2n = "9.4", E2m = "7.3"
        let L1: [(String, String)] = [("meet", "Meet the problem"), ("add", "Add the equations"), ("divS", "Divide: x + y"),
                                      ("sub", "Subtract them"), ("divD", "Divide: x \u{2212} y"), ("solx", "Find x"), ("soly", "Find y")]
        let L2: [(String, String)] = [("add", "A bigger one: add"), ("divS", "Divide: x + y"), ("sub", "Subtract them"),
                                      ("divD", "Divide: x \u{2212} y"), ("solx", "Find x"), ("soly", "Find y")]
        var list: [(String, String, String, String)] = L1.map { ($0.0, E1n, E1m, $0.1) }
        list += L2.map { ($0.0, E2n, E2m, $0.1) }
        list.append(("practice", "", "", "Your turn"))
        return list.map { StepDef(g: $0.0, n: $0.1, m: $0.2, name: $0.3, times: TM[$0.0]!.0, end: TM[$0.0]!.1) }
    }()

    private static func randomP() -> Problem {
        while true {
            let a = rnd(5, 9), b = rnd(2, a - 2), x = rnd(2, 9), y = rnd(1, x - 1)
            if a * x + b * y > 99 || b * x + a * y > 99 { continue }
            return Problem(n: "\(a).\(b)", m: "\(x).\(y)")
        }
    }

    static let spec = LessonSpec(
        id: "swc",
        topTitle: "Swapped coefficients",
        cardTitle: "Swapped Coefficients",
        cardBlurb: "Coefficients swapped between two equations? Add them, then subtract them. Two easy equations are left.",
        rows: [InfoRow(title: "Add the equations", sub: "7x + 3y = 41 and 3x + 7y = 29 \u{2192} 10x + 10y = 70", value: "x + y = 7"),
               InfoRow(title: "Subtract them", sub: "4x \u{2212} 4y = 12", value: "x \u{2212} y = 3"),
               InfoRow(title: "Solve the pair", sub: "x = (7 + 3) \u{00F7} 2, y = (7 \u{2212} 3) \u{00F7} 2", value: "x = 5, y = 2")],
        sutra: "Sankalana-Vyavakalanabhyam: add the equations, then subtract them",
        steps: steps,
        practice: [Problem(n: "9.2", m: "4.3"), Problem(n: "8.5", m: "6.2"), Problem(n: "7.2", m: "5.3"),
                   Problem(n: "9.4", m: "7.5"), Problem(n: "7.2", m: "9.4")],
        random: randomP,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { _ in "**Add and subtract** solves any swapped pair." }
    )
}
