import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

func getProject(name: String, completion: @escaping (Result<[CircleCIBuild]>) -> Void) {
    request(circleCIGetRequest(path: "project/\(name)"), of: [CircleCIBuild].self, completion: completion)
}

func circleCIGetRequest(path: String) -> URLRequest {
    var request = URLRequest(url: circleCIurlForPath(path: path))
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "accept")
    request.addValue("application/json", forHTTPHeaderField: "content-type")
    return request
}

func circleCIurlForPath(path: String) -> URL {
    var token = ""
    if let apiKey = UserDefaults.standard.string(forKey: "SeaEyeAPIKey") {
        token = apiKey
    }
    return URL(string: "https://circleci.com/api/v1.1/\(path)?circle-token=\(token)")!
}

func request <T: Decodable>(_ request: URLRequest, of: T.Type, completion: ((Result<T>) -> Void)?) {
    let session = URLSession(configuration: URLSessionConfiguration.default)

    let task = session.dataTask(with: request) { (responseData, response, responseError) in  DispatchQueue.main.async {
            guard responseError == nil else {
                completion!(.failure(responseError!))
                return
            }

            guard let jsonData = responseData else {
                let userInfo = [NSLocalizedDescriptionKey: "Data was not retrieved from request"]
                let error = NSError(domain: "",
                                    code: 0,
                                    userInfo: userInfo) as Error
                completion!(.failure(error))
                return
            }

            do {
                let builds = try CircleCIDecoder().decode(T.self, from: jsonData)
                completion!(.success(builds))
            } catch {
                completion!(.failure(error))
            }
        }
    }
    task.resume()
}
