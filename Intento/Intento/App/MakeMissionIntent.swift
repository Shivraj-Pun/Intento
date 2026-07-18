import AppIntents

// MARK: - General Shopping Intent

struct MakeMissionIntent: AppIntent {
    static var title: LocalizedStringResource = "Make a shopping cart"
    static var description = IntentDescription("Describe a shopping goal and Intento builds the cart.")
    static var openAppWhenRun = true

    @Parameter(title: "Request", requestValueDialog: "What should I shop for?")
    var request: String

    @Parameter(title: "Number of people", default: nil)
    var peopleCount: Int?

    @Parameter(title: "Budget in rupees", default: nil)
    var budget: Int?

    init() {}

    init(request: String, peopleCount: Int? = nil, budget: Int? = nil) {
        self.request = request
        self.peopleCount = peopleCount
        self.budget = budget
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let mission = PendingMission(
            prompt: request,
            peopleCount: peopleCount,
            budget: budget
        )
        PendingMissionCenter.shared.submit(mission: mission)
        return .result()
    }
}

// MARK: - Order Ingredients Intent (optimized for dish-based ordering)

struct OrderIngredientsIntent: AppIntent {
    static var title: LocalizedStringResource = "Order ingredients"
    static var description = IntentDescription("Order all ingredients for a dish and Intento builds the cart.")
    static var openAppWhenRun = true

    @Parameter(title: "Dish name", requestValueDialog: "Which dish do you want ingredients for?")
    var dishName: String

    @Parameter(title: "Number of people", default: nil)
    var peopleCount: Int?

    @Parameter(title: "Budget in rupees", default: nil)
    var budget: Int?

    @Parameter(title: "Dietary preference", default: nil)
    var dietary: String?

    init() {}

    init(dishName: String, peopleCount: Int? = nil, budget: Int? = nil, dietary: String? = nil) {
        self.dishName = dishName
        self.peopleCount = peopleCount
        self.budget = budget
        self.dietary = dietary
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        // Build a natural prompt from the structured parameters
        var prompt = "Order ingredients for \(dishName)"
        if let count = peopleCount {
            prompt += " for \(count) people"
        }
        if let diet = dietary, !diet.isEmpty {
            prompt += " (\(diet))"
        }

        var dietaryConstraints: [String] = []
        if let diet = dietary, !diet.isEmpty {
            dietaryConstraints = diet.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }

        let mission = PendingMission(
            prompt: prompt,
            peopleCount: peopleCount,
            budget: budget,
            dietaryConstraints: dietaryConstraints
        )
        PendingMissionCenter.shared.submit(mission: mission)
        return .result()
    }
}

// MARK: - Quick Reorder Intent

struct QuickReorderIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick reorder"
    static var description = IntentDescription("Quickly reorder groceries for a meal or occasion.")
    static var openAppWhenRun = true

    @Parameter(title: "What to reorder", requestValueDialog: "What would you like to reorder?")
    var request: String

    init() {}

    init(request: String) {
        self.request = request
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let mission = PendingMission(prompt: request)
        PendingMissionCenter.shared.submit(mission: mission)
        return .result()
    }
}

// MARK: - App Shortcuts Provider

struct IntentoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Primary: order ingredients for a specific dish
        AppShortcut(
            intent: OrderIngredientsIntent(),
            phrases: [
                "Order ingredients from \(.applicationName)",
                "Get ingredients from \(.applicationName)",
                "Buy ingredients from \(.applicationName)",
                "Shop for ingredients with \(.applicationName)",
                "I need ingredients from \(.applicationName)"
            ],
            shortTitle: "Order Ingredients",
            systemImageName: "fork.knife"
        )

        // General shopping mission
        AppShortcut(
            intent: MakeMissionIntent(),
            phrases: [
                "Start a shopping mission with \(.applicationName)",
                "Make a cart with \(.applicationName)",
                "Shop with \(.applicationName)",
                "Get groceries with \(.applicationName)",
                "Add to my cart with \(.applicationName)"
            ],
            shortTitle: "Make a Cart",
            systemImageName: "cart.badge.plus"
        )

        // Quick reorder
        AppShortcut(
            intent: QuickReorderIntent(),
            phrases: [
                "Reorder from \(.applicationName)",
                "Quick order with \(.applicationName)"
            ],
            shortTitle: "Quick Reorder",
            systemImageName: "arrow.clockwise"
        )
    }
}
