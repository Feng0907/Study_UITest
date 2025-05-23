//
//  NetworkManager.swift
//  Study_UITest
//
//  Created by Feng on 2025/5/9.
//

import Foundation
import Alamofire

var APIDomain = "https://sample-api-url.com/api"

enum APIEndpoint {
    case getSchedule

    var url: String {
        switch self {
        case .getSchedule:
            return "/v1/teacher-time"
        }
    }
}

typealias DoneHandler<T> = (T?, Error?) -> Void

// 網路api處理
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // MARK: - Private Methods
    private func doRequest<T: Decodable>(
        _ endPoint: APIEndpoint,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        completion: DoneHandler<T>? = nil
    ) {
        let urlString = APIDomain + endPoint.url
        
        AF.request(urlString,
                   method: method,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .responseDecodable(of: T.self) { response in
            self.handleResponse(response: response, completion: completion)
        }
    }
    
    // Response handler
    private func handleResponse<T: Decodable>(
        response: DataResponse<T, AFError>,
        completion: DoneHandler<T>?
    ) {
        switch response.result {
        case .success(let result):
            completion?(result, nil)
        case .failure(let error):
            if let data = response.data {
                print("server error response data: \(data)")
            }
            
            if let statusCode = response.response?.statusCode {
                print("HTTP Status Code: \(statusCode)")
            }
            
            print("Request failed with error: \(error.localizedDescription)")
            completion?(nil, error)
        }
    }
    
    // MARK: - Public Methods
    // Do get Schedule
    func doGetSchedule(completion: @escaping DoneHandler<WeeklySchedule>) {
        doRequest(.getSchedule, method: .get, completion: completion)
    }
}
