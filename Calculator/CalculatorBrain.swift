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
    var pendingOperandNumber = Double()
    var accumulator = " "
    var textCurrentlyInAccumulator = String()

    private func string(from number: Double) -> String {
        return String(format: "%.14g", number)
    }
    
    private mutating func reset() {
        isPendingOperand = false
        isPendingOperator = false
        isOperationPending = false
        isEqualsPressed = false
        pendingOperand = "0"
        pendingOperandNumber = 0.0
        accumulator = " "
        textCurrentlyInAccumulator = ""
    }
    
    private mutating func evaluate(_ expression: String) -> String {
        guard let result = solver.evaluate(expression) else {
            reset()
            return "Error"
        }
        pendingOperandNumber = result
        return string(from: result)
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
        pendingOperandNumber = Double(pendingOperand) ?? 0.0
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
            case let .unaryOperation(function, _, _, _):
                if isEqualsPressed {
                    accumulator = " "
                    isEqualsPressed = false
                }
                pendingOperandNumber = function(pendingOperandNumber)
                pendingOperand = string(from: pendingOperandNumber)
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
                    accumulator.append(string(from: pendingOperandNumber))
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
                    accumulator.append(string(from: pendingOperandNumber))
                    isPendingOperand = false
                    if accumulator != " " {
                        pendingOperand = evaluate(accumulator)
                        isPendingOperator = false
                        isOperationPending = false
                    }
                    isEqualsPressed = true
                }
            case .clear:
                reset()
            }
        }
    }
}

    
