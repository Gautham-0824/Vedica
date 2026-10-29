import SwiftUI

struct NameScreen: View {
    @Environment(Nav.self) private var nav
    @FocusState private var focused: Bool

    var body: some View {
        @Bindable var store = nav.store
        let ready = !store.trimmedName.isEmpty
        VStack(spacing: 18) {
            VedicaLogo(size: 72)
            Text("Vedica").font(Theme.round(52, .black)).tracking(-1.8)
            Text("Fast mental maths, the Vedic way.").font(Theme.text(20, .medium)).foregroundColor(Theme.sub)
            Text("What should we call you?").font(Theme.round(26, .heavy)).padding(.top, 28)
            TextField("Your first name", text: $store.name)
                .font(Theme.round(26, .heavy)).multilineTextAlignment(.center)
                .focused($focused)
                .submitLabel(.continue)
                .onSubmit { if ready { next() } }
                .frame(width: 400, height: 64)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(focused ? Theme.blue : Theme.line, lineWidth: 2))
            Button(action: next) {
                Text("Continue").font(Theme.text(17, .bold))
                    .foregroundColor(ready ? .white : Color(hex: 0xa9b5c4))
                    .frame(width: 400, height: 56)
                    .background(Capsule().fill(ready ? Theme.blue : Color(hex: 0xeef2f6)))
                    .shadow(color: ready ? Theme.blue.opacity(0.3) : .clear, radius: 12, x: 0, y: 10)
            }
            .buttonStyle(PressStyle())
            .disabled(!ready)
            .padding(.top, 4)
        }
        .frame(width: Canvas.w, height: Canvas.h)
    }

    private func next() {
        nav.store.name = nav.store.trimmedName
        nav.store.save()
        nav.go(.account)
    }
}

struct AccountScreen: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        let nm = nav.store.trimmedName
        VStack(spacing: 18) {
            TopBar(title: "Account", onBack: { nav.go(.name, forward: false) })
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .overlay {
            VStack(spacing: 16) {
                Text(nm.isEmpty ? "Nice to meet you." : "Nice to meet you, \(nm).")
                    .font(Theme.round(38, .black)).tracking(-1.2)
                Text("Sign in to keep your progress on every device.")
                    .font(Theme.text(19, .medium)).foregroundColor(Theme.sub)
                Button { nav.go(.showcase(0)) } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                        Text("Sign in with Apple")
                    }
                    .font(Theme.text(18, .bold)).foregroundColor(.white)
                    .frame(width: 360, height: 58)
                    .background(Capsule().fill(Theme.ink))
                }
                .buttonStyle(PressStyle())
                .padding(.top, 14)
                Button("Skip for now") { nav.go(.showcase(0)) }
                    .font(Theme.text(17, .semibold)).foregroundColor(Theme.sub)
                    .padding(.top, 4)
            }
        }
        .frame(width: Canvas.w, height: Canvas.h)
    }
}

struct ShowcaseScreen: View {
    @Environment(Nav.self) private var nav
    let index: Int
    @State private var drag: CGFloat = 0

    private let slides: [(String, String, String)] = [
        ("Learn interactively", "Watch every trick come alive, step by step.", "play.circle.fill"),
        ("Practice at your pace", "No clock. No pressure. Just you getting better.", "pencil.and.scribble"),
        ("Speed up your calculations", "Do in your head what others need a calculator for.", "bolt.fill"),
        ("Track your progress", "Watch yourself grow, one sutra at a time.", "chart.bar.fill"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { i in
                    Button { nav.go(.showcase(i)) } label: {
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.line).frame(height: 5)
                            Capsule().fill(Theme.blue).frame(width: i <= index ? 62 : 0, height: 5)
                        }
                        .frame(width: 62).padding(.vertical, 10).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(slides[i].0)
                }
            }
            .padding(.top, 34)

            HStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { i in
                    VStack(spacing: 18) {
                        Image(systemName: slides[i].2).font(.system(size: 120, weight: .regular))
                            .foregroundColor(Theme.blue)
                            .frame(width: 420, height: 320)
                            .background(RoundedRectangle(cornerRadius: 40, style: .continuous).fill(Theme.soft))
                        Text(slides[i].0).font(Theme.round(40, .black)).tracking(-1.2)
                        Text(slides[i].1).font(Theme.text(21, .medium)).foregroundColor(Theme.sub)
                    }
                    .frame(width: Canvas.w)
                }
            }
            .frame(width: Canvas.w * 4, alignment: .leading)
            .offset(x: -CGFloat(index) * Canvas.w + drag)
            .frame(width: Canvas.w, height: 560, alignment: .leading)
            .clipped()
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 8)
                .onChanged { v in
                    let dx = v.translation.width
                    drag = (index == 0 && dx > 0) || (index == 3 && dx < 0) ? dx / 3 : dx
                }
                .onEnded { v in
                    let dx = v.translation.width
                    withAnimation(.timingCurve(0.32, 0.72, 0, 1, duration: 0.55)) { drag = 0 }
                    if dx < -80 && index < 3 { nav.go(.showcase(index + 1)) }
                    else if dx > 80 && index > 0 { nav.go(.showcase(index - 1), forward: false) }
                })
            Spacer(minLength: 0)
            PrimaryPill(title: index == 3 ? "Start Learning" : "Next", minWidth: 200) {
                if index < 3 { nav.go(.showcase(index + 1)) }
                else { nav.store.onboarded = true; nav.store.save(); nav.go(.home) }
            }
            .padding(.bottom, 44)
        }
        .frame(width: Canvas.w, height: Canvas.h)
    }
}
