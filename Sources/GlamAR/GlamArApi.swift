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
        return self.debug ? "https://api.pixelbinz0.de" : "https://api.pixelbin.io"
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
        
        var components = URLComponents(
            string: "\(baseURL)/service/private/misc/v3.0/sdk-settings/version"
        )
        
        if let appId = appId {
            components?.queryItems = [
                URLQueryItem(name: "appId", value: appId)
            ]
        }
        
        guard let urlString = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        print("Version Url:", urlString)
        
        let encodedKey = Data(accessKey.utf8).base64EncodedString()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(encodedKey)"
        ]
        session.request(urlString, method: .get, headers: headers)
            .responseDecodable(of: VersionResponse.self) { response in
                if let raw = response.data, let str = String(data: raw, encoding: .utf8) {
                    print("Raw response:", str)
                }
                switch response.result {
                case .success(let response):
                    completion(.success(response.sdkVersion))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
