//
//  TwinsWalletCreationView.swift
//  Tangem Tap
//
//  Created by Andrew Son on 18/11/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import SwiftUI

struct SimpleProgressBar: View {
	
	var isSelected: Bool
	
	var body: some View {
		isSelected ?
			Color.tangemTapBlue :
			Color.tangemTapBlueLight2
	}
	
}

struct TwinsWalletCreationView: View {
	
	@EnvironmentObject var navigation: NavigationCoordinator
	
	@ObservedObject var viewModel: TwinsWalletCreationViewModel
	
    var body: some View {
		VStack(spacing: 0) {
			NavigationBar(title: viewModel.isRecreatingWallet ? "details_twins_recreate_toolbar" : "details_row_title_twins_create",
						  settings: .init(horizontalPadding: 16),
						  backAction: {
							withAnimation {
								self.viewModel.backAction()
							}
						  })
			VStack(alignment: .leading, spacing: 8) {
				Text(viewModel.step.stepTitle)
					.font(.system(size: 30, weight: .bold))
					.foregroundColor(.tangemTapBlue)
				HStack {
					SimpleProgressBar(isSelected: true)
					SimpleProgressBar(isSelected: viewModel.step >= .second)
					SimpleProgressBar(isSelected: viewModel.step >= .third)
					
				}
				.frame(height: 3)
				ZStack {
					Image("twinSmall")
						.offset(x: 22, y: -1.5)
						.opacity(viewModel.step >= .second ? 1 : 0.0)
					Image("twinSmall")
						.offset(y: 11)
				}
				.frame(height: 104, alignment: .leading)
				Text(viewModel.step.title)
					.font(.system(size: 30, weight: .bold))
				Text(viewModel.step.hint)
				Spacer()
				HStack {
					Spacer()
					TangemLongButton(isLoading: false,
									 title: viewModel.step.buttonTitle,
									 image: "scan") {
						withAnimation {
							self.viewModel.buttonAction()
						}
					}
					.buttonStyle(TangemButtonStyle(color: .black, isDisabled: false))
				}
				.padding(.bottom, 16)
			}
			.padding(.horizontal, 24)
			.background(Color.tangemTapBgGray.edgesIgnoringSafeArea(.all))
			.foregroundColor(.tangemTapGrayDark6)
			.navigationBarTitle("")
			.navigationBarBackButtonHidden(true)
			.navigationBarHidden(true)
		}
		.alert(item: $viewModel.error) { $0.alert }
		.alert(isPresented: $viewModel.doneAlertPresented, content: {
			Alert(title: Text("common_success"),
				  message: Text("notification_twins_recreate_success"),
				  dismissButton: .default(Text("common_ok"), action: {
					self.navigation.showTwinsWalletCreation = false
				  }))
		})
    }
}

struct TwinsWalletCreationView_Previews: PreviewProvider {
    static var previews: some View {
		TwinsWalletCreationView(viewModel: Assembly.previewAssembly.makeTwinsWalletCreationViewModel(isRecreating: false))
			.deviceForPreview(.iPhone11Pro)
    }
}
