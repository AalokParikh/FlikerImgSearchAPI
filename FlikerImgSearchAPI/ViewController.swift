//
//  ViewController.swift
//  FlikerImgSearchAPI
//
//  Created by Aalok Parikh on 09/08/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    fileprivate let reuseID = "Cell"
    fileprivate let insets = UIEdgeInsets(top: 5.0, left: 8.0, bottom: 5.0, right: 8.0)
    fileprivate var arrSearch = [SearchResults]()
    fileprivate let photo = Photo()
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate var searchText: String = ""
}

//MARK:- Other Methods
private extension ViewController {
    func photoForIndexPath(_ indexPath: IndexPath) -> SearchPhoto {
        return arrSearch[(indexPath as NSIndexPath).section].searchResults[(indexPath as NSIndexPath).row]
    }
}

//MARK:- CollectionView DataSource Methods
extension ViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return arrSearch.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSearch[section].searchResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID,
                                                      for: indexPath) as! PhotoCVCell
        let searchPhoto = photoForIndexPath(indexPath)
        cell.backgroundColor = UIColor.white
        if searchPhoto.image != nil {
            cell.imageView.image = searchPhoto.image
        } else {
            searchPhoto.loadImage { (photo, error) in
                cell.imageView.image = searchPhoto.image
            }
        }

        if indexPath.row == arrSearch[indexPath.section].searchResults.count - 2, arrSearch[indexPath.section].page < arrSearch[indexPath.section].totalPage {

            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            view.addSubview(activityIndicator)
            activityIndicator.frame = view.bounds
            activityIndicator.startAnimating()
            photo.searchForText(searchText, page: arrSearch.count > 0 ? arrSearch.last?.page : 1) { results, error in
                activityIndicator.removeFromSuperview()
                if let error = error {
                    print("Error searching : \(error)")
                    return
                }
                if let results = results {
                    print("Tota results found are \(results.searchResults.count) for text \(results.searchText)")
                    if self.arrSearch.count == 0 {
                        self.arrSearch.insert(results, at: 0)
                    } else {
                        var resultAvailavle = self.arrSearch.first
                        resultAvailavle?.searchResults.append(contentsOf: results.searchResults)
                        resultAvailavle?.searchText = results.searchText
                        resultAvailavle?.page = results.page
                        resultAvailavle?.totalPage = results.totalPage
                        self.arrSearch.removeAll()
                        self.arrSearch.insert(resultAvailavle!, at: 0)
                    }
                    self.collectionView?.reloadData()
                }
            }
        }

        return cell
    }
}

//MARK:- CollectionView Delegate Methods
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
}

//MARK:- CollectionView Delegate FlowLayout Methods
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = insets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = (availableWidth  - (insets.left * 2)) / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.left
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchText = textField.text!
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()

        photo.searchForText(textField.text!, page: arrSearch.count > 0 ? arrSearch.last?.page : 1) { results, error in
            activityIndicator.removeFromSuperview()
            if let error = error {
                print("Error searching : \(error)")
                return
            }
            if let results = results {
                print("Tota results found are \(results.searchResults.count) for text \(results.searchText)")
                self.arrSearch.insert(results, at: 0)
                self.collectionView?.reloadData()
            }
        }
        textField.resignFirstResponder()
        return true
    }
}
