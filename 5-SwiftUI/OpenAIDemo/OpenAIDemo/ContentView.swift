//
//  ContentView.swift
//  OpenAIDemo
//
//  Created by Auxano on 29/12/25.
//

import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    
    @StateObject private var viewModel = ChatViewModel()
    @State private var csvData: [ExerciseInput] = []
    @State private var csvMealData: [MealInput] = []
    @State private var showFilePicker = false

    @State private var intArrayIndex: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Button {
                    showFilePicker = true
                } label: {
                    Text("Upload CSV File")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
//                if !csvData.isEmpty {
//                    List(csvData.indices, id: \.self) { index in
//                        let item = csvData[index]
//                        VStack(alignment: .leading) {
//                            Text(item.exercise)
//                                .font(.headline)
//                            Text("Body Part: \(item.bodyPart)")
//                            Text("Gender: \(item.preferredGender)")
//                        }
//                    }
//                    .frame(height: 250)
//                }
                
                if !csvMealData.isEmpty {
                    List(csvMealData.indices, id: \.self) { index in
                        let item = csvMealData[index]
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text("Category: \(item.category)")
                        }
                    }
                    .frame(height: 250)
                }
                
                /*TextEditor(text: $viewModel.prompt)
                    .frame(height: 120)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))  /// */
                
                Button {
                    //sendExercisePrompt(index: self.intArrayIndex)
                    sendMealPrompt(index: self.intArrayIndex)
                } label: {
                    Text("Send Prompt")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                ScrollView {
                    Text(viewModel.response)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("OpenAI Chat")
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        //csvData = readCSVFromURL(url)
                        csvMealData = readMealCSVFromURL(url)
                        print("Loaded rows:", csvMealData.count)
                    }
                case .failure(let error):
                    print("File import error:", error)
                }
            }

        }
    }
    
    // MARK: From Bundle
    /*func readCSV(fileName: String) -> [ExerciseInput] {
        
        var result: [ExerciseInput] = []
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
            print("CSV file not found")
            return []
        }
        
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let rows = data.components(separatedBy: "\n")
            
            for (index, row) in rows.enumerated() {
                if index == 0 { continue } // skip header
                
                let columns = row.components(separatedBy: ",")
                if columns.count >= 3 {
                    let item = ExerciseInput(
                        bodyPart: columns[0].trimmingCharacters(in: .whitespaces),
                        exercise: columns[1].trimmingCharacters(in: .whitespaces),
                        preferredGender: columns[2].trimmingCharacters(in: .whitespaces)
                    )
                    result.append(item)
                }
            }
        } catch {
            print("Error reading CSV: \(error)")
        }
        
        return result
    }   ///  */

    func readCSVFromURL(_ url: URL) -> [ExerciseInput] {

        var result: [ExerciseInput] = []

        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            let rows = data.components(separatedBy: .newlines)

            for (index, row) in rows.enumerated() {
                if index == 0 || row.isEmpty { continue }

                let columns = row.components(separatedBy: ",")

                if columns.count >= 3 {
                    result.append(
                        ExerciseInput(
                            bodyPart: columns[0].trimmingCharacters(in: .whitespaces),
                            exercise: columns[1].trimmingCharacters(in: .whitespaces),
                            preferredGender: columns[2].trimmingCharacters(in: .whitespaces)
                        )
                    )
                }
            }
        } catch {
            print("CSV read error:", error)
        }

        return result
    }
    
    func readMealCSVFromURL(_ url: URL) -> [MealInput] {

        var result: [MealInput] = []

        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            let rows = data.components(separatedBy: .newlines)

            for (index, row) in rows.enumerated() {
                if index == 0 || row.isEmpty { continue }

                let columns = parseCSVLine(row)

                if columns.count >= 2 {
                    result.append(
                        MealInput(
                            name: columns[1],
                            category: columns[0]
                        )
                    )
                }
            }
        } catch {
            print("CSV read error:", error)
        }

        return result
    }
    
    func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var insideQuotes = false
        
        var iterator = line.makeIterator()
        while let char = iterator.next() {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        
        return result.map {
            $0.trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }
    }
    
    func sendExercisePrompt(index: Int = 0) {
        
        guard csvData.indices.contains(index) else {
            print("Index out of range")
            return
        }
        
        let item = csvData[index]
        
        let prompt = """
        You are a fitness exercise data generator.

        You will be given:
        - Body Part
        - Exercise Name
        - Preferred Gender

        Your task:
        - Generate structured exercise data
        - Return ONLY valid JSON
        - NEVER remove any key
        - NEVER change key names
        - If a value is unknown, return an empty string ""
        - Do NOT add explanations, comments, or extra text

        CRITICAL OUTPUT RULES (MUST FOLLOW):
        - EVERY value MUST be a STRING
        - NEVER return numbers, arrays, objects, or null
        - NEVER return lists like ["a","b"]
        - Multiple values MUST be a single comma-separated STRING

        ACCURACY RULE (VERY IMPORTANT):
        - Before generating the final JSON, internally analyze ALL possible exercise variations
        - Use standard fitness knowledge and common industry practices
        - Choose the MOST accurate and widely accepted values
        - Prefer realistic defaults used by professional trainers
        - If multiple values are possible, select the most common and safest option
        - DO NOT expose this reasoning in the output

        Examples:
        "primary_muscles": "Deltoids, Triceps"
        "default_sets": "4"
        "duration_seconds": "45"
        "goal_tags": "Strength, Hypertrophy"

        -----------------------------------
        FIELD RULES (STRICT):
        -----------------------------------

        exercise_uid:
        - Use the provided exercise_uid exactly
        - Example: "ex001"

        name:
        - Exercise name as a string
        - Example: "Overhead Barbell Press"

        category:
        - One of: Strength, Cardio, Mobility, Stretching
        - Example: "Strength"

        type:
        - One of: Compound, Isolation
        - Example: "Compound"

        difficulty:
        - One of: Beginner, Intermediate, Advanced
        - Example: "Intermediate"

        equipment:
        - Single string
        - Example: "Barbell"

        workout_location:
        - One of: Gym, Home, Both
        - Example: "Gym"

        video_url:
        - Valid URL string or empty string ""
        - Example: ""

        thumbnail_url:
        - Valid URL string or empty string ""
        - Example: ""

        description:
        - Short human-readable description
        - Example: "A shoulder exercise performed by pressing a barbell overhead."

        primary_muscles:
        - Single comma-separated string
        - Example: "Deltoids"

        secondary_muscles:
        - Single comma-separated string
        - Example: "Triceps, Upper Chest"

        default_sets:
        - Numeric value as STRING
        - Example: "4"

        default_reps:
        - Numeric value as STRING
        - Example: "8", "10", "12"

        duration_seconds:
        - Numeric value as STRING
        - Example: "45"

        rest_seconds:
        - Numeric value as STRING
        - Example: "60"

        calories_per_minute:
        - Decimal or integer as STRING
        - Example: "8.5", "7"

        goal_tags:
        - Comma-separated string
        - Example: "Strength, Hypertrophy"

        medical_restrictions:
        - Short text or empty string
        - Example: "Shoulder Injury"

        injury_avoid:
        - Short text or empty string
        - Example: "Rotator cuff strain"

        injury_modify:
        - Short text or empty string
        - Example: "Use lighter weights"

        movement_restrictions:
        - Short text or empty string
        - Example: ""

        tags:
        - Comma-separated string
        - Example: "Shoulders, Barbell"

        notes:
        - Short text or empty string
        - Example: ""

        -----------------------------------
        INPUT:
        -----------------------------------
        Body Part: \(item.bodyPart)
        Exercise: \(item.exercise)
        Preferred Gender: \(item.preferredGender)

        -----------------------------------
        OUTPUT FORMAT:
        -----------------------------------
        Return ONLY valid JSON.
        All values MUST be enclosed in double quotes.
        """     /// */

        //viewModel.sendStructuredPrompt(prompt)
        
        Task {
            do {
                let result = try await viewModel.sendStructuredPrompt(prompt: prompt)
                if let exercise = decodeExercise(result) {
                    await saveExerciseResponseToCSV(exercise)
                }
            } catch {
                print("Error:", error)
            }
        }
    }
    
    func sendMealPrompt(index: Int = 0) {
        
        guard csvMealData.indices.contains(index) else {
            print("Index out of range")
            return
        }
        
        let item = csvMealData[index]
        
        /*let prompt = """
                You are a professional fitness nutrition data generator used in production fitness and diet applications.
                
                You will be given:
                - Meal Name
                - Category
                
                Your task:
                - Generate structured meal nutrition data
                - Return ONLY valid JSON
                - NEVER remove any key
                - NEVER change key names
                - NEVER add new keys
                - NEVER add explanations, comments, or extra text
                
                --------------------------------------------------
                CRITICAL OUTPUT RULES (MANDATORY)
                --------------------------------------------------
                - EVERY value MUST be a STRING
                - NEVER return numbers, arrays, objects, or null
                - NEVER return lists like ["a","b"]
                - Multiple values MUST be a single comma-separated STRING
                - ALL keys MUST always be present in the output
                
                --------------------------------------------------
                FALLBACK & COMPLETENESS RULE (VERY IMPORTANT)
                --------------------------------------------------
                - NO field is allowed to be empty unless explicitly permitted
                - calories, protein, carbs, fat MUST NEVER be empty
                - If an exact value is unknown, infer a realistic average
                - Use standard raw food values per 100 grams as the nutrition base
                - Vegetables MUST always have calories, protein, carbs, and fat populated
                - Be conservative and realistic, but NEVER leave nutrition fields empty
                
                --------------------------------------------------
                SERVING RULE (GLOBAL FIXED STANDARD – CRITICAL)
                --------------------------------------------------
                - Nutrition values MUST always be based on standard raw food values per 100 grams
                - The `serving` field MUST use a fixed global serving count
                - NEVER return "100 grams" as serving
                - DO NOT invent new serving types
                - DO NOT use ranges
                - DO NOT expose gram values in output
                
                GLOBAL FIXED SERVING STANDARD:
                - Leafy greens (raw): "1 bowl"
                - Leafy greens (cooked): "1 bowl"
                - Fresh herbs (coriander, mint): "1 bowl"
                - Plate-based meals: "1 plate"
                - Small whole items: "2 pieces"
                - Idli-based meals: "3 idlis"
                
                RULES:
                - Always select ONE of the above serving labels
                - Calories, protein, carbs, and fat MUST be internally scaled to the selected serving
                - Output ONLY the serving label (example: "1 bowl")
                
                --------------------------------------------------
                MEDICAL & FOOD RESTRICTION SEMANTIC RULE (CRITICAL)
                --------------------------------------------------
                IMPORTANT DEFINITIONS (MUST FOLLOW EXACTLY):
                
                medical_restrictions:
                - This field means: WHO SHOULD NOT EAT THIS MEAL
                - List ONLY medical conditions where this meal should be AVOIDED
                - DO NOT list conditions where the meal is beneficial or safe
                - If the meal is generally safe for most people, return an empty string ""
                
                food_restrictions:
                - This field means: DIETARY COMPATIBILITY of the meal
                - It describes which dietary restrictions this meal COMPLIES WITH
                - Examples: soy_free, nut_free, gluten_free, dairy_free
                - These values indicate the meal DOES NOT CONTAIN these items
                - Multiple values must be a comma-separated STRING
                - Use empty string "" only if no clear compatibility applies
                
                Examples:
                - Spinach:
                  - medical_restrictions: ""
                  - food_restrictions: "soy_free, nut_free, gluten_free, dairy_free"
                
                - High-sugar dessert:
                  - medical_restrictions: "diabetes"
                  - food_restrictions: ""
                
                - Peanut-based meal:
                  - medical_restrictions: ""
                  - food_restrictions: "soy_free"
                
                --------------------------------------------------
                ACCURACY RULE
                --------------------------------------------------
                - Internally analyze common fitness nutrition standards
                - Use values commonly used by professional dieticians and fitness apps
                - Prefer safe, average, widely accepted nutrition values
                - If multiple values are possible, choose the most common one
                - DO NOT expose reasoning in the output
                
                --------------------------------------------------
                FIELD RULES (STRICT)
                --------------------------------------------------
                
                meal_uid:
                - Use the provided meal_uid exactly
                
                name:
                - Meal name as a string
                
                category:
                - One of: Breakfast, Lunch, Dinner, Snack
                
                diet_type:
                - One of: Vegetarian, Vegan, Non-Vegetarian, Keto, Paleo
                - Vegetables MUST be Vegetarian or Vegan
                
                cuisine:
                - Cuisine name as a string (e.g., Indian, Asian, Mediterranean, Global)
                
                serving:
                - Human-friendly serving description
                - Must be ONE of: "1 bowl", "1 plate", "2 pieces", "3 idlis"
                
                calories:
                - Numeric value as STRING
                - MUST NOT be empty
                
                protein:
                - Numeric grams as STRING
                - MUST NOT be empty
                
                carbs:
                - Numeric grams as STRING
                - MUST NOT be empty
                
                fat:
                - Numeric grams as STRING
                - MUST NOT be empty
                
                allergens:
                - List ONLY allergens PRESENT in the meal
                - Comma-separated STRING or empty string ""
                
                food_restrictions:
                - List ONLY dietary restrictions the meal COMPLIES WITH
                - Empty string "" if none
                
                medical_restrictions:
                - List ONLY medical conditions that must AVOID this meal
                - Empty string "" if generally safe
                
                image_url:
                - Valid URL string or empty string ""
                
                ingredients:
                - Comma-separated STRING
                
                tags:
                - Comma-separated STRING
                
                notes:
                - Short text or empty string ""
                
                --------------------------------------------------
                INPUT
                --------------------------------------------------
                Meal Name: \(item.name)
                Category: \(item.category)
                
                --------------------------------------------------
                OUTPUT FORMAT
                --------------------------------------------------
                Return ONLY valid JSON.
                All values MUST be enclosed in double quotes.
                """ ///  */

        let prompt = """
                        You are a professional fitness nutrition data generator used in production fitness and diet applications.
                        
                        You will be given:
                        - Meal Name
                        - Category
                        
                        Your task:
                        - Generate structured meal nutrition data
                        - Return ONLY valid JSON
                        - NEVER remove any key
                        - NEVER change key names
                        - NEVER add new keys
                        - NEVER add explanations, comments, or extra text
                        
                        --------------------------------------------------
                        CRITICAL OUTPUT RULES (MANDATORY)
                        --------------------------------------------------
                        - EVERY value MUST be a STRING
                        - NEVER return numbers, arrays, objects, or null
                        - NEVER return lists like ["a","b"]
                        - Multiple values MUST be a single comma-separated STRING
                        - ALL keys MUST always be present in the output
                        
                        --------------------------------------------------
                        FALLBACK & COMPLETENESS RULE (VERY IMPORTANT)
                        --------------------------------------------------
                        - NO field is allowed to be empty unless explicitly permitted
                        - calories, protein, carbs, fat MUST NEVER be empty
                        - If an exact value is unknown, infer a realistic average
                        - Use standard raw food values per 100 grams as the nutrition base
                        - Vegetables MUST always have calories, protein, carbs, and fat populated
                        - Be conservative and realistic, but NEVER leave nutrition fields empty
                        
                        --------------------------------------------------
                        SERVING RULE (GLOBAL FIXED STANDARD – CRITICAL)
                        --------------------------------------------------
                        - Nutrition values MUST always be based on standard raw food values per 100 grams
                        - The `serving` field MUST be a human-friendly serving description
                        - The serving MUST include an approximate weight in parentheses
                        
                        SERVING FORMAT (MANDATORY):
                        - "<serving unit> (about <grams> grams)"
                        
                        Examples:
                        - "1 cup (about 50 grams)"
                        - "1 bowl (about 35 grams)"
                        - "1 bowl (about 170 grams)"
                        - "2 pieces (about 80 grams)"
                        - "3 idlis (about 120 grams)"
                        
                        RULES:
                        - Always use the word "about" before grams
                        - Grams value MUST be realistic and globally accepted
                        - NEVER expose calculations
                        - NEVER use ranges
                        - Calories, protein, carbs, and fat MUST be internally scaled to the stated serving
                        
                        --------------------------------------------------
                        MEDICAL & FOOD RESTRICTION SEMANTIC RULE (CRITICAL)
                        --------------------------------------------------
                        IMPORTANT DEFINITIONS (MUST FOLLOW EXACTLY):
                        
                        medical_restrictions:
                        - This field means: WHO SHOULD NOT EAT THIS MEAL
                        - List ONLY medical conditions where this meal should be AVOIDED
                        - DO NOT list conditions where the meal is beneficial or safe
                        - If the meal is generally safe for most people, return an empty string ""
                        
                        food_restrictions:
                        - This field means: DIETARY COMPATIBILITY of the meal
                        - It describes which dietary restrictions this meal COMPLIES WITH
                        - Examples: soy_free, nut_free, gluten_free, dairy_free
                        - These values indicate the meal DOES NOT CONTAIN these items
                        - Multiple values must be a comma-separated STRING
                        - Use empty string "" only if no clear compatibility applies
                        
                        --------------------------------------------------
                        ACCURACY RULE
                        --------------------------------------------------
                        - Internally analyze common fitness nutrition standards
                        - Use values commonly used by professional dieticians and fitness apps
                        - Prefer safe, average, widely accepted nutrition values
                        - If multiple values are possible, choose the most common one
                        - DO NOT expose reasoning in the output
                        
                        --------------------------------------------------
                        FIELD RULES (STRICT)
                        --------------------------------------------------
                        
                        meal_uid:
                        - Use the provided meal_uid exactly
                        
                        name:
                        - Meal name as a string
                        
                        category:
                        - Use EXACTLY the category value provided in the input
                        - DO NOT normalize, map, or restrict category values
                        
                        diet_type:
                        - One of: Vegetarian, Vegan, Non-Vegetarian, Keto, Paleo
                        - Vegetables MUST be Vegetarian or Vegan
                        
                        cuisine:
                        - Cuisine name as a string (e.g., Indian, Asian, Mediterranean, Global)
                        
                        serving:
                        - Human-friendly serving description WITH approximate grams
                        - MUST follow format: "<serving> (about <grams> grams)"
                        
                        calories:
                        - Numeric value as STRING
                        - MUST NOT be empty
                        
                        protein:
                        - Numeric grams as STRING
                        - MUST NOT be empty
                        
                        carbs:
                        - Numeric grams as STRING
                        - MUST NOT be empty
                        
                        fat:
                        - Numeric grams as STRING
                        - MUST NOT be empty
                        
                        allergens:
                        - List ONLY allergens PRESENT in the meal
                        - Comma-separated STRING or empty string ""
                        
                        food_restrictions:
                        - List ONLY dietary restrictions the meal COMPLIES WITH
                        - Empty string "" if none
                        
                        medical_restrictions:
                        - List ONLY medical conditions that must AVOID this meal
                        - Empty string "" if generally safe
                        
                        image_url:
                        - Valid URL string or empty string ""
                        
                        ingredients:
                        - Comma-separated STRING
                        
                        tags:
                        - Comma-separated STRING
                        
                        notes:
                        - Short text or empty string ""
                        
                        --------------------------------------------------
                        INPUT
                        --------------------------------------------------
                        Meal Name: \(item.name)
                        Category: \(item.category)
                        
                        --------------------------------------------------
                        OUTPUT FORMAT
                        --------------------------------------------------
                        Return ONLY valid JSON.
                        All values MUST be enclosed in double quotes.
                        """

        
        //viewModel.sendStructuredPrompt(prompt)
        
        Task {
            do {
                let result = try await viewModel.sendStructuredPrompt(prompt: prompt)
                if let meal = decodeMeal(result) {
                    await saveMealResponseToCSV(meal)
                }
            } catch {
                print("Error:", error)
            }
        }
    }
    
    func nextExerciseUID() -> String {
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "ex001"
        }
        let fileURL = docsURL.appendingPathComponent("response_data.csv")

        if !fileManager.fileExists(atPath: fileURL.path) {
            return "ex001"
        }

        do {
            let content = try String(contentsOf: fileURL)
            let lines = content.components(separatedBy: .newlines)
            let uids = lines.dropFirst() // skip header
                .compactMap { $0.components(separatedBy: ",").first }
                .filter { $0.starts(with: "ex") }

            if let lastUID = uids.last,
               let number = Int(lastUID.replacingOccurrences(of: "ex", with: "")) {
                let nextNumber = number + 1
                return String(format: "ex%03d", nextNumber)
            }
        } catch {
            print("Error reading CSV for UID:", error)
        }

        return "ex001"
    }

    func saveExerciseResponseToCSV(_ exercise: ExerciseDetail) async {
        let fileName = "response_data.csv"
        
        // Get Documents directory
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find documents directory")
            return
        }
        
        let fileURL = docsURL.appendingPathComponent(fileName)
        //print("CSV saved at:", fileURL.path)
        
        // Prepare CSV row (all fields, separated by comma)
        let row = [
            exercise.exercise_uid,
            exercise.name,
            exercise.category,
            exercise.type,
            exercise.difficulty,
            exercise.equipment,
            exercise.workout_location,
            exercise.video_url,
            exercise.thumbnail_url,
            exercise.description,
            exercise.primary_muscles,
            exercise.secondary_muscles,
            exercise.default_sets,
            exercise.default_reps,
            exercise.duration_seconds,
            exercise.rest_seconds,
            exercise.calories_per_minute,
            exercise.goal_tags,
            exercise.medical_restrictions,
            exercise.injury_avoid,
            exercise.injury_modify,
            exercise.movement_restrictions,
            exercise.tags,
            exercise.notes
        ]
        .map { csvSafe($0) }
        .joined(separator: ",") + "\n"
        
        // Check if file exists
        if !fileManager.fileExists(atPath: fileURL.path) {
            // Create file with header
            let header = """
            exercise_uid,name,category,type,difficulty,equipment,workout_location,video_url,thumbnail_url,description,primary_muscles,secondary_muscles,default_sets,default_reps,duration_seconds,rest_seconds,calories_per_minute,goal_tags,medical_restrictions,injury_avoid,injury_modify,movement_restrictions,tags,notes
            """
            do {
                //try (header + "\n" + row + "\n").write(to: fileURL, atomically: true, encoding: .utf8)
                try (header + "\n" + row).write(to: fileURL, atomically: true, encoding: .utf8)
                print("Index >>>>>>>>> \(intArrayIndex)")
                print("CSV created and row added at: \(fileURL.path)")
                
                self.intArrayIndex = self.intArrayIndex + 1
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 sec
                sendExercisePrompt(index: self.intArrayIndex)
            } catch {
                print("CSV write error: \(error)")
            }
        } else {
            // Append row
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                if let data = (row).data(using: .utf8) {
                    handle.write(data)
                    print("Index >>>>>>>>> \(intArrayIndex)")
                    print("Row appended to CSV at: \(fileURL.path)")
                    if self.intArrayIndex < 4 {
                        do {
                            self.intArrayIndex = self.intArrayIndex + 1
                            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 sec
                            sendExercisePrompt(index: self.intArrayIndex)
                        } catch {
                            print("CSV write error: \(error)")
                        }
                    }
                }
                handle.closeFile()
            }
        }
    }

    func saveMealResponseToCSV(_ meal: MealDetail) async {
        let fileName = "response_meal_data.csv"
        
        // Get Documents directory
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find documents directory")
            return
        }
        
        let fileURL = docsURL.appendingPathComponent(fileName)
        //print("CSV saved at:", fileURL.path)
        
        // Prepare CSV row (all fields, separated by comma)
        let row = [
            meal.meal_uid,
            meal.name,
            meal.category,
            meal.diet_type,
            meal.cuisine,
            meal.serving,
            meal.calories,
            meal.protein,
            meal.carbs,
            meal.fat,
            meal.allergens,
            meal.food_restrictions,
            meal.medical_restrictions,
            meal.image_url,
            meal.ingredients,
            meal.tags,
            meal.notes
        ]
        .map { csvSafe($0) }
        .joined(separator: ",") + "\n"
        
        print("\n\n\nNew Row >>>>>>>>> \(row)")
        
        // Check if file exists
        if !fileManager.fileExists(atPath: fileURL.path) {
            // Create file with header
            let header = """
                meal_uid,name,category,diet_type,cuisine,serving,calories,protein,carbs,fat,allergens,food_restrictions,medical_restrictions,image_url,ingredients,tags,notes
                """
            do {
                //try (header + "\n" + row + "\n").write(to: fileURL, atomically: true, encoding: .utf8)
                try (header + "\n" + row).write(to: fileURL, atomically: true, encoding: .utf8)
                print("Index >>>>>>>>> \(intArrayIndex)")
                print("CSV created and row added at: \(fileURL.path)")
                
                self.intArrayIndex = self.intArrayIndex + 1
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 sec
                sendMealPrompt(index: self.intArrayIndex)
            } catch {
                print("CSV write error: \(error)")
            }
        } else {
            // Append row
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                if let data = (row).data(using: .utf8) {
                    handle.write(data)
                    print("Index >>>>>>>>> \(intArrayIndex)")
                    print("Row appended to CSV at: \(fileURL.path)")
                    //if self.intArrayIndex < 99 {
                        do {
                            self.intArrayIndex = self.intArrayIndex + 1
                            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 sec
                            sendMealPrompt(index: self.intArrayIndex)
                        } catch {
                            print("CSV write error: \(error)")
                        }
                    //}
                }
                handle.closeFile()
            }
        }
    }

    func decodeExercise(_ content: String) -> ExerciseDetail? {
        guard let data = content.data(using: .utf8) else { return nil }
        do {
            let exercise = try JSONDecoder().decode(ExerciseDetail.self, from: data)
            return exercise
        } catch {
            print("JSON decode error:", error)
            return nil
        }
    }
    
    func decodeMeal(_ content: String) -> MealDetail? {
        guard let data = content.data(using: .utf8) else { return nil }
        do {
            let meal = try JSONDecoder().decode(MealDetail.self, from: data)
            return meal
        } catch {
            print("JSON decode error:", error)
            return nil
        }
    }
    
    /*func csvSafe(_ value: Any?) -> String {
        guard let value else { return "" }

        var string: String

        if let v = value as? String {
            string = v
        } else {
            string = "\(value)"
        }

        // Replace line breaks
        string = string
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")

        // Escape quotes
        string = string.replacingOccurrences(of: "\"", with: "\"\"")

        // Wrap in quotes ALWAYS (safest)
        return "\"\(string)\""
    }   /// */

    func csvSafe(_ value: Any?) -> String {
        guard let value else { return "\"\"" }

        var string = value as? String ?? "\(value)"

        string = string
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "„", with: "\"")
            .replacingOccurrences(of: "\"", with: "\"\"")

        return "\"\(string)\""
    }
    
    func escapeCSV(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")

        if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
            return "\"\(escaped)\""
        }
        return escaped
    }

}


#Preview {
    ContentView()
}
