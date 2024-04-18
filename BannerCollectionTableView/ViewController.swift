//
//  ViewController.swift
//  BannerCollectionTableView
//
//  Created by Yuth Fight on 18/4/24.
//

import UIKit
import Extension
import AdvancedPageControl

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imageArr : [String] = ["Banner1","Banner2","Banner3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellCollection = tableView.dequeueReusableCell(withIdentifier: "BannerTablCell", for: indexPath) as! BannerTablCell
            cellCollection.configCell(imageArr: imageArr)
            cellCollection.pageControl.drawer     = SwapDrawer(numberOfPages: imageArr.count, height: 4, width: 8, space: 4, raduis: 4, currentItem: 0, indicatorColor: UIColor.hex("#367FFA"), dotsColor: UIColor.hex("#E1EFFF"), isBordered: false, borderColor: .white, borderWidth: 0, indicatorBorderColor: .white)
//            cellCollection.owner = self
            return cellCollection
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200
        } else {
            return UITableView.automaticDimension
        }
    }
    
}


class BannerTablCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var pageControl: AdvancedPageControlView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var saveImage = [String]()
    
    let collectionMargin    = CGFloat(20)
    let itemSpacing         = CGFloat(20)
    var itemWidth           = CGFloat(0)
    
    var currentSlideIndex = 0
    
    var timer : Timer?
    
    // For Pushing to naviation
    weak var owner                              : UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.startTimer(withCurrent: 0)
        
        setUpCollectionView : do {
            itemWidth =  UIScreen.main.bounds.width - (collectionMargin * 2.0)
            collectionView?.decelerationRate        = .fast
            
            let layout =  UICollectionViewFlowLayout()
            var insets = self.collectionView.contentInset
            insets.left = 20
            insets.right = 20
            self.collectionView.contentInset = insets
            layout.itemSize = CGSize(width: itemWidth, height: self.collectionView.frame.height)
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = itemSpacing
            collectionView.setCollectionViewLayout(layout, animated: false)
        }
        
    }
    
    private func indexOfCell() -> Int {
        let itemWidth = self.collectionView.frame.width - (collectionMargin * 2.0)
        let proportionalOffset  = self.collectionView.contentOffset.x / itemWidth
        let index               = Int(round(proportionalOffset))
        let safeIndex           = max(0, min(saveImage.count, index))
        return safeIndex
    }
    
    func startTimer(withCurrent index: Int) {
        self.currentSlideIndex = index
        if currentSlideIndex == self.saveImage.count {
            currentSlideIndex = 0
        }
        self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func scrollToNextCell() {
        
        let numberOfSlide = saveImage.count
        if self.currentSlideIndex < numberOfSlide + 1 {
            self.currentSlideIndex += 1
            self.collectionView.scrollToItem(at: IndexPath(row: self.currentSlideIndex ,section:0), at: .centeredHorizontally, animated: true)
            if self.currentSlideIndex == numberOfSlide {
                self.currentSlideIndex = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 , execute: {
                    self.collectionView.selectItem(at: IndexPath(row: self.currentSlideIndex ,section:0), animated: false, scrollPosition: .right)
                })
                
            }
        }
    }
    
    func configCell(imageArr: [String]) {
        self.saveImage = imageArr
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return saveImage.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionCell", for: indexPath) as! BannerCollectionCell
        // -1 Becuz increase +1 in numberOfItemsInSection
        if indexPath.row <= saveImage.count - 1 {
            colCell.bannerImage.image = UIImage(named: self.saveImage[indexPath.item])
            colCell.bannerImage.contentMode  = .scaleToFill
        }
        return colCell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexRow = indexOfCell()
        
        let offset = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.setPageOffset(offset)
    }
    
    // Scrolling until
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = Float(itemWidth + itemSpacing )
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(collectionView!.contentSize.width)
        var newPage = Float(currentSlideIndex)
        
        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? currentSlideIndex + 1 : currentSlideIndex - 1)
            if newPage < 0 {
                newPage = 0
            }
            if (newPage > contentWidth / pageWidth) {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        
        currentSlideIndex = Int(newPage)
        let point = CGPoint (x: CGFloat(newPage * pageWidth) - 20, y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stopTimer()
        let indexRow = indexOfCell()
        if indexRow == saveImage.count {
            
            DispatchQueue.main.async {
                self.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
            }
        }
        
        self.startTimer(withCurrent: indexRow)
//        if (Share.loginData?.BANNER3_REC?.count ?? 0) > 0 {
//            registerBannerAds()
//        }
    }
}


class BannerCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var bannerImage : UIImageView!
    
    
}

