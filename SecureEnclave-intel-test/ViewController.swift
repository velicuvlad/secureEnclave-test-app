import Cocoa
import Foundation
import CommonCrypto
import Security

class SecureEnclaveChecker {
    var msg: String = ""
    
    init() {
        self.msg = createSecureEnclaveKey() ?? "Secure Enclave is available"
    }
    
    func createSecureEnclaveKey() -> String? {
        var error: Unmanaged<CFError>?
        
        if SecKeyCreateRandomKey([
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: "SecureEnclave-intel-test" // Replace with your application-specific tag
            ] as [String: Any]
        ] as [String : Any] as CFDictionary, &error) != nil {
            // Key creation success
            return "Elliptic curve encryption key created successfully."
        } else {
            if let errorValue = error?.takeRetainedValue() {
                // Handle the error
                return "Key creation error: \(errorValue)"
            } else {
                // Handle the unknown error
                return "Key creation error: Unknown error"
            }
        }
    }
}

class ViewController: NSViewController {
    @IBOutlet var messageLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundQueue = DispatchQueue.global(qos: .background)
            
        backgroundQueue.async {
            let enclaveChecker = SecureEnclaveChecker()
            let message = enclaveChecker.msg
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.messageLabel.stringValue = message
            }
        }
    }
}
