//
//  RocketSearchController.swift
//  Rockety
//
//  Created by Antoine Bellanger on 27.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit

protocol RocketSearchControllerDelegate {
    func didStartSearching()
    
    func didTapOnSearchButton()
    
    func didTapOnCancelButton()
    
    func didChangeSearchText(searchText: String)
}

class RocketSearchController: UISearchController, UISearchBarDelegate {
    
    var rocketSearchBar: RocketSearchBar!
    
    var customDelegate: RocketSearchControllerDelegate!

    init(searchResultsController: UIViewController?, searchBarFrame: CGRect, searchBarFont: UIFont, searchBarTextColor: UIColor, searchBarTintColor: UIColor) {
        super.init(searchResultsController: searchResultsController)
        
        configureSearchBar(frame: searchBarFrame, font: searchBarFont, textColor: searchBarTextColor, bgColor: searchBarTintColor)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureSearchBar(frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
        rocketSearchBar = RocketSearchBar(frame: frame, font: font, textColor: textColor)
        
        rocketSearchBar.barTintColor = bgColor
        rocketSearchBar.tintColor = textColor
        rocketSearchBar.showsBookmarkButton = false
        rocketSearchBar.showsCancelButton = true
        rocketSearchBar.delegate = self
    }
    
    //MARK: UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        customDelegate.didStartSearching()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        rocketSearchBar.resignFirstResponder()
        customDelegate.didTapOnSearchButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        rocketSearchBar.resignFirstResponder()
        customDelegate.didTapOnCancelButton()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        customDelegate.didChangeSearchText(searchText: searchText)
    }

}
