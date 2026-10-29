import SwiftUI

/// Basics: squaring numbers ending in 5 (Ekadhikena Purvena).
extension BK {
    enum SquaresEndingIn5 {
        static func A(_ P: BP) -> Int { P.n / 10 }

        struct SB { var xs: [Double]; var pIds: [String]; var rest: [String] }
        struct SC { var xs: [Double]; var res: [String]; var rest: [String] }

        static func bubble(_ S: inout Scene, _ P: BP, _ boxO: Double, _ txtO: Double, _ resO: Double) -> SB {
            let a = A(P), b = a + 1
            S.box("bub", 512, BY, 330, 104, o: boxO, r: 28, shadow: true)
            let pd = digs(a * b)
            let pI = pd.enumerated().map { i, d in SeqItem("p\(i)", String(d), c: ORANGE, g: i < pd.count - 1 ? 0 : nil) }
            let xs = kseq(&S, [SeqItem("ba", String(a)), SeqItem("bx", TIMES, op: true), SeqItem("bb", String(b)),
                               SeqItem("be", "=", op: true)] + pI, 512, BY, 52, o: txtO)
            S.mods(pI.map { $0.id }, o: resO)
            return SB(xs: xs, pIds: pI.map { $0.id }, rest: ["ba", "bx", "bb", "be"])
        }

        static func place(_ S: inout Scene, _ P: BP, _ ph: Int) -> (ids: [String], pIds: [String], w: Double) {
            let r = work(&S, P, RY)
            let bb = bubble(&S, P, 1, 1, 1)
            S.mod(r.nIds[0], c: BLUE); S.mod(r.nIds[1], o: 0.25)
            let J = xsOf(String(P.n * P.n).count, 512, 60), pl = bb.pIds.count
            S.el("t2", "2", J[pl], RY, c: ORANGE, o: 0, s: 0.6)
            if ph >= 1 {
                for (i, id) in bb.pIds.enumerated() { S.mod(id, x: J[i], y: RY, s: Z / 52) }
                S.mod("bub", o: 0, s: 0.9)
                S.mods(bb.rest, o: 0)
                S.mod(r.nIds[0], o: 0)
                S.fa(bb.pIds); S.h(bb.pIds[pl - 1])
            }
            if ph >= 2 {
                S.mod("t2", o: 1, s: 1)
                S.mod(r.nIds[1], x: J[pl + 1], o: 1, c: ORANGE)
                S.fa(["t2", r.nIds[1]]); S.h("t2")
            }
            return (bb.pIds + ["t2", r.nIds[1]], bb.pIds, Double(J.count) * 60 + 110)
        }

        static func succ(_ S: inout Scene, _ P: BP, _ boxO: Double, _ txtO: Double, _ resO: Double) -> SC {
            let a = A(P)
            S.box("sbub", 512, BY, 330, 104, o: boxO, r: 28, shadow: true)
            let rd = digs(a + 1)
            let rI = rd.enumerated().map { i, d in SeqItem("sr\(i)", String(d), c: ORANGE, g: i < rd.count - 1 ? 0 : nil) }
            let xs = kseq(&S, [SeqItem("sa", String(a)), SeqItem("sp", "+", op: true), SeqItem("s1", "1"),
                               SeqItem("se", "=", op: true)] + rI, 512, BY, 52, o: txtO)
            S.mods(rI.map { $0.id }, o: resO)
            return SC(xs: xs, res: rI.map { $0.id }, rest: ["sa", "sp", "s1", "se"])
        }

        static let steps: [BStep] = [
            BStep(name: "Meet the problem", times: [0, 500, 1500], end: 2600, P: BP(n: 35, m: 35),
                  cap: { _ in "Squaring means a number times itself. **Watch this.**" },
                  scene: { S, P, ph in meet(&S, P, ph) }),

            BStep(name: "Look in front of the 5", times: [0, 450, 1400], end: 2300, P: BP(n: 35, m: 35),
                  cap: { P in "Leave the 5 for a moment. Look at the digit in front: **\(A(P))**." },
                  sum: { P in ["In front: \(A(P))"] },
                  scene: { S, P, ph in
                      let r = work(&S, P, RY)
                      if ph >= 1 { S.mod(r.nIds[0], c: BLUE); S.f(r.nIds[0]); S.h(r.nIds[0]) }
                      if ph >= 2 { S.mod(r.nIds[1], o: 0.25) }
                  }),

            BStep(name: "Find the successor", times: [0, 450, 1400, 2300], end: 3000, P: BP(n: 35, m: 35),
                  cap: { P in let a = A(P); return "Find its successor, the number just after it. Add 1: **\(a) + 1 = \(a + 1)**." },
                  hl: ORANGE, sum: { P in ["\(A(P)) + 1 = \(A(P) + 1)"] },
                  scene: { S, P, ph in
                      let r = work(&S, P, RY)
                      S.mod(r.nIds[0], c: BLUE); S.mod(r.nIds[1], o: 0.25)
                      let sb = succ(&S, P, ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 2 ? 1 : 0)
                      if ph >= 1 {
                          S.arrow(0, (S.e(r.nIds[0]).x, RY + 52), (sb.xs[0] - 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: 0.25)
                      }
                      if ph == 1 { S.fa([r.nIds[0], "sbub"] + sb.rest); S.h("s1") }
                      if ph >= 2 { S.fa(["sbub"] + sb.res); S.h(sb.res[sb.res.count - 1]) }
                  }),

            BStep(name: "Multiply them together", times: [0, 500, 1500, 2500], end: 3300, P: BP(n: 35, m: 35),
                  cap: { P in
                      let a = A(P)
                      return "Now multiply the number by its successor. **\(a) \(TIMES) \(a + 1) = \(a * (a + 1))**."
                  },
                  hl: ORANGE, sum: { P in let a = A(P); return ["\(a) \(TIMES) \(a + 1) = \(a * (a + 1))"] },
                  scene: { S, P, ph in
                      let r = work(&S, P, RY)
                      S.mod(r.nIds[0], c: BLUE); S.mod(r.nIds[1], o: 0.25)
                      let off: Double = ph >= 1 ? 0 : 1
                      let sb = succ(&S, P, off, off, off)
                      let bb = bubble(&S, P, ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph >= 3 ? 1 : 0)
                      S.mod("bb", c: ORANGE)
                      if ph == 0 { S.fa(["sbub"] + sb.res); S.h(sb.res[sb.res.count - 1]) }
                      if ph >= 2 {
                          S.arrow(0, (S.e(r.nIds[0]).x, RY + 52), (bb.xs[0] - 6, BY - 62), st: ph >= 3 ? 2 : 1, bend: 0.25)
                      }
                      if ph == 1 || ph == 2 { S.fa(["bub"] + bb.rest); S.h(ph == 1 ? "bb" : "ba") }
                      if ph >= 3 { S.fa(["bub"] + bb.pIds); S.h(bb.pIds[bb.pIds.count - 1]) }
                  }),

            BStep(name: "Bring it up", times: [0, 600], end: 1900, P: BP(n: 35, m: 35),
                  cap: { P in
                      let a = A(P)
                      return "Carry the **\(a * (a + 1))** up to the front. That is the first part of the answer."
                  },
                  hl: ORANGE, sum: { P in let a = A(P); return ["Front: \(a * (a + 1)) _ _"] },
                  scene: { S, P, ph in
                      let f = place(&S, P, ph)
                      if ph == 0 { S.fa(["bub"] + f.pIds); S.h(f.pIds[f.pIds.count - 1]) }
                  }),

            BStep(name: "Write 25 on the end", times: [0, 500, 1500, 2600], end: 3400, P: BP(n: 35, m: 35),
                  cap: { _ in "Now the last digit. **5 \(TIMES) 5 = 25**, so write 25 on the end." },
                  hl: ORANGE, sum: { _ in ["5 \(TIMES) 5 = 25"] },
                  scene: { S, P, ph in
                      _ = place(&S, P, ph >= 3 ? 2 : 1)
                      let five = S.e("n1")
                      let showBub = ph >= 1 && ph < 3
                      S.box("fbub", 512, BY, 330, 104, o: showBub ? 1 : 0, s: ph >= 3 ? 0.9 : 1, r: 28, shadow: true)
                      let xs = kseq(&S, [SeqItem("fa", "5"), SeqItem("fx", TIMES, op: true), SeqItem("fb", "5"),
                                         SeqItem("fe", "=", op: true), SeqItem("f0", "2", c: ORANGE, g: 0),
                                         SeqItem("f1", "5", c: ORANGE)], 512, BY, 52, o: showBub ? 1 : 0)
                      S.mods(["f0", "f1"], o: ph == 2 ? 1 : 0)
                      if showBub {
                          S.mod("n1", o: 1, c: BLUE)
                          S.arrow(0, (five.x, RY + 52), (xs[0] - 6, BY - 62), st: ph >= 2 ? 2 : 1, bend: -0.25)
                      }
                      if ph == 1 { S.fa(["n1", "fbub", "fa", "fx", "fb", "fe"]); S.h("fb") }
                      if ph == 2 { S.fa(["fbub", "f0", "f1"]); S.h("f1") }
                      if ph >= 3 { S.fa(["t2", "n1"]); S.h("t2") }
                  }),

            BStep(name: "Read the answer", times: [0, 500], end: 1700, P: BP(n: 35, m: 35),
                  cap: { P in "That is the whole trick. \(P.n) \(TIMES) \(P.n) = **\(P.n * P.n)**." },
                  hl: GREEN, sum: { P in ["\(P.n)\u{00B2} = \(P.n * P.n)"] },
                  scene: { S, P, ph in
                      let f = place(&S, P, 2)
                      if ph >= 1 {
                          green(&S, f.ids)
                          win(&S, 512, RY, f.w, 160)
                      } else { S.fa(f.ids) }
                  }),

            BStep(name: "Your turn", times: [0, 500], end: 700),
        ]

        /// The extra 95 x 95 steps are the originals replayed on a bigger example, a little slower.
        static var allSteps: [BStep] {
            func v(_ i: Int, _ f: Double, _ name: String, _ cap: @escaping (BP) -> String) -> BStep {
                var s = steps[i]
                s.P = BP(n: 95, m: 95)
                s.times = s.times.map { ($0 * f).rounded() }
                s.end = (s.end * f).rounded()
                s.name = name; s.cap = cap
                return s
            }
            var out = steps
            let extra: [BStep] = [
                v(1, 1.5, "A bigger one: 95") { _ in "Now a bigger one: **95 \(TIMES) 95**. Leave the 5. The digit in front is **9**." },
                v(2, 1.6, "Successor of 9") { _ in "The successor of 9 is the number right after it. **9 + 1 = 10**." },
                v(3, 1.6, "Multiply 9 \(TIMES) 10") { _ in "Multiply 9 by its successor, 10. **9 \(TIMES) 10 = 90**." },
                v(4, 1.6, "Bring the 90 up") { _ in "Carry the whole **90** up to the front. Both digits, 9 and 0, come with it." },
                v(5, 1.5, "5 \(TIMES) 5 on the end") { _ in "The last digit is still 5. **5 \(TIMES) 5 = 25**. Write 25 on the end." },
                v(6, 1.5, "Read the answer") { _ in "So **95 \(TIMES) 95 = 9025**. The same trick works, even when the successor is 10." },
            ]
            out.insert(contentsOf: extra, at: out.count - 1)
            return out
        }

        static func tasks(_ P: BP) -> [BTask] {
            let a = A(P)
            return [
                BTask(cap: "Your turn. What is the successor of **\(a)**?", q: "\(a) + 1", ans: a + 1, ex: [String(a), "+", "1"], d: 0),
                BTask(cap: "Now multiply them together: **\(a) \(TIMES) \(a + 1)**.", q: "\(a) \(TIMES) \(a + 1)", ans: a * (a + 1),
                      ex: [String(a), TIMES, String(a + 1)], d: 0),
                BTask(cap: "The last digit is 5. What is **5 \(TIMES) 5**?", q: "5 \(TIMES) 5", ans: 25, ex: ["5", TIMES, "5"], d: 1),
                BTask(cap: "Put it together. What is **\(P.n) \(TIMES) \(P.n)**?", q: "\(P.n) \(TIMES) \(P.n)", ans: P.n * P.n),
            ]
        }

        static func taskScene(_ S: inout Scene, _ P: BP, _ t: Int) {
            let T = tasks(P)[t]
            guard let ex = T.ex else { return }
            S.mod("n\(T.d)", c: BLUE)
            S.box("tb\(t)", 512, 368, 280, 84, r: 26, shadow: true)
            let items = ex.enumerated().map { i, x in
                SeqItem("te\(t)_\(i)", x, op: i == 1, c: i == 2 && t == 1 ? ORANGE : INK)
            }
            S.seq(items, 512, 368, 46)
            S.fa(["n\(T.d)", "tb\(t)"] + items.map { $0.id })
        }

        static func hint(_ S: inout Scene, _ P: BP) -> [String] {
            let a = A(P)
            S.box("hc0", 412, 362, 200, 64, r: 20, shadow: true, q: "\(a) \(TIMES) \(a + 1) = ?", qz: 26, qc: INK)
            S.box("hc1", 632, 362, 140, 64, r: 20, shadow: true, q: "then 25", qz: 26, qc: ORANGE)
            return ["hc0", "hc1"]
        }

        static var lesson: BLesson {
            BLesson(
                id: "sq5", topic: "Squares ending in 5", sutra: "Ekadhikena Purvena: by one more than the previous one",
                infoTitle: "Squaring Numbers Ending in 5", exQ: "35\u{00B2}", exA: "1225",
                steps: allSteps, practice: [BP(n: 25, m: 25), BP(n: 65, m: 65)],
                hintText: { _ in "Close! Add 1 to the front digit, multiply the two, then write 25." },
                hint: hint, tasks: tasks, taskScene: taskScene,
                taskHint: { _, t in
                    ["Close! The successor is the next number. Just add 1.",
                     "Close! Multiply the front digit by its successor.",
                     "Close! 5 \(TIMES) 5 is always the same.",
                     "Close! Write your first answer, then 25 on the end."][t]
                },
                replayFor: { _, t in t == 0 ? [2] : t == 1 ? [3] : t == 2 ? [5] : [2, 3, 4, 5] },
                random: { let n = rnd(1, 9) * 10 + 5; return BP(n: n, m: n) })
        }
    }
}
