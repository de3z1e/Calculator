//
//  ViewController.swift
//  Calculator
//
//  Created by Dimitry Zadorozny on 5/6/17.
//  Copyright © 2017 Dimitry Zadorozny. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var operationSequence: UILabel!

    override func viewDidLoad() {
        display.layer.borderWidth = 0.5
        display.layer.borderColor = UIColor.black.cgColor
        buttons.forEach({button in
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.black.cgColor
        })
//        let solver = Solver()
//        let expression = "(1.7 + -2² × 3)² × -2sin(π²e) + 42 ÷ -tancos(-√(2 ÷ √√.5 - -.1) + 2)²²"
//        let expression = "√√2²²"
//        if let solution = solver.evaluate(expression) {
//            print(solution)
//        } else {
//            print("nil")
//        }
        
        
    }
    
    
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            if newValue.remainder(dividingBy: 1) == 0 {
                display.text = String(Int(newValue))
            } else {
                display.text = String(newValue)
            }
            
        }
    }
    private var textCurrentlyInDisplay = String()
    private var currentOperand = String()
    private var pendingOperation = false
    private var userIsInTheMiddleOfOperand = false
    
    private var solver = Solver()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfOperand {
            currentOperand += (digit == "." && currentOperand.contains(".") ? "" : digit)
            display.text! = textCurrentlyInDisplay + currentOperand
        } else {
            currentOperand = (digit == "." ? "0." : digit)
            if display.text! == "0" {
                display.text! = currentOperand
            } else {
                display.text! = textCurrentlyInDisplay + currentOperand
            }
            userIsInTheMiddleOfOperand = true
            pendingOperation = false
        }
        print(currentOperand)
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if let operation = operations[sender.currentTitle!] {
            userIsInTheMiddleOfOperand = false
            pendingOperation = true
            switch operation {
            case .unaryOperation(let function, _, _, _):
                if sender.currentTitle == "±" {
                    if let number = Double(currentOperand) {
                        currentOperand = String(function(number))
                    }
                } else if pendingOperation {
                    display.text = textCurrentlyInDisplay + operation.description
                } else {
                    
                }
            }
            
            
            if operation.type == .binaryOperation {
                display.text?.append(" \(operation.description) ")
            } else if sender.currentTitle == "±" {
                
            } else if display.text == "0" {
                display.text = operation.description
            } else {
                display.text?.append(operation.description)
            }
            textCurrentlyInDisplay = display.text!
        }
        
//        if userIsInTheMiddleOfTyping {
//            brain.setOperand(displayValue)
//            userIsInTheMiddleOfTyping = false
//        }
//        if let mathematicalSymbol = sender.currentTitle {
//            brain.performOperation(mathematicalSymbol)
//        }
//        if let result = brain.result {
//            displayValue = result
//        }
//        operationSequence.text = brain.description
    }


}

