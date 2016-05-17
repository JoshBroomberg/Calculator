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
    
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var memoryButton: UIButton!
    
    var inputInProgress = false {
        didSet {
            if inputInProgress {
                valueOnscreen = true
            } else {
                valueOnscreen = false
            }
        }
    }
    
    var resultOnscreen = false {
        didSet {
            if resultOnscreen {
                if let _ = displayValue {
                    valueOnscreen = true
                    display.text = display.text! + "="
                }
            } else {
                valueOnscreen = false
            }
        }
    }
    
    var valueOnscreen: Bool {
        get { return resultOnscreen || inputInProgress }
        set {
            if valueOnscreen {
                clearButton.setTitle("C", forState: .Normal)
                memoryButton.setTitle("→M", forState: .Normal)
            } else {
                clearButton.setTitle("AC", forState: .Normal)
                memoryButton.setTitle("M", forState: .Normal)
            }
        }
    }
    
    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if inputInProgress {
            if display.text?.rangeOfString("=") != nil {
                display.text = digit
            } else {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            inputInProgress = true
        }
    }
    
    @IBAction func enterConstant(sender: UIButton) {
        let constant = sender.currentTitle!
        displayValue = brain.pushOperand(constant)
        display.text = constant
        inputInProgress = false
    }
    
    @IBAction func enterVariable(sender: UIButton) {
        var variable = sender.currentTitle!
        if valueOnscreen {
            if let newValue = displayValue {
                variable.removeRange(variable.rangeOfString("→")!)
                brain.setVariable(variable, value: newValue)
                resetInput("\(variable)←\(newValue)")
            }
        } else {
            displayValue = brain.pushOperand(variable)
            display.text = variable
        }
    }

    @IBAction func enter() {
        // Fix this method to unify format/input error handling.
        print("value on screen: \(valueOnscreen)")
        if valueOnscreen {
            if let value = displayValue {
                displayValue = brain.pushOperand(value)
                inputInProgress = false
                resultOnscreen = false
            } else {
                resetInput("Error in input")
            }
        } else {
            displayValue = brain.evaluate()
            resultOnscreen = true
        }
            
        
    }
    
    @IBAction func back() {
        if inputInProgress {
            let displayText = display.text!
            if (displayText as NSString).length > 1 {
                displayString = displayString[displayString.startIndex..<displayString.endIndex.predecessor()]
                display.text = String(displayText.characters.dropLast())
            } else {
                resetInput()
            }
        }
    }
    

    @IBAction func clear(sender: UIButton) {
        let action = sender.currentTitle!
        if action == "AC" {
            brain.clear()
            refreshLog()
        }
        resetInput ()
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if inputInProgress {
            enter()
        }
        displayValue = brain.pushOperation(operation)
        resultOnscreen = true
    }
    
    func refreshLog() {
        if let string = brain.stackString() {
            log.text = string.stringByReplacingOccurrencesOfString(", ", withString: "\n")
        } else {
            log.text = ""
        }
    }
    
    func resetInput(resetTo: String = "0.0") {
        inputInProgress = false
        resultOnscreen = false
        display.text = resetTo
    }
    
    var displayString: String {
        get {
            return display.text!
        }
        
        set{
            display.text = newValue
        }
    }
    
    var displayValue: Double? {
        get {
            return brain.numberFromString(display.text!)
        }
        
        set {
            if let value = newValue {
                display.text = "\(value)"
            } else {
                resetInput("Error in stack eval")
            }
            refreshLog()
        }
    }
}

