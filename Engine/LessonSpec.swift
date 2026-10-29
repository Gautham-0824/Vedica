import SwiftUI

/// One step of a lesson. `g` is the scene group ("left", "cross", ...), `n`/`m` identify the worked
/// example, `k` is an optional variant index some lessons use.
struct StepDef {
    var g: String
    var n: String
    var m: String = ""
    var k: Int? = nil
    var name: String
    var times: [Double]
    var end: Double
}

/// One practice problem. Single-input lessons leave `m` empty.
struct Problem: Equatable {
    var n: String
    var m: String = ""
}

/// One question inside a practice problem.
struct PTask {
    var g: String
    var cap: String
    var q: String
    var ans: String
    var ex: [String]
    var hint: String
    var ok: String? = nil
    var k: Int? = nil
    var hl: Color? = nil
    var prompt: String? = nil     // text shown before the answer box, default "="
}

struct InfoRow {
    var title: String
    var sub: String
    var value: String
}

/// Small rendering differences between lessons (the later lessons fade and pop a little differently).
struct RenderStyle {
    var dimElement: Double = 0.14
    var dimBox: Double = 0.35
    var blur: Double = 2.5
    var newElementScale: Double = 1.0      // multiplier an element starts from when it first appears
    var newBoxScale: Double = 0.9
    var reappearFresh = false              // a glyph that left and came back enters like a new one
    var dur: Double = 1.05                 // glide duration in seconds (the Basics lessons use 0.82)
}

/// A run of big text in the intro card's one-line teaser (the pop-in run animates in after the card opens).
struct TeaserRun {
    var text: String
    var color: Color = Theme.ink
    var scale: Double = 1
    var pop = false
}

typealias Styled = (text: String, color: Color)

/// Everything a lesson has to say. The runner, renderer and chrome are shared by all lessons.
struct LessonSpec: Identifiable {
    var id: String
    var topTitle: String            // small title in the top bar
    var cardTitle: String           // big title on the intro card
    var cardBlurb: String
    var rows: [InfoRow] = []
    var teaser: [[TeaserRun]]? = nil     // used instead of `rows` by the lessons with a one-line preview
    var teaserSize: Double = 48
    var sutra: String
    var defaultHint: String = "Use the trick from the lesson."
    var style = RenderStyle()
    var keys: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "\u{232B}"]

    var steps: [StepDef]
    var practice: [Problem]
    var random: () -> Problem

    var stepScene: (StepDef, Int) -> Scene
    var caption: (StepDef) -> Styled
    var summary: (StepDef) -> Styled?
    var tasks: (Problem) -> [PTask]
    var practiceScene: (Problem, Int, Bool, Bool) -> Scene       // problem, task, ok, done
    var doneCaption: (Problem) -> String

    /// Timings for replaying a step from the practice screen. Defaults to the step's own timings.
    var replayStep: ((Problem, PTask) -> StepDef)? = nil

    /// Basics lessons: several summary lines per step, shown as separate chips in the rail.
    var summaryLines: ((StepDef) -> [Styled])? = nil
    /// Basics lessons: practice scene that also knows how many wrong tries there were (hint scaffolding).
    var practiceFull: ((Problem, Int, Bool, Bool, Int) -> Scene)? = nil
    /// Basics lessons: the list of steps replayed after three wrong tries.
    var replaySteps: ((Problem, Int) -> [StepDef])? = nil
    /// Basics lessons: the intro card shows a title with a highlighted number and a worked example.
    var example: (q: String, a: String)? = nil

    // Fraction lesson specifics (all optional, defaults give the normal behaviour).
    var practiceByState: ((Problem, PracticeState) -> Scene)? = nil
    var okAdvanceMs: (Double, Double) = (1100, 1500)
    var okAnimMs: Double? = nil
    var tickMs: Double? = nil
    var replayOnWrong = true
    var taskProgress = false
    var okHint = "That\u{2019}s it."
    var doneSub: ((Problem) -> String)? = nil
    var bigRail = false
    var stageShift: Double = 0
    var fractionExample = false

    var last: Int { steps.count - 1 }

    func stepFor(_ problem: Problem, _ task: PTask) -> StepDef {
        if let r = replayStep { return r(problem, task) }
        var s = steps.first(where: { $0.g == task.g }) ?? steps[0]
        s.n = problem.n
        s.m = problem.m
        s.k = task.k
        return s
    }
}

// MARK: - Small shared helpers for lesson ports

/// Splits `**bold**` markup into alternating plain / bold runs.
func styledRuns(_ s: String) -> [(String, Bool)] {
    var out: [(String, Bool)] = []
    let parts = s.components(separatedBy: "**")
    for (i, p) in parts.enumerated() where !p.isEmpty { out.append((p, i % 2 == 1)) }
    return out
}

func plain(_ s: String) -> String { s.replacingOccurrences(of: "**", with: "") }

func rnd(_ a: Int, _ b: Int) -> Int { Int.random(in: a...b) }
