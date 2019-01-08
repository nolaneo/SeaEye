import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

func request<T: Decodable>(_ request: URLRequest, of _: T.Type, completion: ((Result<T>) -> Void)?) {
    let session = URLSession(configuration: URLSessionConfiguration.default)

    let task = session.dataTask(with: request) { responseData, _, responseError in DispatchQueue.main.async {
        guard responseError == nil else {
            completion!(.failure(responseError!))
            return
        }

        guard let jsonData = responseData else {
            let error = NSError(domain: "",
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Data was not retrieved from request"]) as Error
            completion!(.failure(error))
            return
        }

        do {
            let response = try SeaEyeDecoder().decode(T.self, from: jsonData)
            completion!(.success(response))
        } catch {
            completion!(.failure(error))
        }
        }
    }
    task.resume()
}
