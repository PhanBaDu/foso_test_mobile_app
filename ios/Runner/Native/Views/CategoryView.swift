import SwiftUI

struct NativeCategoryView: View {
    @ObservedObject var viewModel: CategoryViewModel
    let onProduct: (Product) -> Void
    var body: some View {
        HStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(viewModel.catalog.categories) { category in
                        Button(action: { viewModel.select(category.id) }) {
                            VStack(alignment: .leading, spacing: 8) {
                                ShopImage(name: "category_air", width: 40, height: 32)
                                Text(category.name).font(ShopTheme.font(12, .semibold)).lineLimit(3).frame(maxWidth: .infinity, alignment: .leading)
                            }.padding(.horizontal, 12).frame(width: 90, height: 100).background(viewModel.selectedId == category.id ? ShopTheme.background : ShopTheme.paleBlue).cornerRadius(20)
                        }.buttonStyle(PlainButtonStyle()).foregroundColor(viewModel.selectedId == category.id ? ShopTheme.text : Color(hex: 0x003D80)).accessibility(identifier: "category-\(category.id)")
                    }
                }.padding(.bottom, 24)
            }.frame(width: 90).background(ShopTheme.paleBlue)
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack {
                            Text(viewModel.selected.name).font(ShopTheme.font(16, .bold))
                            Spacer(minLength: 0)
                            FigmaIcon(name: "right", size: 16)
                        }.frame(height: 56)
                        Divider()
                        if viewModel.matches.isEmpty {
                            Text("Không tìm thấy sản phẩm").font(ShopTheme.font(14)).padding(.vertical, 80)
                        } else {
                            ForEach(1..<4) { section in
                                group(section, compact: geometry.size.width < 260)
                            }
                        }
                    }.padding(.horizontal, 12).padding(.bottom, 24)
                }.id(viewModel.selectedId).accessibility(identifier: "native-category")
            }
        }
    }
    private func group(_ number: Int, compact: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Sub Category \(number)").font(ShopTheme.font(14, .bold))
                Spacer(minLength: 2)
                SeeAllButton(action: { if let product = viewModel.catalog.products.first { onProduct(product) } })
            }.padding(.top, 18).padding(.bottom, 16)
            ForEach(0..<((viewModel.matches.count + 2) / 3), id: \.self) { row in
                HStack(alignment: .top, spacing: 12) {
                    ForEach(0..<3) { column in
                        self.cell(at: row * 3 + column, compact: compact)
                    }
                }.frame(height: row == 0 ? 134 : 106, alignment: .top)
            }
            Divider()
        }
    }
    @ViewBuilder private func cell(at index: Int, compact: Bool) -> some View {
        if index < viewModel.matches.count {
            let filter = viewModel.matches[index]
            Button(action: { if let product = viewModel.catalog.product(id: filter.productId) { onProduct(product) } }) {
                VStack(spacing: 8) {
                    ShopImage(name: filter.image, height: compact ? 58 : 70).cornerRadius(12)
                    Text(filter.name == "Bộ lọc trong cabin" ? "Bộ lọc\ntrong\ncabin" : filter.name).font(ShopTheme.font(compact ? 11 : 12)).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity)
            }.buttonStyle(PlainButtonStyle()).foregroundColor(ShopTheme.text)
        } else { Color.clear.frame(maxWidth: .infinity, maxHeight: 1) }
    }
}
