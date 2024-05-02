//
//  CrashView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 17/5/2567 BE.
//

import SwiftUI

struct CrashView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                // เมื่อกดปุ่มนี้ จะเพิ่มบันทึก (addLog) และตรวจสอบค่า myString ซึ่งเป็น nil ถ้า nil จะส่งข้อผิดพลาดแบบไม่ร้ายแรง (sendNonFatal)
                Button("Click me 1") {
                    CrashManager.shared.addLog(message: "button_1_clicked")
                    
                    let myString: String? = nil
                    
                    guard let myString else {
                        CrashManager.shared.sendNonFatal(error: URLError(.dataNotAllowed))
                        return
                    }
                    
                    let string2 = myString
                }
                
                // เมื่อกดปุ่มนี้ จะเพิ่มบันทึกและเกิดข้อผิดพลาดแบบร้ายแรง (fatalError)
                Button("Click me 2") {
                    CrashManager.shared.addLog(message: "button_2_clicked")
                    
                    fatalError("This was a fatal crash.")
                }
                
                // เมื่อกดปุ่มนี้ จะเพิ่มบันทึกและพยายามเข้าถึงสมาชิกในอาเรย์ที่ว่างเปล่า ทำให้เกิดข้อผิดพลาด
                Button("Click me 3") {
                    CrashManager.shared.addLog(message: "button_3_clicked")
                    
                    let array: [String] = []
                    let item = array[0]
                }
            }
        }
        
        // เรียกใช้เมธอด CrashManager เมื่อวิวปรากฏบนหน้าจอ รวมถึงการตั้งค่า userId และ isPremium และเพิ่มบันทึกการแสดงผลของวิว
        .onAppear {
            CrashManager.shared.setUserId(userId: "ABC123")
            CrashManager.shared.setIsPremiumValue(isPremium: false)
            CrashManager.shared.addLog(message: "crash_view_appeard")
            CrashManager.shared.addLog(message: "Crash view appeared on user's screen.")
        }
    }
}

#Preview {
    CrashView()
}
