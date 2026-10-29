import SwiftUI

struct AvatarButton: View {
    @Environment(Nav.self) private var nav
    var body: some View {
        let nm = nav.store.trimmedName
        Button {
            nav.profFrom = nav.route
            nav.go(.profile)
        } label: {
            Text(nm.isEmpty ? "" : String(nm.prefix(1)).uppercased())
                .font(Theme.round(24, .black)).foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(Circle().fill(nm.isEmpty ? Color(hex: 0xdcdfe3) : Profile.swatches[nav.store.avatar]))
                .shadow(color: Theme.shadow.opacity(nm.isEmpty ? 0 : 0.16), radius: 8, x: 0, y: 6)
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel("Profile")
    }
}

struct HomeScreen: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        let s = nav.store
        let nm = s.trimmedName
        let next = s.nextBasic
        let nextIdx = next.flatMap { n in ["frac", "sq5", "x11", "x9"].firstIndex(of: n.id) } ?? 4
        let barFill = Double([s.frac, s.sq5, s.m11, s.m9].filter { $0 == .done }.count) / 4
            + (next?.status == .progress ? 0.125 : 0)
        let mins = 12.0
        let goal = min(mins / Double(s.session), 1)
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(nm.isEmpty ? "Hi there" : "Hi, \(nm)").font(Theme.round(38, .black)).tracking(-1.2)
                    Text("Ready for a little maths?").font(Theme.text(18, .medium)).foregroundColor(Theme.sub)
                }
                Spacer()
                AvatarButton()
            }
            // Next lesson
            VStack(alignment: .leading, spacing: 14) {
                Text(next == nil ? "ALL BASICS DONE" : "UP NEXT").font(Theme.text(13, .bold)).tracking(1).foregroundColor(Theme.blue)
                Text(next.map { Catalog.famNames[$0.id] ?? "" } ?? "Basics complete")
                    .font(Theme.round(32, .black)).tracking(-0.8)
                Text(next == nil ? "All 4 sutras done \u{00B7} Basics" : "Sutra \(nextIdx + 1) of 4 \u{00B7} Basics")
                    .font(Theme.text(16, .medium)).foregroundColor(Theme.sub)
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.line)
                        Capsule().fill(Theme.blue).frame(width: g.size.width * min(barFill, 1))
                    }
                }.frame(height: 8)
                PrimaryPill(title: next == nil ? "Review" : next?.status == .progress ? "Resume" : "Start", minWidth: 150) {
                    nav.nextLessonTapped()
                }
            }
            .padding(26).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 30, style: .continuous).fill(.white))
            .shadow(color: Theme.shadow.opacity(0.06), radius: 14, x: 0, y: 10)

            // Daily goal
            HStack(spacing: 20) {
                ZStack {
                    Circle().stroke(Theme.line, lineWidth: 6)
                    Circle().trim(from: 0, to: goal).stroke(Theme.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int((goal * 100).rounded()))%").font(Theme.round(15, .heavy))
                }.frame(width: 66, height: 66)
                VStack(alignment: .leading, spacing: 4) {
                    Text("12 of \(s.session) min today").font(Theme.round(22, .heavy))
                    Text(12 >= s.session ? "Goal reached for today" : "\(s.session - 12) minutes left to hit your goal")
                        .font(Theme.text(16, .medium)).foregroundColor(Theme.sub)
                }
                Spacer()
            }
            .padding(22)
            .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(.white))
            .shadow(color: Theme.shadow.opacity(0.05), radius: 12, x: 0, y: 8)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 36).padding(.top, 36).padding(.bottom, 120)
        .frame(width: Canvas.w, height: Canvas.h, alignment: .topLeading)
    }
}

struct LessonsLanding: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        let s = nav.store
        let interDone = Catalog.inter.filter { s.sub[$0.id] == .done }.count
        let advDone = Catalog.adv.filter { s.sub[$0.id] == .done }.count
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lessons").font(Theme.round(38, .black)).tracking(-1.2)
                    Text("Pick a level to begin.").font(Theme.text(18, .medium)).foregroundColor(Theme.sub)
                }
                Spacer()
                AvatarButton()
            }
            tierRow("Basics", "Fractions, squares, times tables", "\(s.basicsDone) of \(s.basicsTotal) done",
                    s.basicsDone == s.basicsTotal, "textformat.123") { nav.go(.tier(.basics)) }
            tierRow("Intermediate", "Decimals, division, squares near a base", "\(interDone) of \(Catalog.inter.count) done",
                    interDone == Catalog.inter.count, "function") { nav.go(.tier(.inter)) }
            tierRow("Advanced", "Binomials, ratios, cubes, algebra", "\(advDone) of \(Catalog.adv.count) done",
                    advDone == Catalog.adv.count, "sum") { nav.go(.tier(.adv)) }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 36).padding(.top, 36).padding(.bottom, 120)
        .frame(width: Canvas.w, height: Canvas.h, alignment: .topLeading)
    }

    private func tierRow(_ title: String, _ sub: String, _ prog: String, _ done: Bool, _ sym: String,
                         _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: sym).font(.system(size: 28, weight: .semibold)).foregroundColor(Theme.blue)
                    .frame(width: 68, height: 68).background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.soft))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(Theme.round(28, .black)).tracking(-0.6)
                    Text(sub).font(Theme.text(16, .medium)).foregroundColor(Theme.sub)
                }
                Spacer()
                Text(prog).font(Theme.text(15, .semibold)).foregroundColor(done ? Theme.green : Theme.blue)
                Icon(d: IconPath.forward, size: 22, stroke: 2.4, color: Theme.muted)
            }
            .padding(.horizontal, 24).frame(height: 116)
            .background(RoundedRectangle(cornerRadius: 30, style: .continuous).fill(.white))
            .shadow(color: Theme.shadow.opacity(0.06), radius: 14, x: 0, y: 10)
        }
        .buttonStyle(PressStyle(scale: 0.985))
    }
}

struct TierListScreen: View {
    @Environment(Nav.self) private var nav
    let tier: Tier

    private struct Card: Identifiable { var id: String; var name: String; var glyph: String; var status: Status }

    private var cards: [Card] {
        let s = nav.store
        switch tier {
        case .adv: return Catalog.adv.map { Card(id: $0.id, name: $0.name, glyph: $0.glyph, status: s.sub[$0.id] ?? .new) }
        case .inter: return Catalog.inter.map { Card(id: $0.id, name: $0.name, glyph: $0.glyph, status: s.sub[$0.id] ?? .new) }
        case .basics:
            let main = [Card(id: "frac", name: "Adding Unlike Fractions", glyph: "a/b + c/d", status: s.frac),
                        Card(id: "sq5", name: "Squaring Numbers Ending in 5", glyph: "_5 \u{00D7} _5", status: s.sq5),
                        Card(id: "x11", name: "Multiply by 11 and 101", glyph: "__ \u{00D7} 11", status: s.famStatus("x11")),
                        Card(id: "x9", name: "Multiply by 9, 99 and 999", glyph: "__ \u{00D7} 99", status: s.famStatus("x9"))]
            return main + Catalog.basicsExtra.map { Card(id: $0.id, name: $0.name, glyph: $0.glyph, status: s.sub[$0.id] ?? .new) }
        }
    }

    var body: some View {
        let list = cards
        let title = tier == .adv ? "Advanced" : tier == .inter ? "Intermediate" : "Basics"
        let done = list.filter { $0.status == .done }.count
        let focus = list.first { $0.status != .done }?.id
        let cols = list.count > 6 ? 4 : 3
        VStack(alignment: .leading, spacing: 0) {
            TopBar(title: title, onBack: { nav.go(.lessons, forward: false) }, trailing: AnyView(AvatarButton()))
                .padding(.top, 24)
            Text("\(list.count) sutras \u{00B7} \(done) done")
                .font(Theme.text(16, .semibold)).foregroundColor(Theme.sub).padding(.horizontal, 36).padding(.bottom, 14)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: cols), spacing: 16) {
                    ForEach(list) { c in
                        Button { nav.tapCard(c.id) } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(c.glyph).font(Theme.round(28, .heavy)).tracking(-0.8).foregroundColor(Color(hex: 0x3a4860))
                                    .minimumScaleFactor(0.6).lineLimit(1)
                                    .frame(maxWidth: .infinity).frame(height: 92)
                                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.panel))
                                Text(c.name).font(Theme.round(16, .heavy)).tracking(-0.3).lineLimit(2).multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                                HStack(spacing: 8) {
                                    StatusDot(status: c.status)
                                    let l = statusLabel(c.status)
                                    Text(l.0).font(Theme.text(14, .semibold)).foregroundColor(l.1)
                                }
                            }
                            .padding(16).frame(height: 214).frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(.white))
                            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(focus == c.id ? Theme.blue : Color(hex: 0xedf1f5), lineWidth: focus == c.id ? 2 : 1))
                            .shadow(color: Theme.shadow.opacity(0.06), radius: 12, x: 0, y: 8)
                        }
                        .buttonStyle(PressStyle(scale: 0.97))
                    }
                }
                .padding(.horizontal, 36).padding(.bottom, 40)
            }
        }
        .frame(width: Canvas.w, height: Canvas.h, alignment: .topLeading)
    }
}

/// Sub-module chooser for "Multiply by 11 and 101" / "Multiply by 9, 99 and 999".
struct SubSheet: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        if let fam = nav.sheet {
            let info = IntroInfo.all[fam]!
            ZStack {
                Color(hex: 0x17233a, alpha: 0.32).ignoresSafeArea()
                    .onTapGesture { close() }
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(info.name).font(Theme.round(28, .black)).tracking(-0.8)
                        Spacer()
                        RoundIconButton(d: IconPath.close, size: 40, icon: 18, stroke: 2.6) { close() }
                    }
                    Text(info.sutra).font(Theme.text(14, .bold)).foregroundColor(Theme.blue)
                    ForEach(Catalog.subs[fam] ?? []) { sub in
                        let st = nav.store.sub[sub.id] ?? .new
                        Button { nav.openLesson(sub.id) } label: {
                            HStack(spacing: 16) {
                                Text(sub.glyph).font(Theme.round(20, .heavy)).foregroundColor(Theme.blue)
                                    .frame(width: 80, height: 56)
                                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.soft))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sub.name).font(Theme.round(20, .heavy))
                                    Text(sub.example).font(Theme.text(15, .medium)).foregroundColor(Theme.sub)
                                }
                                Spacer()
                                Text(st == .done ? "Done" : st == .progress ? "In progress" : "Start")
                                    .font(Theme.text(15, .bold)).foregroundColor(st == .done ? Theme.green : Theme.blue)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.panel))
                        }
                        .buttonStyle(PressStyle(scale: 0.98))
                    }
                }
                .padding(.horizontal, 28).padding(.top, 30).padding(.bottom, 28)
                .frame(width: 520)
                .background(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(.white))
                .shadow(color: Theme.shadow.opacity(0.24), radius: 40, x: 0, y: 30)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.94)))
        }
    }

    private func close() { withAnimation(.easeOut(duration: 0.26)) { nav.sheet = nil } }
}

struct QuizzesScreen: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        let s = nav.store
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quizzes").font(Theme.round(38, .black)).tracking(-1.2)
                    Text("Timed, handwritten, no hints.").font(Theme.text(18, .medium)).foregroundColor(Theme.sub)
                }
                Spacer()
                AvatarButton()
            }
            ForEach(QuizData.ids, id: \.self) { id in
                let n = QuizData.questions(id).count
                let sc = s.scores[id]
                Button { nav.startQuiz(id, fromQuizzesTab: true) } label: {
                    HStack(spacing: 18) {
                        Icon(d: "M7 3.5h10a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-13a2 2 0 0 1 2-2zM9 9h6M9 12.5h6M9 16h3.5", size: 24, stroke: 2, color: Theme.blue)
                            .frame(width: 50, height: 50).background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.soft))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(QuizData.names[id] ?? "") quiz").font(Theme.round(20, .heavy)).tracking(-0.2)
                            Text(sc != nil
                                 ? "\(n) questions \u{00B7} last \(sc!) of \(n) in \(clockText(s.times[id]?.last ?? 0))" + (s.times[id].map { " \u{00B7} best \(clockText($0.best))" } ?? "")
                                 : "\(n) questions \u{00B7} timed")
                                .font(Theme.text(15, .medium)).foregroundColor(Theme.sub)
                        }
                        Spacer()
                        Text(sc != nil ? "Retake" : "Start").font(Theme.text(16, .bold))
                            .padding(.horizontal, 22).frame(height: 44)
                            .background(Capsule().fill(Color(hex: 0xeef2f6)))
                    }
                    .padding(.horizontal, 20).frame(height: 76)
                    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.white))
                    .shadow(color: Theme.shadow.opacity(0.05), radius: 9, x: 0, y: 6)
                }
                .buttonStyle(PressStyle(scale: 0.985))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 36).padding(.top, 36).padding(.bottom, 120)
        .frame(width: Canvas.w, height: Canvas.h, alignment: .topLeading)
    }
}
