//
//  Photo.swift
//  FlikerImgSearchAPI
//
//  Created by Aalok Parikh on 09/08/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"

class Photo {
    let taskQueue = OperationQueue()

    func searchForText(_ text: String, page: Int? = 1, completion : @escaping (_ results: SearchResults?, _ error : NSError?) -> Void){

        guard let searchURL = searchURLForText(text, page: page!) else {
            let APIError = NSError(domain: "SearchError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Search response"])
            completion(nil, APIError)
            return
        }

        let searchRequest = URLRequest(url: searchURL)

        URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in

            if let _ = error {
                let APIError = NSError(domain: "SearchError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Search response"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }

            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "SearchError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Search response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
            }

            do {

                guard let resultsDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    let stat = resultsDict["stat"] as? String else {

                        let APIError = NSError(domain: "SearchError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Search response"])
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                        return
                }

                switch (stat) {
                case "ok":
                    print("Results process success")
                case "fail":
                    if let message = resultsDict["message"] {

                        let APIError = NSError(domain: "SearchError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:message])

                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                    }

                    let APIError = NSError(domain: "SearchError", code: 0, userInfo: nil)

                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })

                    return
                default:
                    let APIError = NSError(domain: "SearchError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Search response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }

                guard let photosContainer = resultsDict["photos"] as? [String: AnyObject], let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {

                    let APIError = NSError(domain: "SearchError", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown Search response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }

                var searchPhotos = [SearchPhoto]()

                for photoObject in photosReceived {
                    guard let id = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String else {
                            break
                    }
                    let searchPhoto = SearchPhoto(id: id, farm: farm, server: server, secret: secret)
                    searchPhotos.append(searchPhoto)
                    /*guard let url = searchPhoto.imageURL(),
                        let imageData = try? Data(contentsOf: url as URL) else {
                            break
                    }

                    if let image = UIImage(data: imageData) {
                        searchPhoto.image = image
                        searchPhotos.append(searchPhoto)
                    }*/
                }

                var pageNo = 1
                if let pageGet = photosContainer["page"] as? Int {
                    pageNo = pageGet + 1
                }

                var totalPages = 1
                if let pagesGet = photosContainer["pages"] as? Int {
                    totalPages = pagesGet
                }

                OperationQueue.main.addOperation({
                    completion(SearchResults(searchText: text, searchResults: searchPhotos, page: pageNo, totalPage: totalPages), nil)
                })

            } catch _ {
                completion(nil, nil)
                return
            }


        }) .resume()
    }

    fileprivate func searchURLForText(_ text:String, page:Int) -> URL? {

        guard let senetizedTxt = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }

        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(senetizedTxt)&page=\(page)&format=json&nojsoncallback=1&per_page=14&safe_search=1"

        guard let url = URL(string:URLString) else {
            return nil
        }

        return url
    }

}
