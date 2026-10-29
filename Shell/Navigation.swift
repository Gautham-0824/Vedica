import SwiftUI
import Observation

enum Tier: Hashable { case basics, inter, adv }

enum Route: Hashable {
    case name, account, showcase(Int)
    case home, lessons, tier(Tier), quizzes, progress, profile
    case lesson(String, review: Bool, start: Int)
    case quiz
}

/// App-wide navigation + shared state. The web build kept all of this in one component's `state`.
@MainActor
@Observable
final class Nav {
    let store = Store()
    var route: Route
    var forward = true
    var toast = ""
    var sheet: String? = nil          // "x11" or "x9" sub-module sheet
    var profFrom: Route = .home
    var quizFromQuizzesTab = false
    let quiz = QuizSession()
    private var toastTask: Task<Void, Never>?

    init() {
        route = store.onboarded ? .home : .name
    }

    private func rank(_ r: Route) -> Int {
        switch r {
        case .name: return 0
        case .account: return 1
        case .showcase(let i): return 2 + i
        case .home: return 10
        case .lessons: return 11
        case .tier: return 12
        case .lesson: return 13
        case .quizzes: return 11
        case .progress: return 12
        case .profile: return 20
        case .quiz: return 14
        }
    }

    func go(_ r: Route, forward f: Bool? = nil) {
        forward = f ?? (rank(r) >= rank(route))
        withAnimation(.timingCurve(0.32, 0.72, 0, 1, duration: 0.55)) { route = r }
    }

    func flash(_ msg: String) {
        toast = msg
        toastTask?.cancel()
        toastTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            if !Task.isCancelled { withAnimation { self?.toast = "" } }
        }
    }

    // MARK: lessons

    func tier(of id: String) -> Tier {
        if Catalog.adv.contains(where: { $0.id == id }) { return .adv }
        if Catalog.inter.contains(where: { $0.id == id }) { return .inter }
        return .basics
    }

    func openLesson(_ id: String) {
        store.begin(id)
        sheet = nil
        go(.lesson(id, review: false, start: 0))
    }

    /// Tapping a card on the sutra list.
    func tapCard(_ id: String) {
        if id == "x11" || id == "x9" {
            withAnimation(.easeOut(duration: 0.26)) { sheet = id }
        } else {
            openLesson(id)
        }
    }

    func lessonFinished(_ id: String) {
        // Fraction and squares-ending-in-5 are marked done when their quiz is finished.
        if id != "frac" && id != "sq5" { store.complete(id) }
    }

    func lessonExit(_ id: String) {
        go(.tier(tier(of: id)), forward: false)
        let fam = Catalog.family(of: id)
        if ["m11", "m101", "m9", "m99", "m999"].contains(id) {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 420_000_000)
                withAnimation(.easeOut(duration: 0.26)) { self.sheet = fam }
            }
        }
    }

    func startQuiz(_ id: String, fromQuizzesTab: Bool) {
        quizFromQuizzesTab = fromQuizzesTab
        quiz.begin(id)
        go(.quiz)
    }

    func closeQuiz() {
        go(quizFromQuizzesTab ? .quizzes : .tier(.basics), forward: false)
    }

    func nextLessonTapped() {
        guard let n = store.nextBasic else { go(.tier(.basics)); return }
        if n.id == "frac" || n.id == "sq5" { openLesson(n.id) }
        else {
            let first = (Catalog.subs[n.id] ?? []).first { store.sub[$0.id] != .done } ?? Catalog.subs[n.id]![0]
            openLesson(first.id)
        }
    }
}

// MARK: - Root

struct RootView: View {
    @State private var nav = Nav()

    var body: some View {
        ZStack {
            Group {
                switch nav.route {
                case .lesson(let id, let review, let start):
                    LessonHost(id: id, review: review, start: start)
                        .id("lesson-\(id)-\(review)-\(start)")
                default:
                    CanvasFit {
                        ScreenRouter()
                    }
                }
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(x: nav.forward ? 32 : -32)),
                removal: .opacity))
        }
        .environment(nav)
        .preferredColorScheme(.light)
    }
}

struct LessonHost: View {
    @Environment(Nav.self) private var nav
    let id: String
    let review: Bool
    let start: Int

    var body: some View {
        let hasQuiz = (id == "frac" || id == "sq5")
        LessonView(
            spec: Catalog.spec(id),
            startStep: start,
            continueTitle: review ? "Back to results" : (hasQuiz ? "Start quiz" : "Back to list"),
            onContinue: {
                if review { nav.go(.quiz, forward: false) }
                else if hasQuiz { nav.startQuiz(id, fromQuizzesTab: false) }
                else { nav.lessonExit(id) }
            },
            onExit: {
                if review { nav.go(.quiz, forward: false) } else { nav.lessonExit(id) }
            },
            onFinished: { nav.lessonFinished(id) })
    }
}

struct ScreenRouter: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        ZStack {
            Group {
                switch nav.route {
                case .name: NameScreen()
                case .account: AccountScreen()
                case .showcase(let i): ShowcaseScreen(index: i)
                case .home: HomeScreen()
                case .lessons: LessonsLanding()
                case .tier(let t): TierListScreen(tier: t)
                case .quizzes: QuizzesScreen()
                case .progress: ProgressScreen()
                case .profile: ProfileScreen()
                case .quiz: QuizScreen()
                case .lesson: EmptyView()
                }
            }
            .id(nav.route)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(x: nav.forward ? 32 : -32)),
                removal: .opacity))

            if showsTabs { TabBar().frame(maxHeight: .infinity, alignment: .bottom).padding(.bottom, 26) }
            if nav.sheet != nil, case .tier = nav.route { SubSheet() }
            if !nav.toast.isEmpty { ToastView(text: nav.toast) }
        }
        .frame(width: Canvas.w, height: Canvas.h)
        .foregroundColor(Theme.ink)
    }

    private var showsTabs: Bool {
        switch nav.route {
        case .home, .lessons, .quizzes, .progress, .profile: return true
        default: return false
        }
    }
}

struct ToastView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(Theme.text(16, .semibold)).foregroundColor(.white)
            .padding(.horizontal, 22).frame(height: 48)
            .background(Capsule().fill(Theme.ink.opacity(0.92)))
            .frame(maxHeight: .infinity, alignment: .bottom).padding(.bottom, 110)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// MARK: - Tab bar

struct TabBar: View {
    @Environment(Nav.self) private var nav
    private let tabs: [(String, Route, String)] = [
        ("Home", .home, "M4 10.6 12 4l8 6.6V19a1 1 0 0 1-1 1h-4.6v-5.6H9.6V20H5a1 1 0 0 1-1-1z"),
        ("Lessons", .lessons, "M12 6.6C10.2 5.2 7.6 4.6 3.8 4.8v13.1c3.8-.2 6.4.4 8.2 1.8 1.8-1.4 4.4-2 8.2-1.8V4.8c-3.8-.2-6.4.4-8.2 1.8zM12 6.6v13.1"),
        ("Quiz", .quizzes, "M12 3.5a8.5 8.5 0 1 1 0 17 8.5 8.5 0 0 1 0-17zM12 7.5V12h3.6"),
        ("Progress", .progress, "M4.8 13.2h3.4v6.3H4.8zM10.3 8.8h3.4v10.7h-3.4zM15.8 4.5h3.4v15h-3.4z"),
    ]

    private var index: Int? {
        switch nav.route {
        case .home: return 0
        case .lessons: return 1
        case .quizzes: return 2
        case .progress: return 3
        default: return nil
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if let i = index {
                Capsule().fill(Theme.ink.opacity(0.07))
                    .frame(width: 100, height: 58)
                    .offset(x: CGFloat(i) * 102)
                    .animation(.spring(response: 0.5, dampingFraction: 0.72), value: i)
            }
            HStack(spacing: 2) {
                ForEach(0..<tabs.count, id: \.self) { i in
                    let on = index == i
                    Button { if nav.route != tabs[i].1 { nav.go(tabs[i].1, forward: i >= (index ?? 0)) } } label: {
                        VStack(spacing: 2) {
                            Icon(d: tabs[i].2, size: 24, stroke: on ? 2 : 1.7, color: on ? Theme.blue : Color(hex: 0x5b6779))
                            Text(tabs[i].0).font(Theme.text(12, .semibold)).foregroundColor(on ? Theme.blue : Color(hex: 0x5b6779))
                        }
                        .frame(width: 100, height: 58)
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityLabel(tabs[i].0)
                }
            }
        }
        .padding(6)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
        .shadow(color: Theme.shadow.opacity(0.12), radius: 20, x: 0, y: 12)
    }
}

// MARK: - Shared chrome

struct TopBar: View {
    var title: String
    var onBack: (() -> Void)?
    var trailing: AnyView? = nil
    var body: some View {
        HStack(spacing: 14) {
            if let b = onBack { RoundIconButton(d: IconPath.back, size: 44, icon: 22, action: b) }
            Text(title).font(Theme.round(26, .black)).tracking(-0.6)
            Spacer()
            if let t = trailing { t }
        }
        .padding(.horizontal, 36)
        .frame(width: Canvas.w, height: 60)
    }
}

struct StatusDot: View {
    var status: Status
    var body: some View {
        ZStack {
            switch status {
            case .done:
                Circle().fill(Theme.green)
                Icon(d: "m6 12.5 4 4 8-9", size: 24, stroke: 3.2, color: .white)
            case .progress:
                Circle().fill(Color(hex: 0xe1e8ef))
                Circle().trim(from: 0, to: 0.5).stroke(Theme.blue, lineWidth: 12).frame(width: 12, height: 12).rotationEffect(.degrees(-90))
                Circle().fill(.white).frame(width: 13, height: 13)
            case .new:
                Circle().stroke(Color(hex: 0xdfe7ef), lineWidth: 2.5)
            }
        }
        .frame(width: 24, height: 24)
    }
}

func statusLabel(_ s: Status) -> (String, Color) {
    switch s {
    case .done: return ("Done", Theme.green)
    case .progress: return ("In progress", Theme.blue)
    case .new: return ("Not started", Color(hex: 0x8391a6))
    }
}
