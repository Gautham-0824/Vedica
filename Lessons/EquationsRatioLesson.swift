import SwiftUI

/// Advanced: Anurupye Shunyamanyat. If one variable's coefficients are in the same ratio as the constants,
/// the other variable is zero.
enum EquationsRatioLesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let COL: [String: Double] = ["a": 298, "x": 364, "p": 428, "b": 496, "y": 570, "e": 634, "c": 714]
    private static let E1 = 240.0, E2 = 330.0, CY = 435.0, TY = 150.0

    struct RY {
        var n: String, m: String
        var a1: Int, b1: Int, c1: Int, a2: Int, b2: Int, c2: Int
        var ok: Bool
        var R: String, Z: String
        var r1: Int, r2: Int
        var rp: Int, rq: Int, cp: Int, cq: Int
        var val: Int
        var zero: String
    }

    static func yav(_ n: String, _ m: String) -> RY {
        let p1 = n.split(separator: ".").map { Int($0) ?? 0 }
        let p2 = m.split(separator: ".").map { Int($0) ?? 0 }
        let a1 = p1[0], b1 = p1[1], c1 = p1[2], a2 = p2[0], b2 = p2[1], c2 = p2[2]
        let yOk = b1 * c2 == b2 * c1
        let xOk = a1 * c2 == a2 * c1
        let ok = yOk || xOk
        let R = (xOk && !yOk) ? "x" : "y"
        let Z = R == "y" ? "x" : "y"
        let r1 = R == "y" ? b1 : a1
        let r2 = R == "y" ? b2 : a2
        let g1 = gcd(r1, r2), g2 = gcd(c1, c2)
        let val = (ok && r1 != 0) ? c1 / r1 : 0
        return RY(n: n, m: m, a1: a1, b1: b1, c1: c1, a2: a2, b2: b2, c2: c2, ok: ok, R: R, Z: Z, r1: r1, r2: r2,
                  rp: r1 / g1, rq: r2 / g1, cp: c1 / g2, cq: c2 / g2, val: val, zero: Z + " = 0")
    }

    private static func fe(_ Y: RY, _ k: Int) -> String {
        let a = k == 1 ? Y.a1 : Y.a2, b = k == 1 ? Y.b1 : Y.b2, c = k == 1 ? Y.c1 : Y.c2
        return "\(a)x + \(b)y = \(c)"
    }
    private static func rcx(_ Y: RY) -> Double { Y.R == "y" ? COL["b"]! : COL["a"]! }
    private static func rids(_ Y: RY) -> [String] { Y.R == "y" ? ["b1", "b2"] : ["a1", "a2"] }
    private static func zids(_ Y: RY) -> [String] { Y.R == "y" ? ["a1", "a2"] : ["b1", "b2"] }
    private static func isOpId(_ i: String) -> Bool {
        guard i.count >= 2, let f = i.first, f == "p" || f == "e" else { return false }
        return i.dropFirst().first?.isNumber ?? false
    }

    @discardableResult
    private static func eqs(_ S: inout Scene, _ Y: RY, _ y1: Double, _ y2: Double) -> [String] {
        let rows: [[Int]] = [[Y.a1, Y.b1, Y.c1], [Y.a2, Y.b2, Y.c2]]
        let ys = [y1, y2]
        var ids: [String] = []
        for (i, r) in rows.enumerated() {
            let k = i + 1
            let cells: [(String, String)] = [("a", String(r[0])), ("x", "x"), ("p", "+"), ("b", String(r[1])),
                                             ("y", "y"), ("e", "="), ("c", String(r[2]))]
            for (c, t) in cells {
                let op = c == "p" || c == "e"
                S.el(c + String(k), t, COL[c]!, ys[i], z: op ? 50 : 62, c: op ? MU : INK, w: op ? 700 : 900)
                ids.append(c + String(k))
            }
        }
        return ids
    }

    private static func chip(_ S: inout Scene, _ Y: RY, _ k: String) {
        let cx = k == "R" ? rcx(Y) : COL["c"]!
        let p = k == "R" ? Y.rp : Y.cp, q = k == "R" ? Y.rq : Y.cq
        S.box("h" + k, cx, CY, 128, 66, r: 18, shadow: true)
        let ts = [String(p), ":", String(q)]
        for (i, t) in ts.enumerated() { S.el(k + String(i), t, cx + Double(i - 1) * 32, CY, z: 40, c: OR) }
    }

    private static func tags(_ S: inout Scene, _ Y: RY, _ col: Color, _ ty: Double) {
        let zx = Y.Z == "x" ? 392.0 : 632.0, rx = Y.Z == "x" ? 632.0 : 392.0
        S.box("tag", zx, ty, 200, 64, r: 22, shadow: true, q: Y.zero, qz: 28, qc: col)
        S.box("tag2", rx, ty, 200, 64, r: 22, shadow: true, q: Y.R + " = \(Y.val)", qz: 28, qc: col)
    }

    private static func ratio(_ S: inout Scene, _ Y: RY, _ ph: Int, _ k: String) {
        eqs(&S, Y, E1, E2)
        let R = k == "R"
        if !R { chip(&S, Y, "R") }
        let src = R ? rids(Y) : ["c1", "c2"]
        let cx = R ? rcx(Y) : COL["c"]!
        let a = R ? Y.r1 : Y.c1, b = R ? Y.r2 : Y.c2, p = R ? Y.rp : Y.cp, q = R ? Y.rq : Y.cq
        let bb = S.bub([BubItem("u0", String(a)), BubItem("u1", ":", op: true), BubItem("u2", String(b)), BubItem("u3", "=", op: true),
                        BubItem(k + "0", String(p), res: true, c: OR), BubItem(k + "1", ":", op: true, res: true, c: OR),
                        BubItem(k + "2", String(q), res: true, c: OR)],
                       ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
        if ph < 3 { S.mods(src, c: BLUE) }
        S.box("h" + k, cx, CY, 128, 66, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 18, shadow: true)
        if ph == 0 { S.fa(src); S.h(src[0]) }
        if ph == 1 { S.fa(src); S.f("bub"); S.fa(bb.rest); S.h("u1") }
        if ph == 2 { S.fa(src); S.f("bub"); S.fa(bb.ids); S.h(k + "0") }
        if ph >= 1 && ph < 3 {
            S.arrow(0, (cx, E2 + 44), (bb.xs[0] - 6, 530 - 62), st: ph >= 2 ? 2 : 1, bend: 0.25)
        }
        if ph >= 3 {
            for (i, id) in bb.res.enumerated() { S.mod(id, x: cx + Double(i - 1) * 32, y: CY, o: 1, s: 40.0 / 52.0) }
            for id in bb.rest { S.mod(id, o: 0) }
            S.mod("bub", o: 0, s: 0.9)
            S.f("h" + k); S.fa(bb.res); S.h(k + "0")
        }
    }

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = yav(d.n, d.m)
        var S = Scene(Y.n + "x" + Y.m + ".")
        switch d.g {
        case "meet":
            let ids = eqs(&S, Y, E1, E2)
            if ph == 0 { S.hide(ids) }
            if ph >= 2 { S.fa(ids); S.h("c1") }
        case "ratR": ratio(&S, Y, ph, "R")
        case "ratC": ratio(&S, Y, ph, "C")
        case "same":
            eqs(&S, Y, E1, E2); chip(&S, Y, "R"); chip(&S, Y, "C")
            let col = Y.ok ? GR : OR
            let msg = Y.ok ? "Same ratio!" : "Different ratios"
            let bb = S.bub([BubItem("s0", String(Y.rp), c: OR), BubItem("s1", ":", op: true, c: OR), BubItem("s2", String(Y.rq), c: OR),
                            BubItem("s3", Y.ok ? "=" : "\u{2260}", op: true, c: col),
                            BubItem("s4", String(Y.cp), c: OR), BubItem("s5", ":", op: true, c: OR), BubItem("s6", String(Y.cq), c: OR)],
                           ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, 1)
            S.box("tag", 512, TY, 300, 64, o: ph >= 2 ? 1 : 0, s: ph >= 2 ? 1 : 0.9, r: 22, shadow: true, q: msg, qz: 28, qc: col)
            if ph >= 2 { S.mod("hR", c: col); S.mod("hC", c: col) }
            if ph == 0 { S.f("hR", "R0", "R1", "R2", "hC", "C0", "C1", "C2"); S.h("C2") }
            if ph == 1 { S.f("bub"); S.fa(bb.ids); S.h("s3") }
            if ph >= 2 { S.f("tag", "hR", "R0", "R1", "R2", "hC", "C0", "C1", "C2", "bub"); S.fa(bb.ids); S.h("s6") }
        case "zero":
            eqs(&S, Y, E1, E2); chip(&S, Y, "R"); chip(&S, Y, "C")
            S.mod("hR", c: GR); S.mod("hC", c: GR)
            let zc = zids(Y)
            S.mods(zc, c: OR)
            S.box("tag", 512, TY, 200, 64, o: ph >= 1 ? 1 : 0, s: ph >= 1 ? 1 : 0.9, r: 22, shadow: true, q: Y.zero, qz: 28, qc: OR)
            if ph == 0 { S.fa(zc); S.h(zc[0]) }
            if ph >= 1 { S.fa(zc); S.f("tag"); S.hp(512, 190) }
        case "solve":
            eqs(&S, Y, E1, E2)
            let zx = Y.Z == "x" ? 392.0 : 632.0, rx = Y.Z == "x" ? 632.0 : 392.0, rc = rids(Y)[0]
            S.mods(zids(Y), c: OR)
            S.box("tag", zx, TY, 200, 64, r: 22, shadow: true, q: Y.zero, qz: 28, qc: OR)
            S.box("tag2", rx, TY, 200, 64, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 22, shadow: true,
                  q: Y.R + " = \(Y.val)", qz: 28, qc: OR)
            let bb = S.bub([BubItem("v0", String(Y.c1)), BubItem("v1", "\u{00F7}", op: true), BubItem("v2", String(Y.r1)),
                            BubItem("v3", "=", op: true), BubItem("rv", String(Y.val), res: true, c: OR)],
                           ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph == 2 ? 1 : 0)
            if ph < 3 { S.mod(rc, c: BLUE); S.mod("c1", c: BLUE) }
            if ph == 0 { S.f(rc, "c1", "tag"); S.h(rc) }
            if ph == 1 { S.f(rc, "c1", "bub"); S.fa(bb.rest); S.h("v1") }
            if ph == 2 { S.f("bub"); S.fa(bb.ids); S.h("rv") }
            if ph >= 3 {
                S.mod("bub", o: 0, s: 0.9)
                for id in bb.ids { S.mod(id, o: 0) }
                S.f("tag", "tag2"); S.hp(512, 190)
            }
        case "nope":
            eqs(&S, Y, E1, E2)
            let ry = rids(Y), cs = ["c1", "c2"], rx = rcx(Y)
            let edge: Color = ph >= 4 ? OR : Theme.line
            S.box("hR", rx, CY, 128, 66, o: ph >= 1 ? 1 : 0, s: ph >= 1 ? 1 : 0.9, r: 18, c: edge, shadow: true)
            S.box("hC", COL["c"]!, CY, 128, 66, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 18, c: edge, shadow: true)
            for (i, t) in [String(Y.rp), ":", String(Y.rq)].enumerated() {
                S.el("R\(i)", t, rx + Double(i - 1) * 32, CY, z: 40, c: OR, o: ph >= 1 ? 1 : 0)
            }
            for (i, t) in [String(Y.cp), ":", String(Y.cq)].enumerated() {
                S.el("C\(i)", t, COL["c"]! + Double(i - 1) * 32, CY, z: 40, c: OR, o: ph >= 3 ? 1 : 0)
            }
            S.box("tag", 512, TY, 300, 64, o: ph >= 4 ? 1 : 0, s: ph >= 4 ? 1 : 0.9, r: 22, shadow: true,
                  q: "Different ratios", qz: 28, qc: OR)
            if ph < 2 { S.mods(ry, c: BLUE) }
            if ph == 2 || ph == 3 { S.mods(cs, c: BLUE) }
            if ph == 0 { S.fa(ry); S.h(ry[0]) }
            if ph == 1 { S.fa(ry); S.f("hR", "R0", "R1", "R2"); S.h("R2") }
            if ph == 2 { S.fa(cs); S.f("hR", "R0", "R1", "R2"); S.h("c1") }
            if ph == 3 { S.fa(cs); S.f("hC", "C0", "C1", "C2"); S.h("C2") }
            if ph >= 4 { S.f("tag", "hR", "R0", "R1", "R2", "hC", "C0", "C1", "C2"); S.h("tag") }
        case "check":
            let ids = eqs(&S, Y, E1, E2)
            tags(&S, Y, OR, TY)
            S.mods(zids(Y), c: OR)
            let src = [rids(Y)[1], "c2"]
            let bb = S.bub([BubItem("w0", String(Y.r2)), BubItem("w1", "\u{00D7}", op: true), BubItem("w2", String(Y.val), c: OR),
                            BubItem("w3", "=", op: true), BubItem("w4", String(Y.c2), res: true, c: GR)],
                           ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
            if ph < 3 { S.mods(src, c: BLUE) }
            if ph == 0 { S.fa(src); S.f("tag2"); S.h(src[0]) }
            if ph == 1 { S.fa(src); S.f("bub"); S.fa(bb.rest); S.h("w1") }
            if ph == 2 { S.f("bub"); S.fa(bb.ids); S.h("w4") }
            if ph >= 3 {
                for i in ids { S.mod(i, c: isOpId(i) ? MU : GR) }
                S.mod("tag", qc: GR)
                S.mod("tag2", qc: GR)
                S.mod("bub", o: 0, s: 0.9)
                for id in bb.ids { S.mod(id, o: 0) }
                S.fa(ids)
                S.finale = SFinale(x: 506, y: (E1 + E2) / 2, w: 580, h: 230)
                S.win = true
            }
        default: break
        }
        return S
    }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n, d.m)
        switch d.g {
        case "ratR": return ("Ratio of " + Y.R + ": \(Y.rp):\(Y.rq)", OR)
        case "ratC": return ("Constants: \(Y.cp):\(Y.cq)", OR)
        case "same": return ("Compare: " + (Y.ok ? "same" : "different"), BLUE)
        case "zero": return (Y.zero, OR)
        case "solve": return (Y.R + " = \(Y.val)", OR)
        case "check": return ("Check: ok", GR)
        default: return nil
        }
    }

    private static func hl(_ g: String) -> Color {
        switch g {
        case "ratR", "ratC", "zero", "solve": return OR
        case "check": return GR
        default: return BLUE
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n, d.m)
        var t = ""
        switch d.g {
        case "meet":
            t = "Solve **" + fe(Y, 1) + "** and **" + fe(Y, 2) + "**. This usually takes many steps. Today it takes **one look**. **Watch this.**"
        case "ratR":
            t = "Look at the **" + Y.R + "** numbers: \(Y.r1) and \(Y.r2). " +
                (Y.rp == Y.r1 ? "Their ratio is **\(Y.rp) : \(Y.rq)**." : "Their ratio is \(Y.r1) : \(Y.r2) = **\(Y.rp) : \(Y.rq)**.")
        case "ratC":
            t = "Now the numbers on the right: \(Y.c1) and \(Y.c2). " +
                (Y.cp == Y.c1 ? "Their ratio is **\(Y.cp) : \(Y.cq)**." : "Their ratio is \(Y.c1) : \(Y.c2) = **\(Y.cp) : \(Y.cq)**.")
        case "same":
            t = Y.ok
                ? "**\(Y.rp) : \(Y.rq)** and **\(Y.cp) : \(Y.cq)** are the **same ratio**! The sutra says: if one is in ratio, **the other is zero**."
                : "**\(Y.rp) : \(Y.rq)** and **\(Y.cp) : \(Y.cq)** are **different**. The sutra does not work here. Use another method."
        case "nope":
            t = "The **" + Y.R + "** numbers give **\(Y.rp) : \(Y.rq)**. The constants give **\(Y.cp) : \(Y.cq)**. They are **different**, so the sutra does not work here. Use another method."
        case "zero":
            t = "So the other variable, **" + Y.Z + "**, is **0**."
        case "solve":
            t = "Put **" + Y.Z + " = 0** in the first equation: **\(Y.r1)" + Y.R + " = \(Y.c1)**. So " + Y.R + " = \(Y.c1) \u{00F7} \(Y.r1) = **\(Y.val)**."
        case "check":
            t = "Check the second equation: **\(Y.r2) \u{00D7} \(Y.val) = \(Y.c2)**. Solved: **" + Y.Z + " = 0** and **" + Y.R + " = \(Y.val)**."
        default:
            t = "Your turn."
        }
        return (t, hl(d.g))
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n, p.m)
        var T: [PTask] = [
            PTask(g: "ratR", cap: "Look at the **" + Y.R + "** numbers: **\(Y.r1)** and **\(Y.r2)**. Reduce **\(Y.r1) : \(Y.r2)**. Type the bigger number.",
                  q: "ratio", ans: String(Y.rq), ex: [String(Y.r1), ":", String(Y.r2)],
                  hint: "Close! Divide both numbers by the same number until you cannot go smaller.",
                  ok: "\(Y.r1) : \(Y.r2) = \(Y.rp) : \(Y.rq)"),
            PTask(g: "ratC", cap: "Now reduce the constants, **\(Y.c1) : \(Y.c2)**. Type the bigger number.",
                  q: "ratio", ans: String(Y.cq), ex: [String(Y.c1), ":", String(Y.c2)],
                  hint: "Close! Divide both numbers by the same number until you cannot go smaller.",
                  ok: "\(Y.c1) : \(Y.c2) = \(Y.cp) : \(Y.cq)"),
            PTask(g: "same", cap: "Compare **\(Y.rp) : \(Y.rq)** and **\(Y.cp) : \(Y.cq)**. Type **1** if they match, **0** if they do not.",
                  q: "compare", ans: Y.ok ? "1" : "0", ex: ["\(Y.rp):\(Y.rq)", "vs", "\(Y.cp):\(Y.cq)"],
                  hint: "Close! 1 means the two ratios are the same, 0 means they differ.",
                  ok: Y.ok ? "They match, so one variable is 0" : "They differ, so there is no shortcut"),
        ]
        if Y.ok {
            T.append(PTask(g: "zero", cap: "Which variable is **0**? Type **1** for x or **2** for y.",
                           q: "zero", ans: Y.Z == "x" ? "1" : "2", ex: ["1 = x", "or", "2 = y"],
                           hint: "Close! The variable that is not in ratio is the zero one.", ok: Y.zero))
            T.append(PTask(g: "solve", cap: "Put the zero in the first equation: **\(Y.r1)" + Y.R + " = \(Y.c1)**. Find **" + Y.R + "**.",
                           q: Y.R, ans: String(Y.val), ex: [String(Y.c1), "\u{00F7}", String(Y.r1)],
                           hint: "Close! Divide \(Y.c1) by \(Y.r1).", ok: Y.R + " = \(Y.val)"))
        }
        return T
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = yav(p.n, p.m)
        var S = Scene(Y.n + "x" + Y.m + ".")
        let T = tasks(p)
        let fin = done || (ok && t == T.count - 1)
        let ids = eqs(&S, Y, 215, 295)
        if fin {
            for i in ids { S.mod(i, c: isOpId(i) ? MU : (Y.ok ? GR : OR)) }
            if Y.ok {
                tags(&S, Y, GR, 130)
                S.finale = SFinale(x: 506, y: 255, w: 580, h: 200)
            }
        } else {
            let tk = T[min(t, T.count - 1)]
            let ex = tk.ex
            let ids2 = ex.indices.map { "te\(t)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids2[$0.offset], $0.element, op: $0.offset == 1) }, 512, 385, 46)
            S.box("tb\(t)", 512, 385, max(240, q.total + 90), 84, r: 26, shadow: true)
            let src: [String]
            switch tk.g {
            case "ratR": src = rids(Y)
            case "ratC": src = ["c1", "c2"]
            case "zero": src = zids(Y)
            case "solve": src = [rids(Y)[0], "c1"]
            default: src = []
            }
            S.mods(src, c: BLUE)
            S.fa(ids); S.f("tb\(t)"); S.fa(ids2)
        }
        return S
    }

    // MARK: spec

    private static let TM: [String: ([Double], Double)] = [
        "meet": ([0, 800, 2300], 3600), "ratR": ([0, 800, 2300, 3800], 5100), "ratC": ([0, 800, 2300, 3800], 5100),
        "same": ([0, 800, 2300, 3800], 5100), "zero": ([0, 800, 2300], 3600), "solve": ([0, 800, 2300, 3800], 5100),
        "check": ([0, 800, 2300, 3800], 5100), "nope": ([0, 800, 2300, 3800, 5300], 6600), "practice": ([0, 500], 700),
    ]

    private static let steps: [StepDef] = {
        let E1n = "2.3.12", E1m = "5.6.24", E2n = "4.3.20", E2m = "6.7.30", E3n = "2.3.12", E3m = "5.6.20"
        let list: [(String, String, String, String)] = [
            ("meet", E1n, E1m, "Meet the problem"), ("ratR", E1n, E1m, "Ratio of the y numbers"),
            ("ratC", E1n, E1m, "Ratio of the constants"), ("same", E1n, E1m, "Compare the ratios"),
            ("zero", E1n, E1m, "The other is zero"), ("solve", E1n, E1m, "Find the other one"),
            ("check", E1n, E1m, "Check the answer"),
            ("ratR", E2n, E2m, "Another kind: x numbers"), ("ratC", E2n, E2m, "Ratio of the constants"),
            ("same", E2n, E2m, "Compare the ratios"), ("zero", E2n, E2m, "The other is zero"),
            ("solve", E2n, E2m, "Find the other one"),
            ("ratR", E3n, E3m, "When it does not work"), ("ratC", E3n, E3m, "Ratio of the constants"),
            ("same", E3n, E3m, "Different ratios"), ("practice", "", "", "Your turn"),
        ]
        return list.map { StepDef(g: $0.0, n: $0.1, m: $0.2, name: $0.3, times: TM[$0.0]!.0, end: TM[$0.0]!.1) }
    }()

    private static func randomP() -> Problem {
        let pairs = [(1, 2), (1, 3), (1, 4), (2, 3), (3, 4), (2, 5)]
        let t = Double.random(in: 0..<1)
        let (p, q) = pairs[rnd(0, pairs.count - 1)]
        let gl = Int((2.0 / Double(p)).rounded(.up))
        let g = rnd(gl, max(gl, 9 / q))
        let r1 = g * p, r2 = g * q
        var o1 = 0, o2 = 0
        repeat { o1 = rnd(2, 9); o2 = rnd(2, 9) } while o1 * r2 == o2 * r1
        if t < 0.2 {
            var c1 = 0, c2 = 0
            repeat { c1 = rnd(6, 40); c2 = rnd(6, 60) } while c1 * r2 == c2 * r1 || c1 * o2 == c2 * o1
            return Problem(n: "\(o1).\(r1).\(c1)", m: "\(o2).\(r2).\(c2)")
        }
        let v = rnd(2, 9)
        let c1 = r1 * v, c2 = r2 * v
        return t < 0.6 ? Problem(n: "\(o1).\(r1).\(c1)", m: "\(o2).\(r2).\(c2)")
                       : Problem(n: "\(r1).\(o1).\(c1)", m: "\(r2).\(o2).\(c2)")
    }

    static let spec = LessonSpec(
        id: "eqr",
        topTitle: "Simultaneous equations",
        cardTitle: "Equations in Ratio",
        cardBlurb: "Two equations, one look. If one pair of numbers is in the same ratio as the constants, the other variable is zero.",
        rows: [InfoRow(title: "Spot the ratios", sub: "3 : 6 and 12 : 24", value: "1 : 2"),
               InfoRow(title: "Same ratio?", sub: "both are 1 : 2", value: "x = 0"),
               InfoRow(title: "Solve the other one", sub: "3y = 12, so y = 4", value: "y = 4")],
        sutra: "Anurupye Shunyamanyat: if one is in ratio, the other is zero",
        steps: steps,
        practice: [Problem(n: "3.2.10", m: "7.4.20"), Problem(n: "2.5.8", m: "6.7.24"), Problem(n: "3.4.18", m: "5.8.24"),
                   Problem(n: "5.3.12", m: "2.9.36"), Problem(n: "2.6.18", m: "5.9.27")],
        random: randomP,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { _ in "**Ratios** solve these in one look." }
    )
}
