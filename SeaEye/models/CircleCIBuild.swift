import Foundation

struct CircleCIBuild: Decodable {
    let branch : String
    let reponame : String
    let status : String
    let subject : String?
    let author_name : String?
    let build_num : Int
    let build_url : URL
    let start_time : Date

    init(branch: String, project: String, status: String, subject: String, user: String, buildNum: Int, url: URL, date: Date) {
        self.branch = branch
        self.reponame = project
        self.status = status
        self.subject = subject
        self.author_name = user
        self.build_num = buildNum
        self.build_url = url
        self.start_time = date
    }
}