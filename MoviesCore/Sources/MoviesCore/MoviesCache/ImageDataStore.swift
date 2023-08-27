
import Foundation

public protocol ImageDataStore {
    typealias RetrievalResult = Result<Data?, Error>
    
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void)
    func insert(_ data: Data, for url: URL)
}
