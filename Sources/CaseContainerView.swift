//
//  CaseContainerView.swift
//  CaseContainer
//
//  Created by minjuniMac on 25/09/2018.
//  Copyright © 2018 mjun. All rights reserved.
//

import UIKit

open class CaseContainerView: CaseContainerBaseView<CaseContainerViewController> {
    public private(set) var containerScrollView: UIScrollView = {
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        /// was specified unidirection Scrolling, this direction of scrollView is vertical
        $0.isDirectionalLockEnabled = true
        $0.bounces = false
        $0.backgroundColor = .white
        return $0
    }(UIScrollView(frame: CGRect.zero))
    
    /**
     This property is containerScrollView's contentView
     */
    lazy public private(set) var verticalCanvasView: UIView = {
        $0.backgroundColor = .white
        return $0
    }(UIView(frame: CGRect.zero))
    
    public var headerView: UIView = {
        $0.backgroundColor = .white
        return $0
    }(UIView(frame: CGRect.zero))
    
    public var tabScrollView = TabScrollView()
    
    public var contentsScrollView: UIScrollView = {
        $0.bounces = false
        $0.backgroundColor = .white
        $0.isDirectionalLockEnabled = true
        $0.showsVerticalScrollIndicator = false
        $0.isPagingEnabled = true
        return $0
    }(UIScrollView(frame: CGRect.zero))
    
    /**
     This propery is ContentsScrollView's Content View
     */
    lazy public private(set) var horizonCanvasView: UIView = {
        let rect = CGRect(
            x: 0, y: 0,
            width: ui.contentsScrollViewContentSize.width,
            height: ui.contentsScrollViewContentSize.height)
        $0.frame = rect
        $0.backgroundColor = .white
        return $0
    }(UIView(frame: CGRect.zero))
    
    struct UI {
        var headerViewHeight: CGFloat
        var tabScrollViewHeight: CGFloat
        var contentsScrollViewFrameSize: CGSize
        var contentsScrollViewContentSize: CGSize
        var containerScrollViewContentSize: CGSize
        
        init(needs numberOfChildVC: [UIViewController],
             headerHeight: CGFloat,
             tabScrollHeaight: CGFloat, viewController: CaseContainerViewController) {
            guard numberOfChildVC.count > 0  else {
                fatalError("you must Implement ChildViewController")
            }
            let numberOfChildVierControlelr: CGFloat = CGFloat(numberOfChildVC.count)
            headerViewHeight = headerHeight
            tabScrollViewHeight = tabScrollHeaight
            
            var tabBarHeight: CGFloat = 0
            if let tabBarController = viewController.tabBarController,
                tabBarController.tabBar.isHidden == false  {
                tabBarHeight = tabBarController.tabBar.frame.height
            }
                        
            contentsScrollViewFrameSize = CGSize(
                width: UIScreen.mainWidth,
                height: UIScreen.mainHeight - (UIApplication.statusBarHeight + tabScrollViewHeight + tabBarHeight))
            
            contentsScrollViewContentSize = CGSize(
                width: UIScreen.mainWidth * numberOfChildVierControlelr,
                height: contentsScrollViewFrameSize.height)
            
//            contentsScrollViewContentSize = CGSize(
//                width: UIScreen.mainWidth * numberOfChildVierControlelr,
//                height: UIScreen.mainHeight - UIApplication.statusBarHeight)
            
            containerScrollViewContentSize = CGSize(
                width: UIScreen.mainWidth,
                height: headerViewHeight + tabScrollViewHeight + contentsScrollViewFrameSize.height)
            
        }
    }
    
    lazy var ui = UI(
        needs: vc.viewContorllers,
        headerHeight: vc.appearence.headerHeight,
        tabScrollHeaight: vc.appearence.tabScrollHegiht, viewController: vc)
    
    
    override func setupUI() {
        backgroundColor = .white
        /*
         ⎮ View
         ⎮ -- containerScrollView
         ⎮ ---- verticalCanvasView
         ⎮ ------ headerView
         ⎮ ------ tabCollectionView
         ⎮ ------ contentsScrollView
         ⎮ -------- horizonCanvasView
         ⎮ ---------- vc.children.view
         ⎮ ---------- vc.children.view1
         ⎮ ----------- ...
         */
        addSubviews([containerScrollView])
        containerScrollView.addSubview(verticalCanvasView)
        contentsScrollView.addSubview(horizonCanvasView)
        verticalCanvasView.addSubviews([headerView, tabScrollView, contentsScrollView])
        
        let _bottomHeight: CGFloat = vc.tabBarController == nil ? 0 : vc.tabBarController!.tabBar.frame.height
        
        containerScrollView
            .topAnchor(to: layoutMarginsGuide.topAnchor)
            .leadingAnchor(to: leadingAnchor)
            .trailingAnchor(to: trailingAnchor)
            .bottomAnchor(to: bottomAnchor, constant: -_bottomHeight)
            .activateAnchors()
        
        verticalCanvasView
            .topAnchor(to: containerScrollView.topAnchor)
            .bottomAnchor(to: containerScrollView.bottomAnchor)
            .leadingAnchor(to: containerScrollView.leadingAnchor)
            .trailingAnchor(to: containerScrollView.trailingAnchor)
            .dimensionAnchors(size: ui.containerScrollViewContentSize)
            .activateAnchors()
        
        headerView
            .topAnchor(to: verticalCanvasView.topAnchor)
            .leadingAnchor(to: verticalCanvasView.leadingAnchor)
            .trailingAnchor(to: verticalCanvasView.trailingAnchor)
            .heightAnchor(constant: ui.headerViewHeight)
            .activateAnchors()
        
        tabScrollView
            .topAnchor(to: headerView.bottomAnchor)
            .leadingAnchor(to: verticalCanvasView.leadingAnchor)
            .trailingAnchor(to: verticalCanvasView.trailingAnchor)
            .heightAnchor(constant: ui.tabScrollViewHeight)
            .activateAnchors()
        
        contentsScrollView
            .topAnchor(to: tabScrollView.bottomAnchor)
            .leadingAnchor(to: verticalCanvasView.leadingAnchor)
            .trailingAnchor(to: verticalCanvasView.trailingAnchor)
            .heightAnchor(constant: ui.contentsScrollViewFrameSize.height)
            .activateAnchors()
        
        /// ViewControllers that are added on initilization add parent ViewController's childViewController
        
        guard vc.viewContorllers.count > 0 else {
            fatalError("You must be to add container view controller's child view controller when it is initializaed")
        }
        
        vc.viewContorllers.forEach {
            guard $0.title != nil else {
                fatalError("You must be to add viewControllers`s title when it is initialized")
            }
        }
        
        setupChildViewController(of: vc.viewContorllers)
        
    }
    
    override func setupBinding() {
        containerScrollView.contentSize = ui.containerScrollViewContentSize
        contentsScrollView.contentSize = ui.contentsScrollViewContentSize
        
        containerScrollView.delegate = vc
        contentsScrollView.delegate = vc
        tabScrollView.delegate = vc
        
        tabScrollView.setupBinding(parent: vc, ui: ui)
        
    }
    
    func setupChildViewController(of childViewControllers: [UIViewController]) {
        guard let initialChildVC = childViewControllers.first else {
            return
        }
        // 1. Add child Viewcontroller into ContainerViewControlelr
        vc.addChild(initialChildVC)
        
        // 2. add child ViewController's view into ContainerViewController view
        horizonCanvasView.addSubview(initialChildVC.view)
        
        // 3. determine child View Controller`s view frame
        if initialChildVC is ParallaxTableViewController {
            initialChildVC.view.frame = CGRect(x: 0, y: 0, width: ui.contentsScrollViewFrameSize.width, height: ui.contentsScrollViewContentSize.height)
        }else {
            let vaildViewHeight = UIScreen.mainHeight - UIApplication.statusBarHeight
            let scaleRatio = ui.contentsScrollViewContentSize.height / vaildViewHeight
            initialChildVC.view.transform = CGAffineTransform(scaleX: 1.0, y: scaleRatio)
            initialChildVC.view.frame.origin = CGPoint.zero
        }
        
        initialChildVC.didMove(toParent: vc)
    }
    
}


