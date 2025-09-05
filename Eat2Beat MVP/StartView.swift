//
//  StartView.swift
//  Eat2Beat MVP
//
//  Created by Igor Odaryuk on 05.09.2025.
//

import SwiftUI

struct StartView: View {
    @AppStorage("appearance") private var appearanceRaw = AppAppearance.system.rawValue
    private var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRaw) ?? .system }
        set { appearanceRaw = newValue.rawValue }
    }

    var onStart: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemIndigo), Color(.systemPurple), Color(.black)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 72, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.9))

                VStack(spacing: 8) {
                    Text("Eat2Beat")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                    Text("Turn food calories into minutes of exercise")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.horizontal)

                Picker("Theme", selection: Binding<AppAppearance>(
                    get: { AppAppearance(rawValue: appearanceRaw) ?? .system },
                    set: { appearanceRaw = $0.rawValue }
                )) {
                    Text("System").tag(AppAppearance.system)
                    Text("Light").tag(AppAppearance.light)
                    Text("Dark").tag(AppAppearance.dark)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                Button(action: onStart) {
                    Text("Start")
                        .fontWeight(.semibold)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 8, y: 4)
                }
                .padding(.horizontal)

                Spacer().frame(height: 20)
            }
            .padding(.top, 80)
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}
