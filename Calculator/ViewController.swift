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
    
    @IBOutlet weak var log: UILabel!
    
    var inputInProcess = false
    var operatingStack = Array<Double>()
    var logEmpty = true

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if inputInProcess {
            if digit == "." {
                if displayString.rangeOfString(".") == nil {
                    display.text = display.text! + digit
                }
            }
            else {
                display.text = display.text! + digit
            }
            
        }
        else {
            display.text = digit
            inputInProcess = true
        }
    }
    
    func appendToLog(logItem: String) {
        log.numberOfLines = 0;
        if logEmpty {
            log.text = logItem + "\n"
            logEmpty = false
        }
        else {
           log.text = log.text! + logItem + "\n"
        }
    }
    
    
    @IBAction func enter() {

        inputInProcess = false
        if let value = displayValue {
            operatingStack.append(value)
            appendToLog("\(value)")
        } else {
            displayString = "error"
        }
        
    }
    
    @IBAction func back() {
        if inputInProcess {
            if (displayString as NSString).length > 1 {
                displayString = displayString[displayString.startIndex..<displayString.endIndex.predecessor()]
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func clear() {
        operatingStack = []
        display.text = "0"
        inputInProcess = false
        logEmpty = true
        log.text = ""
    }
    
    @IBAction func operate(sender: UIButton) {
        let dualPurposeFunction = ["±"]
        let operation = sender.currentTitle!
        if inputInProcess{
            if dualPurposeFunction.indexOf(operation) == nil {
                enter()
            }
        }
        appendToLog("\(operation)")
        
        switch operation {
            case "*": performOperation {$0 * $1}
            case "+": performOperation {$0 + $1}
            case "-": performOperation {$1 - $0}
            case "/": performOperation {$1 / $0}
            case "√": performSingleOperation {sqrt($0)}
            case "sin": performSingleOperation {sin($0)}
            case "cos": performSingleOperation {cos($0)}
            case "±":
                if inputInProcess {
                    displayString = "-" + displayString
                } else {
                    performSingleOperation {-($0)}
                }
            default: break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operatingStack.count >= 2 {
            displayValue = operation(operatingStack.removeLast(), operatingStack.removeLast())
            enter()
            displayString = "=\(displayString)"
        }
    }
    
    func performSingleOperation(operation: Double -> Double) {
        if operatingStack.count >= 1 {
            displayValue = operation(operatingStack.removeLast())
            enter()
            displayString = "=\(displayString)"
        }
    }
    
    var displayString: String {
        get {
            return display.text!
        }
        
        set{
            display.text = newValue
            inputInProcess = false
        }
    }
    
    var displayValue: Double? {
        get {
            if display.text! != "π" {
                return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
            }
            else {
                return M_PI
            }
        }
        
        set {
            if newValue == nil {
                display.text = "0.0"
            } else {
                display.text = "\(newValue!)"
                inputInProcess = false
            }
        }
    }
}

