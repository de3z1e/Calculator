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

    var isPendingOperand = false
    var isPendingOperator = false
    var operationPending = false
    var equalsPressed = false
    
    var pendingOperand = "0"
    var accumulator = " "
    var textCurrentlyInAccumulator = String()


    mutating func evaluate(_ expression: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 20
        if let result = solver.evaluate(expression) {
            let formattedResult = formatter.string(for: result)
            return formattedResult ?? "Error"
        } else {
            pendingOperand = "0"
            accumulator = " "
            isPendingOperand = false
            isPendingOperator = false
            equalsPressed = false
            textCurrentlyInAccumulator = ""
            return "Error"
        }
    }
    
    mutating func setOperand(_ digit: String) {
        if isPendingOperand {
            pendingOperand.append(digit == "." && pendingOperand.contains(".") ? "" : digit)
        } else {
            if equalsPressed {
                accumulator = " "
                equalsPressed = false
            }
            pendingOperand = (digit == "." ? "0." : digit)
            isPendingOperand = true
            isPendingOperator = false
        }
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant:
                break
            case let .unaryOperation(_, _, associativity, description):
                if equalsPressed {
                    accumulator = " "
                    equalsPressed = false
                }
                let unaryExpression = (associativity == .left ? pendingOperand + description : description + "(\(pendingOperand))")
                pendingOperand = evaluate(unaryExpression)
                isPendingOperand = false
                isPendingOperator = false
            case let .binaryOperation(_, _, _, description):
                if equalsPressed {
                    accumulator = " "
                    equalsPressed = false
                }
                let pendingOperation = " \(description) "
                if isPendingOperator {
                    accumulator = textCurrentlyInAccumulator + pendingOperation
                } else {
                    accumulator.append(pendingOperand)
                    textCurrentlyInAccumulator = accumulator
                    accumulator.append(pendingOperation)
                    isPendingOperand = false
                    isPendingOperator = true
                    operationPending = true
                }
            case .brace:
                break
            case .equals:
                guard operationPending else {
                    break
                }
                if !equalsPressed {
                    accumulator.append(pendingOperand)
                    isPendingOperand = false
                    if accumulator != " " {
                        pendingOperand = evaluate(accumulator)
                        //textCurrentlyInAccumulator = pendingOperand
                        isPendingOperator = false
                        operationPending = false
                    }
                    equalsPressed = true
                }
            case .clear:
                pendingOperand = "0"
                accumulator = " "
                isPendingOperand = false
                isPendingOperator = false
                operationPending = false
                equalsPressed = false
                textCurrentlyInAccumulator = ""
            }
        }
    }
}

    
