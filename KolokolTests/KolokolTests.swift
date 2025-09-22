//
//  KolokolTests.swift
//  KolokolTests
//
//  Created by Кирилл Исаев on 22.09.2025.
//

import XCTest

@testable import Kolokol

final class KolokolTests: XCTestCase {

    var authorizationModel: AuthorizationModelProtocol?
    var codeEnteringModel: CodeEnteringModelProtocol?
    
    override func setUpWithError() throws {
        authorizationModel = AuthorizationModel()
        codeEnteringModel = CodeEnteringModel()
    }

    override func tearDownWithError() throws {
        authorizationModel = nil
        codeEnteringModel = nil
    }

    // MARK: - Unit
    
    func testOtpRequestSuccess() async throws {
        let request = OTPRequest(email: "v@edu.hse.ru")
        let response = try await authorizationModel?.sendOtpRequest(request)
        XCTAssertNotNil(response)
    }
    
    func testOtpRequestCorrectResponse() async throws {
        let request = OTPRequest(email: "v@edu.hse.ru")
        let response = try await authorizationModel?.sendOtpRequest(request)
        XCTAssertNotNil(response)
        XCTAssertEqual(request.email, response?.email)
        XCTAssert(response!.expiresAt > Date.now)
    }
    
    func testOtpRequestFailed() async throws {
        let request = OTPRequest(email: "@edu.hse.ru")
        do {
            _ = try await authorizationModel?.sendOtpRequest(request)
            XCTFail("Got response, but should be error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testConfirmationFailedWithWrongOtpType() async throws {
        let otpRequest = OTPRequest(email: "v@edu.hse.ru")
        let response = try await authorizationModel?.sendOtpRequest(otpRequest)
        XCTAssertNotNil(response)
        let request = ConfirmOTPRequest(email: response!.email, regToken: UUID(), otp: 12345)
        do {
            _ = try await codeEnteringModel?.sendOtpConfirmationRequest(request)
            XCTFail("Got response, but should be error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testConfirmationFailedWithWrongOtp() async throws {
        let otpRequest = OTPRequest(email: "v@edu.hse.ru")
        let response = try await authorizationModel?.sendOtpRequest(otpRequest)
        XCTAssertNotNil(response)
        let request = ConfirmOTPRequest(email: response!.email, regToken: response!.regToken, otp: 0000)
        do {
            _ = try await codeEnteringModel?.sendOtpConfirmationRequest(request)
            XCTFail("Got response, but should be error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Performance
    
    /// если хотя бы 1 из 10 попыток будет длиться дольше 5 секунд, то тест не пройден
    func testEmailCodeReceivingPerformance() throws {
        measure(metrics: [XCTClockMetric()]) {
            let expectation = XCTestExpectation(description: "Запрос на отправку OTP должен завершиться")
            Task {
                if (try? await authorizationModel?.sendOtpRequest(OTPRequest(email: "v@edu.hse.ru"))) != nil {
                    expectation.fulfill()
                }
            }
            wait(for: [expectation], timeout: 5.0)
        }
    }
}
