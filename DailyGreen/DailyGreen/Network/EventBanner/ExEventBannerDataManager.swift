//
//  EventBannerDataManager.swift
//  DailyGreen
//
//  Created by 유준용 on 2021/11/22.
//


import Alamofire

class ExEventBannerDataManager {
    
    func getExEventBanner(delegate: MainPageViewController) {
        
        let headers: HTTPHeaders = ["X-ACCESS-TOKEN": Constant.shared.JWTTOKEN]
        AF.request("\(Constant.BASE_URL)/app/ads",
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: headers)
            .validate()
            .responseDecodable(of: ExEventBannerResponse.self) { response in
                switch response.result{
                case .success(let response):

                    if response.isSuccess  {
                        let results = response.result
                        delegate.didSuccessGetExEventBanner(message: "성공", results: results)
                    }

                    else {
                        switch response.code {
                        case 2000: delegate.failedToRequest(message: "2000error")
                        default :
                            delegate.failedToRequest(message: "실패 code: \(response.code)")
                            break
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    print(String(describing: error))
                    delegate.failedToRequest(message: "EventBAnnerDataManagerError")
                }
            }
    }
}

