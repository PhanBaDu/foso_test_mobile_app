import SwiftUI

struct NativeHomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let onCategory: (String) -> Void
    let onProduct: (Product) -> Void
    let onBuy: (Product) -> Void
    let onArticle: (Article) -> Void
    let onNews: () -> Void
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ShopImage(name: "welcome_banner").aspectRatio(369 / 65, contentMode: .fit).cornerRadius(8).padding(.horizontal, 12).padding(.top, 24)
                    featuredCategories
                    carousel(width: max(1, geometry.size.width - 24))
                    flashSale
                    SectionHeader(title: "Thương Hiệu Nổi Bật", icon: "brand")
                    brands
                    SectionHeader(title: "Sản Phẩm Bán Chạy", icon: "bestseller", action: { onCategory("air") })
                    productRow(limited: true)
                    promos(width: max(1, geometry.size.width - 24))
                    SectionHeader(title: "Dành Cho Bạn", icon: "recommend", action: { onCategory("air") })
                    recommended
                    VStack(spacing: 0) {
                        SectionHeader(title: "Hàng Mới Về", icon: "new_arrivals", light: true, action: { onCategory("air") })
                        productRow().padding(.bottom, 16)
                    }.background(ShopTheme.blue).padding(.top, 24)
                    SectionHeader(title: "Bài Viết Nổi Bật", icon: "article", action: onNews)
                    NativeArticleList(articles: viewModel.catalog.articles, onSelect: onArticle).padding(.bottom, 48)
                }
            }.accessibility(identifier: "native-home")
        }
    }
    private var featuredCategories: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danh mục tiêu biểu").font(ShopTheme.font(16, .semibold)).padding(.horizontal, 12).padding(.top, 24)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.catalog.featuredCategories) { category in
                        Button(action: { onCategory(category.id) }) {
                            VStack(spacing: 10) {
                                ShopImage(name: category.image, width: 55, height: 39)
                                Text(category.name).font(ShopTheme.font(11)).multilineTextAlignment(.center).lineLimit(2).frame(maxWidth: .infinity)
                            }.padding(.horizontal, 4).frame(width: 77, height: 98).background(Color.white).cornerRadius(6)
                        }.buttonStyle(PlainButtonStyle()).foregroundColor(ShopTheme.text)
                    }
                }.padding(.horizontal, 12)
            }
            ZStack(alignment: .leading) {
                Capsule().fill(Color(hex: 0xDFE3E8)).frame(width: 59, height: 6)
                Capsule().fill(ShopTheme.blue).frame(width: 24, height: 6)
            }.frame(maxWidth: .infinity).padding(.bottom, 28)
        }
    }
    @ViewBuilder private func carousel(width: CGFloat) -> some View {
        if #available(iOS 14.0, *) {
            TabView(selection: $viewModel.banner) {
                ForEach(0..<3) { index in
                    ShopImage(name: index == 0 ? "welcome_banner" : "offer_banner", width: width, height: 170, fit: .fill).cornerRadius(8).tag(index)
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)).frame(height: 170)
        } else {
            // Maintain iOS 13 support without requiring PageTabViewStyle.
            ScrollView(.horizontal, showsIndicators: false) { HStack { ShopImage(name: "offer_banner", width: width, height: 170, fit: .fill).cornerRadius(8) }.padding(.horizontal, 12) }
        }
        HStack(spacing: 6) {
            ForEach(0..<3) { i in Capsule().fill(viewModel.banner == i ? ShopTheme.brightBlue : Color(hex: 0xC4CDD5)).frame(width: viewModel.banner == i ? 20 : 10, height: 3) }
        }.padding(.top, 9).padding(.bottom, 24)
    }
    private var flashSale: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                FigmaIcon(name: "flash", size: 25, color: ShopTheme.flash)
                Text("FLASH SALE").font(ShopTheme.font(16, .bold)).lineLimit(1).minimumScaleFactor(0.7)
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        if index > 0 { Text(":").foregroundColor(ShopTheme.red) }
                        Text(viewModel.clock[index]).font(ShopTheme.font(12, .semibold)).foregroundColor(.white).padding(.horizontal, 4).padding(.vertical, 5).background(ShopTheme.red).cornerRadius(2)
                    }
                }
                Spacer(minLength: 2)
                SeeAllButton(color: Color(hex: 0xFF6948), action: { onCategory("air") })
            }.padding(.horizontal, 12).padding(.vertical, 14)
            productRow(flash: true).padding(.bottom, 12)
        }.background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0xFFE4BF), Color(hex: 0xFFFAF4)]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    private var brands: some View {
        VStack(spacing: 8) {
            ForEach(0..<2) { row in
                HStack(spacing: 8) {
                    ForEach(0..<5) { column in
                        Button(action: { onCategory("air") }) { ShopImage(name: "brand_\(row * 5 + column)").aspectRatio(1.3, contentMode: .fit).cornerRadius(6) }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }.padding(.horizontal, 12)
    }
    private func productRow(flash: Bool = false, limited: Bool = false) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.catalog.products) { product in
                    NativeProductCard(product: product, flash: flash, limited: limited, onDetails: { onProduct(product) }, onBuy: { onBuy(product) })
                }
            }.padding(.horizontal, 12)
        }
    }
    private func promo(_ name: String) -> some View {
        Button(action: { onCategory("air") }) { ShopImage(name: name, fit: .fill).cornerRadius(12) }.buttonStyle(PlainButtonStyle())
    }
    private func promos(width: CGFloat) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 12) { promo("promo_red"); promo("promo_yellow") }
            promo("promo_blue")
        }.frame(height: width * 270 / 369).padding(.horizontal, 12).padding(.top, 24)
    }
    private var recommended: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                promo("recommend_banner").frame(width: 150, height: 291)
                ForEach(viewModel.catalog.products) { product in
                    NativeProductCard(product: product, onDetails: { onProduct(product) }, onBuy: { onBuy(product) })
                }
            }.padding(.horizontal, 12)
        }
    }
}
