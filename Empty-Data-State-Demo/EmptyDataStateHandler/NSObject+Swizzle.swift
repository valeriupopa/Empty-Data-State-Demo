//
//  NSObject+Swizzle.swift
//  TheMovie
//
//  Created by Valeriu POPA on 3/2/17.
//  Copyright © 2017 Valeriu POPA. All rights reserved.
//

import Foundation

extension NSObject {
    class func swizzleMethods(originalSelector: Selector, withSelector: Selector, forClass: AnyClass) {
        
        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
        let swizzleMethod = class_getInstanceMethod(forClass, withSelector)
        
        method_exchangeImplementations(originalMethod, swizzleMethod)
    }
    
    func swizzleMethods(originalSelector: Selector, withSelector: Selector) {
        let targetClass : AnyClass = object_getClass(self)
        NSObject.swizzleMethods(originalSelector: originalSelector, withSelector: withSelector, forClass: targetClass)
    }
}
