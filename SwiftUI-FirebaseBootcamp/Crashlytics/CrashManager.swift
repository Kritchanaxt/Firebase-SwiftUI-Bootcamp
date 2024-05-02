//
//  CrashManager.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 17/5/2567 BE.
//

import Foundation
import FirebaseCrashlytics

final class CrashManager {
    
    // ถูกออกแบบให้เป็น Singleton เพื่อให้สามารถเข้าถึงได้จากที่ใดก็ได้ในแอปพลิเคชันโดยใช้ CrashManager.shared
    static let shared = CrashManager()
    private init() { }
    
    // ฟังก์ชันนี้ใช้ตั้งค่า User ID ใน Crashlytics เพื่อระบุผู้ใช้ที่ทำให้เกิดข้อผิดพลาด
    func setUserId(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    // ฟังก์ชันนี้ใช้ตั้งค่า Custom Value ใน Crashlytics ด้วยค่าและคีย์ที่กำหนด
    private func setValue(value: String, key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    // ฟังก์ชันนี้ใช้ตั้งค่า Custom Value ใน Crashlytics เพื่อระบุสถานะการเป็นผู้ใช้ Premium หรือไม่ โดยแปลงค่า Bool เป็น String
    func setIsPremiumValue(isPremium: Bool) {
        setValue(value: isPremium.description.lowercased(), key: "user_is_premium")
    }
    
    // ฟังก์ชันนี้ใช้เพิ่มข้อความ Log ใน Crashlytics เพื่อบันทึกเหตุการณ์ที่เกิดขึ้นในแอปพลิเคชัน
    func addLog(message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    // ฟังก์ชันนี้ใช้บันทึกข้อผิดพลาดที่ไม่ร้ายแรงใน Crashlytics เพื่อเก็บข้อมูลข้อผิดพลาดที่ไม่ทำให้แอปพลิเคชันหยุดทำงาน
    func sendNonFatal(error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
}
