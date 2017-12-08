import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

func recentBuilds(completion:((Result<[CircleCIRecentBuild]>) -> Void)?){
    request(CircleCIGetRequest(path: "recent-builds"), of: [CircleCIRecentBuild].self, completion: completion)
}

func getProject(name:String, completion: @escaping (Result<[CircleCIBuild]>) -> Void) {
    request(CircleCIGetRequest(path: "project/\(name)"), of: [CircleCIBuild].self, completion: completion)
}

func getProjects(completion:((Result<[CircleCIProject]>) -> Void)?){
    request(CircleCIGetRequest(path: "projects"), of: [CircleCIProject].self, completion: completion)
}

func getMe(completion: (((Result<Me>) -> Void)?)) {
    request(CircleCIGetRequest(path: "me"), of: Me.self, completion: completion)
}

struct Me: Decodable {
    let name : String
}

func CircleCIurlForPath(path: String) -> URL {
    var token = ""
    if let apiKey = UserDefaults.standard.string(forKey: "SeaEyeAPIKey") {
        token = apiKey
    }
    return URL(string: "https://circleci.com/api/v1.1/\(path)?circle-token=\(token)")!
}

func CircleCIGetRequest(path: String) -> URLRequest {
    var request = URLRequest(url: CircleCIurlForPath(path: path))
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "accept")
    request.addValue("application/json", forHTTPHeaderField: "content-type")
    return request
}

struct SeaEyeVersion : Decodable {
    let latest_version: String
    let download_url: URL
    let changes: String
}

func latestSeaEyeVersion(completion:((Result<SeaEyeVersion>) -> Void)?) {
    let r = URLRequest(url: (URL(string :"https://raw.githubusercontent.com/nolaneo/SeaEye/master/project_status.json"))!)
    
    request(r, of: SeaEyeVersion.self, completion: completion)
}

func request <T: Decodable>(_ request: URLRequest, of:T.Type, completion:((Result<T>) -> Void)?) {
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    let task = session.dataTask(with: request) { (responseData, response, responseError) in  DispatchQueue.main.async {
            guard responseError == nil else {
                completion!(.failure(responseError!))
                return
            }
        
            guard let jsonData = responseData else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
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
