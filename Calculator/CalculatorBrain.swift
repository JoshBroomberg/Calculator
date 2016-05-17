//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Josh Broomberg on 2016/05/10.
//  Copyright © 2016 iXperience. All rights reserved.
//

import Foundation

class CalculatorBrain
{
     private enum Op: CustomStringConvertible {
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Bool, (Double, Double) -> Double)
        
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(Double(round(1000*operand)/1000))"
            case .Variable(let name):
                return name
            case .UnaryOperation(let operation, _):
                return operation
            case .BinaryOperation(let operation, _, _):
                return operation
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var variableValues = [String:Double]()
    
    private var knownOps = [String:Op]()
    
    init(){
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        func learnVariable(op: Op, value: Double) {
            variableValues[op.description] = value
        }
        
        // Learn ops
        learnOp(Op.BinaryOperation("*", false) { $0 * $1 })
        learnOp(Op.BinaryOperation("+", true) { $0 + $1 })
        learnOp(Op.BinaryOperation("-", true) { $1 - $0 })
        learnOp(Op.BinaryOperation("/", true) { $1 / $0 })
        learnOp(Op.UnaryOperation("√") { sqrt($0)})
        learnOp(Op.UnaryOperation("sin") { sin($0) })
        learnOp(Op.UnaryOperation("cos") { cos($0) })
        learnOp(Op.UnaryOperation("±") { -($0) })
        
        // Learn variables
        learnVariable(.Variable("π"), value: M_PI)
    }
    
    
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(.Variable(symbol))
        return evaluate()
    }
    
    func pushOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }

        if let result = evaluate() {
            //pushOperand(result)
            return result
        } else {
            return nil
        }
    }
    
    func setVariable(name: String, value: Double) {
        print("\(name): \(value)")
        variableValues[name] = value
    }
    
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func stackString() -> String? {
        let (result, _) = stackString(opStack)
        return result
    }
    
    func numberFromString(string: String) -> Double? {
        var stringToEval = string
        if let range = stringToEval.rangeOfString("=") {
            stringToEval.removeRange(range)
        }
        return NSNumberFormatter().numberFromString(stringToEval)?.doubleValue ?? variableValues[string]
    }
    
    func clear() {
        opStack = []
        deleteVariable("M")
    }
    
    func deleteVariable(name: String) {
        if let _ = variableValues[name] {
            variableValues.removeValueForKey(name)
        }
    }
    
    private func evaluate(opStack: [Op]) -> (result: Double?, remainingOps: [Op]) {
        var remainingOps = opStack
        if !opStack.isEmpty {
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .Variable(let name):
                return (variableValues[name], remainingOps)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, _, let operation):
                let operandOneEvaluation = evaluate(remainingOps)
                if let operandOne = operandOneEvaluation.result {
                    let operandTwoEvaluation = evaluate(operandOneEvaluation.remainingOps)
                    if let operandTwo = operandTwoEvaluation.result {
                        return (operation(operandOne, operandTwo), operandTwoEvaluation.remainingOps)
                    }
                }
            }
            
            
        }
        return (nil, remainingOps)
    }
    
    private func stackString(opStack: [Op]) -> (stringResult: String?, remainingOps: [Op]) {
        
        if opStack.isEmpty {
            return (nil, [])
        }
        
        let (operationSubstring, remainingOps) = operationString(opStack)
        if remainingOps.count == 0 || operationSubstring == nil {
            return (operationSubstring, [])
        } else {
            let nextOperationEvaluation = stackString(remainingOps)
            if let nextOpString = nextOperationEvaluation.stringResult {
                return (nextOpString + ", " + operationSubstring!, nextOperationEvaluation.remainingOps)
            } else {
                return (operationSubstring!, [])
            }
        }
    }
    
    private func operationString(opStack: [Op]) -> (stringResult: String?, remainingOps: [Op]) {
        var remainingOps = opStack
        if !opStack.isEmpty {
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
                
            case .Variable(let name):
                return (name, remainingOps)
                
            case .UnaryOperation(let operation, _):
                let stringEvaluation = operationString(remainingOps)
                if let substring = stringEvaluation.stringResult {
                    return ("\(operation)(\(substring))", stringEvaluation.remainingOps)
                }
                
            case .BinaryOperation(let operation, let reversed, _):
                let stringOneEvaluation = operationString(remainingOps)
                if let substringOne = stringOneEvaluation.stringResult {
                    let stringTwoEvaluation = operationString(stringOneEvaluation.remainingOps)
                    if let substringTwo = stringTwoEvaluation.stringResult {
                        if reversed {
                            return ("(\(substringTwo)\(operation)\(substringOne))", stringTwoEvaluation.remainingOps)
                        } else {
                            return ("(\(substringOne)\(operation)\(substringTwo))", stringTwoEvaluation.remainingOps)
                        }
                    }
                }
            }
            
            
        }
        return ("?", remainingOps)
    }
}
