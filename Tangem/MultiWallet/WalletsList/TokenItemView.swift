//
//  TokenItemView.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 20.05.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct TokenItemView: View {
    let item: TokenItemViewModel
    var isLoading: Bool
    
    private var accentColor: Color {
        if item.state.failureDescription != nil {
            return .tangemWarning
        }
        return .tangemGrayDark
    }
    
    @ViewBuilder var customTokenMark: some View {
        if item.isCustom {
            Circle()
                .foregroundColor(Color.white)
                .frame(width: 15, height: 15)
                .overlay(
                    Circle()
                        .foregroundColor(Color.tangemTextGray)
                        .frame(width: 9, height: 9, alignment: .center)
                )
        }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            TokenIconView(with: item.amountType, blockchain: item.blockchainNetwork.blockchain)
                .background(Color.tangemBgGray)
                .clipShape(Circle())
                .saturation(item.isTestnet ? 0.0 : 1.0)
                .overlay(
                    customTokenMark
                        .frame(width: 42, height: 42, alignment: .topTrailing)
                        .offset(x: 1, y: -2)
                )
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .medium))
                        .layoutPriority(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .skeletonable(isShown: isLoading, size: CGSize(width: 70, height: 11))
                    
                    Spacer()
                    
                    Text(item.displayFiatBalanceText)
                        .font(.system(size: 15, weight: .regular))
                        .multilineTextAlignment(.trailing)
                        .truncationMode(.middle)
                        .fixedSize(horizontal: false, vertical: true)
                        .skeletonable(isShown: isLoading, size: CGSize(width: 50, height: 11))
                }
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .foregroundColor(.tangemGrayDark6)
                
                
                HStack(alignment: .firstTextBaseline, spacing: 5.0) {
                    Text(item.displayRateText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                        .skeletonable(isShown: isLoading, size: CGSize(width: 50, height: 11))
                    
                    Spacer()
                    
                    Text(item.displayBalanceText)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                        .fixedSize()
                        .skeletonable(isShown: isLoading, size: CGSize(width: 50, height: 11))
                }
                .font(.system(size: 13, weight: .regular))
                .frame(minHeight: 20)
                .foregroundColor(accentColor)
            }
        }
    }
}
