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
        "paneer": ["curry", "paneer"],
        "shahi paneer": ["curry", "paneer", "shahi"],
        "white sauce pasta": ["pasta", "white-sauce-pasta", "italian"],
        "red sauce pasta": ["pasta", "red-sauce-pasta", "italian"],
        "pasta": ["pasta", "italian"],
        "alfredo": ["pasta", "white-sauce-pasta", "italian"],
        "noodles": ["noodles", "chinese", "indo-chinese"],
        "hakka noodles": ["noodles", "chinese", "hakka"],
        "fried rice": ["chinese", "rice"],
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
        "restock": [.produce, .dairy, .pantry, .bakery],
        "pasta": [.pantry, .dairy, .produce],
        "noodles": [.pantry, .produce],
        "breakfast": [.dairy, .bakery, .pantry, .produce]
    ]
}
