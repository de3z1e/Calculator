//
//  Solver.swift
//  Calculator
//
//  Created by Dimitry Zadorozny on 7/14/17.
//  Copyright © 2017 Dimitry Zadorozny. All rights reserved.
//

import Foundation

typealias BinaryTuple = ((Double, Double) -> Double, Int, Associativity, String)
typealias UnaryTuple = ((Double) -> Double, Int, Associativity, String)

enum Associativity {
    case left
    case right
}
 
struct Operation {
    static let unaryLeftAssociative = Token.unaryOperation( ({$0}, 0, .left, "") )
    static let unaryRightAssociative = Token.unaryOperation( ({$0}, 0, .right, "") )
    
    static let multiplication: BinaryTuple = ({$0 * $1}, 4, .left, "×")
    static let division: BinaryTuple = ({$0 / $1}, 4, .left, "÷")
    static let addition: BinaryTuple = ({$0 + $1}, 2, .left, "+")
    static let subtraction: BinaryTuple = ({$0 - $1}, 2, .left, "-")
    static let negate: UnaryTuple = ({-$0}, 6, .right, "-")
    static let squareRoot: UnaryTuple = (sqrt, 8, .right, "√")
    static let squared: UnaryTuple = ({$0 * $0}, 8, .left, "²")
    static let sinFunction: UnaryTuple = (sin, 8, .right, "sin")
    static let cosFunction: UnaryTuple = (cos, 8, .right, "cos")
    static let tanFunction: UnaryTuple = (tan, 8, .right, "tan")
}

var operations: Dictionary<String, Token> = [
    "=" : Token.equals("="),
    "C" : Token.clear("C"),
    "AC" : Token.clear("AC"),
    "π" : Token.constant( (Double.pi, "π") ),
    "e" : Token.constant( (M_E, "e") ),
    "(" : Token.brace("("),
    ")" : Token.brace(")"),
    "×" : Token.binaryOperation(Operation.multiplication),
    "÷" : Token.binaryOperation(Operation.division),
    "+" : Token.binaryOperation(Operation.addition),
    "-" : Token.binaryOperation(Operation.subtraction),
    "±" : Token.unaryOperation(Operation.negate),
    "√" : Token.unaryOperation(Operation.squareRoot),
    "²" : Token.unaryOperation(Operation.squared),
    "x²" : Token.unaryOperation(Operation.squared),
    "sin" : Token.unaryOperation(Operation.sinFunction),
    "cos" : Token.unaryOperation(Operation.cosFunction),
    "tan" : Token.unaryOperation(Operation.tanFunction)
]

enum Type {
    case constant
    case brace
    case binaryOperation
    case unaryOperation
    case equals
    case clear
}

enum Token {
    case constant( (Double, String) )
    case brace(String)
    case binaryOperation(BinaryTuple)
    case unaryOperation(UnaryTuple)
    case equals(String)
    case clear(String)
    
    var description: String {
        switch self {
        case .constant(_, let description):
            return description
        case .brace(let description):
            return description
        case .binaryOperation(_, _, _, let description):
            return description
        case .unaryOperation(_, _, _, let description):
            return description
        case .equals(let description):
            return description
        case .clear(let description):
            return description
        }
    }
    
    var type: Type {
        switch self {
        case .constant: return Type.constant
        case .brace: return Type.brace
        case .binaryOperation: return Type.binaryOperation
        case .unaryOperation: return Type.unaryOperation
        case .equals: return Type.equals
        case .clear: return Type.clear
        }
    }
    
    var precedence: Int {
        switch self {
        case .binaryOperation(_, let precedence, _, _):
            return precedence
        case .unaryOperation(_,let precedence, _, _):
            return precedence
        default:
            return 0
        }
    }
    
    var associativity: Associativity {
        switch self {
        case .binaryOperation(_, _, let associativity, _):
            return associativity
        case .unaryOperation(_, _, let associativity, _):
            return associativity
        default:
            return .left
        }
    }
    
    func compare(to token: Token) -> Bool {
        switch self {
        case .constant:
            switch token {case .constant: return true; default: return false}
        case .brace:
            switch token {case .brace: return true; default: return false}
        case .binaryOperation:
            switch token {case .binaryOperation: return true; default: return false}
        case .unaryOperation:
            switch token {case .unaryOperation: return self.associativity == token.associativity; default: return false}
        case .equals:
            switch token {case .equals: return true; default: return false}
        case .clear:
            switch token {case .clear: return true; default: return false}
        }
    }
}

class Solver {
    
    func evaluate(_ expression: String) -> Double? {
        let parsedExpression = parse(expression)
        let rpn = reversePolishNotation(parsedExpression)
        return evaluateReversePolishNotation(rpn)
    }
    
    // MARK: - Parser
    
    private func parse(_ expression: String) -> [Token] {
        var tokenizedExpression = [Token]()
        var currentOperand = String()
        var pendingOperationKey = String()
        
        func tokenize(_ currentOperandString: String) -> Token? {
            if let number = Double(currentOperandString) {
                currentOperand = ""
                return Token.constant( (number, String(number)) )
            } else if let token = operations[currentOperandString] {
                currentOperand = ""
                return token
            } else {
                return nil
            }
        }

        for char in expression.characters {
            
            if let token = operations[pendingOperationKey] {
                pendingOperationKey = ""
                switch token {
                case .unaryOperation:
                    if let tokenizedOperand = tokenize(currentOperand) {
                        tokenizedExpression.append(tokenizedOperand)
                        if token.associativity == .right {
                            tokenizedExpression.append(Token.binaryOperation(Operation.multiplication))
                        }
                    }
                    tokenizedExpression.append(token)
                default:
                    break
                }
            }
            
            if let token = operations[char.description] {
                switch token {
                case .constant:
                    if currentOperand.isEmpty &&
                        (tokenizedExpression.last?.description == ")" ||
                            tokenizedExpression.last?.compare(to: Operation.unaryLeftAssociative) == true) {
                        tokenizedExpression.append(Token.binaryOperation(Operation.multiplication))
                    } else if let tokenizedOperand = tokenize(currentOperand) {
                        tokenizedExpression.append(tokenizedOperand)
                        tokenizedExpression.append(Token.binaryOperation(Operation.multiplication))
                    }
                    currentOperand = token.description
                case .brace:
                    if !currentOperand.isEmpty {
                        if let tokenizedOperand = tokenize(currentOperand) {
                            tokenizedExpression.append(tokenizedOperand)
                        }
                        currentOperand = ""
                        if token.description == "(" {
                            tokenizedExpression.append(Token.binaryOperation(Operation.multiplication))
                        }
                    }
                    tokenizedExpression.append(token)
                case .binaryOperation:
                    if token.description == "-"
                        && currentOperand.isEmpty
                        && tokenizedExpression.last?.description != ")"
                        && tokenizedExpression.last?.type != .unaryOperation {
                            tokenizedExpression.append(Token.unaryOperation(Operation.negate))
                    } else {
                        if let tokenizedOperand = tokenize(currentOperand) {
                            if tokenizedExpression.last?.compare(to: Operation.unaryLeftAssociative) == true {
                                tokenizedExpression.append(Token.binaryOperation(Operation.multiplication))
                            }
                            tokenizedExpression.append(tokenizedOperand)
                        }
                        tokenizedExpression.append(token)
                    }
                case .unaryOperation:
                    if let tokenizedOperand = tokenize(currentOperand) {
                        tokenizedExpression.append(tokenizedOperand)
                        if token.associativity == .right {
                            tokenizedExpression.append(Token.binaryOperation(Operation.multiplication))
                        }
                    } else if tokenizedExpression.last?.compare(to: Operation.unaryLeftAssociative) == true {
                        if token.associativity == .right {
                            tokenizedExpression.append(Token.binaryOperation(Operation.multiplication))
                        }
                    }
                    tokenizedExpression.append(token)
                default:
                    break
                }
            } else {
                switch char.description {
                case ".":
                    if currentOperand.isEmpty {
                        currentOperand.append("0")
                    }
                    currentOperand.append(".")
                case let digit where Int(digit) != nil:
                    if currentOperand.isEmpty &&
                        (tokenizedExpression.last?.description == ")" ||
                            tokenizedExpression.last?.compare(to: Operation.unaryLeftAssociative) == true) {
                        tokenizedExpression.append(Token.binaryOperation(Operation.multiplication))
                    }
                    if let operation = operations[currentOperand] {
                        tokenizedExpression.append(operation)
                        currentOperand = ""
                        tokenizedExpression.append(Token.binaryOperation(Operation.multiplication))
                    }
                    currentOperand.append(digit)
                default:
                    if char != " " {
                        pendingOperationKey.append(char)
                    }
                }
            }
        }
        
        if let tokenizedNumber = tokenize(currentOperand) {
            tokenizedExpression.append(tokenizedNumber)
            currentOperand = ""
        } else if !currentOperand.isEmpty {
            print("currentToken: \"\(currentOperand)\" not tokenized")
        }
        return tokenizedExpression
    }

    // MARK: - Reverse Polish Notation
    
    private func reversePolishNotation(_ tokenizedExpression: [Token]) -> [Token] {
        var operatorStack = [Token]()
        var outputStack = [Token]()
        for token in tokenizedExpression {
            switch token {
            case .constant:
                outputStack.append(token)
            case .binaryOperation, .unaryOperation:
                while operatorStack.last != nil
                    && token.precedence <= operatorStack.last!.precedence
                    && token.associativity == .left {
                    if let lastOperatorToken = operatorStack.popLast() {
                        outputStack.append(lastOperatorToken)
                    }
                }
                operatorStack.append(token)
            case .brace:
                if token.description == "(" {
                    operatorStack.append(token)
                } else {
                    while operatorStack.last != nil && operatorStack.last!.description != "(" {
                        outputStack.append(operatorStack.popLast()!)
                    }
                    _ = operatorStack.popLast()
                }
            default:
                break
            }
        }
        while !operatorStack.isEmpty {
            outputStack.append(operatorStack.popLast()!)
        }
        return outputStack
    }
    
    // MARK: - Evaluate Reverse Polish Notation
    
    private func evaluateReversePolishNotation(_ expression: [Token]) -> Double? {
        var outputQueue = [Double]()
        for token in expression {
            switch token {
            case .constant(let value, _):
                outputQueue.append(value)
            case .binaryOperation(let function, _, _, _):
                if let rightOperand = outputQueue.popLast(), let leftOperand = outputQueue.popLast() {
                    outputQueue.append(function(leftOperand, rightOperand))
                } else {
                    return nil
                }
            case .unaryOperation(let function, _, _, _):
                if let operand = outputQueue.popLast() {
                    outputQueue.append(function(operand))
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        if !outputQueue.isEmpty {
            return outputQueue[0]
        } else {
            return nil
        }
    }
}
