//
//  Model.swift
//  GlamAR
//
//  Created by Dipendra Sharma on 09/08/24.
//

import Foundation

public struct SkuListResponse: Decodable {
    public let page: Page
    public let items: [Item]
}

public struct SkuItemResponse: Decodable {
    public let item: Item
    enum CodingKeys: String, CodingKey {
        case item = "sku"
    }
}

public struct Page: Decodable {
    public let type: String
    public let size: Int
    public let current: Int
    public let hasNext: Bool
    public let itemTotal: Int
    
    enum CodingKeys: String, CodingKey {
        case type
        case size
        case current
        case hasNext = "hasNext"
        case itemTotal = "itemTotal"
    }
}

public struct Meta: Decodable {
    public let material: String?
    public let dimension: String?
}

public struct Item: Decodable {
    public let id: String
    public let orgId: Int
    public let category: String
    public let subCategory: String
    public let productName: String?
    public let productImage: String?
    public let vendor: String?
    public let isActive: Bool?
    public let itemCode: String?
    public let styleVariant: String?
    public let styleIcon: String?
    public let attributes: [Attribute]
    public let meta: Meta?
    public let createdAt: String?
    public let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case orgId = "orgId"
        case category
        case subCategory = "subCategory"
        case productName = "productName"
        case productImage = "productImage"
        case vendor
        case isActive = "isActive"
        case itemCode = "itemCode"
        case styleVariant = "styleVariant"
        case styleIcon = "styleIcon"
        case attributes
        case meta
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}

public struct Attribute: Decodable {
    public let icons: [String]
    public let colors: [String]
    public let effectAssets: [String]
}
