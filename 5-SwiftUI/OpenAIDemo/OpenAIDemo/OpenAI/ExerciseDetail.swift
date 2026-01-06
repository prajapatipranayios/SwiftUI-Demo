//
//  ExerciseDetail.swift
//  OpenAIDemo
//
//  Created by Auxano on 29/12/25.
//


import Foundation

struct ExerciseDetail: Codable {

    var exercise_uid: String
    let name: String
    let category: String
    let type: String
    let difficulty: String
    let equipment: String
    let workout_location: String
    let video_url: String
    let thumbnail_url: String
    let description: String
    let primary_muscles: String
    let secondary_muscles: String
    let default_sets: String
    let default_reps: String
    let duration_seconds: String
    let rest_seconds: String
    let calories_per_minute: String
    let goal_tags: String
    let medical_restrictions: String
    let injury_avoid: String
    let injury_modify: String
    let movement_restrictions: String
    let tags: String
    let notes: String
}


struct MealDetail: Codable {
    
    let meal_uid: String
    let name: String
    let category: String
    let diet_type: String
    let cuisine: String
    let serving: String
    let calories: String
    let protein: String
    let carbs: String
    let fat: String
    let allergens: String
    let food_restrictions: String
    let medical_restrictions: String
    let image_url: String
    let ingredients: String
    let tags: String
    let notes: String
}
