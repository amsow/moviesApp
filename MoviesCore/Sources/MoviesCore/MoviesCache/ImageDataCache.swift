
import Foundation

public protocol ImageDataCache {
    typealias SaveResult = Result<(), Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
