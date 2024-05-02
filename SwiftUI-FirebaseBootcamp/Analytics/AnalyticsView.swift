//
//  AnalyticsView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 18/5/2567 BE.
//

import SwiftUI
import FirebaseAnalytics
import FirebaseAnalyticsSwift

final class AnalyticsManager {
    
    // คลาสนี้เป็น Singleton ที่ใช้ในการจัดการการบันทึกเหตุการณ์และตั้งค่าคุณสมบัติผู้ใช้ใน Firebase Analytics
    static let shared = AnalyticsManager()
    private init() { }
    
    // ฟังก์ชันบันทึกเหตุการณ์
    func logEvent(name: String, params: [String:Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    // ฟังก์ชันตั้งค่า User ID
    func setUserId(userId: String) {
        Analytics.setUserID(userId)
    }
    
    // ฟังก์ชันตั้งค่าคุณสมบัติผู้ใช้
    func setUserProperty(value: String?, property: String) {
         // AnalyticsEventAddPaymentInfo
        Analytics.setUserProperty(value, forName: property)
    }
}

// View ที่ใช้แสดงเนื้อหาและเรียกใช้งาน AnalyticsManager เพื่อบันทึกเหตุการณ์ต่างๆ
struct AnalyticsView: View {
    var body: some View {
        VStack(spacing: 40) {
            
            // ปุ่มแรกที่บันทึกเหตุการณ์เมื่อถูกคลิก
            Button("Click me!") {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_ButtonClick")
            }
            
            // ปุ่มที่สองที่บันทึกเหตุการณ์พร้อมพารามิเตอร์เมื่อถูกคลิก
            Button("Click me too!") {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_SecondaryButtonClick", 
                                                 params: ["screen_title" : "Hello, world!"])
            }
        }
        
        // ตั้งชื่อหน้าจอสำหรับการติดตาม
        .analyticsScreen(name: "AnalyticsView")
        
        // บันทึกเหตุการณ์เมื่อ View ปรากฏบนหน้าจอ
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_Appear")
        }
        
        // บันทึกเหตุการณ์เมื่อ View หายไปจากหน้าจอ
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_Disppear")
            
            // ตั้งค่า User ID และคุณสมบัติผู้ใช้
            AnalyticsManager.shared.setUserId(userId: "ABC123")
            AnalyticsManager.shared.setUserProperty(value: true.description, property: "user_is_premium")
        }
    }
}

#Preview {
    AnalyticsView()
}
