//
//  Endpoints.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import Foundation

enum Endpoints: String {
    /// Auth endpoints
    /// enjoy!
    case authOtpRequest = "/auth/otp/request"
    case authOtpConfirm = "/auth/otp/confirm"
    case authRefresh = "/auth/refresh"
    case teacherTests = "/teacher/tests"
    case test = "/tests"
    case credentials = "/users/profile"
    case getStudent = "/teacher/students"
    case startTest = "/attempts/start-by-code"
    case answer = "/attempts/answer"
    case submit = "/attempts/submit"
    case testsResults = "/me/attempts"
    case attempts = "/attempts/"
}
