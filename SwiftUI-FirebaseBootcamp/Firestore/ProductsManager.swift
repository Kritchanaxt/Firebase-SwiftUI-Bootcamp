//
//  ProductsManager.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 10/5/2567 BE.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProductsManager {
    
    // รับรองว่าจะมีเพียงอินสแตนซ์เดียวของ ProductsManager ผ่าน static let shared
    static let shared = ProductsManager()
    private init() { }
    
    // ชี้ไปที่คอลเลกชัน "products" ใน Firestore
    private let productsCollection = Firestore.firestore().collection("products")
    
    // MARK: เมธอดหลัก
    
    // ส่งคืนการอ้างอิงไปยังเอกสารในคอลเลกชัน "products"
    private func productDocument(productId: String) -> DocumentReference {
        productsCollection.document(productId)
    }
    
    // อัปโหลดผลิตภัณฑ์ไปยัง Firestore โดยใช้ ID ของผลิตภัณฑ์เป็น ID ของเอกสาร
    func uploadProduct(product: Product) async throws {
        try productDocument(productId: String(product.id)).setData(from: product, merge: false)
    }
    
    // ดึงข้อมูลผลิตภัณฑ์จาก Firestore โดยใช้ ID ของผลิตภัณฑ์
    func getProduct(productId: String) async throws -> Product {
        try await productDocument(productId: productId).getDocument(as: Product.self)
    }
    
//    private func getAllProducts() async throws -> [Product] {
//        try await productsCollection
//            .getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
//        try await productsCollection
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsForCategory(category: String) async throws -> [Product] {
//        try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .getDocuments(as: Product.self)
//    }
//
//    private func getAllProductsByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
//        try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
    
    // MARK: ตัวช่วยสร้าง Query (เมธอดส่วนตัว)
    
    // ส่งคืน query สำหรับผลิตภัณฑ์ทั้งหมด
    private func getAllProductsQuery() -> Query {
        productsCollection
    }
    
    // ส่งคืน query สำหรับผลิตภัณฑ์ที่เรียงตามราคา
    private func getAllProductsSortedByPriceQuery(descending: Bool) -> Query {
        productsCollection
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    // ส่งคืน query สำหรับผลิตภัณฑ์ที่กรองตามหมวดหมู่
    private func getAllProductsForCategoryQuery(category: String) -> Query {
        productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
    }
    
    // ส่งคืน query สำหรับผลิตภัณฑ์ที่กรองตามหมวดหมู่และเรียงตามราคา
    private func getAllProductsByPriceAndCategoryQuery(descending: Bool, category: String) -> Query {
        productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    // ส่งคืนรายการผลิตภัณฑ์ที่มีการแบ่งหน้า โดยสามารถเลือกเรียงตามราคา กรองตามหมวดหมู่ และระบุพารามิเตอร์การแบ่งหน้าได้
    func getAllProducts(priceDescending descending: Bool?, forCategory category: String?, count: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [Product], lastDocument: DocumentSnapshot?) {
        var query: Query = getAllProductsQuery()

        if let descending, let category {
            query = getAllProductsByPriceAndCategoryQuery(descending: descending, category: category)
        } else if let descending {
            query = getAllProductsSortedByPriceQuery(descending: descending)
        } else if let category {
            query = getAllProductsForCategoryQuery(category: category)
        }
        
        return try await query
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Product.self)
    }
    
    // ดึงผลิตภัณฑ์ที่เรียงตามการให้คะแนน โดยเริ่มจากการให้คะแนนที่กำหนด
    func getProductsByRating(count: Int, lastRating: Double?) async throws -> [Product] {
        try await productsCollection
            .order(by: Product.CodingKeys.rating.rawValue, descending: true)
            .limit(to: count)
            .start(after: [lastRating ?? 9999999])
            .getDocuments(as: Product.self)
    }
    
    // ดึงผลิตภัณฑ์ที่เรียงตามการให้คะแนน พร้อมรองรับการแบ่งหน้า
    func getProductsByRating(count: Int, lastDocument: DocumentSnapshot?) async throws -> (products: [Product], lastDocument: DocumentSnapshot?) {
        if let lastDocument {
            return try await productsCollection
                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                .limit(to: count)
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Product.self)
        } else {
            return try await productsCollection
                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Product.self)
        }
    }
    
    //  ส่งคืนจำนวนผลิตภัณฑ์ทั้งหมดในคอลเลกชัน
    func getAllProductsCount() async throws -> Int {
        try await productsCollection
            .aggregateCount()
    }
    
}
