//
//  ContentView.swift
//  Eat2Beat MVP
//
//  Created by Igor Odaryuk on 05.09.2025.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var state = AppState()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
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
        .onChange(of: state.selectedItem) { _ in
            Task { await state.loadImage() }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Сфоткай еду → получи цену в спорте")
                .font(.headline)
            Text("Пересчитаем калории в минуты активности. Введи калории вручную или выбери фото.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var picker: some View {
        HStack(spacing: 12) {
            PhotosPicker(selection: $state.selectedItem, matching: .images) {
                Label("Выбрать фото", systemImage: "photo")
            }
            .buttonStyle(.bordered)

            Button {
                state.selectedImage = nil
                state.detected = []
                state.caloriesInput = ""
                state.estimates = []
            } label: {
                Label("Сброс", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if state.isDetecting {
                ProgressView("Определяем еду…")
            }
            if !state.detected.isEmpty {
                HStack {
                    Text("Похоже на:")
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
                Text("Вес, кг")
                Slider(value: $state.weightKg, in: 40...130, step: 1) {
                    Text("Вес")
                }
                Text("\(Int(state.weightKg))")
                    .frame(width: 36)
            }
            HStack {
                Text("Калории")
                TextField("например 540", text: $state.caloriesInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                Button("Рассчитать") { state.recalc() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 4)
        }
        .padding()
    }

    private var results: some View {
        VStack(alignment: .leading, spacing: 8) {
            if state.estimates.isEmpty {
                Text("Здесь появятся минуты тренировки для сжигания калорий.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(state.estimates) { est in
                    HStack {
                        Text(est.activity.name)
                        Spacer()
                        Text("\(est.minutes) мин")
                            .monospacedDigit()
                    }
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                }
                Text("Формула: мин = калории / ((MET × 3.5 × вес)/200)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }
        }
    }
}
