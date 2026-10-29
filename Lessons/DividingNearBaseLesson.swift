import SwiftUI

/// Basics: dividing by numbers just below 100 (Nikhilam).
extension BK {
    enum DividingNearBase {
        static let DLX = [380.0, 440.0], DRX = [580.0, 640.0]
        static let DY1 = 330.0, DY2 = 410.0, DY3 = 500.0, DS = 0.75
        static let DIVIDE = "\u{00F7}"

        @discardableResult
        static func row(_ S: inout Scene, _ split: Bool, labels: Bool = false, ans: Bool = false) -> (L: [String], R: [String]) {
            S.seq(numItems("n", 1234) + [SeqItem("op", DIVIDE, op: true)] + numItems("m", 98), 512, 300, Z)
            S.el("lbl", "1234 \(DIVIDE) 98", 512, 168, z: 36, c: MUTE, w: 800, o: split ? 1 : 0)
            S.el("dd", "100 \(MINUS) 98 = 2", 512, 214, z: 30, c: ORANGE, w: 800, o: split ? 1 : 0)
            S.box("bar", 506, 415, 6, 230, o: split ? 1 : 0, s: split ? 1 : 0.5, r: 99, c: INK, fill: INK)
            S.el("ls", ans ? "quotient" : "left", 410, 262, z: 24, c: ans ? GREEN : MUTE, w: 800, o: labels ? 1 : 0)
            S.el("rs", ans ? "remainder" : "right", 610, 262, z: 24, c: ans ? GREEN : MUTE, w: 800, o: labels ? 1 : 0)
            if split {
                S.mods(["op", "m0", "m1"], o: 0, s: 0.6)
                for i in 0..<2 { S.mod("n\(i)", x: DLX[i], y: DY1, s: DS, c: BLUE) }
                for i in 2..<4 { S.mod("n\(i)", x: DRX[i - 2], y: DY1, s: DS) }
            }
            return (["n0", "n1"], ["n2", "n3"])
        }

        static func col(_ S: inout Scene, _ show24: Bool, _ show58: Bool) {
            S.el("pl", "+", 538, DY2, c: ORANGE, w: 700, o: show24 ? 1 : 0, s: DS)
            for (i, d) in ["2", "4"].enumerated() {
                S.el("t\(i)", d, show24 ? DRX[i] : 512 + (Double(i) - 0.5) * 34 + 90, show24 ? DY2 : 640,
                     c: ORANGE, o: show24 ? 1 : 0, s: DS)
            }
            S.box("ln", 600, 455, 150, 5, o: show58 ? 1 : 0, s: show58 ? 1 : 0.4, r: 99, c: INK, fill: INK)
            for (i, d) in ["5", "8"].enumerated() {
                S.el("r\(i)", d, DRX[i], show58 ? DY3 : DY3 - 30, o: show58 ? 1 : 0, s: DS)
            }
        }

        static let steps: [BStep] = [
            BStep(name: "Meet the problem", times: [0, 500, 1600], end: 2800, P: BP(n: 1234, m: 98),
                  cap: { _ in "Let\u{2019}s divide **1234 by 98**. Long division is slow. There is a faster way." },
                  scene: { S, P, ph in
                      row(&S, false)
                      if ph == 0 { S.hide(["n0", "n1", "n2", "n3", "op", "m0", "m1"]) }
                      if ph >= 2 { S.mods(["m0", "m1"], c: BLUE); S.fa(["m0", "m1"]); S.h("m1") }
                  }),

            BStep(name: "How far from 100?", times: [0, 700, 2100, 3500], end: 4600, P: BP(n: 1234, m: 98),
                  cap: { _ in "98 is very close to **100**. How far away is it? **100 \(MINUS) 98 = 2**." },
                  hl: ORANGE, sum: { _ in ["100 \(MINUS) 98 = 2"] },
                  scene: { S, P, ph in
                      row(&S, false)
                      S.box("db", 512, 470, 400, 100, o: ph >= 2 ? 1 : 0, s: ph >= 2 ? 1 : 0.94, r: 28, shadow: true)
                      let ids = ["e0", "e1", "e2", "e3", "e4"]
                      S.seq([SeqItem("e0", "100"), SeqItem("e1", MINUS, op: true), SeqItem("e2", "98", c: BLUE),
                             SeqItem("e3", "=", op: true), SeqItem("e4", "2", c: ORANGE)], 512, 470, 56)
                      S.mods(ids, o: ph >= 2 ? 1 : 0)
                      if ph < 3 { S.mods(["e3", "e4"], o: 0) }
                      if ph >= 1 { S.mods(["m0", "m1"], c: BLUE) }
                      if ph == 1 { S.fa(["m0", "m1"]); S.h("m1") }
                      if ph >= 2 {
                          S.arrow(0, (S.e("m0").x, 356), (S.e("e2").x, 414), st: ph >= 3 ? 2 : 1, bend: 0.25)
                      }
                      if ph == 2 { S.fa(["db"] + Array(ids[0..<3])); S.h("e2") }
                      if ph >= 3 { S.fa(["db"] + ids); S.h("e4") }
                  }),

            BStep(name: "Split the number", times: [0, 900, 2500], end: 3800, P: BP(n: 1234, m: 98),
                  cap: { _ in "100 has **two zeros**, so split off the **last two digits**: 12 | 34." },
                  sum: { _ in ["1234 \u{2192} 12 | 34"] },
                  scene: { S, P, ph in
                      let r = row(&S, ph >= 1, labels: ph >= 2)
                      if ph == 0 { S.fa(r.R); S.h("n3") }
                      if ph == 1 { S.fa(r.L + r.R + ["bar"]); S.h("bar") }
                      if ph >= 2 { S.fa(r.L + r.R + ["bar", "ls", "rs"]); S.hand = nil }
                  }),

            BStep(name: "Multiply the left", times: [0, 800, 2300, 3800], end: 5000, P: BP(n: 1234, m: 98),
                  cap: { _ in "Multiply the left side by the gap, **2**: **12 \(TIMES) 2 = 24**. Write it under the right side." },
                  hl: ORANGE, sum: { _ in ["12 \(TIMES) 2 = 24"] },
                  scene: { S, P, ph in
                      let r = row(&S, true, labels: true)
                      col(&S, ph >= 3, false)
                      S.box("mb", 512, 640, 330, 92, o: ph >= 1 ? 1 : 0, s: ph >= 1 ? 1 : 0.94, r: 28, shadow: true)
                      let ids = ["q0", "q1", "q2", "q3", "q4"]
                      kseq(&S, [SeqItem("q0", "12", c: BLUE), SeqItem("q1", TIMES, op: true), SeqItem("q2", "2", c: ORANGE),
                                SeqItem("q3", "=", op: true), SeqItem("q4", "24", c: ORANGE)], 512, 640, 50, o: ph >= 1 ? 1 : 0)
                      if ph < 2 { S.mods(["q3", "q4"], o: 0) }
                      if ph == 0 { S.fa(r.L + ["dd"]); S.h("n1") }
                      if ph == 1 { S.fa(r.L + ["mb"] + Array(ids[0..<3])); S.h("q2") }
                      if ph == 2 { S.fa(["mb"] + ids); S.h("q4") }
                      if ph >= 3 { S.fa(r.R + ["t0", "t1", "pl"]); S.h("t1") }
                  }),

            BStep(name: "Add to the right", times: [0, 800, 2300], end: 3600, P: BP(n: 1234, m: 98),
                  cap: { _ in "Now add on the right side: **34 + 24 = 58**." },
                  sum: { _ in ["34 + 24 = 58"] },
                  scene: { S, P, ph in
                      let r = row(&S, true, labels: true)
                      col(&S, true, ph >= 2)
                      if ph == 0 { S.fa(r.R + ["t0", "t1", "pl"]); S.h("n3") }
                      if ph == 1 { S.fa(r.R + ["t0", "t1", "pl", "ln"]); S.h("ln") }
                      if ph >= 2 {
                          S.mods(["r0", "r1"], c: BLUE)
                          S.fa(r.R + ["t0", "t1", "pl", "ln", "r0", "r1"]); S.h("r1")
                      }
                  }),

            BStep(name: "Read the answer", times: [0, 800, 2000], end: 3200, P: BP(n: 1234, m: 98),
                  cap: { _ in "The left is the **answer**, the right is the **remainder**: **1234 \(DIVIDE) 98 = 12 R 58**." },
                  hl: GREEN, sum: { _ in ["12 R 58"] },
                  scene: { S, P, ph in
                      let r = row(&S, true, labels: true, ans: ph >= 1)
                      col(&S, true, true)
                      if ph == 0 { S.fa(r.L + ["r0", "r1"]); S.h("n1") }
                      if ph >= 1 {
                          green(&S, r.L + ["r0", "r1"])
                          S.fa(r.L + ["r0", "r1", "ls", "rs"])
                      }
                      if ph >= 2 { S.finale = SFinale(x: 510, y: 390, w: 420, h: 330); S.win = true }
                  }),

            BStep(name: "Your turn", times: [0, 500], end: 700),
        ]

        static func tasks(_ P: BP) -> [BTask] {
            let d = 100 - P.m, L = P.n / 100, R = P.n % 100
            let Rs = R < 10 ? "0\(R)" : String(R)
            return [
                BTask(cap: "Divide **\(P.n) by \(P.m)**. How far is \(P.m) from 100?", q: "100 \(MINUS) \(P.m)", ans: d,
                      ex: ["100", MINUS, String(P.m)]),
                BTask(cap: "Split it: **\(L) | \(Rs)**. Multiply the left side by \(d).", q: "\(L) \(TIMES) \(d)", ans: L * d,
                      ex: [String(L), TIMES, String(d)]),
                BTask(cap: "Add that to the right side. This is the **remainder**.", q: "\(Rs) + \(L * d)", ans: R + L * d,
                      ex: [Rs, "+", String(L * d)]),
            ]
        }

        static func pscene(_ S: inout Scene, _ P: BP, _ t: Int, _ ok: Bool, _ done: Bool) {
            let T = tasks(P), L = P.n / 100, R = P.n % 100
            S.seq(numItems("pn", P.n) + [SeqItem("po", DIVIDE, op: true)] + numItems("pm", P.m), 512, 206, 64)
            let ids = digs(P.n).indices.map { "pn\($0)" } + ["po"] + digs(P.m).indices.map { "pm\($0)" }
            S.el("ps", "\(L) | \(R < 10 ? "0\(R)" : String(R))", 512, 276, z: 34, c: MUTE, w: 800, o: t >= 1 ? 1 : 0)
            let fin = done || (ok && t == T.count - 1)
            if !fin {
                if t == 0 { for i in digs(P.m).indices { S.mod("pm\(i)", c: BLUE) } }
                let X = T[t].ex ?? []
                S.box("tb\(t)", 512, 380, max(260, Double(X.count) * 56 + 70), 84, r: 26, shadow: true)
                let items = X.enumerated().map { j, x in
                    SeqItem("te\(t)_\(j)", x, op: x == TIMES || x == "+" || x == MINUS, c: t == 1 && j == 2 ? ORANGE : INK)
                }
                S.seq(items, 512, 380, 46)
                S.fa(ids + ["ps", "tb\(t)"] + items.map { $0.id })
            } else {
                S.el("pa", "\(L) R \(R + L * (100 - P.m))", 512, 380, z: 64, c: GREEN)
                green(&S, ids)
                S.fa(ids + ["pa"])
                S.finale = SFinale(x: 512, y: 290, w: 360, h: 260)
            }
        }

        static let lesson = BLesson(
            id: "dv", topic: "Dividing near a base", sutra: "Nikhilam: all from 9 and the last from 10",
            infoTitle: "Dividing by Numbers Near 100", exQ: "1234 \(DIVIDE) 98", exA: "12 R 58",
            steps: steps, practice: [BP(n: 1321, m: 98), BP(n: 2412, m: 97)],
            hintText: { _ in "Close! Use the gap from 100." },
            tasks: tasks, pscene: pscene,
            taskHint: { _, t in
                ["Close! Take the divisor away from 100.", "Close! Multiply the left side by the gap.",
                 "Close! Add your answer to the last two digits."][t]
            },
            doneCap: { P in
                let L = P.n / 100, r = P.n % 100 + L * (100 - P.m)
                return "**\(P.n) \(DIVIDE) \(P.m) = \(L) R \(r)**. Same trick, every time."
            },
            replayFor: { _, t in [[1], [3], [4]][t] },
            random: {
                while true {
                    let m = [97, 98, 99].randomElement()!, d = 100 - m
                    let L = 11 + Int.random(in: 0..<(80 / d - 10))
                    let maxR = min(99, m - 1 - L * d)
                    if maxR < 10 { continue }
                    let R = 10 + Int.random(in: 0..<(maxR - 9))
                    return BP(n: L * 100 + R, m: m)
                }
            })
    }
}
