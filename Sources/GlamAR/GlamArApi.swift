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
    let development: Bool
    private let session: Session
    
    public init(accessKey: String, development: Bool) {
        self.accessKey = accessKey
        self.development = development
        let interceptor = RequestSigningAdapter(signingKey: "1234567")
        self.session = Session(interceptor: interceptor)
    }
    
    private var baseURL: String {
        return self.development ? "https://api.pixelbinz0.de" : "https://api.pixelbin.io"
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
}
