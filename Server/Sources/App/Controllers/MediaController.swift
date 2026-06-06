import Vapor

struct MediaController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.on(.POST, "media", "upload", body: .collect(maxSize: "50mb"), use: upload)
    }

    struct UploadResponse: Content {
        let url: String
    }

    func upload(req: Request) async throws -> UploadResponse {
        guard let file = try? req.content.decode(File.self) else {
            throw Abort(.badRequest, reason: "No file provided")
        }

        let ext = (file.filename as NSString).pathExtension.lowercased()
        let allowed = ["jpg", "jpeg", "png", "webp", "mp4", "mov", "m4a", "aac"]
        guard allowed.contains(ext) else { throw Abort(.unsupportedMediaType) }

        let filename = "\(UUID().uuidString).\(ext)"
        let dir = req.application.directory.publicDirectory + "media/"

        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

        let path = dir + filename
        try await req.fileio.writeFile(file.data, at: path)

        let baseURL = Environment.get("BASE_URL") ?? "http://localhost:8080"
        return UploadResponse(url: "\(baseURL)/media/\(filename)")
    }
}
