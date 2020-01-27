//
//  PreviewDataSource.swift
//  TableViewPrefetching
//
//  Created by Sudhakar on 27/01/20.
//  Copyright © 2020 Sudhakar. All rights reserved.
//

import Foundation
import UIKit.UIImage

let baseUrl = "https://robohash.org/"

class PreviewDataSource {
    private var image = (1...200).map { Preview(url: baseUrl+"\($0).png", order: $0) }
    var numberOfPrevies:Int{
        image.count
    }
    public func loadPreview(at index:Int)->PreviewOperation?{
        if ( 0...image.count-1).contains(index){
             return PreviewOperation(preview: image[index])
        }
        return .none
    }
}
class PreviewOperation : Operation{
    var image:UIImage?
    var loadingCompletionHandle:((UIImage?)->())?
    private var preview:Preview
    init(preview:Preview) {
        self.preview = preview
    }
    override func main() {
        if isCancelled{ return }
        guard let url = preview.url else { return }
        downloadImageFrom(url) {  (image) in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                if self.isCancelled { return }
                   self.image = image
                   self.loadingCompletionHandle?(image)
            }
        }
    }
}

func downloadImageFrom(_ url:URL,completion:@escaping(UIImage?)->()){
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
            let mimeType = response?.mimeType,mimeType.hasPrefix("image"),
            let data = data, error == nil,let image = UIImage(data: data)
           
        else{
            return
        }
         completion(image)
    }.resume()
}
