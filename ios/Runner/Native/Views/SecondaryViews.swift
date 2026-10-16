import SwiftUI

struct NativeCartView: View {
    @ObservedObject var viewModel: CartViewModel
    var body: some View {
        Group {
            if viewModel.lines.isEmpty {
                VStack(spacing: 16) {
                    FigmaIcon(name: "cart", size: 64, color: ShopTheme.muted)
                    Text("Giỏ hàng của bạn đang trống").font(ShopTheme.font(14))
                    Text("Khám phá sản phẩm tại Trang chủ").font(ShopTheme.font(12)).foregroundColor(ShopTheme.muted)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Giỏ hàng").font(ShopTheme.font(22, .bold))
                        ForEach(viewModel.lines) { line in
                            HStack(spacing: 12) {
                                ShopImage(name: line.product.image, width: 96, height: 100)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(line.product.name).font(ShopTheme.font(14, .semibold))
                                    Text(ShopFormat.money(line.product.price)).font(ShopTheme.font(14, .bold)).foregroundColor(ShopTheme.red)
                                    HStack(spacing: 20) {
                                        Button("−") { viewModel.remove(line.id) }.accessibility(label: Text("Giảm số lượng"))
                                        Text("\(line.quantity)").foregroundColor(ShopTheme.text)
                                        Button("+") { viewModel.add(line.product) }.accessibility(label: Text("Tăng số lượng"))
                                    }.font(ShopTheme.font(22)).foregroundColor(ShopTheme.blue)
                                }
                            }.padding(12).background(Color.white).cornerRadius(12)
                        }
                        Text("Tổng cộng: \(ShopFormat.money(viewModel.total))").font(ShopTheme.font(18, .bold)).accessibility(identifier: "cart-total")
                    }.padding(16).padding(.bottom, 24)
                }
            }
        }.accessibility(identifier: "native-cart")
    }
}
struct NativeSheetView: View {
    let destination: ShopSheet
    let onBuy: (Product) -> Void
    @Environment(\.presentationMode) private var presentation
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack { Spacer(); Button("Đóng") { presentation.wrappedValue.dismiss() }.font(ShopTheme.font(14)).foregroundColor(ShopTheme.blue) }
                if case .product(let product) = destination {
                    ShopImage(name: product.image, height: 180).frame(maxWidth: .infinity)
                    Text(product.name).font(ShopTheme.font(20, .semibold))
                    Text(ShopFormat.money(product.price)).font(ShopTheme.font(22, .bold)).foregroundColor(ShopTheme.red)
                    Button(action: { presentation.wrappedValue.dismiss(); onBuy(product) }) {
                        Text("Thêm vào giỏ hàng").font(ShopTheme.font(14, .semibold)).foregroundColor(.white).frame(maxWidth: .infinity).padding(16).background(ShopTheme.blue).cornerRadius(12)
                    }
                } else if case .article(let article) = destination {
                    ShopImage(name: article.image, height: 180).frame(maxWidth: .infinity)
                    Text(article.title).font(ShopTheme.font(20, .semibold))
                    Text(ShopFormat.date(article.date)).font(ShopTheme.font(12)).foregroundColor(ShopTheme.blue)
                } else if case .notice(let message) = destination {
                    Text(message).font(ShopTheme.font(16)).padding(.vertical, 40)
                }
            }.padding(24)
        }
    }
}
