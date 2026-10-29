import SwiftUI

/// Advanced: Gunita Samuccayah. The digit sum of a product equals the product of the digit sums,
/// so a mismatch always exposes a wrong answer.
enum DigitSumCheckLesson {
    private static let BLUE = Theme.blue, OR = Theme.orange, GR = Theme.green, MU = Theme.muted, INK = Theme.ink
    private static let EY = 250.0, EZ = 62.0, BY = 530.0
    private static let ORDER = ["N", "M", "E", "P"]

    // MARK: maths

    private static func dsum(_ n: Int) -> Int { String(n).reduce(0) { $0 + Int(String($1))! } }
    private static func ds(_ nIn: Int) -> Int { var n = abs(nIn); while n >= 10 { n = dsum(n) }; return n }

    struct DY {
        var n: String, m: String
        var N: Int, M: Int, P: Int
        var dN: Int, dM: Int, prod: Int, E: Int, dP: Int
        var ok: Bool, truth: Int, correct: Bool
        func v(_ k: String) -> Int { k == "N" ? dN : (k == "M" ? dM : (k == "E" ? E : dP)) }
    }

    static func yav(_ n: String, _ m: String) -> DY {
        let N = Int(n) ?? 23
        let parts = m.split(separator: "-").map { Int($0) ?? 0 }
        let M = parts.count > 0 ? parts[0] : 47, P = parts.count > 1 ? parts[1] : 1081
        let dN = ds(N), dM = ds(M), prod = dN * dM, E = ds(prod), dP = ds(P)
        return DY(n: n, m: m, N: N, M: M, P: P, dN: dN, dM: dM, prod: prod, E: E, dP: dP,
                  ok: E == dP, truth: N * M, correct: P == N * M)
    }

    private static func chainTok(_ expr: String, _ sum: Int) -> [String] {
        var T = [expr, "=", String(sum)]
        var v = sum
        while v >= 10 { v = dsum(v); T.append("\u{2192}"); T.append(String(v)) }
        return T
    }
    private static func digTok(_ n: Int) -> [String] {
        chainTok(String(n).map { String($0) }.joined(separator: "+"), dsum(n))
    }
    private static func pretty(_ n: Int) -> String {
        var p: [String] = []
        var v = n
        repeat {
            let d = String(v).map { String($0) }
            let t = dsum(v)
            p.append(d.joined(separator: " + ") + " = " + String(t))
            v = t
        } while v >= 10
        return p.joined(separator: ", then ")
    }
    private static func prettyMul(_ Y: DY) -> String {
        var p = ["\(Y.dN) \u{00D7} \(Y.dM) = \(Y.prod)"]
        if Y.prod >= 10 { p.append(pretty(Y.prod)) }
        return p.joined(separator: ", then ")
    }
    private static func opT(_ t: String) -> Bool { t.count == 1 && "+\u{00D7}=\u{2192}\u{00F7}\u{2260}".contains(t) }

    // MARK: scenes

    private struct Row { var xs: [Double]; var total: Double; var ids: [String]; var bx: [String: Double]; var by: Double }

    private static func eqRow(_ S: inout Scene, _ Y: DY, _ y: Double) -> Row {
        let q = S.seq([SeqItem("e0", String(Y.N)), SeqItem("e1", "\u{00D7}", op: true), SeqItem("e2", String(Y.M)),
                       SeqItem("e3", "=", op: true), SeqItem("e4", String(Y.P))], 512, y, EZ)
        return Row(xs: q.xs, total: q.total, ids: ["e0", "e1", "e2", "e3", "e4"],
                   bx: ["N": q.xs[0], "M": q.xs[2], "E": q.xs[3], "P": q.xs[4]], by: y + 90)
    }

    private static func holdBox(_ S: inout Scene, _ r: Row, _ Y: DY, _ k: String) {
        S.box("b" + k, r.bx[k]!, r.by, 80, 66, r: 18, shadow: true)
        S.el("v" + k, String(Y.v(k)), r.bx[k]!, r.by, z: 40, c: OR)
    }

    private static func stage(_ S: inout Scene, _ Y: DY, _ ph: Int, _ k: String) {
        let r = eqRow(&S, Y, EY)
        let idx = ORDER.firstIndex(of: k)!
        for q in ORDER[0..<idx] { holdBox(&S, r, Y, q) }
        let T: [String] = k == "E" ? chainTok("\(Y.dN)\u{00D7}\(Y.dM)", Y.prod) : digTok(k == "N" ? Y.N : (k == "M" ? Y.M : Y.P))
        let last = T.count - 1
        let items = T.enumerated().map { (i, t) in
            BubItem(i == last ? "v" + k : "c\(i)", t, op: opT(t), res: i == last, c: i == last ? OR : INK)
        }
        let b = S.bub(items, ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
        let src: [String] = k == "N" ? ["e0"] : (k == "M" ? ["e2"] : (k == "P" ? ["e4"] : ["bN", "vN", "bM", "vM"]))
        if k != "E" && ph < 3 { for i in src { S.mod(i, c: BLUE) } }
        let x = r.bx[k]!
        S.box("b" + k, x, r.by, 80, 66, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.9, r: 18, shadow: true)
        if ph == 0 { S.fa(src); S.h(src[0]) }
        if ph == 1 { S.fa(src); S.f("bub"); S.fa(b.rest); S.h("c1") }
        if ph == 2 { S.f("bub"); S.fa(b.res); S.h("v" + k) }
        if ph >= 1 && ph < 3 && k != "E" {
            S.arrow(0, (x, EY + 44), (b.xs[0] - 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: 0.25)
        }
        if ph >= 3 {
            S.mod("v" + k, x: x, y: r.by, o: 1, s: 40.0 / 52.0)
            for id in b.rest { S.mod(id, o: 0) }
            S.mod("bub", o: 0, s: 0.9)
            S.f("b" + k, "v" + k); S.h("v" + k)
        }
    }

    private static func compare(_ S: inout Scene, _ Y: DY, _ ph: Int) {
        let r = eqRow(&S, Y, EY)
        let col = Y.ok && Y.correct ? GR : OR
        for q in ORDER { holdBox(&S, r, Y, q) }
        let b = S.bub([BubItem("k0", String(Y.E), c: OR), BubItem("k1", Y.ok ? "=" : "\u{2260}", op: true, c: col),
                       BubItem("k2", String(Y.dP), c: OR)], ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, 1)
        let msg = !Y.ok ? "Mismatch: definitely wrong" : (Y.correct ? "Match: looks right" : "Match, but \(Y.P) is wrong")
        S.box("tag", 512, 170, max(320, Double(msg.count) * 15 + 60), 64, o: ph >= 2 ? 1 : 0, s: ph >= 2 ? 1 : 0.9,
              r: 22, shadow: true, q: msg, qz: 26, qc: col)
        S.el("hold", Y.ok ? "A match means probably right. Digit sums can miss some errors." : "A mismatch always means a mistake.",
             512, 640, z: 26, c: MU, w: 800, o: ph >= 3 ? 1 : 0)
        if ph >= 2 { S.mod("bE", c: col); S.mod("bP", c: col) }
        if ph >= 3 {
            for i in r.ids { S.mod(i, c: col) }
            if Y.ok && Y.correct { S.win = true }
        }
        if ph == 0 { S.f("bE", "vE", "bP", "vP"); S.h("vP") }
        if ph == 1 { S.f("bub"); S.fa(b.ids); S.h("k1") }
        if ph >= 2 { S.f("tag", "bE", "vE", "bP", "vP", "bub"); S.fa(b.ids); S.f("hold"); S.h("k2") }
        if ph >= 3 && Y.ok && Y.correct {
            S.f("tag", "bE", "vE", "bP", "vP", "bub"); S.fa(b.ids); S.f("hold"); S.fa(r.ids)
        }
    }

    private static func scene(_ d: StepDef, _ ph: Int) -> Scene {
        let Y = yav(d.n, d.m)
        var S = Scene("\(Y.n)x\(Y.m).")
        switch d.g {
        case "meet":
            let r = eqRow(&S, Y, EY)
            if ph == 0 { S.hide(r.ids) }
            if ph >= 2 { S.mod("e4", c: BLUE); S.f("e4"); S.h("e4") }
        case "dsN": stage(&S, Y, ph, "N")
        case "dsM": stage(&S, Y, ph, "M")
        case "mul": stage(&S, Y, ph, "E")
        case "dsP": stage(&S, Y, ph, "P")
        case "cmp": compare(&S, Y, ph)
        default: break
        }
        return S
    }

    private static func hl(_ g: String) -> Color { g == "cmp" ? BLUE : (g == "meet" ? BLUE : OR) }

    private static func summary(_ d: StepDef) -> Styled? {
        let Y = yav(d.n, d.m)
        switch d.g {
        case "dsN": return ("Sum of \(Y.N): \(Y.dN)", OR)
        case "dsM": return ("Sum of \(Y.M): \(Y.dM)", OR)
        case "mul": return ("Expected: \(Y.E)", OR)
        case "dsP": return ("Sum of \(Y.P): \(Y.dP)", OR)
        case "cmp": return ("Check: " + (Y.ok ? "Match" : "Mismatch"), BLUE)
        default: return nil
        }
    }

    private static func caption(_ d: StepDef) -> Styled {
        let Y = yav(d.n, d.m)
        var t = ""
        switch d.g {
        case "meet": t = "Is **\(Y.P)** the right answer to \(Y.N) \u{00D7} \(Y.M)? Check it without redoing the multiplication. **Watch this.**"
        case "dsN": t = "Add the digits of \(Y.N) until one digit is left. **\(pretty(Y.N))**."
        case "dsM": t = "Do the same for \(Y.M). **\(pretty(Y.M))**."
        case "mul": t = "Multiply the two digit sums. **\(prettyMul(Y))**. This is what the answer should reduce to."
        case "dsP": t = "Now the claimed answer, \(Y.P). **\(pretty(Y.P))**."
        case "cmp":
            if !Y.ok { t = "**\(Y.E)** and **\(Y.dP)** are different, so \(Y.P) is **definitely wrong**. Recheck the multiplication." }
            else if Y.correct { t = "**\(Y.E)** and **\(Y.dP)** match. The answer **\(Y.P)** looks right." }
            else { t = "**\(Y.E)** and **\(Y.dP)** match, but \(Y.P) is wrong. The real answer is **\(Y.truth)**. A match means probably right." }
        default: t = "Your turn."
        }
        return (t, hl(d.g))
    }

    // MARK: practice

    private static func tasks(_ p: Problem) -> [PTask] {
        let Y = yav(p.n, p.m)
        func dg(_ n: Int) -> [String] {
            String(n).enumerated().flatMap { (i, d) in i > 0 ? ["+", String(d)] : [String(d)] }
        }
        let close = "Close! Add the digits. If you get 10 or more, add again."
        return [
            PTask(g: "dsN", cap: "Find the digit sum of **\(Y.N)**. Keep adding until one digit is left.", q: "digit sum of \(Y.N)",
                  ans: String(Y.dN), ex: dg(Y.N), hint: close),
            PTask(g: "dsM", cap: "Now the digit sum of **\(Y.M)**.", q: "digit sum of \(Y.M)", ans: String(Y.dM), ex: dg(Y.M), hint: close),
            PTask(g: "mul", cap: "Multiply the two digit sums: **\(Y.dN) \u{00D7} \(Y.dM)**. Reduce it to one digit.", q: "\(Y.dN) \u{00D7} \(Y.dM) reduced",
                  ans: String(Y.E), ex: [String(Y.dN), "\u{00D7}", String(Y.dM)],
                  hint: "Close! Multiply, then add the digits of the result until one digit is left."),
            PTask(g: "dsP", cap: "Now the digit sum of the claimed answer, **\(Y.P)**.", q: "digit sum of \(Y.P)", ans: String(Y.dP), ex: dg(Y.P),
                  hint: "Close! Add all the digits. If you get 10 or more, add again."),
            PTask(g: "cmp", cap: "Compare **\(Y.E)** and **\(Y.dP)**. Type **1** if they match, **0** if they do not.", q: "\(Y.E) vs \(Y.dP)",
                  ans: Y.ok ? "1" : "0", ex: [String(Y.E), "vs", String(Y.dP)],
                  hint: "Close! 1 means the two digit sums are the same, 0 means they differ.",
                  ok: Y.ok ? "They match, so the answer looks right" : "They differ, so the answer is wrong"),
        ]
    }

    private static func practiceScene(_ p: Problem, _ t: Int, _ ok: Bool, _ done: Bool) -> Scene {
        let Y = yav(p.n, p.m)
        var S = Scene("\(Y.n)x\(Y.m).")
        let T = tasks(p)
        let tt = min(t, T.count - 1)
        let r = eqRow(&S, Y, 190)
        let fin = done || (ok && tt == T.count - 1)
        for q in ORDER[0..<(fin ? 4 : min(tt, 4))] {
            S.box("b" + q, r.bx[q]!, r.by, 80, 66, r: 18, shadow: true)
            S.el("v" + q, String(Y.v(q)), r.bx[q]!, r.by, z: 40, c: OR)
        }
        if fin {
            for i in r.ids { S.mod(i, c: Y.ok && Y.correct ? GR : OR) }
            if Y.ok && Y.correct { S.finale = SFinale(x: 512, y: 190, w: r.total + 120, h: 120) }
        } else {
            let ex = T[tt].ex
            let ids2 = ex.indices.map { "te\(tt)_\($0)" }
            let q = S.seq(ex.enumerated().map { SeqItem(ids2[$0.offset], $0.element, op: $0.offset == 1) }, 512, 400, 46)
            S.box("tb\(tt)", 512, 400, max(240, q.total + 90), 84, r: 26, shadow: true)
            let src: [String] = tt == 0 ? ["e0"] : (tt == 1 ? ["e2"] : (tt == 3 ? ["e4"] : []))
            for i in src { S.mod(i, c: BLUE) }
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
        let list: [(String, String, String, String)] = [
            ("meet", "23", "47-1081", "Meet the problem"), ("dsN", "23", "47-1081", "Digit sum of 23"),
            ("dsM", "23", "47-1081", "Digit sum of 47"), ("mul", "23", "47-1081", "Multiply the digit sums"),
            ("dsP", "23", "47-1081", "Digit sum of the answer"), ("cmp", "23", "47-1081", "Compare: a match"),
            ("meet", "23", "47-1071", "A wrong answer: 1071"), ("dsP", "23", "47-1071", "Digit sum of 1071"),
            ("cmp", "23", "47-1071", "Compare: a mismatch"),
            ("dsN", "138", "26-3588", "A bigger one: 138"), ("dsM", "138", "26-3588", "Digit sum of 26"),
            ("mul", "138", "26-3588", "Multiply the digit sums"), ("dsP", "138", "26-3588", "Digit sum of 3588"),
            ("cmp", "138", "26-3588", "Compare: a match"),
            ("dsP", "23", "47-1018", "A match is not proof"), ("cmp", "23", "47-1018", "Match, but wrong"),
            ("practice", "", "", "Your turn"),
        ]
        return list.map { g, n, m, name in
            let t = timing(g)
            return StepDef(g: g, n: n, m: m, name: name, times: t.0, end: t.1)
        }
    }()

    private static func randomP() -> Problem {
        let N = Bool.random() ? rnd(12, 99) : rnd(100, 399), M = rnd(12, 59), T = N * M
        var P = T
        if Bool.random() {
            var d = 0
            repeat { d = rnd(1, 30) * (Bool.random() ? -1 : 1) } while d % 9 == 0 || T + d <= 0
            P = T + d
        }
        return Problem(n: String(N), m: "\(M)-\(P)")
    }

    static let spec = LessonSpec(
        id: "dsc",
        topTitle: "Check with digit sums",
        cardTitle: "Check Products with Digit Sums",
        cardBlurb: "Not sure a multiplication is right? Add the digits of each number and compare. A mismatch always means a mistake.",
        rows: [
            InfoRow(title: "Digit sum of each number", sub: "23 \u{2192} 5 and 47 \u{2192} 2", value: "5, 2"),
            InfoRow(title: "Multiply the digit sums", sub: "5 \u{00D7} 2 = 10 \u{2192} 1", value: "1"),
            InfoRow(title: "Digit sum of the answer", sub: "1081 \u{2192} 1 \u{2192} compare with 1", value: "Match"),
        ],
        sutra: "Gunita Samuccayah: the product of the digit sums equals the digit sum of the product",
        steps: steps,
        practice: [Problem(n: "34", m: "26-884"), Problem(n: "52", m: "38-1966"), Problem(n: "67", m: "45-3015"),
                   Problem(n: "124", m: "36-4474"), Problem(n: "253", m: "47-11891")],
        random: randomP,
        stepScene: scene,
        caption: caption,
        summary: summary,
        tasks: tasks,
        practiceScene: practiceScene,
        doneCaption: { _ in "**Digit sums** are a quick check for any product." }
    )
}
