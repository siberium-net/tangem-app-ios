//
//  ShopView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 08.02.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct ShopView: View {
    @ObservedObject var viewModel: ShopViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigation: NavigationCoordinator
    
    private let sectionRowVerticalPadding = 12.0
    private let sectionCornerRadius = 18.0
    private let applePayCornerRadius = 18.0
    
    #warning("TODO: l10n")
    
    var body: some View {
        GeometryReader { geometry in
            
            ScrollView {
                VStack {
                    SheetDragHandler()
                    
                    Image("wallet_card")
                        .padding(.top)
                    
                    Spacer()
                        .frame(maxHeight: .infinity)
                    
                    Text("One Wallet")
                        .font(.system(size: 30, weight: .bold))
                    
                    Picker("Variant", selection: $viewModel.selectedBundle) {
                        Text("3 cards").tag(ShopViewModel.Bundle.threeCards)
                        Text("2 cards").tag(ShopViewModel.Bundle.twoCards)
                    }
                    .pickerStyle(.segmented)
                    .frame(minWidth: 0, maxWidth: 250)
                    
                    Spacer()
                        .frame(maxHeight: .infinity)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "square")
                            Text("Delivery (Free shipping)")
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, sectionRowVerticalPadding)
                        
                        Separator(height: 0.5)
                        
                        HStack {
                            Image(systemName: "square")
                            TextField("I have a promo code...", text: $viewModel.discountCode)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, sectionRowVerticalPadding)
                    }
                    .background(Color.white.cornerRadius(sectionCornerRadius))
                    .padding(.bottom, 8)
                    
                    
                    VStack {
                        HStack {
                            Text("Total")
                            
                            Spacer()
                            
                            if let totalAmountWithoutDiscount = viewModel.totalAmountWithoutDiscount {
                                Text(totalAmountWithoutDiscount)
                                    .strikethrough()
                            }
                            
                            Text(viewModel.totalAmount)
                                .font(.system(size: 22, weight: .bold))
                        }
                        .padding(.horizontal)
                        .padding(.vertical, sectionRowVerticalPadding)
                    }
                    .background(Color.white.cornerRadius(sectionCornerRadius))
                    .padding(.bottom, 8)
                    
                    
                    if viewModel.canUseApplePay {
                        ApplePayButton {
                            viewModel.showingApplePay = true
                        }
                        .frame(height: 46)
                        .cornerRadius(applePayCornerRadius)
                        
                        Button {
                            viewModel.showingWebCheckout = true
                        } label: {
                            Text("Other payment methods")
                        }
                        .buttonStyle(TangemButtonStyle(colorStyle: .transparentWhite, layout: .flexibleWidth))
                    } else {
                        Button {
                            viewModel.showingWebCheckout = true
                        } label: {
                            Text("Buy now")
                        }
                        .buttonStyle(TangemButtonStyle(colorStyle: .black, layout: .flexibleWidth))
                    }
                }
                .padding(.horizontal)
                .frame(minWidth: geometry.size.width,
                       maxWidth: geometry.size.width,
                       minHeight: geometry.size.height,
                       maxHeight: .infinity, alignment: .top)
            }
        }
        .background(Color(UIColor.tangemBgGray).edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.didAppear()
        }
    }
}

struct ShopView_Previews: PreviewProvider {
    static let assembly: Assembly = .previewAssembly
    
    static var previews: some View {
        ShopView(viewModel: assembly.makeShopViewModel())
            .environmentObject(assembly.services.navigationCoordinator)
    }
}
