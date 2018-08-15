//
//  GetService.swift
//  TestAvira
//
//  Created by Adrian Popovici on 15/08/2018.
//  Copyright © 2018 adrian. All rights reserved.
//

import Alamofire
import Foundation

class GetService {
    static let shared = GetService()
    private init() { }

    func get(url: String, completion: @escaping (DataResponse<Any>?, Bool) -> ()) {
        DispatchQueue.global(qos: .background).async {
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    guard let statusCode = response.response?.statusCode else {
                        completion(nil, false)
                        return
                    }
                    guard statusCode < 300 && statusCode >= 200 else {
                        completion(nil, false)
                        return
                    }
                    completion(response, true)
            }
        }
    }

}
