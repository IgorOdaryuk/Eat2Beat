//
//  Core.swift
//  Eat2Beat MVP
//
//  Created by Igor Odaryuk on 05.09.2025.
//

import Foundation
import SwiftUI
import PhotosUI

// MARK: - Models
struct Activity: Identifiable, Hashable {
    let name: String
    let met: Double
    var id: String { name }
}

struct WorkoutEstimate: Identifiable {
    let activity: Activity
    let minutes: Int
    var id: String { activity.name }
}

struct FoodGuess: Identifiable {
    let label: String
    let confidence: Double
    var id: String { label }
}

// MARK: - Services
protocol FoodRecognitionService {
    func detectFood(in image: UIImage) async throws -> [FoodGuess]
}

/// Заглушка распознавания. Позже подключим реальный API.
final class StubFoodRecognitionService: FoodRecognitionService {
    func detectFood(in image: UIImage) async throws -> [FoodGuess] {
        return [
            FoodGuess(label: "pizza", confidence: 0.78),
            FoodGuess(label: "burger", confidence: 0.14),
            FoodGuess(label: "pasta", confidence: 0.08)
        ]
    }
}

/// Простая таблица калорий. Потом заменим на USDA/Nutritionix.
struct CalorieLookupService {
    static func calories(for label: String) -> Int? {
        let map: [String: Int] = [
            "pizza": 285,   // за кусок
            "burger": 540,
            "fries": 365,
            "pasta": 400,
            "salad": 150,
            "sushi": 200,
            "donut": 300
        ]
        return map[label.lowercased()]
    }
}

// MARK: - Calculator
struct BurnCalculator {
    /// Calories per minute = (MET * 3.5 * kg) / 200
    static func minutes(toBurn calories: Double, weightKg: Double, met: Double) -> Double {
        let perMinute = (met * 3.5 * weightKg) / 200.0
        guard perMinute > 0 else { return 0 }
        return calories / perMinute
    }
}

// MARK: - App State
@MainActor
final class AppState: ObservableObject {
    @Published var weightKg: Double = 75
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var detected: [FoodGuess] = []
    @Published var caloriesInput: String = ""
    @Published var estimates: [WorkoutEstimate] = []
    @Published var isDetecting: Bool = false

    private let recognizer: FoodRecognitionService = StubFoodRecognitionService()

    let activities: [Activity] = [
        Activity(name: "Walking (brisk)", met: 3.5),
        Activity(name: "Running (8 km/h)", met: 8.0),
        Activity(name: "Cycling (moderate)", met: 6.8),
        Activity(name: "Swimming", met: 6.0),
        Activity(name: "Jump rope", met: 12.3),
        Activity(name: "Strength (moderate)", met: 5.0)
    ]

    func loadImage() async {
        guard let item = selectedItem else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                try await detectFood()
            }
        } catch {
            print("Image load error: \(error)")
        }
    }

    func detectFood() async throws {
        guard let img = selectedImage else { return }
        isDetecting = true
        defer { isDetecting = false }
        let guesses = try await recognizer.detectFood(in: img)
        detected = guesses
        if let top = guesses.first, let kcal = CalorieLookupService.calories(for: top.label) {
            caloriesInput = String(kcal)
            recalc()
        }
    }

    func recalc() {
        guard let cals = Double(caloriesInput), cals > 0 else {
            estimates = []
            return
        }
        estimates = activities.map { act in
            let minutes = BurnCalculator.minutes(toBurn: cals, weightKg: weightKg, met: act.met)
            return WorkoutEstimate(activity: act, minutes: max(1, Int(minutes.rounded())))
        }
    }
}
