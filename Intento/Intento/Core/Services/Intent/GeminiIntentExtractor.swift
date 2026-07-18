import Foundation

enum LLMIntentError: Error, Sendable {
    case missingAPIKey
    case invalidResponse
    case httpError(status: Int, body: String)
}

struct GeminiIntentExtractor: LLMIntentExtracting {
    let apiKey: String
    let baseURL: URL
    let model: String
    let session: URLSession

    init(apiKey: String, baseURL: URL, model: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
        self.session = session
    }

    func extractIntent(from text: String) async throws -> ShoppingIntent {
        guard !apiKey.isEmpty else { throw LLMIntentError.missingAPIKey }

        let request = try makeRequest(for: text)
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw LLMIntentError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw LLMIntentError.httpError(status: http.statusCode, body: body)
        }

        let envelope = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let jsonText = envelope.firstText,
              let payloadData = jsonText.data(using: .utf8) else {
            throw LLMIntentError.invalidResponse
        }

        let parsed = try JSONDecoder().decode(ExtractedIntentDTO.self, from: payloadData)
        return parsed.toIntent(rawText: text)
    }

    private func makeRequest(for text: String) throws -> URLRequest {
        let endpoint = baseURL
            .appendingPathComponent("models")
            .appendingPathComponent("\(model):generateContent")

        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = components?.url else { throw LLMIntentError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GeminiRequest(
            contents: [.init(parts: [.init(text: Self.prompt(for: text))])],
            generationConfig: .init(responseMimeType: "application/json", temperature: 0.2)
        )
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    static func prompt(for text: String) -> String {
        """
        You extract structured shopping intent from a user's request for an Indian grocery app.
        Return ONLY minified JSON matching this schema, no markdown:
        {
          "goal": string,
          "peopleCount": number|null,
          "budgetRupees": number|null,
          "dietary": string[] (subset of: vegetarian, non_vegetarian, vegan, eggetarian),
          "occasion": string|null (one of: everyday, weekly_restock, breakfast, dinner_party, movie_night, birthday, festival, guests_over, baby_care, illness, picnic, cleaning),
          "durationDays": number|null,
          "existingItems": string[],
          "category": string|null,
          "confidence": number (0..1)
        }
        Infer sensible values when not stated and lower confidence accordingly.
        User request: "\(text)"
        """
    }
}

private struct GeminiRequest: Encodable {
    struct Content: Encodable { let parts: [Part] }
    struct Part: Encodable { let text: String }
    struct GenerationConfig: Encodable {
        let responseMimeType: String
        let temperature: Double
    }
    let contents: [Content]
    let generationConfig: GenerationConfig
}

private struct GeminiResponse: Decodable {
    struct Candidate: Decodable {
        struct Content: Decodable {
            struct Part: Decodable { let text: String? }
            let parts: [Part]?
        }
        let content: Content?
    }
    let candidates: [Candidate]?

    var firstText: String? {
        candidates?.first?.content?.parts?.compactMap(\.text).joined()
    }
}

struct ExtractedIntentDTO: Decodable, Sendable {
    let goal: String?
    let peopleCount: Int?
    let budgetRupees: Double?
    let dietary: [String]?
    let occasion: String?
    let durationDays: Int?
    let existingItems: [String]?
    let category: String?
    let confidence: Double?

    func toIntent(rawText: String) -> ShoppingIntent {
        let fields = ParsedIntentFields(
            goal: goal?.trimmingCharacters(in: .whitespacesAndNewlines) ?? rawText,
            peopleCount: peopleCount,
            budgetRupees: budgetRupees.map { Int($0.rounded()) },
            dietary: (dietary ?? []).compactMap(DietaryConstraint.init(rawValue:)),
            occasion: occasion.flatMap(Occasion.init(rawValue:)),
            durationDays: durationDays,
            existingItems: existingItems ?? [],
            category: category.flatMap(ProductCategory.init(rawValue:)),
            confidenceOverride: confidence
        )
        let subIntents = IntentHeuristics.splitSubIntents(in: rawText)
        let resolvedSubs: [SubIntent] = subIntents.count > 1
            ? subIntents.map { SubIntent(goal: $0) }
            : []
        return IntentBuilder.assemble(rawText: rawText, fields: fields, subIntents: resolvedSubs)
    }
}
