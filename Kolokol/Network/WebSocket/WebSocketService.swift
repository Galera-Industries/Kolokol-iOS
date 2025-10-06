//
//  WebSocketService.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import Foundation
import Starscream

// MARK: - Модели

public enum TestWSMessage: Sendable {
    case connection(ConnectionState)
    case snapshot(SnapshotData)
    case studentJoined(StudentEventData)
    case studentProgress(StudentEventData)
    case unknown(type: String, raw: String)
    
    public enum ConnectionState: Sendable {
        case connecting
        case connected
        case disconnected(reason: String?)
        case reconnecting(attempt: Int, after: TimeInterval)
        case failed(Error)
    }
}

// 1) Обёртка
struct SnapshotEnvelope: Codable, Sendable {
    let type: String
    let data: SnapshotData
}

public struct SnapshotData: Codable, Sendable {
    public let total: Int
    public let items: [StudentEventData]
}

public struct StudentEventData: Codable, Sendable {
    public let attemptId: UUID
    public let userId: String
    public let firstName: String
    public let lastName: String
    public let answered: Int
    public let total: Int
    public let updatedAt: Date
    public let tg: String
    public let aiCheckStatus: AICheckStatus
    public let result: Int?

    enum CodingKeys: String, CodingKey {
        case attemptId = "attempt_id"
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case answered, total
        case updatedAt = "updated_at"
        case tg = "telegram"
        case aiCheckStatus = "ai_check_status"
        case result
    }
}

private struct StudentEnvelope: Decodable { let type: String; let data: StudentEventData }
private struct EnvelopeOnly: Decodable { let type: String }

// MARK: - Actor Service
public actor WebSocketService {
    public nonisolated static let shared = WebSocketService()
    
    private let baseIp: String
    private let basePort: Int
    private let decoder: JSONDecoder
    
    private var socket: WebSocket?
    private var delegate: ActorBridgeDelegate?
    private var isManuallyClosed = false
    private var retryAttempt = 0
    
    private var pingTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?
    
    private var lastTestId: UUID?
    private var lastBearer: String?
    
    private var continuation: AsyncThrowingStream<TestWSMessage, Error>.Continuation?
    
    private init() {
        guard let ip = Bundle.main.object(forInfoDictionaryKey: "BASE_IP") as? String, !ip.isEmpty else {
            fatalError("BASE_IP is not set in Info.plist")
        }
        self.baseIp = ip
        
        if let pStr = Bundle.main.object(forInfoDictionaryKey: "BASE_PORT") as? String,
           let p = Int(pStr) {
            self.basePort = p
        } else if let pNum = Bundle.main.object(forInfoDictionaryKey: "BASE_PORT") as? NSNumber {
            self.basePort = pNum.intValue
        } else {
            self.basePort = 8080
        }
        
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        self.decoder = dec
        
    }
        
    public nonisolated func openTestProgressStream(
        testId: UUID,
        bearer: String
    ) -> AsyncThrowingStream<TestWSMessage, Error> {
        AsyncThrowingStream { [weak self] cont in
            guard let self = self else { return }
            
            cont.onTermination = { [weak self] _ in
                Task {  self?.close(withReason: "Stream terminated") }
            }
            
            Task { await self._open(cont: cont, testId: testId, bearer: bearer) }
        }
    }
    
    public nonisolated func close(withReason reason: String?) {
        Task { await _close(reason: reason) }
    }
        
    private func _open(cont: AsyncThrowingStream<TestWSMessage, Error>.Continuation,
                       testId: UUID,
                       bearer: String) async
    {
        await _close(reason: nil)
        
        self.isManuallyClosed = false
        self.retryAttempt = 0
        self.lastTestId = testId
        self.lastBearer = bearer
        self.continuation = cont
        
        emit(.connection(.connecting))
        await connect(testId: testId, bearer: bearer)
    }
    
    private func _close(reason: String?) async {
        isManuallyClosed = true
        reconnectTask?.cancel()
        pingTask?.cancel()
        reconnectTask = nil
        pingTask = nil
        
        let old = socket
        socket = nil
        delegate = nil
        old?.disconnect()
        
        if continuation != nil {
            emit(.connection(.disconnected(reason: reason)))
            continuation?.finish()
            continuation = nil
        }
        
        retryAttempt = 0
        lastTestId = nil
        lastBearer = nil
    }
    
    // MARK: - Подключение / реконнект / пинг
    private func connect(testId: UUID, bearer: String) async {
        guard let url = makeWSURL(endpoint: "/ws/tests/\(testId.uuidString)") else {
            failStream(WebSocketError.badURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let sock = WebSocket(request: request)
        
        let bridge = ActorBridgeDelegate { [weak self] event, client in
            guard let self = self else { return }
            Task { await self.handle(event: event, client: client) }
        }
        sock.delegate = bridge
        
        self.delegate = bridge
        self.socket = sock
        
        startPing()
        
        sock.connect()
    }
    
    private func scheduleReconnect() async {
        guard !isManuallyClosed else { return }
        reconnectTask?.cancel()
        
        retryAttempt += 1
        let base = min(pow(2.0, Double(retryAttempt)), 30.0)
        let jitter = Double.random(in: 0.0...0.5)
        let delay = base + jitter
        emit(.connection(.reconnecting(attempt: retryAttempt, after: delay)))
        
        let id = lastTestId
        let bearer = lastBearer
        
        reconnectTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard let self = self else { return }
            guard let id, let bearer else { return }
            await self.connect(testId: id, bearer: bearer)
        }
    }
    
    private func startPing() {
        pingTask?.cancel()
        pingTask = Task { [weak self] in
            guard let self = self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
                // Пингуем только если сокет ещё наш и живой
                await self.socket?.write(ping: Data())
            }
        }
    }
    
    private func stopPing() {
        pingTask?.cancel()
        pingTask = nil
    }
    
    // MARK: - Делегатные события (на акторе)
    
    private func handle(event: WebSocketEvent, client: WebSocketClient) async {
        // Игнорируем события неактуальных сокетов
        guard let current = socket, (client as AnyObject) === current else { return }
        
        // print("WS event:", event) // при желании включай лог
        print(event)
        switch event {
        case .connected(_):
            retryAttempt = 0
            emit(.connection(.connected))
            
        case .disconnected(let reason, let code):
            stopPing()
            emit(.connection(.disconnected(reason: "\(reason) (\(code))")))
            await scheduleReconnect()
            
        case .text(let text):
            decodeAndEmit(text: text)
            
        case .error(let err):
            stopPing()
            if let err { emit(.connection(.failed(err))) }
            await scheduleReconnect()
            
        case .cancelled:
            stopPing()
            emit(.connection(.disconnected(reason: "cancelled")))
            if !isManuallyClosed { await scheduleReconnect() }
            
        case .peerClosed:
            stopPing()
            emit(.connection(.disconnected(reason: "peerClosed")))
            if !isManuallyClosed { await scheduleReconnect() }
            
        case .binary, .viabilityChanged, .reconnectSuggested, .pong, .ping:
            break
            
        @unknown default:
            break
        }
    }
    
    // MARK: - Декодирование/эмит
    private func decodeAndEmit(text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        if let type = (try? decoder.decode(EnvelopeOnly.self, from: data))?.type {
            let d = "{\"attempt_id\":\"76c12f2f-d68e-4674-a599-2bd5c808d1ca\",\"user_id\":\"qYf56sPQukSEaeTZFfaCQHUfdxy2\",\"first_name\":\"Панкратов\",\"last_name\":\"Владислав\",\"telegram\":\"@sundayti\",\"answered\":2,\"total\":2,\"result\":0,\"updated_at\":\"2025-09-27T13:14:00.27740034Z\",\"ai_check_status\":\"done\"}]}"
            print(d)
            switch type {
            case "snapshot":
                do {
                    let payload = try decoder.decode(SnapshotEnvelope.self, from: data)
                    emit(.snapshot(payload.data))
                } catch {
                    print("WS decode snapshot error:", error, "raw:", text)
                    emit(.unknown(type: type, raw: text))
                }
            case "student_joined":
                do {
                    let payload = try decoder.decode(StudentEnvelope.self, from: data)
                    emit(.studentJoined(payload.data))
                } catch {
                    print("WS decode student_joined error:", error, "raw:", text)
                    emit(.unknown(type: type, raw: text))
                }
            case "student_progress":
                do {
                    let payload = try decoder.decode(StudentEnvelope.self, from: data)
                    emit(.studentProgress(payload.data))
                } catch {
                    print("WS decode student_progress error:", error, "raw:", text)
                    emit(.unknown(type: type, raw: text))
                }
            default:
                emit(.unknown(type: type, raw: text))
            }
        } else {
            emit(.unknown(type: "unknown", raw: text))
        }
    }
    
    private func emit(_ message: TestWSMessage) {
        continuation?.yield(message)
    }
    
    private func failStream(_ error: Error) {
        emit(.connection(.failed(error)))
        continuation?.finish(throwing: error)
        continuation = nil
    }
    
    // MARK: - URL
    private func makeWSURL(endpoint: String) -> URL? {
        var comps = URLComponents()
        comps.scheme = "ws"
        comps.host = baseIp
        comps.port = basePort
        let clean = "/" + endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        comps.path = clean
        return comps.url
    }
}

private final class ActorBridgeDelegate : WebSocketDelegate {
    private let handler: @Sendable (WebSocketEvent, WebSocketClient) -> Void
    init(handler: @escaping @Sendable (WebSocketEvent, WebSocketClient) -> Void) {
        self.handler = handler
    }
    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        handler(event, client)
    }
}
