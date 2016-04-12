//
//  ViewController.swift
//  Calculator
//
//  Created by Josh Broomberg on 2016/04/10.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    var inputInProcess = false

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if inputInProcess {
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            inputInProcess = true
        }
        
    }
    
    var operatingStack = Array<Double>()
    @IBAction func enter() {
        inputInProcess = false
        operatingStack.append(displayValue)
        print("\(operatingStack)")
        
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        
        if inputInProcess{
            enter()
        }
        
        switch operation {
            case "*": performOperation {$0 * $1}
            case "+": performOperation {$0 + $1}
            case "-": performOperation {$1 - $0}
            case "/": performOperation {$1 / $0}
            case "√": performSingleOperation {sqrt($0)}
            default: break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operatingStack.count >= 2 {
            displayValue = operation(operatingStack.removeLast(), operatingStack.removeLast())
            enter()
        }
    }
    
    func performSingleOperation(operation: Double -> Double) {
        if operatingStack.count >= 2 {
            displayValue = operation(operatingStack.removeLast())
            enter()
        }
    }
    
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        
        set {
            display.text = "\(newValue)"
            inputInProcess = false
        }
    }
}

