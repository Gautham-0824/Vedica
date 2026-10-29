import SwiftUI
import Observation

enum Status: String, Codable { case new, progress, done }

struct TimeRec: Codable, Equatable {
    var last: Int          // ms
    var best: Int
    var prevBest: Int?
}

/// A practice / quiz question: either a fraction sum (a/b + c/d) or a multiplication (x * m).
struct Question: Equatable {
    var isFraction: Bool
    var a = 0, b = 1, c = 0, d = 1      // fraction
    var x = 0, m = 0                    // multiplication

    static func f(_ a: Int, _ b: Int, _ c: Int, _ d: Int) -> Question { Question(isFraction: true, a: a, b: b, c: c, d: d) }
    static func mul(_ x: Int, _ m: Int) -> Question { Question(isFraction: false, x: x, m: m) }

    var solNum: Int { isFraction ? a * d + c * b : x * m }
    var solDen: Int { isFraction ? b * d : 1 }
    var text: String { isFraction ? "\(a)/\(b) + \(c)/\(d)" : "\(x) \u{00D7} \(m)" }
    var answer: String { isFraction ? "\(solNum)/\(solDen)" : "\(solNum)" }
}

enum QuizData {
    static let ids = ["frac", "sq5", "x11", "x9", "mix"]
    static let quizzes: [String: [Question]] = [
        "frac": [.f(1, 3, 1, 4), .f(2, 5, 1, 2), .f(3, 5, 1, 4), .f(3, 4, 2, 3), .f(1, 6, 3, 5)],
        "x11": [.mul(23, 11), .mul(45, 11), .mul(78, 11), .mul(32, 101), .mul(56, 101)],
        "sq5": [.mul(25, 25), .mul(45, 45), .mul(65, 65), .mul(75, 75), .mul(95, 95)],
        "x9": [.mul(7, 9), .mul(36, 99), .mul(58, 99), .mul(124, 999), .mul(462, 999)],
        "mix": [.f(1, 2, 1, 3), .mul(55, 55), .mul(64, 11), .mul(43, 99), .f(2, 3, 1, 5), .mul(27, 101), .mul(318, 999)],
    ]
    static let names = ["frac": "Unlike fractions", "sq5": "Squaring numbers ending in 5", "x11": "Multiply by 11 and 101",
                        "x9": "Multiply by 9, 99 and 999", "mix": "Mixed review"]
    static let doneLines = ["frac": "Badge earned: Crosswise.", "sq5": "Badge earned: Fives.", "x11": "Badge earned: Elevens.",
                            "x9": "Badge earned: Nines.", "mix": "You\u{2019}ve reviewed every Basics sutra."]
    static func questions(_ id: String) -> [Question] { quizzes[id] ?? quizzes["frac"]! }
}

enum Catalog {
    struct Item: Identifiable { var id: String; var name: String; var glyph: String }
    static let inter = [Item(id: "rd", name: "Recurring Decimals", glyph: "1 / _9"),
                        Item(id: "dv", name: "Dividing Near a Base", glyph: "___ \u{00F7} 98"),
                        Item(id: "ld10", name: "Last Digits Add to 10", glyph: "_4 \u{00D7} _6"),
                        Item(id: "d7", name: "Divisibility by 7", glyph: "\u{00F7} 7 ?"),
                        Item(id: "sq50", name: "Squaring 50 to 100", glyph: "5_\u{00B2}"),
                        Item(id: "yav", name: "Squaring Near a Base", glyph: "9_\u{00B2}")]
    static let basicsExtra = [Item(id: "dsc", name: "Checking with Digit Sums", glyph: "_ \u{00D7} _ \u{2713}"),
                              Item(id: "ssz", name: "Same Sum Means Zero", glyph: "x + _ = 0")]
    static let adv = [Item(id: "bin", name: "Multiplying Two Binomials", glyph: "(x+a)(x+b)"),
                      Item(id: "eqr", name: "Equations in Ratio", glyph: "a : b = c : d"),
                      Item(id: "vex", name: "Verify an Expansion", glyph: "(x+a)\u{00B2} \u{2713}"),
                      Item(id: "tdm", name: "Two-digit \u{00D7} Two-digit", glyph: "__ \u{00D7} __"),
                      Item(id: "cube", name: "Completing the Cube", glyph: "(x+a)\u{00B3}"),
                      Item(id: "swc", name: "Swapped Coefficients", glyph: "ax+by, bx+ay"),
                      Item(id: "eqf", name: "Equations with Fractions", glyph: "x/_ + x/_")]
    struct Sub: Identifiable { var id: String; var name: String; var glyph: String; var example: String }
    static let subs: [String: [Sub]] = [
        "x11": [Sub(id: "m11", name: "Times 11", glyph: "\u{00D7} 11", example: "32 \u{00D7} 11 = 352"),
                Sub(id: "m101", name: "Times 101", glyph: "\u{00D7} 101", example: "32 \u{00D7} 101 = 3232")],
        "x9": [Sub(id: "m9", name: "Times 9", glyph: "\u{00D7} 9", example: "7 \u{00D7} 9 = 63"),
               Sub(id: "m99", name: "Times 99", glyph: "\u{00D7} 99", example: "47 \u{00D7} 99 = 4653"),
               Sub(id: "m999", name: "Times 999", glyph: "\u{00D7} 999", example: "235 \u{00D7} 999 = 234765")],
    ]
    static let famNames = ["frac": "Adding Unlike Fractions", "sq5": "Squaring Numbers Ending in 5",
                           "x11": "Multiply by 11 and 101", "x9": "Multiply by 9, 99 and 999"]
    static func family(of id: String) -> String { (id == "x11" || id == "m11" || id == "m101") ? "x11" : "x9" }

    /// Every lesson id maps to its engine spec.
    static func spec(_ id: String) -> LessonSpec {
        switch id {
        case "frac": return FractionLesson.spec
        case "sq5": return BK.SquaresEndingIn5.lesson.spec
        case "m11": return BK.TimesEleven.m11.spec
        case "m101": return BK.TimesEleven.m101.spec
        case "m9": return BK.TimesNine.m9.spec
        case "m99": return BK.TimesNine.m99.spec
        case "m999": return BK.TimesNine.m999.spec
        case "rd": return BK.RecurringDecimals.lesson.spec
        case "dv": return BK.DividingNearBase.lesson.spec
        case "dsc": return DigitSumCheckLesson.spec
        case "ssz": return SameSumZeroLesson.spec
        case "ld10": return LastDigits10Lesson.spec
        case "d7": return Divisibility7Lesson.spec
        case "sq50": return Squares50to100Lesson.spec
        case "yav": return YavadunamLesson.spec
        case "bin": return BinomialsLesson.spec
        case "eqr": return EquationsRatioLesson.spec
        case "vex": return VerifyExpansionLesson.spec
        case "tdm": return TwoDigitMultLesson.spec
        case "cube": return CompletingCubeLesson.spec
        case "swc": return SwappedCoeffLesson.spec
        case "eqf": return EquationsFractionsLesson.spec
        default: return FractionLesson.spec
        }
    }
}

struct IntroInfo {
    var n: Int; var name: String; var sutra: String; var when: String; var steps: [String]; var exQ: String; var exA: String
    static let all: [String: IntroInfo] = [
        "frac": IntroInfo(n: 1, name: "Adding Unlike Fractions", sutra: "Urdhva-Tiryagbhyam: vertically and crosswise",
                          when: "Adding two fractions whose bottom numbers are different.",
                          steps: ["Top: multiply crosswise, then add. 3 \u{00D7} 2 + 1 \u{00D7} 4 = 10.", "Bottom: multiply the two bottoms. 4 \u{00D7} 2 = 8.", "Simplify if you can. 10/8 is the same as 5/4."],
                          exQ: "3/4 + 1/2", exA: "= 10/8"),
        "x11": IntroInfo(n: 2, name: "Multiply by 11 and 101", sutra: "Urdhva-Tiryagbhyam: vertically and crosswise",
                         when: "Multiplying any two-digit number by 11 or by 101.",
                         steps: ["Split the two digits apart and leave a gap.", "Add the digits and drop the sum in the gap. 3 + 2 = 5, so 32 \u{00D7} 11 = 352.", "If the sum is 10 or more, carry the 1 to the left.", "For 101, write the number twice. 32 \u{00D7} 101 = 3232."],
                         exQ: "32 \u{00D7} 11", exA: "= 352"),
        "x9": IntroInfo(n: 3, name: "Multiply by 9, 99 and 999", sutra: "Ekanyunena Purvena: by one less than the previous one",
                        when: "Multiplying by 9, 99 or 999, when your number has no more digits than there are nines.",
                        steps: ["Take 1 away from your number. 47 becomes 46.", "Give each digit a partner that makes 9. 4 needs 5, 6 needs 3.", "Put the two parts side by side. 46 and 53 make 4653."],
                        exQ: "47 \u{00D7} 99", exA: "= 4653"),
    ]
}

@Observable
final class Store {
    var name = ""
    var onboarded = false
    var frac = Status.new
    var sq5 = Status.new
    var m11 = Status.new
    var m9 = Status.new
    var sub: [String: Status] = [:]
    var scores: [String: Int] = [:]
    var times: [String: TimeRec] = [:]
    var avatar = 0
    var remOn = true
    var rem = 1050          // minutes after midnight
    var session = 15
    var narrOn = false
    var narrLang = "en"

    private struct Snapshot: Codable {
        var name: String, onboarded: Bool, frac: Status, sq5: Status, m11: Status, m9: Status
        var sub: [String: Status], scores: [String: Int], times: [String: TimeRec]
        var avatar: Int, remOn: Bool, rem: Int, session: Int
    }
    private static let key = "vedica-proto-v1"

    init() {
        let d = UserDefaults.standard
        if let data = d.data(forKey: Store.key), let s = try? JSONDecoder().decode(Snapshot.self, from: data) {
            name = s.name; onboarded = s.onboarded; frac = s.frac; sq5 = s.sq5; m11 = s.m11; m9 = s.m9
            sub = s.sub; scores = s.scores; times = s.times; avatar = s.avatar; remOn = s.remOn; rem = s.rem; session = s.session
        }
        narrLang = d.string(forKey: "vedica.narration.lang") ?? "en"
        narrOn = d.bool(forKey: "vedica.narration.audio")
    }

    func save() {
        let s = Snapshot(name: name, onboarded: onboarded, frac: frac, sq5: sq5, m11: m11, m9: m9, sub: sub,
                         scores: scores, times: times, avatar: avatar, remOn: remOn, rem: rem, session: session)
        if let data = try? JSONEncoder().encode(s) { UserDefaults.standard.set(data, forKey: Store.key) }
    }
    func saveNarration() {
        let d = UserDefaults.standard
        d.set(narrLang, forKey: "vedica.narration.lang")
        d.set(narrOn, forKey: "vedica.narration.audio")
    }
    func reset() {
        name = ""; onboarded = false; frac = .new; sq5 = .new; m11 = .new; m9 = .new
        sub = [:]; scores = [:]; times = [:]; avatar = 0; remOn = true; rem = 1050; session = 15
        save()
    }

    // MARK: derived
    var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    var basicsTotal: Int { 4 + Catalog.basicsExtra.count }
    var basicsDone: Int {
        ([frac, sq5, m11, m9] + Catalog.basicsExtra.map { sub[$0.id] ?? .new }).filter { $0 == .done }.count
    }
    var earned: [Bool] { [frac, sq5, m11, m9].map { $0 == .done } }

    func status(_ id: String) -> Status {
        switch id {
        case "frac": return frac
        case "sq5": return sq5
        case "x11": return famStatus("x11")
        case "x9": return famStatus("x9")
        default: return sub[id] ?? .new
        }
    }
    func famStatus(_ fam: String) -> Status {
        let v = (Catalog.subs[fam] ?? []).map { sub[$0.id] ?? .new }
        if v.allSatisfy({ $0 == .done }) { return .done }
        if v.contains(where: { $0 != .new }) || (fam == "x11" ? m11 : m9) == .progress { return .progress }
        return .new
    }
    func begin(_ id: String) {
        func up(_ s: Status) -> Status { s == .done ? .done : .progress }
        switch id {
        case "frac": frac = up(frac)
        case "sq5": sq5 = up(sq5)
        case "m11", "m101": sub[id] = up(sub[id] ?? .new); m11 = up(m11)
        case "m9", "m99", "m999": sub[id] = up(sub[id] ?? .new); m9 = up(m9)
        default: sub[id] = up(sub[id] ?? .new)
        }
        save()
    }
    func complete(_ id: String) {
        switch id {
        case "frac": frac = .done
        case "sq5": sq5 = .done
        case "m11", "m101":
            sub[id] = .done
            if (Catalog.subs["x11"] ?? []).allSatisfy({ sub[$0.id] == .done }) { m11 = .done }
        case "m9", "m99", "m999":
            sub[id] = .done
            if (Catalog.subs["x9"] ?? []).allSatisfy({ sub[$0.id] == .done }) { m9 = .done }
        default: sub[id] = .done
        }
        save()
    }
    var nextBasic: (id: String, status: Status)? {
        [("frac", frac), ("sq5", sq5), ("x11", m11), ("x9", m9)].first { $0.1 != .done }.map { ($0.0, $0.1) }
    }
    func formatClock(_ minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        return "\(((h + 11) % 12) + 1):\(String(format: "%02d", m)) \(h < 12 ? "AM" : "PM")"
    }
}

func clockText(_ ms: Int) -> String { let s = ms / 1000; return "\(s / 60):\(String(format: "%02d", s % 60))" }
func secsText(_ ms: Double) -> String {
    ms < 60000 ? "\((ms / 100).rounded() / 10) s" : clockText(Int(ms))
}
