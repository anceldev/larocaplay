//
//  SuscriptionScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 3/12/25.
//

import SwiftUI

struct SubscriptionScreen: View {
//    @Environment(AuthService.self) var auth
    
//    var managementURL: URL? {
//        guard let managementURL = auth.customerInfo?.managementURL else {
//            return nil
//        }
//        return managementURL
//    }
    
    @State private var expirationDate: Date? = nil
//    @State private var renewDate: Date? = nil
    @State private var willRenew: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            TopBarScreen(title: "Suscripción", true)
            Text("Detalles")
                .padding(.leading, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16))
                .fontWeight(.semibold)
            VStack(spacing: 16) {
                HStack {
                    Image(.star)
                    Text("Suscripción")
                    Spacer(minLength: 0)
//                    Button {
//                        if !auth.isPremium {
//                            showPaywall = true
//                        }
//                    } label: {
                    Text("Activa")
                        .font(.system(size: 14))
                        .foregroundStyle(.customRed)
//                    }
                }
//                if let product = auth.currentProduct {
//                    
//                    HStack {
//                        Image(.box)
//                        Text("Producto")
//                        Spacer(minLength: 0)
//                        Text(product.localizedTitle)
//                            .font(.system(size: 14))
//                            .foregroundStyle(.customRed)
//                        //                    }
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                    HStack {
//                        Image(.subscription2)
//                        Text("Precio")
//                        Spacer(minLength: 0)
//                        Text(product.localizedPriceString)
//                            .font(.system(size: 14))
//                            .foregroundStyle(.customRed)
//                        //                    }
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    HStack {
//                        Image(.subscription2)
//                        Text("Tipo")
//                        Spacer(minLength: 0)
//                        Text(product.subscriptionPeriod?.unit == .month ? "Mensual" : "Anual")
//                            .font(.system(size: 14))
//                            .foregroundStyle(.customRed)
//                        //                    }
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                }
                HStack {
                    Image(.calendarDays)
                    Text("Fecha de expiración")
                    Spacer()
                    if let expirationDate {
                        Text(expirationDate, style: .date)
                            .font(.system(size: 14))
                            .foregroundStyle(.customRed)
                    }
                }
                HStack {
                    Image(.circleHalfDottedCheck)
                    Text("Renovable")
                    Spacer()
                    Text(willRenew ? "Sí" : "No")
                        .font(.system(size: 14))
                        .foregroundStyle(.customRed)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
//                if let managementURL {
//                    Link(destination: managementURL) {
//                        HStack {
//                            Image(.fileContent)
//                            Text("Cancelar suscripción")
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    }
////                    .disabled(!auth.isPremium)
//                }
            }
            .padding()
            .background(.black.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            Spacer()
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(.customBlack)
        .onAppear(perform: {
            getExpirationAndRenewDate()
        })
        .enableInjection()
    }
    private func getExpirationAndRenewDate() {
//        if auth.isPremium {
//            if let entitlement = auth.customerInfo?.entitlements["pro"] {
//                self.expirationDate = entitlement.expirationDate
//                self.willRenew = entitlement.willRenew
//            }
//        }
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
//
//#Preview {
//    SuscriptionScreen()
//}
