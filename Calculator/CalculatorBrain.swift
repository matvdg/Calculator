//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Mathieu Vandeginste on 02/05/2016.
//  Copyright © 2016 Mathieu Vandeginste. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    private var internalDescription = " "
    private var newOperand = false
    
    func setOperand(operand: Double){
        newOperand = true
        accumulator = operand
        internalProgram.append(operand)
    }
    
    func performOperation(symbol: String){
        internalProgram.append(symbol)
        formatDescription(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, symbol: symbol, secondOperand: false)
            case .Equals:
                executePendingBinaryOperation()
            case .Clear :
                clear()
            case .Percent :
                performPercentOperation()
            case .Random :
                accumulator = generateRandomNumber()
            }
        }
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
        case Percent
        case Random
    }
    
    private var operations = [
        //Constants
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        //Clear
        "C" : Operation.Clear,
        //Unary operations
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "√" : Operation.UnaryOperation(sqrt),
        "(-)" :Operation.UnaryOperation({-$0}),
        //Binary operations
        "+" : Operation.BinaryOperation({$0 + $1}),
        "−" : Operation.BinaryOperation({$0 - $1}),
        "×" : Operation.BinaryOperation({$0 * $1}),
        "÷" : Operation.BinaryOperation({$0 / $1}),
        "≡" : Operation.BinaryOperation({$0 % $1}),
        //Equals
        "=" : Operation.Equals,
        //Percent (unary or binary operation depending on the context)
        "%" : Operation.Percent,
        //Random
        "rand" : Operation.Random
    ]
    
    private func formatDescription(input: String) {
        let accumulatorString = accumulator.stringFromDouble
        if isPartialResult {
            if let operation = operations[input] {
                switch operation {
                case .UnaryOperation:
                    if input == "(-)" {
                        internalDescription += " -(\(accumulatorString)) "
                    } else {
                        internalDescription += " \(input)(\(accumulatorString)) "
                    }
                    pending!.secondOperand = true
                case .Constant:
                    internalDescription += input
                    pending!.secondOperand = true
                case .BinaryOperation:
                    if isFactorization(input) {
                        internalDescription = "(\(internalDescription) \(accumulatorString) ) \(input) "
                    } else {
                        internalDescription += " \(accumulatorString) \(input) "
                    }
                case .Equals:
                    if !pending!.secondOperand {
                        internalDescription += " \(accumulatorString) "
                    }
                    newOperand = false
                default :
                    break
                }
            }
        } else {
            if let operation = operations[input] {
                switch operation {
                case .Constant:
                    internalDescription += input
                case .UnaryOperation:
                    if internalDescription == " " {
                        internalDescription = accumulatorString
                    }
                    if input == "(-)" {
                        internalDescription = " -(\(internalDescription)) "
                    } else {
                        internalDescription = " \(input)(\(internalDescription)) "
                    }
                    pending?.secondOperand = true
                case .BinaryOperation:
                    if internalDescription == " " {
                        internalDescription += accumulatorString + " \(input) "
                    } else {
                        if newOperand {
                            internalDescription = accumulatorString + " \(input) "
                        } else {
                            if isFactorization(input) {
                                internalDescription = "(\(internalDescription)) \(input) "
                            } else {
                                internalDescription += " \(input) "
                            }
                        }
                    }
                default :
                    break
                }
            }
            
        }
        
    }
    
    private func isFactorization(input: String) -> Bool {
        if input == "×" || input == "÷" {
            return true
        } else {
            return false
        }
    }
    
    private func generateRandomNumber() -> Double {
        return Double(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    private func performPercentOperation() {
        if let p = pending {
            accumulator = p.firstOperand / 100 * accumulator
        } else {
            accumulator = accumulator / 100
        }
    }
    
    private func clear() {
        internalProgram.removeAll()
        accumulator = 0.0
        internalDescription = " "
        pending = nil
    }
    
    var result: Double {
        return accumulator
    }
    
    var description: String {
        return internalDescription
    }
    
    var isPartialResult: Bool {
        return pending != nil
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
        var symbol: String
        var secondOperand: Bool
    }
    
    private func executePendingBinaryOperation() {
        if let p = pending {
            accumulator = p.binaryFunction(p.firstOperand,accumulator)
            pending = nil
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set (new) {
            clear()
            if let arrayOfOps = new as? [AnyObject] {
                for op in arrayOfOps {
                    if let symbol = op as? String {
                        performOperation(symbol)
                    } else if let operand = op as? Double {
                        setOperand(operand)
                    }
                }
            }
        }
    }
}