//
//  UserManager.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 8/5/2567 BE.
//

// MARK: Codable เป็นโปรโตคอลที่ทำให้โครงสร้างสามารถเข้ารหัส (encode) และถอดรหัส (decode) เป็น/จาก JSON ได้

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: โครงสร้างที่เก็บข้อมูลของภาพยนตร์
struct Movie: Codable {
    let id: String
    let title: String
    let isPopular: Bool
}

// MARK: โครงสร้างที่เก็บข้อมูลของผู้ใช้ ประกอบไปด้วยหลายฟิลด์
struct DBUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isPremium: Bool?
    let preferences: [String]?
    let favoriteMovie: Movie?
    let profileImagePath: String?
    let profileImagePathUrl: String?
    
    // ใช้สำหรับสร้าง DBUser จากข้อมูลการยืนยันตัวตน
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.preferences = nil
        self.favoriteMovie = nil
        self.profileImagePath = nil
        self.profileImagePathUrl = nil
    }
    
    // ใช้สำหรับสร้าง DBUser ด้วยข้อมูลที่ให้มา
    init(
        userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil,
        preferences: [String]? = nil,
        favoriteMovie: Movie? = nil,
        profileImagePath: String? = nil,
        profileImagePathUrl: String? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.preferences = preferences
        self.favoriteMovie = favoriteMovie
        self.profileImagePath = profileImagePath
        self.profileImagePathUrl = profileImagePathUrl
    }
    
//    func togglePremiumStatus() -> DBUser {
//        let currentValue = isPremium ?? false
//        return DBUser(
//            userId: userId,
//            isAnonymous: isAnonymous,
//            email: email,
//            photoUrl: photoUrl,
//            dateCreated: dateCreated,
//            isPremium: !currentValue)
//    }
    
//    mutating func togglePremiumStatus() {
//        let currentValue = isPremium ?? false
//        isPremium = !currentValue
//    }
    
    // Enum ที่ใช้กำหนดคีย์สำหรับการเข้ารหัสและถอดรหัส
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "user_isPremium"
        case preferences = "preferences"
        case favoriteMovie = "favorite_movie"
        case profileImagePath = "profile_image_path"
        case profileImagePathUrl = "profile_image_path_url"
    }
    
    // ฟังก์ชันที่ถอดรหัสข้อมูลจาก JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.favoriteMovie = try container.decodeIfPresent(Movie.self, forKey: .favoriteMovie)
        self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
        self.profileImagePathUrl = try container.decodeIfPresent(String.self, forKey: .profileImagePathUrl)
    }
    
    // ฟังก์ชันที่เข้ารหัสข้อมูลเป็น JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.favoriteMovie, forKey: .favoriteMovie)
        try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
        try container.encodeIfPresent(self.profileImagePathUrl, forKey: .profileImagePathUrl)
    }
    
}

final class UserManager {
    
    //  สร้าง instance แบบ singleton ของ UserManager เพื่อให้สามารถใช้งาน instance นี้ได้ทั่วทั้งแอปพลิเคชัน
    static let shared = UserManager()
    
    // ป้องกันการสร้าง instance ใหม่ของ UserManager จากภายนอกคลาส
    private init() { }
    
    // กำหนด CollectionReference ไปยัง collection "users" ใน Firestore
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    // ฟังก์ชันสำหรับการดึง DocumentReference ของผู้ใช้จาก userId
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    // ฟังก์ชันสำหรับการดึง CollectionReference ของ favorite_products สำหรับผู้ใช้ที่ระบุ
    private func userFavoriteProductCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("favorite_products")
    }
    
    // ฟังก์ชันสำหรับการดึง DocumentReference ของ favorite_product ที่ระบุสำหรับผู้ใช้ที่ระบุ
    private func userFavoriteProductDocument(userId: String, favoriteProductId: String) -> DocumentReference {
        userFavoriteProductCollection(userId: userId).document(favoriteProductId)
    }
    
    //  สร้าง Firestore encoder สำหรับการเข้ารหัสข้อมูลเป็น JSON ก่อนส่งไปยัง Firestore
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    // สร้าง Firestore decoder สำหรับการถอดรหัส JSON ที่ได้รับจาก Firestore เป็นออบเจ็กต์ Swift
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // ประกาศตัวแปรสำหรับเก็บ ListenerRegistration ที่จะใช้ในการหยุดการฟังการเปลี่ยนแปลงข้อมูลใน Firestore
    private var userFavoriteProductsListener: ListenerRegistration? = nil
    
    // ฟังก์ชันสำหรับสร้างผู้ใช้ใหม่ใน Firestore
    func createNewUser(user: DBUser) async throws {
        
        // บันทึกข้อมูลของผู้ใช้ใน Firestore โดยไม่ผสานข้อมูลเก่า (merge: false)
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String:Any] = [
//            "user_id" : auth.uid,
//            "is_anonymous" : auth.isAnonymous,
//            "date_created" : Timestamp(),
//        ]
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    // ฟังก์ชันสำหรับดึงข้อมูลผู้ใช้จาก Firestore
    func getUser(userId: String) async throws -> DBUser {
        
        // ดึงข้อมูล Document ของผู้ใช้แล้วแปลงเป็นออบเจ็กต์ DBUser
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userId: userId).getDocument()
//
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//
//        return DBUser(userId: userId, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
//    }
    
//    func updateUserPremiumStatus(user: DBUser) async throws {
//        try userDocument(userId: user.userId).setData(from: user, merge: true)
//    }
    
    // ฟังก์ชันสำหรับอัปเดตสถานะพรีเมียมของผู้ใช้
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        
        // สร้าง Dictionary สำหรับเก็บข้อมูลที่จะอัปเดต
        let data: [String:Any] = [
            DBUser.CodingKeys.isPremium.rawValue : isPremium,
        ]
        
        // อัปเดตข้อมูลของผู้ใช้ใน Firestore
        try await userDocument(userId: userId).updateData(data)
    }
    
    // ฟังก์ชันสำหรับอัปเดตเส้นทางและ URL ของรูปโปรไฟล์ผู้ใช้
    func updateUserProfileImagePath(userId: String, path: String?, url: String?) async throws {
        
        // สร้าง Dictionary สำหรับเก็บข้อมูลที่จะอัปเดต
        let data: [String:Any] = [
            DBUser.CodingKeys.profileImagePath.rawValue : path,
            DBUser.CodingKeys.profileImagePathUrl.rawValue : url,
        ]
        
        // อัปเดตข้อมูลของผู้ใช้ใน Firestore
        try await userDocument(userId: userId).updateData(data)
    }
    
    // ฟังก์ชันสำหรับเพิ่มค่า preference ให้กับผู้ใช้
    func addUserPreference(userId: String, preference: String) async throws {
        
        // สร้าง Dictionary สำหรับเก็บข้อมูลที่จะอัปเดต โดยใช้ FieldValue.arrayUnion เพื่อเพิ่มค่าใน array
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayUnion([preference])
        ]
        
        // อัปเดตข้อมูลของผู้ใช้ใน Firestore
        try await userDocument(userId: userId).updateData(data)
    }
    
    // ฟังก์ชันสำหรับลบค่า preference จากผู้ใช้
    func removeUserPreference(userId: String, preference: String) async throws {
        
        // สร้าง Dictionary สำหรับเก็บข้อมูลที่จะอัปเดต โดยใช้ FieldValue.arrayRemove เพื่อลบค่าใน array
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference])
        ]
        
        // อัปเดตข้อมูลของผู้ใช้ใน Firestore
        try await userDocument(userId: userId).updateData(data)
    }
    
    //  ฟังก์ชันสำหรับเพิ่มภาพยนตร์ที่ชื่นชอบให้กับผู้ใช้
    func addFavoriteMovie(userId: String, movie: Movie) async throws {
        
        // เข้ารหัสข้อมูลของ movie เป็น JSON
        guard let data = try? encoder.encode(movie) else {
            throw URLError(.badURL)
        }
        
        // สร้าง Dictionary สำหรับเก็บข้อมูลที่จะอัปเดต
        let dict: [String:Any] = [
            DBUser.CodingKeys.favoriteMovie.rawValue : data
        ]
        
        // อัปเดตข้อมูลของผู้ใช้ใน Firestore
        try await userDocument(userId: userId).updateData(dict)
    }
    
    // ฟังก์ชันสำหรับลบภาพยนตร์ที่ชื่นชอบจากผู้ใช้
    func removeFavoriteMovie(userId: String) async throws {
        
        // สร้าง Dictionary เพื่อเก็บข้อมูลที่จะอัปเดต โดยตั้งค่า value เป็น nil เพื่อแสดงว่าต้องการลบข้อมูล
        let data: [String:Any?] = [
            DBUser.CodingKeys.favoriteMovie.rawValue : nil
        ]
        
        // อัปเดตข้อมูลของผู้ใช้ใน Firestore
        try await userDocument(userId: userId).updateData(data as [AnyHashable : Any])
    }
    
    //  ฟังก์ชันสำหรับเพิ่มสินค้าที่ชื่นชอบของผู้ใช้
    func addUserFavoriteProduct(userId: String, productId: Int) async throws {
        
        // สร้าง DocumentReference ใหม่ใน collection favorite_products สำหรับผู้ใช้ที่ระบุ
        let document = userFavoriteProductCollection(userId: userId).document()
        
        // ดึง ID ของ Document ที่สร้างใหม่
        let documentId = document.documentID
        
        // สร้าง Dictionary เพื่อเก็บข้อมูลสินค้าที่จะเพิ่ม
        let data: [String:Any] = [
            UserFavoriteProduct.CodingKeys.id.rawValue : documentId,
            UserFavoriteProduct.CodingKeys.productId.rawValue : productId,
            UserFavoriteProduct.CodingKeys.dateCreated.rawValue : Timestamp()
        ]
        
        // บันทึกข้อมูลสินค้าใหม่ลงใน Firestore
        try await document.setData(data, merge: false)
    }
    
    // ฟังก์ชันสำหรับลบสินค้าที่ชื่นชอบของผู้ใช้
    func removeUserFavoriteProduct(userId: String, favoriteProductId: String) async throws {
        
        // ลบเอกสารของสินค้าที่ชื่นชอบออกจาก Firestore
        try await userFavoriteProductDocument(userId: userId, favoriteProductId: favoriteProductId).delete()
    }
    
    // ฟังก์ชันสำหรับดึงข้อมูลสินค้าที่ชื่นชอบทั้งหมดของผู้ใช้
    func getAllUserFavoriteProducts(userId: String) async throws -> [UserFavoriteProduct] {
        
        // ดึงข้อมูลเอกสารทั้งหมดใน collection favorite_products และแปลงเป็นออบเจ็กต์ UserFavoriteProduct
        try await userFavoriteProductCollection(userId: userId).getDocuments(as: UserFavoriteProduct.self)
    }
    
    // ฟังก์ชันสำหรับเลิกติดตามการเปลี่ยนแปลงของสินค้าที่ชื่นชอบของผู้ใช้ทั้งหมด
    func removeListenerForAllUserFavoriteProducts() {
        self.userFavoriteProductsListener?.remove()
    }
    
    // ฟังก์ชันสำหรับเริ่มติดตามการเปลี่ยนแปลงของสินค้าที่ชื่นชอบของผู้ใช้ทั้งหมด
    func addListenerForAllUserFavoriteProducts(userId: String, completion: @escaping (_ products: [UserFavoriteProduct]) -> Void) {
        
        // เริ่มติดตามการเปลี่ยนแปลงของเอกสารใน collection favorite_products สำหรับผู้ใช้ที่ระบุ
        self.userFavoriteProductsListener = userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            
            // ตรวจสอบว่ามีเอกสารใน snapshot หรือไม่ ถ้าไม่มีก็จะประมวลผลเสร็จสิ้น
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            // แปลงข้อมูลจากเอกสารใน snapshot เป็นออบเจ็กต์ UserFavoriteProduct และ
            let products: [UserFavoriteProduct] = documents.compactMap({ try? $0.data(as: UserFavoriteProduct.self) })
            completion(products)
            
            querySnapshot?.documentChanges.forEach { diff in
                
                // หากมีการเพิ่มสินค้า: แสดงข้อความ "New products" พร้อมกับข้อมูลของเอกสารที่เพิ่ม
                if (diff.type == .added) {
                    print("New products: \(diff.document.data())")
                }
                
                // หากมีการแก้ไขสินค้า: แสดงข้อความ "Modified products" พร้อมกับข้อมูลของเอกสารที่แก้ไข
                if (diff.type == .modified) {
                    print("Modified products: \(diff.document.data())")
                }
                
                // หากมีการลบสินค้า: แสดงข้อความ "Removed products" พร้อมกับข้อมูลของเอกสารที่ลบ
                if (diff.type == .removed) {
                    print("Removed products: \(diff.document.data())")
                }
            }
        }
    }
    
//    func addListenerForAllUserFavoriteProducts(userId: String) -> AnyPublisher<[UserFavoriteProduct], Error> {
//        let publisher = PassthroughSubject<[UserFavoriteProduct], Error>()
//
//        self.userFavoriteProductsListener = userFavoriteProductCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//
//            let products: [UserFavoriteProduct] = documents.compactMap({ try? $0.data(as: UserFavoriteProduct.self) })
//            publisher.send(products)
//        }
//
//        return publisher.eraseToAnyPublisher()
//    }
    
    // เพิ่มผู้ฟังสำหรับผลิตภัณฑ์โปรดของผู้ใช้ทั้งหมด
    func addListenerForAllUserFavoriteProducts(userId: String) -> AnyPublisher<[UserFavoriteProduct], Error> {
        
        // เรียกใช้ userFavoriteProductCollection(userId: userId) เพื่อเข้าถึงคอลเล็กชันของผลิตภัณฑ์ที่ผู้ใช้ชื่นชอบ
        let (publisher, listener) = userFavoriteProductCollection(userId: userId)
            .addSnapshotListener(as: UserFavoriteProduct.self)
        
        // เรียก addSnapshotListener(as: UserFavoriteProduct.self)
        // เพื่อเริ่มต้นการติดตามการเปลี่ยนแปลงในคอลเล็กชันดังกล่าว โดยระบุประเภทของข้อมูลที่เราต้องการรับคืนเมื่อมีการเปลี่ยนแปลง ในที่นี้คือ UserFavoriteProduct
        self.userFavoriteProductsListener = listener
        
        // ส่งคืน publisher ที่สร้างขึ้นเพื่อให้ผู้ใช้รับข้อมูลการเปลี่ยนแปลงในคอลเล็กชัน UserFavoriteProduct
        return publisher
    }
    
}

import Combine

// MARK: โครงสร้างที่เก็บข้อมูลของผลิตภัณฑ์ที่ผู้ใช้ชื่นชอบ
// โปรโตคอลที่ทำให้โครงสร้างสามารถเข้ารหัส (encode) และถอดรหัส (decode) เป็น/จากรูปแบบ JSON หรือรูปแบบอื่นๆ ได้
struct UserFavoriteProduct: Codable {
    let id: String
    let productId: Int
    let dateCreated: Date
    
    // ใช้ระบุชื่อคีย์ที่แตกต่างกันระหว่างโครงสร้างและ JSON
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "product_id"
        case dateCreated = "date_created"
    }
    
    // ฟังก์ชันที่ถอดรหัสข้อมูลจาก JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.productId = try container.decode(Int.self, forKey: .productId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    // ฟังก์ชันที่เข้ารหัสข้อมูลเป็น JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.productId, forKey: .productId)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    
}
