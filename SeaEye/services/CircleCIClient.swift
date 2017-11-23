//
//  CircleCIClient.swift
//  SeaEye
//
//  Created by Conor Mongey on 22/10/2017.
//  Copyright © 2017 Nolaneo. All rights reserved.
//

import Foundation
import Alamofire

class CircleCIClient{
    let apiVersion = "1.1"
    let apiKey : String

    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func Me() -> [CircleCIMiniProject]{
        Alamofire.request(request(path: "me")).responseJSON { json in
                let jsonDecoder = JSONDecoder()
                guard let jsonDict = json as? Dictionary<String, Any> else {
//                        return []
                }
                let projects = try decoder.decode(CircleCIMiniProject.self, from: json)
                return [projects];
                
        }
    }
    func Projects() {
        Alamofire.request(request(path: "projects"))
            .responseJSON { response in
                debugPrint(response)

                
        }
    }
    
    func request(path: String) -> String{
        return "https://circleci.com/api/v\(apiVersion)/\(path)?circle-token=\(self.apiKey)"
    }
}
