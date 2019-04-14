//
//  Spinner.swift
//  FilmRoulette
//
//  Created by Dylan Southard on 2019/02/25.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import UIKit

protocol SpinnerDelegate {
    func selectedItem(atIndexPath indexPath:IndexPath)
}


class Spinner: NSObject {
    
    let collectionView:UICollectionView
    var selectedItemIndex = 0
    var selectedItemIndexPath:IndexPath?
    var totalCount = 0
    
    var minimumCount = 100
    var decelerationSpeed1:CGFloat = 0.991
    var decelerationSpeed2:CGFloat = 0.97
    
    var minSpeed1:CGFloat = 10
    var minSpeed2:CGFloat = 1
    
    
    var delegate:SpinnerDelegate?
    
    init(collectionView:UICollectionView) {
        self.collectionView = collectionView
    }
    
    func spin(toIndex index:Int, outOf total:Int) {
        guard self.collectionView.numberOfItems(inSection: 0) > 100000 else {return}
        self.selectedItemIndex = index
        let firstItemRow = self.collectionView.indexPathsForVisibleItems[0].row
        if firstItemRow < index - 400 {
            let indexPath = IndexPath(row: index - 400, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
        self.totalCount = total
        self.selectedItemIndexPath = nil
        self.nextRound()
    }
    
    private func nextRound(count:Int = 0, offsetAmount:CGFloat = 80) {
        
        let offset = self.collectionView.contentOffset.x + offsetAmount
        
        UIView.animate(withDuration: 0.001, delay: 0, options: [], animations: {
            
            self.collectionView.contentOffset = CGPoint(x: offset, y: 0)
            
        }) { _ in
            
            var multiplier:CGFloat = 1
            var minSpeed:CGFloat = self.minSpeed1
            let firstItemRow = self.collectionView.indexPathsForVisibleItems[0].row
            
            if count == self.minimumCount {
                
                self.selectedItemIndexPath = IndexPath(row: self.nextInstanceOfSelected(forIndex: firstItemRow), section: 0)
                if self.selectedItemIndexPath!.row > self.collectionView.indexPathsForVisibleItems[0].row + 200 {
                    let indexPath = IndexPath(row: self.selectedItemIndexPath!.row - 199, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                }
            } else if count > self.minimumCount && firstItemRow >=  self.selectedItemIndexPath!.row - 50 {
                multiplier = self.decelerationSpeed1
                
                if firstItemRow >= self.selectedItemIndexPath!.row - 3 {
                    minSpeed = self.minSpeed2
                    multiplier = self.decelerationSpeed2
                    
                    if let centerItem = self.collectionView.centerCellIndexPath, centerItem.row == self.selectedItemIndexPath?.row {
                        self.finalRound()
                        return
                    }
                }
                multiplier = offsetAmount * multiplier >= minSpeed ? multiplier : 1
            }
            self.nextRound(count: count + 1, offsetAmount: offsetAmount * multiplier)
        }
    }
    
    private func finalRound() {
        guard let centerIndex = self.collectionView.centerCellIndexPath else {return}
        let item = self.collectionView.cellForItem(at: centerIndex)!
        let difference = item.center.x - self.collectionView.centerPoint.x
        let xOffset = self.collectionView.contentOffset.x + difference
        
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseIn, animations: {
            self.collectionView.contentOffset = CGPoint(x: xOffset, y: 0)
        }) { _ in
            self.collectionView.scrollToItem(at: centerIndex, at: .centeredHorizontally, animated: true)
            self.delegate?.selectedItem(atIndexPath: centerIndex)
        }
        
    }
    
   private func nextInstanceOfSelected(forIndex index:Int)->Int{
        
        let currentIndex = index % self.totalCount
        
        var difference = self.selectedItemIndex - currentIndex
        
        while difference < 50 {
            difference += self.totalCount
        }
        return index + difference
    }
    
}

extension UICollectionView {
    
    var centerPoint : CGPoint {
        
        get {
            return CGPoint(x: self.center.x + self.contentOffset.x, y: self.center.y + self.contentOffset.y);
        }
    }
    
    var centerCellIndexPath: IndexPath? {
        
        if let centerIndexPath = self.indexPathForItem(at: self.centerPoint) {
            return centerIndexPath
        }
        return nil
    }
}
