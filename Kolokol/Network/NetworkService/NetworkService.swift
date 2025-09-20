//
//  NetworkService.swift
//  kolokol
//
//  Created by Tom Tim on 20.09.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        body: [String: Any]?,
        headers: [String: String]?,
        shouldCache: Bool
    ) async -> Result<T, NetworkError>
}

final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let baseURL: String
    private let cache = NSCache<NSString, NSData>()
    
    private init() {
        guard let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL is not set in Info.plist!")
        }
        self.baseURL = baseURLString
    }
    
    // MARK: - Подготовка запроса
    private func prepareRequest(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        body: [String: Any]?,
        headers: [String: String]?
    ) -> URLRequest? {
        var urlComponents = URLComponents(string: baseURL + endpoint)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                return nil
            }
        }
        return request
    }
    
    // MARK: - Логика кэширования
    private func cachedData(for request: URLRequest) -> Data? {
        guard let urlString = request.url?.absoluteString else { return nil }
        return cache.object(forKey: urlString as NSString) as Data?
    }
    
    private func cache(data: Data, for request: URLRequest) {
        guard let urlString = request.url?.absoluteString else { return }
        cache.setObject(data as NSData, forKey: urlString as NSString)
    }
    
    // MARK: - Основной метод запроса
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil,
        shouldCache: Bool = true
    ) async -> Result<T, NetworkError> {
        
        guard let request = prepareRequest(
            endpoint: endpoint,
            method: method,
            queryItems: queryItems,
            body: body,
            headers: headers
        ) else {
            return .failure(.invalidURL)
        }
        
        // Проверяем кэш
        if method == .get && shouldCache, let cachedData = cachedData(for: request) {
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: cachedData)
                return .success(decodedData)
            } catch {
                return .failure(.decodingError)
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.unknown(message: "No HTTP response"))
            }
            
            // Проверка ошибок по статус-кодам
            guard (200...299).contains(httpResponse.statusCode) else {
                switch httpResponse.statusCode {
                case 400:
                    if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                        return .failure(NetworkError(message: str) ?? .unknown(message: "UnknownError"))
                    } else {
                        return .failure(.unknown(message: "UnknownError"))
                    }
                case 403: return .failure(.forbidden)
                case 404: return .failure(.notFound)
                case 500...599: return .failure(.internalServerError)
                default: return .failure(.unknown(message: "UnknownError"))
                }
            }
            
            guard !data.isEmpty else {
                return .failure(.noData)
            }
            
            // Кэшируем успешные GET
            if method == .get && shouldCache {
                cache(data: data, for: request)
            }
            
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
            
        } catch {
            return .failure(.unknown(message: error.localizedDescription))
        }
    }
}
