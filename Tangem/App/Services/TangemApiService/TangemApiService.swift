//
//  TangemApiService.swift
//  Tangem
//
//  Created by Alexander Osokin on 21.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol TangemApiService: AnyObject, Initializable {
    var geoIpRegionCode: String { get }

    func loadCoins(requestModel: CoinsListRequestModel) -> AnyPublisher<[CoinModel], Error>
    func loadRates(for coinIds: [String]) -> AnyPublisher<[String: Decimal], Error>
    func loadCurrencies() -> AnyPublisher<[CurrenciesResponse.Currency], Error>

    func loadTokens(for key: String) -> AnyPublisher<UserTokenList, TangemAPIError>
    func saveTokens(list: UserTokenList, for key: String) -> AnyPublisher<Void, TangemAPIError>

    func loadReferralProgramInfo(for userWalletId: String) async throws -> ReferralProgramInfo
    func participateInReferralProgram(
        using token: ReferralProgramInfo.Token,
        for address: String,
        with userWalletId: String
    ) async throws -> ReferralProgramInfo

    func setAuthData(_ authData: TangemApiTarget.AuthData)
}

private struct TangemApiServiceKey: InjectionKey {
    static var currentValue: TangemApiService = CommonTangemApiService()
}

extension InjectedValues {
    var tangemApiService: TangemApiService {
        get { Self[TangemApiServiceKey.self] }
        set { Self[TangemApiServiceKey.self] = newValue }
    }
}
