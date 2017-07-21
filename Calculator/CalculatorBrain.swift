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
    var isOperationPending = false
    var isEqualsPressed = false
    
    var pendingOperand = "0"
    var accumulator = " "
    var textCurrentlyInAccumulator = String()


    mutating func evaluate(_ expression: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 14
        if let result = solver.evaluate(expression) {
            let formattedResult = formatter.string(for: result)
            return formattedResult ?? "Error"
        } else {
            pendingOperand = "0"
            accumulator = " "
            isPendingOperand = false
            isPendingOperator = false
            isOperationPending = false
            isEqualsPressed = false
            textCurrentlyInAccumulator = ""
            return "Error"
        }
    }
    
    mutating func setOperand(_ digit: String) {
        if isPendingOperand {
            pendingOperand.append(digit == "." && pendingOperand.contains(".") ? "" : digit)
        } else {
            if isEqualsPressed {
                accumulator = " "
                isEqualsPressed = false
            }
            pendingOperand = (digit == "." ? "0." : digit)
            isPendingOperand = true
            isPendingOperator = false
        }
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case let .constant(_ , description):
                if isEqualsPressed {
                    accumulator = " "
                    isEqualsPressed = false
                }
                pendingOperand = evaluate(description)
                isPendingOperand = false
                isPendingOperator = false
                break
            case let .unaryOperation(_, _, associativity, description):
                if isEqualsPressed {
                    accumulator = " "
                    isEqualsPressed = false
                }
                let unaryExpression = (associativity == .left ? pendingOperand + description : description + "(\(pendingOperand))")
                pendingOperand = evaluate(unaryExpression)
                isPendingOperand = false
                isPendingOperator = false
            case let .binaryOperation(_, _, _, description):
                if isEqualsPressed {
                    accumulator = " "
                    isEqualsPressed = false
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
                    isOperationPending = true
                }
            case .brace:
                break
            case .equals:
                guard isOperationPending else {
                    break
                }
                if !isEqualsPressed {
                    accumulator.append(pendingOperand)
                    isPendingOperand = false
                    if accumulator != " " {
                        pendingOperand = evaluate(accumulator)
                        //textCurrentlyInAccumulator = pendingOperand
                        isPendingOperator = false
                        isOperationPending = false
                    }
                    isEqualsPressed = true
                }
            case .clear:
                pendingOperand = "0"
                accumulator = " "
                isPendingOperand = false
                isPendingOperator = false
                isOperationPending = false
                isEqualsPressed = false
                textCurrentlyInAccumulator = ""
            }
        }
    }
}

    
