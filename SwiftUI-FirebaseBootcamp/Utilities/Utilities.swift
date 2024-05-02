//
//  Utilities.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 3/5/2567 BE.
//

import Foundation
import UIKit

// ประกาศคลาส Utilities เป็นคลาสที่ใช้เก็บเมธอดที่เป็นประโยชน์สำหรับการจัดการข้อมูลหรือโปรแกรม
final class Utilities {
    
    // ประกาศค่าคงที่ชื่อ shared เป็น instance ของคลาส Utilities
    // เพื่อให้สามารถเข้าถึงเมธอดของคลาสนี้ได้จากทุกที่ในโปรเจกต์ โดยไม่ต้องสร้างอ็อบเจกต์ใหม่
    static let shared = Utilities()
    
    // สร้าง initializer ของคลาส Utilities และทำให้เป็น private เพื่อไม่ให้สามารถสร้างอ็อบเจกต์ของคลาสนี้จากภายนอกคลาสได้โดยตรง
    private init() {}
    
    @MainActor
    
    // ฟังก์ชันนี้มีชื่อว่า topViewController และมีชี่อรับพารามิเตอร์ชื่อ controller ซึ่งเป็น UIViewController และเป็นค่าเริ่มต้นเป็น nil ฟังก์ชันจะส่งคืน UIViewController ที่เป็นค่าสูงสุดในลำดับชั้นของมันเมื่อใช้กับลำดับชั้นของมุมมอง
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        // สร้างตัวแปร controller โดยใช้ค่า controller ถ้ามีค่าให้ใช้ค่านั้น ไม่เช่นนั้นให้ใช้ rootViewController ของ keyWindow ของ UIApplication
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        // ตรวจสอบว่า controller เป็น UINavigationController หรือไม่ ถ้าใช่ จะเก็บค่าที่แปลงแล้วเป็น UINavigationController ในตัวแปร navigationController
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        // ตรวจสอบว่า controller เป็น UITabBarController หรือไม่ ถ้าใช่ จะเก็บค่าที่แปลงแล้วเป็น UITabBarController ในตัวแปร tabController
        if let tabController = controller as? UITabBarController {
            
            // ตรวจสอบว่ามี selectedViewController ใน tabController หรือไม่ และเก็บค่านั้นในตัวแปร selected
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        // ตรวจสอบว่า controller มี presentedViewController หรือไม่ และเก็บค่านั้นในตัวแปร presented
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        // ส่งคืน controller หากไม่มีเงื่อนไขใดเข้ากันในเงื่อนไขที่แล้ว
        return controller
    }
}
