import SwiftUI

/// Basics: recurring decimals, 1/19 by Ekadhikena Purvena.
extension BK {
    enum RecurringDecimals {
        struct G { var d: Int; var c: Int; var v: Int }

        static func gen(_ m: Int, _ n: Int) -> [G] {
            let e = (m + 1) / 10
            var out = [G(d: 1, c: 0, v: 1)]
            while out.count < n {
                let p = out[out.count - 1], v = p.d * e + p.c
                out.append(G(d: v % 10, c: v / 10, v: v))
            }
            return out
        }

        static let G19 = gen(19, 18)
        static let RCX = 620.0, RADV = 36.0, RAY = 420.0, RBY = 548.0
        static func rpos(_ i: Int) -> Double { RCX + (17 - Double(i) - 8.5) * RADV }
        static func ids(_ a: Int, _ b: Int) -> [String] { (a...b).map { "d\($0)" } }

        static func frac(_ S: inout Scene, _ big: Bool) -> [String] {
            let x = big ? 512.0 : 300.0, s = big ? 1.0 : 0.46
            let y0 = big ? 236.0 : 176.0, yb = big ? 304.0 : 207.0, y1 = big ? 372.0 : 238.0
            S.el("fn", "1", x, y0, s: s)
            S.box("fb", x, yb, 150, 8, s: s, r: 99, c: INK, fill: INK)
            S.el("fd0", "1", x - 29 * s, y1, s: s)
            S.el("fd1", "9", x + 29 * s, y1, s: s)
            return ["fn", "fd0", "fd1"]
        }

        static func top(_ S: inout Scene) {
            _ = frac(&S, false)
            S.el("mx", TIMES, 356, 207, z: 40, c: ORANGE, w: 700)
            S.el("er", "2", 386, 207, z: 52, c: ORANGE)
        }

        static func row(_ S: inout Scene, _ upto: Int, pre: Bool = false, pair: Bool = false,
                        noCarry: Bool = false, extra: [Int]? = nil) {
            S.el("pre", "0.", rpos(17) - 50, RAY, z: 46, o: upto >= 0 || pre ? 1 : 0)
            for i in 0..<18 {
                let on = i <= upto || (extra?.contains(i) ?? false)
                let from = pair && i >= 9 ? rpos(i - 9) : rpos(max(0, i - 1))
                S.el("d\(i)", String(G19[i].d), on ? rpos(i) : from,
                     on || !(pair && i >= 9) ? RAY : RAY - 70, z: 46, o: on ? 1 : 0, s: on ? 1 : 0.6)
                if G19[i].c != 0 && i < 9 {
                    S.el("c\(i)", String(G19[i].c), rpos(i) - 18, RAY + 40, z: 26, c: ORANGE, o: on && !noCarry ? 1 : 0)
                }
            }
        }

        static func bubble(_ S: inout Scene, _ lines: [(String, String)], _ cur: Int) {
            S.box("cb", RCX, RBY, 380, 96, o: cur != 0 ? 1 : 0, r: 28, shadow: true)
            for (j, l) in lines.enumerated() {
                S.el(l.0, l.1, RCX, RBY + (j + 1 < cur ? -26 : j + 1 > cur ? 26 : 0), z: 46, o: j + 1 == cur ? 1 : 0)
            }
        }

        static let steps: [BStep] = [
            BStep(name: "Meet the problem", times: [0, 500, 1500], end: 2600, P: BP(n: 1, m: 19),
                  cap: { _ in "Let\u{2019}s turn **1/19** into a decimal. Long division would take ages. **Watch this.**" },
                  scene: { S, P, ph in
                      let i = frac(&S, true)
                      if ph == 0 { S.hide(i); S.mod("fb", o: 0, s: 0.6) }
                      if ph >= 2 { S.mods(["fd0", "fd1"], c: BLUE); S.fa(["fd0", "fd1", "fb"]); S.h("fd1") }
                  }),

            BStep(name: "One more than the previous", times: [0, 450, 1400, 2400], end: 3200, P: BP(n: 1, m: 19),
                  cap: { _ in "Cover the 9 in 19. The digit left is **1**. Add one: **1 + 1 = 2**. We will multiply by 2." },
                  hl: ORANGE, sum: { _ in ["Multiplier: 2"] },
                  scene: { S, P, ph in
                      _ = frac(&S, true)
                      S.box("eb", 512, RBY, 300, 96, o: ph >= 2 ? 1 : 0, r: 28, shadow: true)
                      let ids = ["ea", "ep", "e1", "ee", "er"]
                      let xs = kseq(&S, [SeqItem("ea", "1"), SeqItem("ep", "+", op: true), SeqItem("e1", "1"),
                                         SeqItem("ee", "=", op: true), SeqItem("er", "2", c: ORANGE)],
                                    512, RBY, 52, o: ph >= 2 ? 1 : 0)
                      S.mod("er", o: ph >= 3 ? 1 : 0)
                      if ph >= 1 { S.mod("fd1", o: 0.25); S.mod("fd0", c: BLUE) }
                      if ph == 1 { S.f("fd0"); S.h("fd0") }
                      if ph >= 2 { S.arrow(0, (S.e("fd0").x, 372 + 54), (xs[0] - 6, RBY - 56), st: ph >= 3 ? 2 : 1, bend: 0.25) }
                      if ph == 2 { S.fa(["fd0", "eb"] + Array(ids[0..<4])); S.h(ids[2]) }
                      if ph >= 3 { S.fa(["eb", ids[4]]); S.h(ids[4]) }
                  }),

            BStep(name: "Start from the right", times: [0, 700, 2000, 3300, 4600], end: 5600, P: BP(n: 1, m: 19),
                  cap: { _ in "Write **1** at the far right. Multiply it by 2 and write the answer to its left. Keep going." },
                  sum: { _ in ["1 \u{2192} 2 \u{2192} 4 \u{2192} 8"] },
                  scene: { S, P, ph in
                      top(&S)
                      let up = max(-1, ph - 1)
                      row(&S, up)
                      bubble(&S, [("db1", "1 \(TIMES) 2 = 2"), ("db2", "2 \(TIMES) 2 = 4"), ("db3", "4 \(TIMES) 2 = 8")], ph >= 2 ? ph - 1 : 0)
                      S.el("dir", "\u{2190} work right to left", rpos(4), RAY - 68, z: 22, c: MUTE, w: 700, o: ph >= 1 ? 1 : 0)
                      if ph == 0 { S.fa(["mx", "er"]); S.h("er") }
                      if ph == 1 { S.mod("d0", c: BLUE); S.fa(["d0", "dir"]); S.h("d0") }
                      if ph >= 2 {
                          S.mod("d\(up)", c: BLUE)
                          S.fa(["d\(up)", "d\(up - 1)", "cb", "db\(ph - 1)", "dir"]); S.h("d\(up)")
                      }
                  }),

            BStep(name: "Carry the tens", times: [0, 700, 2300, 3900, 5500, 7100, 8700, 10300, 11900], end: 13000,
                  P: BP(n: 1, m: 19),
                  cap: { _ in "Two digits? Write the right one and **carry** the left one. Add the carry **after** the next multiply." },
                  hl: ORANGE,
                  sum: { _ in ["8 \(TIMES) 2 = 16", "6 \(TIMES) 2 + 1 = 13", "3 \(TIMES) 2 + 1 = 7"] },
                  scene: { S, P, ph in
                      top(&S)
                      let up = [3, 3, 4, 4, 4, 5, 5, 5, 6][ph], cur = [0, 1, 1, 2, 3, 3, 4, 5, 5][ph]
                      row(&S, up)
                      bubble(&S, [("k1", "8 \(TIMES) 2 = 16"), ("k2", "6 \(TIMES) 2 = 12"), ("k3", "12 + 1 = 13"),
                                  ("k4", "3 \(TIMES) 2 = 6"), ("k5", "6 + 1 = 7")], cur)
                      if ph >= 5 { S.mod("c4", o: 0.3) }
                      if ph >= 8 { S.mod("c5", o: 0.3) }
                      let B = ["cb", "k\(cur)"]
                      switch ph {
                      case 0: S.fa(ids(0, 3)); S.h("d3")
                      case 1: S.mod("d3", c: BLUE); S.fa(["d3"] + B); S.h("k1")
                      case 2: S.mod("d4", c: BLUE); S.fa(["d4", "c4"] + B); S.h("c4")
                      case 3: S.mod("d4", c: BLUE); S.fa(["d4"] + B); S.h("d4")
                      case 4: S.fa(["c4"] + B); S.h("c4")
                      case 5: S.mod("d5", c: BLUE); S.fa(["d5", "c5"] + B); S.h("d5")
                      case 6: S.mod("d5", c: BLUE); S.fa(["d5"] + B); S.h("d5")
                      case 7: S.fa(["c5"] + B); S.h("c5")
                      default: S.mod("d6", c: BLUE); S.fa(["d6"] + B); S.h("d6")
                      }
                  }),

            BStep(name: "The pattern", times: [0, 900, 3000, 5100, 7200], end: 9000, P: BP(n: 1, m: 19),
                  cap: { _ in "Every digit follows the **same 3 moves**. Learn these and you can do the rest." },
                  sum: { _ in ["\(TIMES) 2, add, carry"] },
                  scene: { S, P, ph in
                      top(&S); row(&S, 6)
                      S.mods(["c4", "c5"], o: 0.3)
                      S.box("pc", RCX, 552, 470, 172, o: ph >= 1 ? 1 : 0, s: ph >= 1 ? 1 : 0.94, r: 28, shadow: true)
                      let L = ["1.  Multiply the last digit by 2", "2.  Add the carry, if there is one",
                               "3.  Write the ones, carry the tens"]
                      for (i, t) in L.enumerated() {
                          S.el("pl\(i)", t, RCX, 500 + Double(i) * 52, z: 25, c: ph == i + 2 ? BLUE : INK, w: 800, o: ph >= i + 2 ? 1 : 0)
                      }
                      if ph == 0 { S.fa(ids(0, 6)); S.h("d6") }
                      if ph == 1 { S.f("pc"); S.hand = nil }
                      if ph >= 2 && ph <= 4 {
                          S.fa(["pc"] + (0..<(ph - 1)).map { "pl\($0)" })
                          S.hp(RCX + 200, 500 + Double(ph - 2) * 52 + 12)
                      }
                      if ph >= 5 { S.fa(["pc", "pl0", "pl1", "pl2"]); S.hand = nil }
                  }),

            BStep(name: "Halfway there", times: [0, 900, 3100, 5300, 7500, 9700, 11900], end: 13400, P: BP(n: 1, m: 19),
                  cap: { _ in "Now use the 3 moves. 7 \(TIMES) 2 = **14**: write 4, carry 1. 4 \(TIMES) 2 = 8, add the carry: **9**." },
                  sum: { _ in ["7 \(TIMES) 2 = 14", "4 \(TIMES) 2 + 1 = 9"] },
                  scene: { S, P, ph in
                      top(&S)
                      let up = [6, 6, 7, 7, 7, 8, 8][ph], cur = [0, 1, 1, 2, 3, 3, 0][ph]
                      row(&S, up)
                      S.mods(["c4", "c5"], o: 0.3)
                      if ph >= 5 { S.mod("c7", o: 0.3) }
                      bubble(&S, [("h1", "7 \(TIMES) 2 = 14"), ("h2", "4 \(TIMES) 2 = 8"), ("h3", "8 + 1 = 9")], cur)
                      S.el("hl", "first 9 digits", (rpos(0) + rpos(8)) / 2, RAY - 68, z: 24, c: BLUE, w: 800, o: ph >= 6 ? 1 : 0)
                      let B = ["cb", "h\(cur)"]
                      switch ph {
                      case 0: S.fa(ids(0, 6)); S.h("d6")
                      case 1: S.mod("d6", c: BLUE); S.fa(["d6"] + B); S.h("h1")
                      case 2: S.mod("d7", c: BLUE); S.fa(["d7", "c7"] + B); S.h("c7")
                      case 3: S.mod("d7", c: BLUE); S.fa(["d7"] + B); S.h("d7")
                      case 4: S.fa(["c7"] + B); S.h("c7")
                      case 5: S.mod("d8", c: BLUE); S.fa(["d8"] + B); S.h("d8")
                      default: S.mods(ids(0, 8), c: BLUE); S.fa(ids(0, 8) + ["hl"]); S.h("d8")
                      }
                  }),

            BStep(name: "The other half", times: [0, 1000, 3200, 5600, 8000, 10400], end: 12600, P: BP(n: 1, m: 19),
                  cap: { _ in "Shortcut! For the other half, each digit is **9 minus** its partner 9 places to the right." },
                  hl: ORANGE, sum: { _ in ["Partners make 9"] },
                  scene: { S, P, ph in
                      top(&S)
                      let extra: [Int]? = ph >= 5 ? nil : ph == 4 ? [15, 16, 17] : ph == 3 ? [16, 17] : ph == 2 ? [17] : []
                      row(&S, extra != nil ? 8 : 17, pair: true, noCarry: ph >= 2, extra: extra)
                      for j in 0..<9 {
                          let i = 17 - j, filled = extra == nil || extra!.contains(i)
                          S.box("s\(j)", rpos(i), RAY, 30, 52, o: ph >= 1 && !filled ? 1 : 0, r: 10, dashed: true,
                                c: DASH, fill: .clear, dl: ph >= 5 ? Double(8 - j) * 260 : 0)
                      }
                      for i in 9..<18 { S.mod("d\(i)", c: ORANGE, dl: ph >= 5 ? Double(14 - i) * 260 : 0) }
                      bubble(&S, [("ch1", "9 \(MINUS) 9 = 0"), ("ch2", "9 \(MINUS) 4 = 5"), ("ch3", "9 \(MINUS) 7 = 2")],
                             ph >= 2 && ph <= 4 ? ph - 1 : 0)
                      if ph >= 2 { S.arrow(0, (rpos(8), RAY - 36), (rpos(17), RAY - 36), c: ORANGE, st: ph == 2 ? 1 : 3, bend: 0.3) }
                      if ph >= 3 { S.arrow(1, (rpos(7), RAY - 36), (rpos(16), RAY - 36), c: ORANGE, st: ph == 3 ? 1 : 3, bend: 0.3) }
                      if ph >= 4 { S.arrow(2, (rpos(6), RAY - 36), (rpos(15), RAY - 36), c: ORANGE, st: ph == 4 ? 1 : 3, bend: 0.3) }
                      if ph <= 1 { S.mods(ids(0, 8), c: BLUE) }
                      switch ph {
                      case 0: S.fa(ids(0, 8)); S.h("d8")
                      case 1: S.fa(ids(0, 8) + (0..<9).map { "s\($0)" }); S.hp(rpos(17), RAY + 40)
                      case 2: S.mod("d8", c: BLUE); S.fa(["d8", "d17", "cb", "ch1"]); S.h("d17")
                      case 3: S.mod("d7", c: BLUE); S.fa(["d7", "d16", "cb", "ch2"]); S.h("d16")
                      case 4: S.mod("d6", c: BLUE); S.fa(["d6", "d15", "cb", "ch3"]); S.h("d15")
                      default: S.fa(ids(0, 17)); S.h("d9")
                      }
                  }),

            BStep(name: "Read the answer", times: [0, 600], end: 1900, P: BP(n: 1, m: 19),
                  cap: { _ in "**1/19 = 0.052631578947368421**. After 18 digits, the pattern repeats forever." },
                  hl: GREEN, sum: { _ in ["Repeats every 18"] },
                  scene: { S, P, ph in
                      top(&S); row(&S, 17, noCarry: true)
                      S.box("bar", RCX, RAY - 38, 18 * RADV, 5, o: ph >= 1 ? 1 : 0, s: ph >= 1 ? 1 : 0.4, r: 99, c: GREEN, fill: GREEN)
                      if ph == 0 { S.fa(ids(0, 17) + ["pre"]) }
                      if ph >= 1 {
                          green(&S, ids(0, 17) + ["pre"])
                          S.finale = SFinale(x: 590, y: RAY, w: 760, h: 150); S.win = true
                      }
                  }),

            BStep(name: "Your turn", times: [0, 500], end: 700),
        ]

        static func tasks(_ P: BP) -> [BTask] {
            let m = P.m, a = (m - 9) / 10, e = a + 1, g = gen(m, 12)
            let i = (1..<g.count).first(where: { g[$0 - 1].c > 0 }) ?? 4
            let p = g[i - 1], q3 = "\(p.d) \(TIMES) \(e) + \(p.c)"
            return [
                BTask(cap: "Look at **1/\(m)**. What is one more than the digit before the 9?", q: "\(a) + 1", ans: e, ex: [String(a), "+", "1"]),
                BTask(cap: "Start with **1** on the right. Multiply by \(e). What comes next?", q: "1 \(TIMES) \(e)", ans: e, ex: ["1", TIMES, String(e)]),
                BTask(cap: "Keep going. What is **\(e) \(TIMES) \(e)**?", q: "\(e) \(TIMES) \(e)", ans: e * e, ex: [String(e), TIMES, String(e)]),
                BTask(cap: "\(g[i - 2].d) \(TIMES) \(e) = \(p.v): write \(p.d), carry \(p.c). Now what is **\(q3)**?",
                      q: q3, ans: g[i].v, ex: q3.components(separatedBy: " ")),
            ]
        }

        static func pscene(_ S: inout Scene, _ P: BP, _ t: Int, _ ok: Bool, _ done: Bool) {
            let T = tasks(P), dd = digs(P.m), e = String((P.m + 1) / 10)
            S.el("pn", "1", 512, 196, z: 64)
            S.box("pb", 512, 238, 104, 6, r: 99, c: INK, fill: INK)
            for (i, d) in dd.enumerated() { S.el("pd\(i)", String(d), 512 + (Double(i) - 0.5) * 40, 282, z: 64) }
            let ids = ["pn", "pd0", "pd1"]
            let fin = done || (ok && t == T.count - 1)
            if !fin {
                if t == 0 { S.mod("pd0", c: BLUE); S.mod("pd1", o: 0.3) }
                let X = T[t].ex ?? []
                S.box("tb\(t)", 512, 368, max(240, Double(X.count) * 50 + 60), 84, r: 26, shadow: true)
                let items = X.enumerated().map { j, x in
                    SeqItem("te\(t)_\(j)", x, op: x == TIMES || x == "+", c: t > 0 && x == e && j == 2 ? ORANGE : INK)
                }
                S.seq(items, 512, 368, 46)
                S.fa(ids + ["tb\(t)"] + items.map { $0.id })
            } else {
                green(&S, ids)
                S.mod("pb", c: GREEN, fill: GREEN)
                S.finale = SFinale(x: 512, y: 240, w: 210, h: 190)
            }
        }

        static let lesson = BLesson(
            id: "rd", topic: "Recurring decimals", sutra: "Ekadhikena Purvena: by one more than the previous one",
            infoTitle: "Recurring Decimals with 19", exQ: "1/19", exA: "0.0526\u{2026}",
            steps: steps, practice: [BP(n: 1, m: 29), BP(n: 1, m: 39)],
            hintText: { _ in "Close! Use the multiplier from the lesson." },
            tasks: tasks, pscene: pscene,
            taskHint: { _, t in
                ["Close! Drop the 9. Add 1 to the digit in front of it.",
                 "Close! Multiply the 1 by the multiplier.",
                 "Close! Multiply the last digit by the multiplier again.",
                 "Close! Multiply first, then add the carry."][t]
            },
            doneCap: { P in "**1/\(P.m)** works the same way. Same trick, every time." },
            replayFor: { _, t in t == 0 ? [1] : t < 3 ? [2] : [3, 4] },
            random: { BP(n: 1, m: [29, 39, 49, 59, 69, 79, 89].randomElement()!) })
    }
}
