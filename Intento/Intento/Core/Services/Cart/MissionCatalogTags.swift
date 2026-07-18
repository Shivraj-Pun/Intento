import Foundation

enum MissionCatalogTags {

    static let occasionTags: [Occasion: [String]] = [
        .movieNight: ["movie-night"],
        .weeklyRestock: ["staple"],
        .breakfast: ["breakfast"],
        .dinnerParty: ["curry", "dinner", "party"],
        .birthday: ["party", "birthday"],
        .festival: ["party", "celebration"],
        .guestsOver: ["party", "dinner"],
        .picnic: ["snack", "party"],
        .cleaning: ["cleaning"]
    ]

    static let occasionCategories: [Occasion: [ProductCategory]] = [
        .weeklyRestock: [.produce, .dairy, .pantry, .bakery],
        .babyCare: [.baby],
        .illness: [.firstAid],
        .cleaning: [.cleaning],
        .breakfast: [.dairy, .bakery],
        .movieNight: [.snacks, .beverages]
    ]

    static let goalKeywordTags: [String: [String]] = [
        "butter chicken": ["butter-chicken"],
        "chicken curry": ["curry", "chicken"],
        "biryani": ["chicken", "curry", "staple"],
        "paneer": ["curry"],
        "movie": ["movie-night"],
        "party": ["party"],
        "breakfast": ["breakfast"],
        "sandwich": ["breakfast", "sandwich"],
        "restock": ["staple"],
        "groceries": ["staple"],
        "cleaning": ["cleaning"],
        "baby": [],
        "first aid": []
    ]

    static let goalKeywordCategories: [String: [ProductCategory]] = [
        "baby": [.baby],
        "first aid": [.firstAid],
        "medicine": [.firstAid],
        "cleaning": [.cleaning],
        "groceries": [.produce, .dairy, .pantry, .bakery],
        "restock": [.produce, .dairy, .pantry, .bakery]
    ]
}
