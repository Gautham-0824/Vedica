import SwiftUI

/// Basics: x9, x99, x999 (Ekanyunena Purvena).
extension BK {
    enum TimesNine {
        static let WY = 270.0, AY = 430.0, CY = 590.0

        struct Lay { var k: Int; var adv: Double; var sc: Double; var L: [Double]; var R: [Double]; var J: [Double] }

        static func layout(_ P: BP) -> Lay {
            let k = digs(P.n).count
            let adv = k >= 3 ? 54.0 : 60.0, sc = k >= 3 ? 0.88 : 1.0, G = 56.0, half = Double(k) * adv
            return Lay(k: k, adv: adv, sc: sc,
                       L: xsOf(k, 512 - G / 2 - half / 2, adv), R: xsOf(k, 512 + G / 2 + half / 2, adv),
                       J: xsOf(2 * k, 512, adv))
        }

        static func minus(_ S: inout Scene, _ P: BP, _ r: Row, _ on: Bool) {
            let last = r.nIds[r.nIds.count - 1], lx = S.e(last).x
            S.el("mn", MINUS + "1", lx + 36, WY - 130, z: 40, c: ORANGE, o: 0)
            S.el("nb", String(digs(P.n - 1).last ?? 0), lx, WY, c: ORANGE, o: 0, s: 0.6)
            if on {
                S.mod("mn", y: WY - 78, o: 1)
                S.mod(last, o: 0, s: 0.7, dl: 500)
                S.mod("nb", o: 1, s: 1, dl: 540)
            }
        }

        static func left(_ S: inout Scene, _ P: BP, _ r: Row, _ lay: Lay, _ on: Bool) -> [String] {
            let ld = digs(P.n - 1), last = ld.count - 1
            if on { S.mods(r.nIds + ["nb"], o: 0) }
            for (i, d) in ld.enumerated() {
                let src = S.e(i == last ? "nb" : r.nIds[min(i, r.nIds.count - 1)])
                S.el("L\(i)", String(d), on ? lay.L[i] : src.x, on ? AY : WY, o: on ? 1 : 0, s: on ? lay.sc : 1)
                S.box("rs\(i)", lay.R[i], AY, Double(Int((58 * lay.sc).rounded())), Double(Int((84 * lay.sc).rounded())),
                      o: on ? 1 : 0, r: 18, dashed: true, c: DASH, fill: .clear, q: "?")
            }
            return ld.indices.map { "L\($0)" }
        }

        static func base(_ S: inout Scene, _ P: BP) -> (r: Row, lay: Lay, Ls: [String]) {
            let r = work(&S, P, WY), lay = layout(P)
            minus(&S, P, r, true); S.mod("mn", o: 0)
            let Ls = left(&S, P, r, lay, true)
            return (r, lay, Ls)
        }

        static func partners(_ S: inout Scene, _ P: BP, _ lay: Lay, _ placed: Bool) -> [String] {
            digs(P.n - 1).enumerated().map { i, d in
                let id = "R\(i)"
                S.el(id, String(9 - d), lay.R[i], AY, z: 48, c: ORANGE, s: 2 * lay.sc)
                if placed { S.mod("rs\(i)", o: 0) }
                return id
            }
        }

        static func join(_ S: inout Scene, _ P: BP, _ lay: Lay, _ ids: [String], _ ph: Int) {
            if ph >= 1 {
                for (j, id) in ids.enumerated() { S.mod(id, x: lay.J[j]) }
                S.fa(ids)
            }
            if ph >= 2 {
                green(&S, ids)
                win(&S, 512, AY, Double(ids.count) * lay.adv + 110, 160)
            }
        }

        static let steps: [BStep] = [
            BStep(name: "Meet the problem", times: [0, 500, 1500], end: 2600, P: BP(n: 47, m: 99),
                  cap: { _ in "Times 99 sounds scary. **It is not.**" },
                  scene: { S, P, ph in meet(&S, P, ph) }),

            BStep(name: "Take 1 away", times: [0, 450, 1500, 2400], end: 3100, P: BP(n: 47, m: 99),
                  cap: { P in "Take 1 away from \(P.n). That is the first part: **\(P.n - 1)**." },
                  hl: ORANGE, sum: { P in ["\(P.n) \(MINUS) 1 = \(P.n - 1)"] },
                  scene: { S, P, ph in
                      let r = work(&S, P, WY), lay = layout(P)
                      let last = r.nIds[r.nIds.count - 1]
                      minus(&S, P, r, ph >= 2)
                      let Ls = left(&S, P, r, lay, ph >= 3)
                      if ph == 1 { S.mods(r.nIds, c: BLUE); S.fa(r.nIds); S.h(last) }
                      if ph == 2 { S.mods(r.nIds, c: BLUE); S.fa(r.nIds + ["nb", "mn"]); S.h("nb") }
                      if ph >= 3 {
                          S.mod("mn", o: 0)
                          S.fa(Ls + lay.R.indices.map { "rs\($0)" })
                          S.h(Ls[Ls.count - 1])
                      }
                  }),

            BStep(name: "Find the partners", times: [0, 450, 1450, 2450, 3400, 4400], end: 5200, P: BP(n: 47, m: 99),
                  cap: { P in
                      "Each digit needs a partner that makes 9. " + digs(P.n - 1).map { "**\($0) needs \(9 - $0).**" }.joined(separator: " ")
                  },
                  hl: ORANGE,
                  sum: { P in digs(P.n - 1).map { "9 \(MINUS) \($0) = \(9 - $0)" } },
                  scene: { S, P, ph in
                      let (_, lay, Ls) = base(&S, P)
                      for (i, d) in digs(P.n - 1).enumerated() {
                          let a = 1 + 2 * i, b = a + 1
                          if ph < a { continue }
                          let parts = ["c\(i)a", "c\(i)p", "R\(i)", "c\(i)e", "c\(i)n"]
                          S.box("cb\(i)", 512, CY, 300, 92, r: 28, shadow: true)
                          let xs = S.seq([SeqItem(parts[0], String(d)), SeqItem(parts[1], "+", op: true),
                                          SeqItem(parts[2], String(9 - d), c: ORANGE), SeqItem(parts[3], "=", op: true),
                                          SeqItem(parts[4], "9")], 512, CY, 48).xs
                          func arr(_ st: Int) {
                              S.arrow(i % 3, (lay.L[i], AY + 52), (xs[0] - 6, CY - 44), st: st, bend: 0.25)
                          }
                          if ph >= b { S.mod(parts[2], x: lay.R[i], y: AY, s: 2 * lay.sc); S.mod("rs\(i)", o: 0) }
                          if ph >= a + 2 {
                              S.mod("cb\(i)", o: 0, s: 0.9)
                              for j in [0, 1, 3, 4] { S.mod(parts[j], o: 0) }
                          }
                          if ph == a { S.mod(Ls[i], c: BLUE); S.fa([Ls[i], "cb\(i)"] + parts); arr(1); S.h(Ls[i]) }
                          if ph == b { S.fa([parts[2], Ls[i]]); arr(2); S.h(parts[2]) }
                      }
                  }),

            BStep(name: "Join them", times: [0, 500, 1600], end: 2700, P: BP(n: 47, m: 99),
                  cap: { P in "Put them side by side. **\(P.n * P.m)**." },
                  hl: GREEN, sum: { P in ["\(P.n) \(TIMES) \(P.m) = \(P.n * P.m)"] },
                  scene: { S, P, ph in
                      let (_, lay, Ls) = base(&S, P)
                      let Rs = partners(&S, P, lay, true)
                      join(&S, P, lay, Ls + Rs, ph)
                  }),

            BStep(name: "Bigger numbers", times: [0, 450, 1500, 2600, 3300], end: 3900, P: BP(n: 235, m: 999),
                  cap: { _ in "For 999 it is the same idea, with **three digits on each side**." },
                  sum: { P in [
                      "\(P.n) \(MINUS) 1 = \(P.n - 1)",
                      "Partners: " + digs(P.n - 1).map { String(9 - $0) }.joined(),
                      "Answer: \(P.n * P.m)"] },
                  scene: { S, P, ph in
                      let r = work(&S, P, WY), lay = layout(P)
                      if ph == 0 { S.hide(r.nIds + ["lbl"]) }
                      minus(&S, P, r, ph >= 1)
                      if ph == 1 { S.fa(r.nIds + ["nb", "mn"]); S.h("nb") }
                      let Ls = left(&S, P, r, lay, ph >= 2)
                      if ph >= 2 { S.mod("mn", o: 0); S.fa(Ls) }
                      var Rs: [String] = []
                      for (i, d) in digs(P.n - 1).enumerated() {
                          let id = "R\(i)", dl = Double(i) * 300
                          S.el(id, String(9 - d), lay.R[i], AY, z: 48, c: ORANGE, o: 0, s: 0.5)
                          if ph >= 3 {
                              S.mod(id, x: lay.R[i], o: 1, s: 2 * lay.sc, dl: dl)
                              S.mod("rs\(i)", o: 0, dl: dl + 400)
                              S.arrow(i, (lay.L[i], AY - 56), (lay.R[i], AY - 56), c: ORANGE,
                                      st: ph >= 4 ? 3 : 1, bend: -0.32, dl: dl)
                          }
                          Rs.append(id)
                      }
                      if ph == 3 { S.fa(Ls + Rs); S.h(Rs[min(2, Rs.count - 1)]) }
                      if ph >= 4 { join(&S, P, lay, Ls + Rs, 2) }
                  }),

            BStep(name: "Why it works", times: [0, 1300, 2700, 4100], end: 5200, P: BP(n: 47, m: 99),
                  cap: { _ in "99 is just 100 take away 1. So 47 \(TIMES) 99 is **4700 minus 47**. Same answer." },
                  hl: GREEN, sum: { P in ["\(P.n * (P.m + 1)) \(MINUS) \(P.n) = \(P.n * P.m)"] },
                  scene: { S, P, ph in
                      let lines = ["\(P.n) \(TIMES) \(P.m)", "\(P.n) \(TIMES) \(P.m + 1) \(MINUS) \(P.n)",
                                   "\(P.n * (P.m + 1)) \(MINUS) \(P.n)", "\(P.n * P.m)"]
                      for (i, t) in lines.enumerated() {
                          S.el("w\(i)", t, 512, 330 + (i < ph ? -44 : i > ph ? 44 : 0), z: 72, o: i == ph ? 1 : 0)
                      }
                      if ph == 3 {
                          S.mod("w3", c: GREEN)
                          S.finale = SFinale(x: 512, y: 330, w: 300, h: 150)
                          S.f("w3"); S.h("w3"); S.win = true
                      }
                  }),

            BStep(name: "Your turn", times: [0, 500], end: 700),
        ]

        static func hint(_ S: inout Scene, _ P: BP) -> [String] {
            let ld = digs(P.n - 1), xs = xsOf(ld.count, 512, 200)
            return ld.enumerated().map { i, d in
                let id = "hc\(i)"
                S.box(id, xs[i], 362, 180, 64, r: 20, shadow: true, q: "9 \(MINUS) \(d) = ?", qz: 26, qc: INK)
                return id
            }
        }

        static func pick(_ idx: [Int], _ P: BP, _ over: [Int: (inout BStep) -> Void] = [:]) -> [BStep] {
            idx.map { i in
                var s = steps[i]
                if s.P != nil { s.P = P }
                over[i]?(&s)
                return s
            }
        }

        static func dN(_ k: Int) -> Int { Int((0..<k).map { _ in String(rnd(1, 9)) }.joined()) ?? 2 }

        static let whyCap: (inout BStep) -> Void = { s in
            s.cap = { P in
                "\(P.m) is just \(P.m + 1) take away 1. So \(P.n) \(TIMES) \(P.m) is **\(P.n * (P.m + 1)) minus \(P.n)**. Same answer."
            }
        }

        static let lesson = BLesson(
            id: "x9", topic: "Times 9, 99, 999", sutra: "Ekanyunena Purvena: by one less than the previous one",
            infoTitle: "Multiplying by 9, 99 and 999", exQ: "47 \(TIMES) 99", exA: "4653",
            steps: steps, practice: [BP(n: 7, m: 9), BP(n: 36, m: 99), BP(n: 124, m: 999)],
            hintText: { _ in "Close! Take 1 away from the number first. That is the left part." }, hint: hint,
            replayFor: { P, _ in String(P.n).count >= 3 ? [4] : [1, 2, 3] },
            random: {
                let k = rnd(1, 3)
                while true {
                    let n = dN(k)
                    if n >= 2 { return BP(n: n, m: Int(pow(10.0, Double(k))) - 1) }
                }
            })

        static let m9: BLesson = {
            var L = lesson
            L.id = "m9"; L.topic = "Times 9"
            L.infoTitle = "Multiplying by 9"; L.exQ = "7 \(TIMES) 9"; L.exA = "63"
            L.steps = pick([0, 1, 2, 3, 5, 6], BP(n: 7, m: 9), [
                0: { $0.cap = { _ in "Times 9 sounds tricky. **It is not.**" } },
                2: { $0.times = [0, 450, 1450, 2200]; $0.end = 2800 },
                5: whyCap])
            L.practice = [BP(n: 4, m: 9), BP(n: 8, m: 9), BP(n: 6, m: 9)]
            L.replayFor = { _, _ in [1, 2, 3] }
            L.random = { BP(n: rnd(2, 9), m: 9) }
            return L
        }()

        static let m99: BLesson = {
            var L = lesson
            L.id = "m99"; L.topic = "Times 99"
            L.infoTitle = "Multiplying by 99"
            L.steps = pick([0, 1, 2, 3, 5, 6], BP(n: 47, m: 99))
            L.practice = [BP(n: 36, m: 99), BP(n: 58, m: 99), BP(n: 23, m: 99)]
            L.replayFor = { _, _ in [1, 2, 3] }
            L.random = { BP(n: dN(2), m: 99) }
            return L
        }()

        static let m999: BLesson = {
            var L = lesson
            L.id = "m999"; L.topic = "Times 999"
            L.infoTitle = "Multiplying by 999"; L.exQ = "235 \(TIMES) 999"; L.exA = "234765"
            L.steps = pick([0, 1, 4, 5, 6], BP(n: 235, m: 999), [
                0: { $0.cap = { _ in "Times 999 sounds scary. **It is not.**" } },
                5: whyCap])
            L.practice = [BP(n: 124, m: 999), BP(n: 356, m: 999), BP(n: 812, m: 999)]
            L.replayFor = { _, _ in [2] }
            L.random = { BP(n: dN(3), m: 999) }
            return L
        }()
    }
}
