//
//  ContentView.swift
//  Eat2Beat MVP
//
//  Created by Igor Odaryuk on 05.09.2025.
//

import SwiftUI
import PhotosUI
import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var state = AppState()

    // Theme storage
    @AppStorage("appearance") private var appearanceRaw: String = AppAppearance.system.rawValue
    private var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRaw) ?? .system }
        set { appearanceRaw = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    appearancePicker
                    picker

                    if let ui = state.selectedImage {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(16)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    }

                    inputSection
                    results
                }
                .padding(.vertical)
            }
            .navigationTitle("Eat2Beat")
        }
        .preferredColorScheme(appearance.colorScheme)
        .onChange(of: state.selectedItem) { _ in
            Task { await state.loadImage() }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 6) {
            Text("Snap your food → get the gym price")
                .font(.headline)
            Text("Convert calories to workout minutes. Enter calories or pick a photo.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var appearancePicker: some View {
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
    }

    private var picker: some View {
        HStack(spacing: 12) {
            PhotosPicker(selection: $state.selectedItem, matching: .images) {
                Label("Choose Photo", systemImage: "photo")
            }
            .buttonStyle(.bordered)

            Button {
                state.selectedImage = nil
                state.detected = []
                state.caloriesInput = ""
                state.estimates = []
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if state.isDetecting {
                ProgressView("Detecting food…")
            }

            if !state.detected.isEmpty {
                HStack {
                    Text("Looks like:")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(state.detected) { g in
                                Text("\(g.label) • \(Int(g.confidence * 100))%")
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.gray.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }

            HStack {
                Text("Weight, kg")
                Slider(value: $state.weightKg, in: 40...130, step: 1) {
                    Text("Weight")
                }
                Text("\(Int(state.weightKg))")
                    .frame(width: 36)
            }

            HStack {
                Text("Calories")
                TextField("e.g. 540", text: $state.caloriesInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                Button("Calculate") { state.recalc() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 4)
        }
        .padding()
    }

    private var results: some View {
        VStack(alignment: .leading, spacing: 8) {
            if state.estimates.isEmpty {
                Text("Workout minutes will appear here.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(state.estimates) { est in
                    HStack {
                        Text(est.activity.name)
                        Spacer()
                        Text("\(est.minutes) min")
                            .monospacedDigit()
                    }
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                }
                Text("Formula: minutes = calories / ((MET × 3.5 × weight)/200)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }
        }
    }
}
