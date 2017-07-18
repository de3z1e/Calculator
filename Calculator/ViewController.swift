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
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        if let operand = sender.currentTitle {
            brain.setOperand(operand)
        }
        display.text = brain.currentOperand
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if let operation = sender.currentTitle {
            if operation == "C" {
                display.text = "0"
            }
            brain.performOperation(operation)
        }
        if brain.isPendingOperand {
            display.text = brain.currentOperand
        } else {
            operationSequence.text = brain.accumulator
        }
        if let result = brain.result {
            display.text = result
        }
    }

}

