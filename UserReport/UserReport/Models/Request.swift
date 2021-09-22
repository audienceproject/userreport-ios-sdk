import Foundation

struct Request {

    let httpMethod: HTTPMethod
    let urlString: String
    let headers: [String: String]?
    let body: [String: Any?]?
    
    init(_ httpMethod: HTTPMethod = .GET, _ urlString: String, _ headers: [String: String]? = nil, body: [String: Any?]? = nil) {
        self.httpMethod = httpMethod
        self.urlString = urlString
        self.headers = headers
        self.body = body
    }
    
    func build() throws -> URLRequest
    {
        guard let url = URL(string: urlString) else {
            // Track error
            throw URError.invalidURL(url: urlString)
        }
        
        // Create request object
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        // Set headers if needed
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Set body if needed
        if let data = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        }
        
        return request
    }
}
