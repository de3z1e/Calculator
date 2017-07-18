//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Dimitry Zadorozny on 5/16/17.
//  Copyright © 2017 Dimitry Zadorozny. All rights reserved.
//

import Foundation

struct CalculatorBrain {

    private let solver = Solver()
    
    var result: String?

    var operationEvaluated = false
    var unaryOperationEvaluated = false
    var isPendingOperand = false
    var accumulator = " "
    var currentOperand = "0"

    mutating func setOperand(_ operand: String) {
        if operationEvaluated == true {
            accumulator = " "
            operationEvaluated = false
        }
        
        let digit = operand
        if isPendingOperand {
            let textCurrentlyInDisplay = currentOperand
            currentOperand = textCurrentlyInDisplay + (digit == "." && textCurrentlyInDisplay.contains(".") ? "" : digit)
        } else {
            currentOperand = (digit == "." ? "0." : digit)
            isPendingOperand = true
            result = nil
        }
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case let .constant(_, description):
                if operationEvaluated == true {
                    accumulator = " "
                    operationEvaluated = false
                }
                
                if currentOperand == "0" {
                    currentOperand = description
                } else {
                    currentOperand.append(description)
                }
                isPendingOperand = true
                result = nil
            case let .unaryOperation(function, _, associativity, description):
                isPendingOperand = true
                if operationEvaluated {
                    accumulator = " "
                    currentOperand =  result!
                    result = nil
                    operationEvaluated = false
                }
                if description == "-" && currentOperand.hasPrefix("-") {
                    currentOperand.remove(at: currentOperand.startIndex)
                } else if let operand = Double(currentOperand) {
                    isPendingOperand = false
                    if function(operand).remainder(dividingBy: 1) == 0 {
                        result = String(Int(function(operand))) // potential fatal error: Int.max
                    } else {
                        result = String(function(operand))
                    }
                    if associativity == .right {
                        currentOperand = description + (currentOperand == "0" ? "" : currentOperand)
                    } else {
                        currentOperand.append(description)
                    }
                    accumulator.append(currentOperand)
                    operationEvaluated = true
                    unaryOperationEvaluated = true
                }

            case let .binaryOperation(_, _, _, description):
                if operationEvaluated {
                    accumulator = " "
                    currentOperand = unaryOperationEvaluated ? currentOperand : result!
                    result = nil
                    isPendingOperand = true
                    operationEvaluated = false
                    unaryOperationEvaluated = false
                }
                if isPendingOperand {
                    accumulator.append(currentOperand)
                    currentOperand = ""
                    accumulator.append(" \(description) ")
                    isPendingOperand = false
                }
            case .brace:
                break
            case .equals:
                if isPendingOperand {
                    accumulator.append(currentOperand)
                    currentOperand = ""
                    isPendingOperand = false
                }
                if let solution = solver.evaluate(accumulator) {
                    if solution.remainder(dividingBy: 1) == 0 {
                        result = String(Int(solution)) // potential fatal error: Int.max
                    } else {
                        result = String(solution)
                    }
                }
                operationEvaluated = true
            case .clear:
                currentOperand = "0"
                accumulator = " "
                isPendingOperand = false
                operationEvaluated = false
                unaryOperationEvaluated = false
                result = nil
            }
        }
    }
}

    
