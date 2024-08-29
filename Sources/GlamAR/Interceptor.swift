import Alamofire
import CommonCrypto
import Foundation

class RequestSigningAdapter: RequestInterceptor {
    private let signingKey: String
    private let headerPrefix: String
    
    init(signingKey: String, headerPrefix: String = "x-ebg-") {
        self.signingKey = signingKey
        self.headerPrefix = headerPrefix
    }
    
    private var headersToInclude: [NSRegularExpression] {
        [
            try! NSRegularExpression(pattern: "\(headerPrefix).*"),
            try! NSRegularExpression(pattern: "Host"),
        ]
    }
    
    func adapt(
        _ urlRequest: URLRequest, for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        
        let now = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ":", with: "")
        
        urlRequest.setValue(now, forHTTPHeaderField: "\(headerPrefix)param")
        urlRequest.setValue(urlRequest.url?.host, forHTTPHeaderField: "host")
        
        let canonicalString = generateCanonicalString(request: urlRequest)
        let signature = generateHmac(
            secretKey: signingKey, message: "\(now)\n\(sha256(canonicalString))")
        
        urlRequest.setValue("v1:\(signature)", forHTTPHeaderField: "\(headerPrefix)signature")
        urlRequest.setValue(
            Data(now.utf8).base64EncodedString(), forHTTPHeaderField: "\(headerPrefix)param")
        
        completion(.success(urlRequest))
    }
    
    func retry(
        _ request: Request, for session: Session, dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        completion(.doNotRetry)
    }
    
    private func generateCanonicalString(request: URLRequest) -> String {
        let content = request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        let contentHash = sha256(content)
        
        let sortedQueryParams = sortedAndEncodedQueryParams(request: request)
        let canonicalHeaders = self.canonicalHeaders(request: request)
        let signedHeaders = self.signedHeaders(request: request)
        
        print(
            """
      \(request.httpMethod ?? "")\n\
      \(request.url?.path ?? "")\n\
      \(sortedQueryParams)\n\
      \(canonicalHeaders)\n\n\
      \(signedHeaders)\n\
      \(contentHash)
      """)
        return """
      \(request.httpMethod ?? "")\n\
      \(request.url?.path ?? "")\n\
      \(sortedQueryParams)\n\
      \(canonicalHeaders)\n\n\
      \(signedHeaders)\n\
      \(contentHash)
      """
    }
    
    private func sortedAndEncodedQueryParams(request: URLRequest) -> String {
        guard let url = request.url else { return "" }
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let sortedQueryItems = queryItems.sorted { $0.name < $1.name }
        
        return sortedQueryItems.map { item in
            let name = item.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let value = item.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(name)=\(value)"
        }.joined(separator: "&")
    }
    
    private func generateHmac(secretKey: String, message: String) -> String {
        let key = secretKey.cString(using: .utf8)!
        let data = message.cString(using: .utf8)!
        
        var hmac = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, strlen(key), data, strlen(data), &hmac)
        
        return hmac.map { String(format: "%02x", $0) }.joined()
    }
    
    private func canonicalHeaders(request: URLRequest) -> String {
        let headers = request.allHTTPHeaderFields ?? [:]
        
        return headers.filter { key, _ in
            headersToInclude.contains {
                $0.matches(in: key, options: [], range: NSRange(location: 0, length: key.count)).count > 0
            }
        }
        .sorted { $0.key < $1.key }
        .map { "\($0.key.lowercased()):\($0.value.trimmingCharacters(in: .whitespaces))" }
        .joined(separator: "\n")
    }
    
    private func signedHeaders(request: URLRequest) -> String {
        let headers = request.allHTTPHeaderFields ?? [:]
        
        return headers.keys.filter { key in
            headersToInclude.contains {
                $0.matches(in: key, options: [], range: NSRange(location: 0, length: key.count)).count > 0
            }
        }
        .sorted()
        .map { $0.lowercased() }
        .joined(separator: ";")
    }
    
    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
