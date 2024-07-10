import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var verificationID: String = ""
    @AppStorage("isNewUser") var isNewUser: Bool = true // Flag to check if the user is new
    private let dataController = DataController()
    
    /// Sends a verification code to the provided phone number.
    func sendCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Error in sending code: \(error.localizedDescription)")
                completion(false)
            } else {
                self.verificationID = verificationID ?? ""
                completion(true)
            }
        }
    }
    
    /// Verifies the received verification code.
    func verifyCode(verificationCode: String, completion: @escaping (Bool) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error in verifying code: \(error.localizedDescription)")
                completion(false)
            } else if let user = authResult?.user {
                self.checkIfNewUser(userId: user.uid, completion: completion)
            }
        }
    }
    
    /// Checks if the user is new or returning.
    private func checkIfNewUser(userId: String, completion: @escaping (Bool) -> Void) {
        dataController.checkIfUserExists(userId: userId) { exists in
            self.isNewUser = !exists
            completion(true)
        }
    }
    
    /// Resends the verification code to the provided phone number.
    func resendCode(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        sendCode(phoneNumber: phoneNumber, completion: completion)
    }
}
