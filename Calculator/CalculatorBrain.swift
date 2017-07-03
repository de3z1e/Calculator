//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Dimitry Zadorozny on 5/16/17.
//  Copyright © 2017 Dimitry Zadorozny. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    private var accumulator: Double? = 0 {
        willSet {
            if newValue != nil && resultIsPending {
                description.append(String(newValue!))
            }
        }
    }
    
    private var resultIsPending: Bool = true
    var description = String()
    
    private enum Operation {
        case constant(Double)
        case unaryOperation( (Double) -> Double )
        case binaryOperation( (Double, Double) -> Double)
        case equals
        case clear

    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "x²": Operation.unaryOperation( {$0 * $0} ),
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "tan" : Operation.unaryOperation(tan),
        "±" : Operation.unaryOperation( {-$0} ),
        "×" : Operation.binaryOperation( {$0 * $1} ),
        "÷" : Operation.binaryOperation( {$0 / $1} ),
        "+" : Operation.binaryOperation( {$0 + $1} ),
        "-" : Operation.binaryOperation( {$0 - $1} ),
        "=" : Operation.equals,
        "C" : Operation.clear
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                description.append(symbol)
                resultIsPending = false
                accumulator = value
                resultIsPending = true
            case .unaryOperation(let function):
                if accumulator != nil {
                    switch symbol {
                    case "x²":
                        description.append("²")
                    case "√":
                        description = "√(\(description))"
                    default:
                        break
                    }
                    resultIsPending = false
                    accumulator = function(accumulator!)
                    resultIsPending = true
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                    description.append(" \(symbol) ")
                }
            case .equals:
                performPendingBinaryOperation()
            case .clear:
                accumulator = 0
                pendingBinaryOperation = nil
                description = " "
                resultIsPending = true
            }
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            resultIsPending = false
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            resultIsPending = true
            pendingBinaryOperation = nil
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        if !resultIsPending {
            description = " "
            resultIsPending = true
        }
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
}
