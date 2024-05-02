//
//  SecurityRules.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 16/5/2567 BE.
//

import Foundation

// https://firebase.google.com/docs/firestore/security/rules-structure
// https://firebase.google.com/docs/rules/rules-language

// MARK: Reules
/*
 
 rules_version = '2';
 service cloud.firestore {
   match /databases/{database}/documents {
 
    MARK: กฎสำหรับคอลเลกชัน "users"
     match /users/{userId} {
       
       MARK: อนุญาตให้อ่านถ้าผู้ใช้ได้ล็อกอิน
       allow read: if request.auth != null;
 
       MARK: อนุญาตให้เขียนถ้าผู้ใช้ได้ล็อกอินและเป็นเจ้าของข้อมูล
       allow write: if request.auth != null && request.auth.uid == userId;
       
       MARK: สามารถเพิ่มเงื่อนไขการเขียนเพิ่มเติมได้ที่นี่
       // allow write: if resource.data.user_isPremium == false;
       // allow write: if request.resource.data.custom_key == "1234";
       // allow write: if isPublic();
     }
     
     MARK: กฎสำหรับคอลเลกชันย่อย "favorite_products"
     match /users/{userId}/favorite_products/{userFavoriteProductID} {
 
           MARK: อนุญาตให้อ่านถ้าผู้ใช้ได้ล็อกอิน
           allow read: if request.auth != null;
 
           MARK: อนุญาตให้เขียนถ้าผู้ใช้ได้ล็อกอินและเป็นเจ้าของข้อมูล
           allow write: if request.auth != null && request.auth.uid == userId;
     }
     
     MARK: กฎสำหรับคอลเลกชัน "products"
     match /products/{productId} {
 
       MARK: อนุญาตให้อ่านถ้าผู้ใช้ได้ล็อกอิน
       allow read: if request.auth != null;
 
       MARK: อนุญาตให้สร้างถ้าผู้ใช้ได้ล็อกอินและเป็นผู้ดูแลระบบ
       allow create: if request.auth != null && isAdmin(request.auth.uid);
 
       MARK: อนุญาตให้อัปเดตถ้าผู้ใช้ได้ล็อกอินและเป็นผู้ดูแลระบบ
       allow update: if request.auth != null && isAdmin(request.auth.uid);
 
       MARK: ไม่อนุญาตให้ลบ
       allow delete: if false;
     }
     
     MARK: ฟังก์ชันตรวจสอบความเป็นสาธารณะ
     function isPublic() {
         return resource.data.visibility == "public";
     }
     
     MARK: ฟังก์ชันตรวจสอบผู้ดูแลระบบ
     function isAdmin(userId) {
       
         MARK: ตรวจสอบว่าผู้ใช้เป็นผู้ดูแลระบบหรือไม่
         return exists(/databases/$(database)/documents/admins/$(userId));
     }
   }
 }

 MARK: read: อนุญาตให้
 // get - single document reads (อ่านเอกสารเดี่ยว)
 // list - queries and collection read requests (อ่านคอลเลกชัน)
 
 MARK: write: อนุญาตให้
 // create - add document (เพิ่มเอกสาร)
 // update - edit document (แก้ไขเอกสาร)
 // delete - delete document (ลบเอกสาร)
 
 */



// MARK: อธิบายกฎความปลอดภัย:
/*
 
MARK: คอลเลกชัน users
 - อนุญาตให้อ่านได้หากผู้ใช้ได้ล็อกอิน (request.auth != null)
 - อนุญาตให้เขียนได้หากผู้ใช้ได้ล็อกอินและเป็นเจ้าของข้อมูล (request.auth.uid == userId)
 
MARK: คอลเลกชันย่อย favorite_products ภายใต้ users
 - อนุญาตให้อ่านและเขียนได้ในเงื่อนไขเดียวกับคอลเลกชัน users

MARK: คอลเลกชัน products
 - อนุญาตให้อ่านได้หากผู้ใช้ได้ล็อกอิน (request.auth != null)
 - อนุญาตให้สร้างและอัปเดตได้หากผู้ใช้ได้ล็อกอินและเป็นผู้ดูแลระบบ (isAdmin(request.auth.uid))
 - ไม่อนุญาตให้ลบ
 
MARK: ฟังก์ชันเสริม
 - isPublic(): ตรวจสอบว่าเอกสารมีการตั้งค่าความเป็นสาธารณะหรือไม่
 - isAdmin(userId): ตรวจสอบว่าผู้ใช้เป็นผู้ดูแลระบบโดยการตรวจสอบการมีอยู่ของเอกสารผู้ดูแลในคอลเลกชัน admins

 */
