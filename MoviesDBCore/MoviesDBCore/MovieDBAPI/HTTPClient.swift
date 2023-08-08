
import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func request(from url: URL, completion: @escaping (Result) -> Void)
}
