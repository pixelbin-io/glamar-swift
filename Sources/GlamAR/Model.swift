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

public struct VersionResponse: Decodable {
    public let success: Bool
    public let sdkVersion: String?
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

public struct GlamAROverrides {
    public var category: String?
    public var configuration: Configuration?
    public var meta: [String: Any]?
    
    public init(category: String? = nil, configuration: Configuration? = nil, meta: [String: Any]? = nil) {
        self.category = category
        self.configuration = configuration
        self.meta = meta
    }
}

public struct Configuration {
    public var global: GlobalConfig?
    public var skinAnalysis: SkinAnalysisConfig?
    public var ui: UIConfig?

    public init(global: GlobalConfig? = nil, skinAnalysis: SkinAnalysisConfig? = nil, ui: UIConfig? = nil) {
        self.global = global
        self.skinAnalysis = skinAnalysis
        self.ui = ui
    }
}

public struct GlobalConfig {
    public var openLiveOnInit: Bool?
    public var disableClose: Bool?
    public var disableBack: Bool?

    public init(openLiveOnInit: Bool? = nil, disableClose: Bool? = nil, disableBack: Bool? = nil) {
        self.openLiveOnInit = openLiveOnInit
        self.disableClose = disableClose
        self.disableBack = disableBack
    }
}

public struct SkinAnalysisConfig {
    public var appId: String?

    public init(appId: String? = nil) {
        self.appId = appId
    }
}

public struct UIConfig {
    public var loader: LoaderConfig?
    public var watermark: WatermarkConfig?
    public var ar: ARConfig?

    public init(loader: LoaderConfig? = nil, watermark: WatermarkConfig? = nil, ar: ARConfig? = nil) {
        self.loader = loader
        self.watermark = watermark
        self.ar = ar
    }
}

public struct LoaderConfig {
    public var disable: Bool?
    public var jsonData: String?
    public var backgroundColor: String?

    public init(disable: Bool? = nil, jsonData: String? = nil, backgroundColor: String? = nil) {
        self.disable = disable
        self.jsonData = jsonData
        self.backgroundColor = backgroundColor
    }
}

public struct WatermarkConfig {
    public var text: String?
    public var fontColor: String?
    public var logo: String?

    public init(text: String? = nil, fontColor: String? = nil, logo: String? = nil) {
        self.text = text
        self.fontColor = fontColor
        self.logo = logo
    }
}

public struct ARConfig {
    public var disable3DUI: Bool?

    public init(disable3DUI: Bool? = nil) {
        self.disable3DUI = disable3DUI
    }
}
