import Foundation

protocol BuildClient {
    func getProject(name: String, completion: ((Result<[CircleCIBuild]>) -> Void)?)
}
struct CircleCIProject: Decodable {
    let username: String
    let reponame: String
    let vcsUrl: String
    let following: Bool

    func description() -> String {
        return "\(username)/\(reponame)"
    }

    func toProject() -> Project {
        return Project(
            vcsProvider: "github",
            organisation: username,
            name: reponame,
            filter: nil,
            notifySuccess: true,
            notifyFailure: true
        )
    }
}

struct CircleCIClient: Codable, BuildClient {
    var baseURL: String = "https://circleci.com"
    var token: String

    init(apiKey: String) {
        token = apiKey
    }

    func getProjects(completion: ((Result<[CircleCIProject]>) -> Void)?) {
        request(get(path: "projects"), of: [CircleCIProject].self, completion: completion)
    }

    func getProject(name: String, completion: ((Result<[CircleCIBuild]>) -> Void)?) {
        request(get(path: "project/\(name)"), of: [CircleCIBuild].self, completion: completion)
    }

    func getMe(completion: (((Result<CircleCIUser>) -> Void)?)) {
        request(get(path: "me"), of: CircleCIUser.self, completion: completion)
    }

    private func get(path: String) -> URLRequest {
        var request = URLRequest(url: url(path: path))
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        return request
    }

    private func url(path: String) -> URL {
        return URL(string: "\(baseURL)/api/v1.1/\(path)?circle-token=\(token)")!
    }
}

struct CircleCIUser: Decodable {
    let name: String
}
