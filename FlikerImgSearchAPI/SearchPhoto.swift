//
//  SearchPhoto.swift
//  FlikerImgSearchAPI
//
//  Created by Aalok Parikh on 09/08/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class SearchPhoto {
    var image : UIImage?
    let id : String
    let farm : Int
    let server : String
    let secret : String
    var imgURL : URL?

    init (id:String,farm:Int, server:String, secret:String) {
        self.id = id
        self.farm = farm
        self.server = server
        self.secret = secret
        _ = self.imageURL()
    }

    func imageURL() -> URL? {
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg") {
            imgURL = url
            return url
        }
        return nil
    }

    func loadImage(_ completion: @escaping (_ photo:SearchPhoto, _ error: NSError?) -> Void) {
        guard let loadURL = imageURL() else {
            DispatchQueue.main.async {
                completion(self, nil)
            }
            return
        }

        let loadRequest = URLRequest(url:loadURL)

        URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(self, error as NSError?)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(self, nil)
                }
                return
            }

            let returnedImage = UIImage(data: data)
            self.image = returnedImage
            DispatchQueue.main.async {
                completion(self, nil)
            }
        }).resume()
    }

}
