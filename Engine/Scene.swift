import SwiftUI

// MARK: - Scene model
//
// Every lesson builds one `Scene` per (step, phase). The renderer diffs consecutive scenes by id,
// so an element that exists in both scenes glides from its old place to its new one. This is the
// same model as the web build's `mk()` toolkit.

struct SElement: Equatable {
    var t: String
    var x: Double
    var y: Double
    var o: Double = 1          // opacity
    var s: Double = 1          // scale
    var c: Color = Theme.ink
    var z: Double = 96         // font size
    var w: Int = 900           // font weight
    var dl: Double = 0         // delay, ms
    var od: Double? = nil      // opacity delay override, ms
}

struct SBox: Equatable {
    var x: Double
    var y: Double
    var w: Double
    var h: Double
    var o: Double = 1
    var s: Double = 1
    var r: Double = 22
    var dashed = false
    var c: Color = Theme.line
    var fill: Color = .white
    var shadow = false
    var q: String = ""
    var qz: Double? = nil
    var qc: Color? = nil
    var dl: Double = 0
    var bw: Double? = nil      // border width override for solid boxes
    var dimTo: Double? = nil   // opacity multiplier when dimmed, overrides the lesson style
}

struct SArrow: Equatable {
    var p0: CGPoint
    var p1: CGPoint
    var c: Color = Theme.blue
    var st: Int = 1            // 1 draw in, 2 dimmed, 3 gone
    var bend: Double = 0.28
    var dl: Double = 0
}

/// A straight line that draws itself in (the Fraction lesson's crosswise lines).
/// state: 0 hidden (not yet drawn), 1 drawn, 2 faint, 3 drawn but invisible.
struct SLine: Equatable {
    var p0: CGPoint
    var p1: CGPoint
    var c: Color
    var state: Int
}

struct SFinale: Equatable {
    var x: Double
    var y: Double
    var w: Double
    var h: Double
}

enum HandTarget: Equatable {
    case element(String)
    case point(Double, Double)
}

struct Scene {
    var pre: String
    var E: [String: SElement] = [:]
    var B: [String: SBox] = [:]
    var eOrder: [String] = []      // insertion order, so z-order is deterministic
    var bOrder: [String] = []
    var A: [Int: SArrow] = [:]
    var Ls: [Int: SLine] = [:]
    var focus: [String]? = nil
    var hand: HandTarget? = nil
    var finale: SFinale? = nil
    var win = false

    init(_ pre: String = "") { self.pre = pre }

    // Elements -------------------------------------------------------------------------------
    mutating func el(_ id: String, _ t: String, _ x: Double, _ y: Double,
                     z: Double = 96, c: Color = Theme.ink, w: Int = 900,
                     o: Double = 1, s: Double = 1, dl: Double = 0, od: Double? = nil) {
        if E[pre + id] == nil { eOrder.append(pre + id) }
        E[pre + id] = SElement(t: t, x: x, y: y, o: o, s: s, c: c, z: z, w: w, dl: dl, od: od)
    }

    mutating func box(_ id: String, _ x: Double, _ y: Double, _ w: Double, _ h: Double,
                      o: Double = 1, s: Double = 1, r: Double = 22, dashed: Bool = false,
                      c: Color = Theme.line, fill: Color = .white, shadow: Bool = false,
                      q: String = "", qz: Double? = nil, qc: Color? = nil, dl: Double = 0, bw: Double? = nil, dimTo: Double? = nil) {
        if B[pre + id] == nil { bOrder.append(pre + id) }
        B[pre + id] = SBox(x: x, y: y, w: w, h: h, o: o, s: s, r: r, dashed: dashed, c: c,
                           fill: fill, shadow: shadow, q: q, qz: qz, qc: qc, dl: dl, bw: bw, dimTo: dimTo)
    }

    /// Patch whichever of element/box has this id. Only the fields passed are changed.
    mutating func mod(_ id: String, x: Double? = nil, y: Double? = nil, o: Double? = nil,
                      s: Double? = nil, c: Color? = nil, dl: Double? = nil, od: Double? = nil,
                      t: String? = nil, z: Double? = nil, w: Int? = nil,
                      qc: Color? = nil, q: String? = nil, fill: Color? = nil) {
        let k = pre + id
        if var e = E[k] {
            if let x = x { e.x = x }
            if let y = y { e.y = y }
            if let o = o { e.o = o }
            if let s = s { e.s = s }
            if let c = c { e.c = c }
            if let dl = dl { e.dl = dl }
            if let od = od { e.od = od }
            if let t = t { e.t = t }
            if let z = z { e.z = z }
            if let w = w { e.w = w }
            E[k] = e
        } else if var b = B[k] {
            if let x = x { b.x = x }
            if let y = y { b.y = y }
            if let o = o { b.o = o }
            if let s = s { b.s = s }
            if let c = c { b.c = c }
            if let dl = dl { b.dl = dl }
            if let qc = qc { b.qc = qc }
            if let q = q { b.q = q }
            if let fill = fill { b.fill = fill }
            B[k] = b
        }
    }

    mutating func mods(_ ids: [String], c: Color? = nil, o: Double? = nil, s: Double? = nil,
                       x: Double? = nil, y: Double? = nil, dl: Double? = nil) {
        for id in ids { mod(id, x: x, y: y, o: o, s: s, c: c, dl: dl) }
    }

    // Focus / hand / arrows ------------------------------------------------------------------
    mutating func f(_ ids: String...) { fa(ids) }
    mutating func fa(_ ids: [String]) {
        var cur = focus ?? []
        cur.append(contentsOf: ids.map { pre + $0 })
        focus = cur
    }
    mutating func h(_ id: String) { hand = .element(pre + id) }
    mutating func hp(_ x: Double, _ y: Double) { hand = .point(x, y) }

    mutating func arrow(_ i: Int, _ p0: (Double, Double), _ p1: (Double, Double),
                        c: Color = Theme.blue, st: Int = 1, bend: Double = 0.28, dl: Double = 0) {
        A[i] = SArrow(p0: CGPoint(x: p0.0, y: p0.1), p1: CGPoint(x: p1.0, y: p1.1),
                      c: c, st: st, bend: bend, dl: dl)
    }

    mutating func line(_ i: Int, _ p0: (Double, Double), _ p1: (Double, Double), c: Color, state: Int) {
        Ls[i] = SLine(p0: CGPoint(x: p0.0, y: p0.1), p1: CGPoint(x: p1.0, y: p1.1), c: c, state: state)
    }

    /// Fade out and drop 26pt, like the web build's `S.hide`.
    mutating func hide(_ ids: [String]) {
        for id in ids {
            if var e = E[pre + id] { e.o = 0; e.y += 26; E[pre + id] = e }
        }
    }

    /// Read back an element / box that was already placed in this scene (ids are local, without the prefix).
    func e(_ id: String) -> SElement { E[pre + id] ?? SElement(t: "", x: 512, y: 300) }
    func b(_ id: String) -> SBox { B[pre + id] ?? SBox(x: 512, y: 300, w: 0, h: 0) }

    func has(_ id: String) -> Bool { E[pre + id] != nil || B[pre + id] != nil }
}

// MARK: - Layout helpers shared by every lesson

struct SeqItem {
    var id: String
    var t: String
    var op = false
    var c: Color? = nil
    var g: Double? = nil
    var o: Double? = nil
    init(_ id: String, _ t: String, op: Bool = false, c: Color? = nil, g: Double? = nil, o: Double? = nil) {
        self.id = id; self.t = t; self.op = op; self.c = c; self.g = g; self.o = o
    }
}

struct SeqResult {
    var xs: [Double]
    var total: Double
}

extension Scene {
    /// Lay a row of glyphs out centred on `cx`, like the web build's `seq()`.
    @discardableResult
    mutating func seq(_ items: [SeqItem], _ cx: Double, _ y: Double, _ z: Double, sq: Bool = false) -> SeqResult {
        func width(_ it: SeqItem) -> Double {
            if sq && it.t == "\u{00B2}" { return z * 0.34 }
            if it.t.count == 1, let ch = it.t.first, ch.isASCII, ch.isNumber { return z * 0.62 }
            return z * 0.6 * Double(it.t.count)
        }
        var gaps: [Double] = []
        for (i, it) in items.enumerated() {
            if i == items.count - 1 { gaps.append(0) }
            else if sq && items[i + 1].t == "\u{00B2}" { gaps.append(0) }
            else { gaps.append(it.g ?? z * 0.24) }
        }
        var total = 0.0
        for (i, it) in items.enumerated() { total += width(it) + gaps[i] }
        var x = cx - total / 2
        var xs: [Double] = []
        for (i, it) in items.enumerated() {
            let c = x + width(it) / 2
            xs.append(c)
            el(it.id, it.t, c, y, z: z, c: it.c ?? Theme.ink, w: it.op ? 700 : 900, o: it.o ?? 1)
            x += width(it) + gaps[i]
        }
        return SeqResult(xs: xs, total: total)
    }
}

// MARK: - Text helpers

func N2(_ n: Int) -> String { String(n).replacingOccurrences(of: "-", with: "\u{2212}") }
func N2(_ s: String) -> String { s.replacingOccurrences(of: "-", with: "\u{2212}") }
func fmt(_ n: Int) -> String { n < 0 ? "(" + N2(n) + ")" : String(n) }
func num(_ s: String) -> Int { Int(s.replacingOccurrences(of: "\u{2212}", with: "-")) ?? 0 }
func sgn(_ n: Int) -> String { n < 0 ? "\u{2212}" : "+" }
func isOp(_ t: String) -> Bool { ["+", "\u{00D7}", "=", "\u{00F7}"].contains(t) }

// MARK: - Speech bubble ("bub") used by most lessons for the working-out line

struct BubItem {
    var id: String
    var t: String
    var op = false
    var res = false
    var c: Color? = nil
    var o: Double? = nil
    var g: Double? = nil
    init(_ id: String, _ t: String, op: Bool = false, res: Bool = false, c: Color? = nil, o: Double? = nil, g: Double? = nil) {
        self.id = id; self.t = t; self.op = op; self.res = res; self.c = c; self.o = o; self.g = g
    }
}

struct BubResult {
    var xs: [Double]
    var ids: [String]
    var res: [String]
    var rest: [String]
}

extension Scene {
    /// `bo` = bubble opacity, `to` = opacity of the working, `ro` = opacity of the result glyphs.
    @discardableResult
    mutating func bub(_ items: [BubItem], _ bo: Double, _ to: Double, _ ro: Double,
                      y: Double = 530, z: Double = 52, sq: Bool = false) -> BubResult {
        let its: [SeqItem] = items.map { SeqItem($0.id, $0.t, op: $0.op, c: $0.c, g: $0.g, o: $0.o ?? ($0.res ? ro : to)) }
        let q = seq(its, 512, y, z, sq: sq)
        box("bub", 512, y, max(300, q.total + 90), 104, o: bo, r: 28, shadow: true)
        return BubResult(xs: q.xs, ids: items.map { $0.id },
                         res: items.filter { $0.res }.map { $0.id },
                         rest: items.filter { !$0.res }.map { $0.id })
    }
}

func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }


extension Scene {
    /// The later lessons' `seq`: a fixed gap between glyphs and operators drawn muted.
    @discardableResult
    mutating func seqFlat(_ items: [SeqItem], _ cx: Double, _ y: Double, _ z: Double, mute: Bool = true) -> Double {
        func w(_ it: SeqItem) -> Double {
            if it.t.count == 1, let ch = it.t.first, ch.isASCII, ch.isNumber { return z * 0.62 }
            return z * 0.6 * Double(it.t.count)
        }
        var gaps: [Double] = []
        for i in items.indices { gaps.append(i == items.count - 1 ? 0 : z * 0.24) }
        var total = 0.0
        for (i, it) in items.enumerated() { total += w(it) + gaps[i] }
        var x = cx - total / 2
        for (i, it) in items.enumerated() {
            el(it.id, it.t, x + w(it) / 2, y, z: z, c: it.op ? (mute ? Theme.muted : Theme.ink) : Theme.ink)
            x += w(it) + gaps[i]
        }
        return total
    }
}
