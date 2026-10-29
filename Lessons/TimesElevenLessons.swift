import SwiftUI

/// Basics: x11 and x101 (Ekadhikena Purvena / Antyayor Dasakepi).
extension BK {
    enum TimesEleven {
        static let SPL = [416.0, 608.0]

        static func split(_ S: inout Scene, _ P: BP) -> Row {
            let r = work(&S, P, RY)
            for (i, id) in r.nIds.enumerated() { S.mod(id, x: SPL[i]) }
            S.box("gap", 512, RY, 86, 120, dashed: true, c: BLUE, fill: hexAlpha(0x0a84ff, 0.05))
            return r
        }

        struct Bub { var ids: [String]; var rest: [String]; var u: String; var t: String? }

        static func bubble(_ S: inout Scene, _ P: BP, _ boxO: Double, _ txtO: Double, _ dl: Double = 0) -> Bub {
            let d = digs(P.n), a = d[0], b = d[1], s = a + b
            S.box("bub", 512, BY, 330, 104, r: 28, shadow: true)
            S.mod("bub", o: boxO)
            let sd = digs(s)
            let sI: [SeqItem] = sd.enumerated().map { i, x in
                SeqItem(sd.count == 2 && i == 0 ? "t" : "u", String(x), c: ORANGE, g: i < sd.count - 1 ? 0 : nil)
            }
            kseq(&S, [SeqItem("ba", String(a)), SeqItem("bp", "+", op: true), SeqItem("bb", String(b)),
                      SeqItem("be", "=", op: true)] + sI, 512, BY, 52, o: txtO, dl: dl)
            return Bub(ids: ["ba", "bp", "bb", "be"] + sI.map { $0.id }, rest: ["ba", "bp", "bb", "be"],
                       u: "u", t: sd.count == 2 ? "t" : nil)
        }

        static func arrows(_ S: inout Scene, _ st: Int) {
            S.arrow(0, (SPL[0] + 8, RY + 60), (458, BY - 60), st: st, bend: 0.22)
            S.arrow(1, (SPL[1] - 8, RY + 60), (566, BY - 60), st: st, bend: -0.22)
        }

        static func drop(_ S: inout Scene, _ b: Bub) {
            S.mod(b.u, x: 512, y: RY, s: Z / 52, dl: 0)
            S.mod("bub", o: 0, s: 0.9)
            S.mods(b.rest, o: 0)
            S.mod("gap", o: 0, s: 1.1)
            for k in S.A.keys { S.A[k]?.st = 3 }
        }

        static let steps: [BStep] = [
            BStep(name: "Meet the problem", times: [0, 500, 1500], end: 2600, P: BP(n: 32, m: 11),
                  cap: { _ in "Times 11 looks like long work. **Watch this.**" },
                  scene: { S, P, ph in meet(&S, P, ph) }),

            BStep(name: "Split", times: [0, 450, 1500, 2300], end: 3000, P: BP(n: 32, m: 11),
                  cap: { _ in "Pull the digits apart. Leave a **gap in the middle**." },
                  sum: { P in let d = digs(P.n); return ["Split: \(d[0]) _ \(d[1])"] },
                  scene: { S, P, ph in
                      let r = split(&S, P)
                      S.box("gap", 512, RY, 86, 120, o: ph >= 3 ? 1 : 0, s: ph >= 3 ? 1 : 0.8, dashed: true,
                            c: BLUE, fill: hexAlpha(0x0a84ff, 0.05))
                      if ph >= 1 { S.fa(r.nIds); S.hp(512, RY + 44) }
                      if ph >= 3 { S.f("gap") }
                  }),

            BStep(name: "Add them", times: [0, 450, 1400, 2400], end: 3100, P: BP(n: 32, m: 11),
                  cap: { P in let d = digs(P.n); return "Add the two digits. **\(d[0]) + \(d[1]) = \(d[0] + d[1])**." },
                  sum: { P in let d = digs(P.n); return ["\(d[0]) + \(d[1]) = \(d[0] + d[1])"] },
                  scene: { S, P, ph in
                      let r = split(&S, P)
                      let b = bubble(&S, P, ph >= 2 ? 1 : 0, ph >= 3 ? 1 : 0)
                      if ph == 1 { S.mod(r.nIds[0], c: BLUE); S.fa([r.nIds[0], "gap"]); S.h(r.nIds[0]) }
                      if ph >= 2 {
                          S.mods(r.nIds, c: BLUE)
                          arrows(&S, ph >= 3 ? 2 : 1)
                          S.fa(r.nIds + ["gap", "bub"] + b.ids)
                          S.h(r.nIds[1])
                      }
                      if ph >= 3 { S.hp(512, BY + 46) }
                  }),

            BStep(name: "Drop it in", times: [0, 400, 1400, 2300], end: 3200, P: BP(n: 32, m: 11),
                  cap: { P in let d = digs(P.n); return "Drop the \((d[0] + d[1]) % 10) in the middle. **\(P.n * P.m)**." },
                  hl: GREEN, sum: { P in ["\(P.n) \(TIMES) \(P.m) = \(P.n * P.m)"] },
                  scene: { S, P, ph in
                      let r = split(&S, P)
                      let b = bubble(&S, P, 1, 1)
                      arrows(&S, 2)
                      S.fa([b.u, "gap"]); S.h(b.u)
                      if ph >= 1 { S.mod(b.u, y: BY - 64, s: 1.2) }
                      if ph >= 2 { drop(&S, b); S.fa(r.nIds) }
                      if ph >= 3 {
                          let xs = xsOf(3, 512, 60), ids = [r.nIds[0], b.u, r.nIds[1]]
                          for (i, id) in ids.enumerated() { S.mod(id, x: xs[i]) }
                          green(&S, ids)
                          win(&S, 512, RY, 300, 170)
                      }
                  }),

            BStep(name: "When it is 10 or more", times: [0, 450, 1500, 2500, 3400], end: 4200, P: BP(n: 78, m: 11),
                  cap: { P in "If the sum is 10 or more, carry the 1 to the left. **\(P.n * P.m)**." },
                  hl: GREEN,
                  sum: { P in let d = digs(P.n); return ["\(d[0]) + \(d[1]) = \(d[0] + d[1])", "Carry 1: \(P.n * P.m)"] },
                  scene: { S, P, ph in
                      let r: Row
                      if ph >= 1 { r = split(&S, P) } else { r = work(&S, P, RY) }
                      let a = digs(P.n)[0]
                      if ph == 0 { S.hide(r.nIds + ["lbl"]) }
                      S.el("nb", String(a + 1), SPL[0], RY, c: ORANGE, o: 0, s: 0.6)
                      let b = bubble(&S, P, ph >= 1 ? 1 : 0, ph >= 1 ? 1 : 0, ph == 1 ? 700 : 0)
                      let tId = b.t ?? "t"
                      if ph == 1 {
                          S.mods(r.nIds, c: BLUE); arrows(&S, 1)
                          S.fa(r.nIds + ["gap", "bub"] + b.ids); S.hp(512, BY + 46)
                      }
                      if ph >= 2 {
                          arrows(&S, 2)
                          S.mod(tId, x: SPL[0], y: RY, o: 0, s: 1.4, od: 640)
                          S.mod(r.nIds[0], o: 0, s: 0.7, dl: 600)
                          S.mod("nb", o: 1, s: 1, dl: 640)
                          S.fa([tId, r.nIds[0], "nb", b.u, "gap"]); S.h(r.nIds[0])
                      }
                      if ph >= 3 { drop(&S, b); S.fa(["nb", b.u, r.nIds[1]]); S.h(b.u) }
                      if ph >= 4 {
                          let xs = xsOf(3, 512, 60), ids = ["nb", b.u, r.nIds[1]]
                          for (i, id) in ids.enumerated() { S.mod(id, x: xs[i], dl: 0) }
                          S.mod(r.nIds[0], x: xs[0]); S.mod(tId, x: xs[0])
                          green(&S, ids)
                          win(&S, 512, RY, 300, 170)
                      }
                  }),

            BStep(name: "Times 101", times: [0, 450, 1500, 2400], end: 3200, P: BP(n: 32, m: 101),
                  cap: { P in "For 101, just write the number twice. **\(P.n * P.m)**." },
                  hl: GREEN, sum: { P in ["\(P.n) \(TIMES) \(P.m) = \(P.n * P.m)"] },
                  scene: { S, P, ph in
                      let r = work(&S, P, RY), nd = digs(P.n), x4 = xsOf(4, 512, 60)
                      let g = nd.indices.map { "g\($0)" }
                      if ph == 0 { S.hide(r.nIds + ["lbl"]) }
                      for (i, d) in nd.enumerated() { S.el(g[i], String(d), S.e(r.nIds[i]).x, RY, o: 0) }
                      if ph >= 1 { S.mods(r.nIds, c: BLUE); S.fa(r.nIds); S.h(r.nIds[1]) }
                      if ph >= 2 {
                          for (i, id) in r.nIds.enumerated() { S.mod(id, x: x4[i], c: INK) }
                          for (i, id) in g.enumerated() { S.mod(id, x: x4[i + 2], y: RY - 52, o: 0.4, c: BLUE) }
                          S.fa(r.nIds + g); S.h(g[1])
                      }
                      if ph >= 3 {
                          S.mods(g, o: 1, y: RY)
                          green(&S, r.nIds + g)
                          win(&S, 512, RY, 360, 170)
                      }
                  }),

            BStep(name: "Your turn", times: [0, 500], end: 700),
        ]

        static func hint(_ S: inout Scene, _ P: BP) -> [String] {
            let n = String(P.n * P.m).count, xs = xsOf(n, 512, 74)
            return xs.enumerated().map { i, x in
                let id = "hs\(i)"
                S.box(id, x, 362, 62, 62, r: 18, dashed: true, c: DASH, fill: .clear, q: "?")
                return id
            }
        }

        static func hintText(_ P: BP) -> String {
            let d = digs(P.n)
            if P.m == 101 { return "Close! Just write the number twice, side by side." }
            if d[0] + d[1] >= 10 { return "Close! If the middle sum is 10 or more, carry the 1 to the left." }
            return "Close! Add the two digits first, then put the answer in the middle."
        }

        static func pick(_ idx: [Int], _ P: BP, _ over: [Int: (inout BStep) -> Void] = [:]) -> [BStep] {
            idx.map { i in
                var s = steps[i]
                if s.P != nil { s.P = P }
                over[i]?(&s)
                return s
            }
        }

        static let lesson = BLesson(
            id: "x11", topic: "Times 11 and 101", sutra: "Ekadhikena Purvena / Antyayor Dasakepi",
            infoTitle: "Multiplying Numbers with 11", exQ: "32 \(TIMES) 11", exA: "352",
            steps: steps, practice: [BP(n: 23, m: 11), BP(n: 45, m: 101), BP(n: 67, m: 11)],
            hintText: hintText, hint: hint,
            replayFor: { P, _ in
                let d = digs(P.n)
                return P.m == 101 ? [5] : d[0] + d[1] >= 10 ? [4] : [1, 2, 3]
            },
            random: {
                let a = rnd(1, 8), b = rnd(1, 9)
                return BP(n: a * 10 + b, m: Double.random(in: 0..<1) < 0.3 ? 101 : 11)
            })

        static let m11: BLesson = {
            var L = lesson
            L.id = "m11"; L.topic = "Times 11"
            L.steps = pick([0, 1, 2, 3, 4, 6], BP(n: 32, m: 11), [4: { $0.P = BP(n: 78, m: 11) }])
            L.practice = [BP(n: 23, m: 11), BP(n: 67, m: 11), BP(n: 85, m: 11)]
            L.replayFor = { P, _ in let d = digs(P.n); return d[0] + d[1] >= 10 ? [4] : [1, 2, 3] }
            L.random = { BP(n: rnd(1, 8) * 10 + rnd(1, 9), m: 11) }
            return L
        }()

        static let m101: BLesson = {
            var L = lesson
            L.id = "m101"; L.topic = "Times 101"
            L.infoTitle = "Multiplying Numbers with 101"; L.exQ = "32 \(TIMES) 101"; L.exA = "3232"
            L.steps = pick([0, 5, 6], BP(n: 32, m: 101),
                           [0: { $0.cap = { _ in "Times 101 looks like long work. **Watch this.**" } }])
            L.practice = [BP(n: 45, m: 101), BP(n: 23, m: 101), BP(n: 78, m: 101)]
            L.replayFor = { _, _ in [1] }
            L.random = { BP(n: rnd(10, 99), m: 101) }
            return L
        }()
    }
}
