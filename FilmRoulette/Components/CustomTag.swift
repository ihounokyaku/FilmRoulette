//
//  CustomTag.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 7/31/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Foundation
import TagListView

class CustomTag:TagView {
    
    var table:TagListView!
    
    
    
    init(title: String, table:TagListView) {
        super.init(title: title)
        self.table = table
    self.textColor = table.textColor
        self.selectedTextColor = table.selectedTextColor
        self.tagBackgroundColor = table.tagBackgroundColor
        self.highlightedBackgroundColor = table.tagHighlightedBackgroundColor
        self.selectedBackgroundColor = table.tagSelectedBackgroundColor
        self.titleLineBreakMode = table.tagLineBreakMode
        self.cornerRadius = table.cornerRadius
        self.borderWidth = table.borderWidth
        self.borderColor = table.borderColor
        self.selectedBorderColor = table.selectedBorderColor
        self.paddingX = table.paddingX
        self.paddingY = table.paddingY
        self.textFont = table.textFont
        self.removeIconLineWidth = table.removeIconLineWidth
        self.removeButtonIconSize = table.removeButtonIconSize
        self.enableRemoveButton = table.enableRemoveButton
        self.removeIconLineColor = table.removeIconLineColor
    
       self.addTarget(self, action: #selector(tagPressed(_:)), for: .touchUpInside)
        self.removeButton.addTarget(self, action: #selector(self.removeButtonPressed(_:)), for: .touchUpInside)
        
        // On long press, deselect all tags except this one
        self.onLongPress = { [unowned table] this in
            table.tagViews.forEach {
                $0.isSelected = $0 == this
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    @objc func tagPressed(_ sender: TagView!) {
        self.onTap?(self)
        table.delegate?.tagPressed?(self.currentTitle ?? "", tagView: self, sender: self.table)
    }
    
    @objc func removeButtonPressed(_ closeButton: CloseButton) {
        
        table.delegate?.tagRemoveButtonPressed?(self.currentTitle ?? "", tagView: self, sender: self.table)
        
    }
    
}
