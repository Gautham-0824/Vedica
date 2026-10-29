import SwiftUI

enum Profile {
    static let swatches: [Color] = [Color(hex: 0x0a84ff), Color(hex: 0x1a9e62), Color(hex: 0xe86f00), Color(hex: 0x7b61ff)]
    static let langs: [(id: String, name: String, native: String)] = [
        ("en", "English", "English"), ("hi", "Hindi", "\u{0939}\u{093F}\u{0928}\u{094D}\u{0926}\u{0940}"),
        ("ta", "Tamil", "\u{0BA4}\u{0BAE}\u{0BBF}\u{0BB4}\u{0BCD}"), ("te", "Telugu", "\u{0C24}\u{0C46}\u{0C32}\u{0C41}\u{0C17}\u{0C41}"),
        ("ml", "Malayalam", "\u{0D2E}\u{0D32}\u{0D2F}\u{0D3E}\u{0D33}\u{0D02}"),
    ]
    static let acc = [62, 66, 71, 69, 77, 84]
    static let spd = [46, 42, 38, 37, 31, 27]
    static let weeks = ["Aug 17", "Aug 24", "Aug 31", "Sep 7", "Sep 14", "Sep 21"]
    static let days: [(String, Bool)] = [("M", true), ("T", true), ("W", false), ("T", true), ("F", true), ("S", true), ("S", false)]
    static let badges = [("Crosswise", "Unlike fractions"), ("Fives", "Squares ending in 5"), ("Elevens", "\u{00D7} 11 and 101"), ("Nines", "\u{00D7} 9, 99, 999")]
    static let star = "M12 3.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8L12 16.9l-5.2 2.7 1-5.8-4.3-4.1 5.9-.9z"
    static let lock = "M7 11V8a5 5 0 0 1 10 0v3M5 11h14v10H5z"
}

struct Card<Content: View>: View {
    var pad: CGFloat = 22
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding(pad)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(.white))
            .shadow(color: Theme.shadow.opacity(0.05), radius: 10, x: 0, y: 7)
    }
}

struct BadgeTile: View {
    var name: String; var sub: String; var got: Bool
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(got ? Theme.blue : Color.white)
                if !got { Circle().strokeBorder(Color(hex: 0xdfe7ef), style: StrokeStyle(lineWidth: 2, dash: [4, 3])) }
                if got { Icon(d: Profile.star, size: 24, color: .white, filled: true) }
                else { Icon(d: Profile.lock, size: 22, stroke: 2.2, color: Color(hex: 0xb5c3d2)) }
            }
            .frame(width: 52, height: 52)
            .shadow(color: got ? Theme.blue.opacity(0.28) : .clear, radius: 9, x: 0, y: 8)
            VStack(alignment: .leading, spacing: 1) {
                Text(name).font(Theme.round(18, .heavy)).foregroundColor(got ? Theme.ink : Theme.muted)
                Text(got ? "Earned" : sub).font(Theme.text(13, .semibold)).foregroundColor(Theme.sub)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14).frame(height: 80)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(got ? Color(hex: 0xf4f9ff) : Color(hex: 0xf7f9fb)))
    }
}

struct ProgressScreen: View {
    @Environment(Nav.self) private var nav
    @State private var metric = 0   // 0 accuracy, 1 speed
    @State private var confirmReset = false

    var body: some View {
        @Bindable var s = nav.store
        let nm = s.trimmedName
        let learned = learnedLines(s)
        let tricky = trickyLines()
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(nm.isEmpty ? "Your week" : "\(nm)\u{2019}s week").font(Theme.round(38, .black)).tracking(-1.2)
                        Text(nm.isEmpty ? "Keep going." : "Keep going, \(nm).").font(Theme.text(18, .medium)).foregroundColor(Theme.sub)
                    }
                    Spacer()
                    AvatarButton()
                }
                Card {
                    HStack(spacing: 14) {
                        ForEach(0..<Profile.days.count, id: \.self) { i in
                            VStack(spacing: 6) {
                                Text(Profile.days[i].0).font(Theme.text(14, .bold)).foregroundColor(Theme.sub)
                                Circle().fill(Profile.days[i].1 ? Theme.blue : Theme.line)
                                    .frame(width: 34, height: 34)
                                    .overlay { if Profile.days[i].1 { Icon(d: "m6 12.5 4 4 8-9", size: 20, stroke: 3, color: .white) } }
                            }.frame(maxWidth: .infinity)
                        }
                    }
                }
                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(metric == 0 ? "Accuracy" : "Seconds per question").font(Theme.round(20, .heavy))
                            Spacer()
                            Picker("", selection: $metric) { Text("Accuracy").tag(0); Text("Speed").tag(1) }
                                .pickerStyle(.segmented).frame(width: 220)
                        }
                        TrendChart(values: metric == 0 ? Profile.acc : Profile.spd, lo: metric == 0 ? 50 : 20, hi: metric == 0 ? 100 : 50)
                            .frame(height: 150)
                        HStack {
                            ForEach(Profile.weeks, id: \.self) { w in
                                Text(w).font(Theme.text(12, .semibold)).foregroundColor(Theme.muted).frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                HStack(alignment: .top, spacing: 16) {
                    Card { bullets("What they learned", learned) }
                    Card { bullets("Still tricky", tricky) }
                }
                Card {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Badges").font(Theme.round(20, .heavy))
                            Spacer()
                            Text("\(s.earned.filter { $0 }.count) of 4 earned").font(Theme.text(14, .semibold)).foregroundColor(Theme.sub)
                        }
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(0..<4, id: \.self) { i in BadgeTile(name: Profile.badges[i].0, sub: Profile.badges[i].1, got: s.earned[i]) }
                        }
                    }
                }
                Card {
                    VStack(spacing: 14) {
                        Toggle(isOn: $s.remOn) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Daily reminder").font(Theme.round(20, .heavy))
                                Text(s.remOn ? "Every day at \(s.formatClock(s.rem))" : "Off").font(Theme.text(15, .medium)).foregroundColor(Theme.sub)
                            }
                        }.onChange(of: s.remOn) { _, _ in s.save() }
                        if s.remOn {
                            Stepper("Reminder time: \(s.formatClock(s.rem))", value: $s.rem, in: 360...1380, step: 15)
                                .font(Theme.text(16, .semibold)).onChange(of: s.rem) { _, _ in s.save() }
                        }
                        Stepper("Daily goal: \(s.session) min", value: $s.session, in: 5...60, step: 5)
                            .font(Theme.text(16, .semibold)).onChange(of: s.session) { _, _ in s.save() }
                    }
                }
                Button("Reset all progress") { confirmReset = true }
                    .font(Theme.text(16, .semibold)).foregroundColor(Theme.orange).padding(.top, 4)
            }
            .padding(.horizontal, 36).padding(.top, 36).padding(.bottom, 130)
        }
        .frame(width: Canvas.w, height: Canvas.h)
        .confirmationDialog("Reset all progress?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { nav.store.reset(); nav.go(.name, forward: false) }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func learnedLines(_ s: Store) -> [String] {
        var out: [String] = []
        if s.frac != .new { out.append("Adding fractions with different bottoms, using the crosswise trick.") }
        if !s.scores.isEmpty { out.append("Finished \(s.scores.count) quiz\(s.scores.count == 1 ? "" : "zes").") }
        if out.isEmpty { out.append("Their first lesson is ready when they are.") }
        return out
    }

    private func trickyLines() -> [String] {
        let wrongs = nav.quiz.records.filter { !$0.ok }
        var out: [String] = []
        if wrongs.contains(where: { $0.part == .top || $0.part == .both }) { out.append("Adding the two crosswise results for the top number.") }
        if wrongs.contains(where: { $0.part == .bot || $0.part == .both }) { out.append("Multiplying the two bottom numbers.") }
        if out.isEmpty { out.append("Nothing flagged this week.") }
        return out
    }

    private func bullets(_ title: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(Theme.round(20, .heavy))
            ForEach(items, id: \.self) { t in
                HStack(alignment: .top, spacing: 8) {
                    Circle().fill(Theme.blue).frame(width: 6, height: 6).padding(.top, 8)
                    Text(t).font(Theme.text(16, .medium)).foregroundColor(Theme.body)
                }
            }
        }
    }
}

struct TrendChart: View {
    var values: [Int]; var lo: Double; var hi: Double
    var body: some View {
        GeometryReader { g in
            let n = values.count
            let pts: [CGPoint] = values.enumerated().map { i, v in
                CGPoint(x: 12 + CGFloat(i) * (g.size.width - 24) / CGFloat(n - 1),
                        y: g.size.height - 10 - CGFloat((Double(v) - lo) / (hi - lo)) * (g.size.height - 20))
            }
            ZStack {
                Path { p in p.move(to: pts[0]); for q in pts.dropFirst() { p.addLine(to: q) } }
                    .stroke(Theme.blue, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                ForEach(0..<n, id: \.self) { i in
                    Circle().fill(i == n - 1 ? Theme.blue : .white)
                        .overlay(Circle().stroke(Theme.blue, lineWidth: i == n - 1 ? 3 : 2.5))
                        .frame(width: i == n - 1 ? 14 : 9, height: i == n - 1 ? 14 : 9)
                        .position(pts[i])
                }
            }
            .animation(.timingCurve(0.32, 0.72, 0, 1, duration: 0.7), value: values)
        }
    }
}

struct ProfileScreen: View {
    @Environment(Nav.self) private var nav
    @State private var editing = false
    @State private var langOpen = false
    @FocusState private var nameFocus: Bool

    var body: some View {
        @Bindable var s = nav.store
        let nm = s.trimmedName
        let ava = Profile.swatches[s.avatar]
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    LinearGradient(colors: [Color(hex: 0x2b95ff), Color(hex: 0x0a74e8)], startPoint: .top, endPoint: .bottom)
                    VStack(spacing: 12) {
                        Text(nm.isEmpty ? "" : String(nm.prefix(1)).uppercased())
                            .font(Theme.round(52, .black)).foregroundColor(.white)
                            .frame(width: 112, height: 112)
                            .background(Circle().fill(nm.isEmpty ? Color(hex: 0x9fc7f5) : ava))
                            .overlay(Circle().stroke(.white, lineWidth: 5))
                        if editing {
                            TextField("Add your name", text: $s.name)
                                .focused($nameFocus)
                                .font(Theme.round(30, .black)).foregroundColor(.white).multilineTextAlignment(.center)
                                .onSubmit { finishEdit() }
                            HStack(spacing: 14) {
                                ForEach(0..<4, id: \.self) { i in
                                    Button { s.avatar = i; s.save() } label: {
                                        Circle().fill(Profile.swatches[i]).frame(width: 30, height: 30)
                                            .overlay(Circle().stroke(.white, lineWidth: s.avatar == i ? 3 : 0).padding(-3))
                                    }.accessibilityLabel("Avatar colour \(i + 1)")
                                }
                            }
                        } else {
                            Text(nm.isEmpty ? "Add your name" : nm).font(Theme.round(32, .black)).foregroundColor(.white)
                        }
                        Text("Basics \u{00B7} \(s.basicsDone) of \(s.basicsTotal) sutras")
                            .font(Theme.text(16, .semibold)).foregroundColor(.white.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity).padding(.top, 36).padding(.bottom, 28)
                    Button { toggleEdit() } label: {
                        Icon(d: editing ? "m5.5 12.5 4.5 4.5 8.5-9.5" : "M4 20l1.2-4.4L15.6 5.2a2 2 0 0 1 2.8 0l.4.4a2 2 0 0 1 0 2.8L8.4 18.8zM13.8 7l3.2 3.2",
                             size: 24, stroke: 2.4, color: editing ? Color(hex: 0x0a74e8) : .white)
                            .frame(width: 52, height: 52)
                            .background(Circle().fill(editing ? Color.white : Color.white.opacity(0.16)))
                    }
                    .buttonStyle(PressStyle()).padding(28)
                    .accessibilityLabel(editing ? "Done editing" : "Edit profile")
                    Button { nav.go(nav.profFrom, forward: false) } label: {
                        Icon(d: IconPath.back, size: 22, stroke: 2.6, color: .white).frame(width: 52, height: 52)
                            .background(Circle().fill(Color.white.opacity(0.16)))
                    }
                    .buttonStyle(PressStyle()).padding(28).frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: 14) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        stat("Day streak", "1 day", Theme.orange, Color(hex: 0xfff3e6), "flame.fill")
                        stat("Badges", "\(s.earned.filter { $0 }.count) of 4", Theme.blue, Theme.soft, "star.fill")
                        stat("Quizzes taken", "\(s.scores.count)", Theme.green, Color(hex: 0xe8f7ef), "checklist")
                        stat("Member since", "Oct 2026", Color(hex: 0x6a4fe6), Color(hex: 0xf1eeff), "calendar")
                    }
                    Card {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Badges").font(Theme.round(20, .heavy))
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(0..<4, id: \.self) { i in BadgeTile(name: Profile.badges[i].0, sub: Profile.badges[i].1, got: s.earned[i]) }
                            }
                        }
                    }
                    Card {
                        VStack(spacing: 12) {
                            Toggle(isOn: $s.narrOn) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Read lessons aloud").font(Theme.round(20, .heavy))
                                    Text("Narration while you watch").font(Theme.text(15, .medium)).foregroundColor(Theme.sub)
                                }
                            }.onChange(of: s.narrOn) { _, _ in s.saveNarration() }
                            Menu {
                                ForEach(Profile.langs, id: \.id) { l in
                                    Button("\(l.name) \u{00B7} \(l.native)") { s.narrLang = l.id; s.narrOn = true; s.saveNarration() }
                                }
                            } label: {
                                HStack {
                                    Text("Language").font(Theme.text(16, .semibold)).foregroundColor(Theme.ink)
                                    Spacer()
                                    Text((Profile.langs.first { $0.id == s.narrLang } ?? Profile.langs[0]).native)
                                        .font(Theme.text(16, .bold)).foregroundColor(Theme.blue)
                                    Image(systemName: "chevron.up.chevron.down").font(.system(size: 12)).foregroundColor(Theme.muted)
                                }
                            }
                        }
                    }
                    Button { nav.flash("Sign in with Apple is not wired up yet.") } label: {
                        HStack(spacing: 8) { Image(systemName: "apple.logo"); Text("Sign in with Apple") }
                            .font(Theme.text(17, .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 54).background(Capsule().fill(Theme.ink))
                    }.buttonStyle(PressStyle())
                }
                .padding(.horizontal, 36).padding(.top, 20).padding(.bottom, 130)
            }
        }
        .frame(width: Canvas.w, height: Canvas.h)
        .ignoresSafeArea(edges: .top)
    }

    private func toggleEdit() {
        if editing { finishEdit() } else { editing = true; langOpen = false; nameFocus = true }
    }

    private func finishEdit() {
        editing = false
        nav.store.name = nav.store.trimmedName
        nav.store.save()
    }

    private func stat(_ l: String, _ v: String, _ c: Color, _ bg: Color, _ sym: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: sym).font(.system(size: 20, weight: .semibold)).foregroundColor(c)
                .frame(width: 48, height: 48).background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(bg))
            VStack(alignment: .leading, spacing: 1) {
                Text(l).font(Theme.text(14, .semibold)).foregroundColor(Theme.sub)
                Text(v).font(Theme.round(22, .heavy))
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.white))
        .shadow(color: Theme.shadow.opacity(0.05), radius: 8, x: 0, y: 6)
    }
}
