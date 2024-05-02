//
//  SwiftUI_FirebaseBootcampApp.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 2/5/2567 BE.
//

import SwiftUI

// นำเข้า Firebase module เพื่อใช้ในการจัดการกับ Firebase services ต่างๆ
import Firebase

// นำเข้า FirebaseCore module เพื่อใช้ในการกำหนดค่าและกำหนดค่า Firebase app ในแอปพลิเคชัน
import FirebaseCore

// ประกาศ @main ให้ SwiftUI_FirebaseBootcampApp ซึ่งจะถูกเรียกใช้เป็นหน้าหลักของแอป
@main
struct SwiftUI_FirebaseBootcampApp: App {
    
    // กำหนด delegate ของแอปให้กับ AppDelegate เพื่อทำการตั้งค่า Firebase ตอนแอปเริ่มต้น
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
//            RootView()
//            CrashView()
//            PerformanceView()
            AnalyticsView()
        }
    }
}

// ประกาศคลาส AppDelegate ซึ่งเป็นตัวแทนของ UIApplicationDelegate และใช้ในการตั้งค่า Firebase ตอนแอปเริ่มต้น
class AppDelegate: NSObject, UIApplicationDelegate {
  
  // ฟังก์ชันที่ใช้ในการตั้งค่า Firebase ตอนแอปเริ่มต้น โดยจะถูกเรียกเมื่อแอปพลิเคชันเริ่มต้นหรือเปิดใช้งาน
    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
       // เรียกใช้เมท็อด configure() เพื่อกำหนดค่า Firebase ในแอปพลิเคชัน เช่น การเชื่อมต่อกับ Firebase services ต่างๆ
       FirebaseApp.configure()
      
       return true
    }
    
    // จะถูกเรียกเมื่อแอปกลับมาอยู่ในสถานะ active 
    // MARK: ใช้เพื่อเริ่มงานที่หยุดหรือรีเฟรช UI
    func applicationDidBecomeActive(_ application: UIApplication) {
            
    }
    
    // จะถูกเรียกเมื่อแอปกำลังจะเปลี่ยนจากสถานะ active ไปเป็นสถานะ inactive 
    // MARK: ใช้หยุดงานที่กำลังทำอยู่และปิดตัวจับเวลา
    func applicationWillResignActive(_ application: UIApplication) {
            
    }
    
}
