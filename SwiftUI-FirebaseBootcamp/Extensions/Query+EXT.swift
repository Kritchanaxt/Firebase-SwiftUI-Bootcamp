//
//  Query+EXT.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 14/5/2567 BE.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

extension Query {
    
//    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
//        let snapshot = try await self.getDocuments()
//
//        return try snapshot.documents.map({ document in
//            try document.data(as: T.self)
//        })
//    }
    
    // MARK: ใช้ในการรับข้อมูลจาก Firestore เป็นแบบ asynchronous และแปลงเป็นอ็อบเจกต์ของชนิดที่กำหนดให้
    // ฟังก์ชันนี้รับชนิดของข้อมูล (type: T.Type) เป็นพารามิเตอร์ ซึ่ง T ต้อง conform กับโปรโตคอล Decodable.
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        
        // เรียกใช้ฟังก์ชัน getDocumentsWithSnapshot(as:) เพื่อดึงเอกสารจาก Firestore และแปลงเอกสารเหล่านั้นเป็นออบเจกต์ของชนิด T.
        try await getDocumentsWithSnapshot(as: type).products
    }
    
    // MARK: ใช้ในการรับข้อมูลและ Snapshot จาก Firestore เป็นแบบ asynchronous และคืนค่าอ็อบเจกต์ของชนิดที่กำหนดให้พร้อมกับ Snapshot ล่าสุด
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (products: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        
        // ใช้ await เพื่อรอผลลัพธ์จาก getDocuments() ซึ่งจะดึงข้อมูลทั้งหมดที่ตรงกับ Query และคืนค่าเป็น QuerySnapshot
        let snapshot = try await self.getDocuments()
        
        // ใช้ map เพื่อแปลงเอกสารแต่ละรายการใน snapshot เป็นออบเจกต์ของชนิดที่กำหนด (T) โดยใช้ data(as:) ซึ่งเป็นเมธอดของ Firestore ที่แปลง DocumentSnapshot เป็นออบเจกต์ของชนิด T ที่สอดคล้องกับ Decodable
        let products = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        // MARK: ส่งคืนค่าผลลัพธ์เป็น tuple ซึ่งประกอบด้วย:
           // products: อาร์เรย์ของออบเจกต์ที่แปลงจากเอกสารใน Firestore
           // lastDocument: เอกสารสุดท้ายใน snapshot ซึ่งสามารถใช้ในการทำการดึงข้อมูลแบบแบ่งหน้า (pagination) ในครั้งถัดไป
        return (products, snapshot.documents.last)
    }
    
    // MARK: ใช้ในการกำหนดเงื่อนไขในการเริ่มต้นในการค้นหาข้อมูลใน Firestore โดยใช้ DocumentSnapshot ล่าสุดที่กำหนด
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        
        // ใช้ guard let เพื่อทำการตรวจสอบว่า lastDocument มีค่า หากไม่มีค่า (nil) จะคืนค่า self ทันทีซึ่งหมายถึง Query เดิมที่ไม่เปลี่ยนแปลงใดๆ
        guard let lastDocument else { return self }
        
        // ใช้เมธอด start(afterDocument:) ของ Query เพื่อเริ่มการดึงข้อมูลหลังจากเอกสารที่กำหนด (lastDocument)
        return self.start(afterDocument: lastDocument)
    }
    
    // MARK: ใช้ในการคำนวณจำนวนเอกสารใน Firestore แบบ asynchronous
    func aggregateCount() async throws -> Int {
        
        // MARK: ดึงข้อมูลจำนวนทั้งหมดจาก Firestore:
           // self.count.getAggregation(source: .server): เรียกใช้เมธอด getAggregation ผ่าน count เพื่อดึงข้อมูลจำนวนเอกสารทั้งหมดจากเซิร์ฟเวอร์ Firestore โดยตรง
           // await: ใช้เพื่อรอผลลัพธ์จากการดึงข้อมูลแบบ asynchronous
           // try: ใช้เพื่อตรวจสอบและจัดการข้อผิดพลาดที่อาจเกิดขึ้นในระหว่างการดึงข้อมูล
        let snapshot = try await self.count.getAggregation(source: .server)
        
        // ส่งคืนค่าจำนวนเอกสารทั้งหมดในรูปแบบ Int
        // snapshot.count: จำนวนเอกสารที่นับได้ในรูปแบบ NSDecimalNumber
        // Int(truncating:): แปลง NSDecimalNumber เป็น Int โดยใช้การทำงานแบบ truncating (ตัดทอนส่วนที่เกิน)
        return Int(truncating: snapshot.count)
        
    }
    
    // MARK: ใช้ในการเพิ่ม Listener เพื่อรับการแจ้งเตือนเมื่อมีการเปลี่ยนแปลงในข้อมูลใน Firestore และส่งข้อมูลผ่าน Publisher ของ Combine
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        
        // สร้าง PassthroughSubject ซึ่งเป็นประเภทของ Publisher ที่สามารถส่งค่าหลายๆ ค่าออกไปได้พร้อมกับการจัดการข้อผิดพลาด
        let publisher = PassthroughSubject<[T], Error>()
        
        // ใช้ addSnapshotListener เพื่อฟังการเปลี่ยนแปลงของข้อมูลใน Firestore เมื่อมีการเปลี่ยนแปลงในเอกสาร:
        let listener = self.addSnapshotListener { querySnapshot, error in
            
            // ตรวจสอบว่า querySnapshot มีเอกสารหรือไม่
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            // แปลงเอกสารแต่ละรายการเป็นประเภท T โดยใช้ compactMap เพื่อกรองเอกสารที่ไม่สามารถแปลงได้
            let products: [T] = documents.compactMap({ try? $0.data(as: T.self) })
            
            // ส่งข้อมูลที่แปลงแล้วไปยัง Publisher
            publisher.send(products)
        }
        
        // ส่งคืน Publisher ที่ได้จากการแปลง PassthroughSubject เป็น AnyPublisher และ Listener ที่สร้างขึ้นเพื่อใช้ในการยกเลิกการฟังการเปลี่ยนแปลงในภายหลัง
        return (publisher.eraseToAnyPublisher(), listener)
    }
    
}

