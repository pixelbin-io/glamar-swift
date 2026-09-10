//
//  GlamArApi.swift
//  GlamAR
//
//  Created by Dipendra Sharma on 09/08/24.
//

import Foundation
import Alamofire

public class GlamArApi {
    
    let accessKey: String
    let debug: Bool
    private let session: Session
    
    public init(accessKey: String, debug: Bool) {
        self.accessKey = accessKey
        self.debug = debug
        let interceptor = RequestSigningAdapter(signingKey: "1234567", headerPrefix: "x-ebg-")
        self.session = Session(interceptor: interceptor)
    }
    
    private var baseURL: String {
        return self.debug ? "https://api.pixelbin.io" : "https://api.pixelbin.io"
    }

    private var glamARBaseURL: String {
        return self.debug ? "https://api.glamar.fynd.com" : "https://api.glamar.fynd.com"
    }

    private var versionAPIBaseURLs: [String] {
        return [
            "\(glamARBaseURL)/service/private/glamar",
            "\(baseURL)/service/private/misc"
        ]
    }
    
    public func fetchSkuList(pageNo: Int, pageSize: Int, completion: @escaping (Result<SkuListResponse, Error>) -> Void) {
        let url = "\(baseURL)/service/private/misc/v1.0/skus"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessKey)"
        ]
        let parameters: [String: Any] = [
            "pageNo": pageNo,
            "pageSize": pageSize,
        ]
        session.request(url, method: .get, parameters: parameters, headers: headers)
            .responseDecodable(of: SkuListResponse.self) { response in
                switch response.result {
                case .success(let skuListResponse):
                    completion(.success(skuListResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    public func fetchSku(id: String, completion: @escaping (Result<Item, Error>) -> Void) {
        let url = "\(baseURL)/service/private/misc/v1.0/skus/\(id)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessKey)"
        ]
        session.request(url, method: .get, headers: headers)
            .responseDecodable(of: SkuItemResponse.self) { response in
                switch response.result {
                case .success(let skuItemResponse):
                    completion(.success(skuItemResponse.item))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    public func getVersion(appId: String?, completion: @escaping (Result<String?, Error>) -> Void) {
        fetchVersion(appId: appId, from: versionAPIBaseURLs, completion: completion)
    }

    private func fetchVersion(appId: String?, from baseURLs: [String], completion: @escaping (Result<String?, Error>) -> Void) {
        guard let versionBaseURL = baseURLs.first else {
            completion(.failure(URLError(.badServerResponse)))
            return
        }

        var components = URLComponents(
            string: "\(versionBaseURL)/v3.0/sdk-settings/version"
        )
        
        if let appId = appId {
            components?.queryItems = [
                URLQueryItem(name: "appId", value: appId)
            ]
        }
        
        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        print("Version Url:", url)
        
        let encodedKey = Data(accessKey.utf8).base64EncodedString()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(encodedKey)"
        ]
        session.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: VersionResponse.self) { response in
                if let raw = response.data, let str = String(data: raw, encoding: .utf8) {
                    print("Raw response:", str)
                }

                switch response.result {
                case .success(let versionResponse):
                    completion(.success(versionResponse.sdkVersion))
                case .failure(let error):
                    let fallbackBaseURLs = Array(baseURLs.dropFirst())

                    guard !fallbackBaseURLs.isEmpty else {
                        completion(.failure(error))
                        return
                    }

                    print("Version API failed for \(url). Trying fallback.")
                    self.fetchVersion(appId: appId, from: fallbackBaseURLs, completion: completion)
                }
            }
    }
}
