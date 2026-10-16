import Foundation

protocol CatalogRepository {
    func load(completion: @escaping (Result<CatalogData, Error>) -> Void)
}

/// Keep I/O off the main thread. An API implementation uses the same completion contract.
struct BundleCatalogRepository: CatalogRepository {
    var bundle: Bundle = .main
    func load(completion: @escaping (Result<CatalogData, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            completion(Result { try self.load() })
        }
    }
    // Synchronous decoding is also useful for deterministic repository unit tests.
    func load() throws -> CatalogData {
        guard let url = bundle.url(forResource: "catalog", withExtension: "json", subdirectory: "NativeResources") else {
            throw CatalogError.missingResource
        }
        let catalog = try JSONDecoder().decode(CatalogData.self, from: Data(contentsOf: url))
        try catalog.validate()
        return catalog
    }
}
