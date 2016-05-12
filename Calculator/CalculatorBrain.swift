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
    private var lastOperation = ""
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand: Double){
        accumulator = operand
        internalProgram.append(operand)
    }
    
    func performOperation(symbol: String){
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            lastOperation = ""
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, symbol: symbol)
            case .Equals:
                executePendingBinaryOperation()
            case .Clear :
                accumulator = 0
                pending = nil
            }
        }
    }
    
    var result: Double {
        return accumulator
    }
    
    var history: String {
        return lastOperation
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
        var symbol: String
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            lastOperation = "\(pending!.firstOperand) \(pending!.symbol) \(accumulator) = "
            accumulator = pending!.binaryFunction(pending!.firstOperand,accumulator)
            pending = nil
        }
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
        "±" :Operation.UnaryOperation({-$0}),
        "%" : Operation.UnaryOperation({$0/100}),
        //Binary operations
        "+" : Operation.BinaryOperation({$0 + $1}),
        "-" : Operation.BinaryOperation({$0 - $1}),
        "×" : Operation.BinaryOperation({$0 * $1}),
        "÷" : Operation.BinaryOperation({$0 / $1}),
        //Equals
        "=" : Operation.Equals
        
    ]
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
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
    
    private func clear() {
        internalProgram.removeAll()
        accumulator = 0.0
        pending = nil
    }
    
    
}