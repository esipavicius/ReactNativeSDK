import Foundation
import iDenfySDK
@objc(IdenfyReactNative)
class IdenfyReactNative: NSObject {
    
    @objc(start:withResolver:withRejecter:)
    func start(_ config: NSDictionary,
               resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.run(withConfig: config, resolver: resolve, rejecter: reject)
        }
    }
    
    @objc(startFaceReAuth:withResolver:withRejecter:)
    func startFaceReAuth(_ config: NSDictionary,
                         resolve: @escaping RCTPromiseResolveBlock,
                         reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.runFaceReauth(withConfig: config, resolver: resolve, rejecter: reject)
        }
    }
    
  @MainActor private func run(withConfig config: NSDictionary,
                     resolver resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
        do {
            let authToken = GetSdkConfig.getAuthToken(config: config)
            let idenfySettingsV2 = GetSdkConfig.getIdenfySettingsFromConfig(config: config, authToken: authToken)
            
            let idenfyController = IdenfyController.shared
            idenfyController.initializeIdenfySDKV2WithManual(idenfySettingsV2: idenfySettingsV2)
            
            let idenfyVC = idenfyController.instantiateNavigationController()
            
            idenfyVC.modalPresentationStyle = .fullScreen
            
            UIApplication.shared.windows.first?.rootViewController?.present(idenfyVC, animated: true)
            
            handleSdkCallbacks(idenfyController: idenfyController, resolver: resolve)
            
        } catch let error as NSError {
            reject("error", error.domain, error)
            return
        } catch {
            reject("error", "Unexpected error. Verify that config is structured correctly.", error)
            return
        }
    }
    
    private func handleSdkCallbacks(idenfyController: IdenfyController, resolver resolve: @escaping RCTPromiseResolveBlock) {
        idenfyController.handleIdenfyCallbacksWithManualResults(idenfyIdentificationResult: {
            idenfyIdentificationResult
            in
            let response = NativeResponseToReactNativeResponseMapper.map(o: idenfyIdentificationResult)
            resolve(response)
        })
    }
    
  @MainActor private func runFaceReauth(withConfig config: NSDictionary,
                               resolver resolve: @escaping RCTPromiseResolveBlock,
                               rejecter reject: @escaping RCTPromiseRejectBlock) {
        do {
            let authToken = GetSdkConfig.getAuthToken(config: config)
            let immediateRedirect = GetSdkConfig.getImmediateRedirectFromConfig(config: config)
            let idenfyFaceAuthUISettings = GetSdkConfig.getFaceAuthSettingsFromConfig(config: config)
            
            let idenfyController = IdenfyController.shared
            let faceReauthenticationInitialization = FaceAuthenticationInitialization(authenticationToken: authToken, withImmediateRedirect: immediateRedirect, idenfyFaceAuthUISettings: idenfyFaceAuthUISettings)
            idenfyController.initializeFaceAuthentication(faceAuthenticationInitialization: faceReauthenticationInitialization)
            
            let idenfyVC = idenfyController.instantiateNavigationController()
            
            idenfyVC.modalPresentationStyle = .fullScreen
            
            UIApplication.shared.windows.first?.rootViewController?.present(idenfyVC, animated: true)
            
            handleFaceReauthSdkCallbacks(idenfyController: idenfyController, resolver: resolve)
            
        } catch let error as NSError {
            reject("error", error.domain, error)
            return
        } catch {
            reject("error", "Unexpected error. Verify that config is structured correctly.", error)
            return
        }
    }
    
    private func handleFaceReauthSdkCallbacks(idenfyController: IdenfyController, resolver resolve: @escaping RCTPromiseResolveBlock) {
        idenfyController.handleIdenfyCallbacksForFaceAuthentication(faceAuthenticationResult: {
            faceAuthenticationResult
            in
            let response = NativeResponseToReactNativeResponseMapper.mapFaceReauth(o: faceAuthenticationResult)
            resolve(response)
        })
    }
}
