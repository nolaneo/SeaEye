//
//  GithubClient.swift
//  SeaEye
//
//  Created by Conor Mongey on 15/06/2018.
//  Copyright © 2018 Nolaneo. All rights reserved.
//

import Foundation

struct SeaEyeVersion: Decodable {
    let latestVersion: String
    let downloadUrl: URL
    let changes: String
}

struct Release: Decodable {
    let tagName: String
    let prerelease: Bool
    let draft: Bool
    let htmlUrl: String
    let name: String
    let body: String

    func version() -> VersionNumber {
        return tagName.versionNumber()
    }

    func toSeaEye() -> SeaEyeVersion {
        return SeaEyeVersion.init(latestVersion: tagName, downloadUrl: URL.init(string: htmlUrl)!, changes: body)
    }
}


public class GithubClient {
    static func latestRelease(completion: ((Result<Release>) -> Void)?) {
        request(get(path: "releases/latest"), of: Release.self, completion: completion)
    }

    private static func get(path: String) -> URLRequest {
        let baseURL = "api.github.com/repos/nolaneo/SeaEye"
        let url =  URL(string: "https://\(baseURL)/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        return request
    }
}
