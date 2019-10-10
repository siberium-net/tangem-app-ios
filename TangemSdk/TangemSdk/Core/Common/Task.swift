//
//  Task.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 02/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation
import CoreNFC

public enum TaskError: Error, LocalizedError {
    case unknownStatus(sw: UInt16)
    case mappingError
    case errorProcessingCommand
    case invalidState
    case insNotSupported
    case generateChallengeFailed
    case nfcError(NFCReaderError)
    
    public var localizedDescription: String {
        switch self {
        case .nfcError(let nfcError):
            return nfcError.localizedDescription
        default:
             return "\(self)"
        }
    }
}

@available(iOS 13.0, *)
open class Task<TaskResult> {
    var cardReader: CardReader!
    var delegate: CardManagerDelegate?
    var cardEnvironmentRepository: CardEnvironmentRepository!
    
    deinit {
        cardReader.stopSession()
    }
    
    public func run(with environment: CardEnvironment, completion: @escaping (TaskResult) -> Void) {
        guard cardReader != nil else {
            fatalError("Card reader is nil")
        }
        
        guard cardEnvironmentRepository != nil else {
            fatalError("CardEnvironmentRepository reader is nil")
        }
        
        cardReader.startSession()
    }
    
    func sendCommand<AnyCommandSerializer>(_ commandSerializer: AnyCommandSerializer, completion: @escaping (TaskCompletionResult<AnyCommandSerializer.CommandResponse>) -> Void)
        where AnyCommandSerializer: CommandSerializer {
            
            let commandApdu = commandSerializer.serialize(with: cardEnvironmentRepository.cardEnvironment)
            cardReader.send(commandApdu: commandApdu) { [weak self] commandResponse in
                guard let self = self else { return }
                
                switch commandResponse {
                case .success(let responseApdu):
                    guard let status = responseApdu.status else {
                        DispatchQueue.main.async {
                            completion(.failure(TaskError.unknownStatus(sw: responseApdu.sw)))
                        }
                        return
                    }
                    
                    switch status {
                    case .needPause:
                        
                        //TODO: handle security delay
                        break
                    case .needEcryption:
                        //TODO: handle needEcryption
                        break
                    case .invalidParams:
                        //TODO: handle need pin ?
                        //            if let newEnvironment = returnedEnvironment {
                        //                self?.cardEnvironmentRepository.cardEnvironment = newEnvironment
                        //            }
                        
                        break
                    case .processCompleted, .pin1Changed, .pin2Changed, .pin3Changed, .pinsNotChanged:
                        if let responseData = commandSerializer.deserialize(with: self.cardEnvironmentRepository.cardEnvironment, from: responseApdu) {
                            DispatchQueue.main.async {
                                completion(.success(responseData))
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(.failure(TaskError.mappingError))
                            }
                        }
                    case .errorProcessingCommand:
                        DispatchQueue.main.async {
                            completion(.failure(TaskError.errorProcessingCommand))
                        }
                    case .invalidState:
                        DispatchQueue.main.async {
                            completion(.failure(TaskError.invalidState))
                        }
                    case .insNotSupported:
                        DispatchQueue.main.async {
                            completion(.failure(TaskError.insNotSupported))
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(.nfcError(error)))
                    }
                }
            }
    }
}
