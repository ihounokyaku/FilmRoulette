//
//  Selector.swift
//  CustomSelector
//
//  Created by Dylan Southard on 2018/09/26.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import UIKit

@objc protocol SelectorDelegate {
    @objc optional func selectorPressed(sender:Selector)
    @objc optional func selectionWillChange(inSelector:Selector)
    @objc optional func selectionDidChange(sender:Selector)
}

class Selector: UIView {
    
    private var delegate:SelectorDelegate!
    
    var highlightView = UIView()
    
    public var highlightTransparency:CGFloat {
        get {
            return self.highlightView.alpha
        }
        set {
            self.highlightView.alpha = newValue
        }
    }
    
    public var buttons = [UIButton]()
    
    public var animationDuration = 0.2
    
    public var animationOptions:AnimationOptions = .curveEaseIn
    
    public var selectedTextColor:UIColor? {
        didSet {
            self.setButtonAppearance()
        }
    }
    
    public var normalTextColor:UIColor? {
        didSet {
            self.setButtonAppearance()
        }
    }
    
    public var selectedFont:UIFont? {
        didSet {
            self.setButtonAppearance()
        }
    }
    
    public var normalFont:UIFont? {
        didSet {
            self.setButtonAppearance()
        }
    }
    
    private var originalTextColors = [Int:UIColor]()
    
    private var originalFonts = [Int:UIFont]()
    
    public var highlightColor:CGColor {
        get {
            return highlightView.layer.backgroundColor ?? UIColor.clear.cgColor
        }
        set {
            self.highlightView.layer.backgroundColor = newValue
        }
    }
    
    public var indexOfSelectedItem:Int {
        get {
            return self.indexOfSelected
        }
    }
    
    private var indexOfSelected = 0
    
    public func configure(buttons:[UIButton] = [], highlightColor:UIColor = UIColor.black, delegate:SelectorDelegate) {
        self.delegate = delegate
        for button in buttons {
            let index = buttons.index(of:button)!
            button.addTarget(self, action: #selector(selectButton(sender:)), for: .touchUpInside)
            
            if let label = button.titleLabel {
                self.originalTextColors[index] = label.textColor
                self.originalFonts[index] = label.font
            }
        }
        
        self.buttons = buttons
        self.highlightColor = highlightColor.cgColor
        self.createHighlightView()
    }
    
    @objc private func selectButton(sender:UIButton) {
        guard let index = self.buttons.lastIndex(of: sender), index != self.indexOfSelectedItem else {return}
        self.delegate.selectionWillChange?(inSelector: self)
        self.selectItem(atIndex: index)
        self.delegate.selectorPressed?(sender:self)
    }
    
    public func selectItem(atIndex index:Int) {
        guard self.buttons.count > index else {return}
        self.indexOfSelected = index
        self.moveHighlightView()
    }
    
    private func createHighlightView() {
        guard self.buttons.count > self.indexOfSelectedItem else {return}
        self.setHighlightViewPosition()
        self.addSubview(self.highlightView)
        self.sendSubview(toBack: self.highlightView)
        
    }
    
    private func setHighlightViewPosition() {
        self.highlightView.frame = self.buttons[self.indexOfSelectedItem].frame
        self.highlightView.layer.backgroundColor = self.highlightColor
    }
    
    func moveHighlightView(animated:Bool = true) {
        
        guard self.buttons.count > self.indexOfSelectedItem else {return}
        
        if !animated {
            self.setHighlightViewPosition()
            self.setButtonAppearance()
            return
        }
        UIView.animate(withDuration: self.animationDuration, delay: 0, options: self.animationOptions, animations: {
            self.setHighlightViewPosition()
            
        }) { _ in
            //On completion
            self.delegate.selectionDidChange?(sender: self)
        }
    }
    
    private func setButtonAppearance() {
        
        for button in self.buttons {
            //check if selected
            let index = self.buttons.index(of:button)!
            if index == self.indexOfSelected {
                
                self.changeButtonAppearance(button: button, color: self.selectedTextColor, font:self.selectedFont)
            } else {
                self.changeButtonAppearance(button: button, color: self.normalTextColor ?? self.originalTextColors[index], font:self.normalFont ?? self.originalFonts[index])
            }
        }
    }
    
    private func changeButtonAppearance(button:UIButton, color:UIColor?, font:UIFont?){
        if let textColor = color {
            button.setTitleColor(textColor, for: .normal)
        }
        
        if let buttonFont = font {
            button.titleLabel?.font = buttonFont
        }
    }
}
