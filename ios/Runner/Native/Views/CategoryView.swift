import SwiftUI

struct NativeCategoryView: View {
    @ObservedObject var viewModel: CategoryViewModel
    @State private var haptics = UIImpactFeedbackGenerator(style: .light)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var selectedIndex: Int {
        viewModel.catalog.categories.firstIndex { $0.id == viewModel.selectedId } ?? 0
    }
    var body: some View {
        HStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    InverseCategorySelection()
                        .fill(ShopTheme.background)
                        .frame(width: 90, height: 100)
                        .offset(y: CGFloat(selectedIndex) * 100)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.24), value: selectedIndex)
                        .allowsHitTesting(false)
                    VStack(spacing: 0) {
                    ForEach(viewModel.catalog.categories) { category in
                        Button(action: {
                            haptics.impactOccurred(intensity: 0.4)
                            haptics.prepare()
                            viewModel.select(category.id)
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                ShopImage(name: "category_air", width: 40, height: 32)
                                Text(category.name).font(ShopTheme.font(12, .semibold)).lineLimit(3).frame(maxWidth: .infinity, alignment: .leading)
                            }.padding(.horizontal, 12).frame(width: 90, height: 100)
                        }.buttonStyle(PlainButtonStyle()).foregroundColor(viewModel.selectedId == category.id ? ShopTheme.text : Color(hex: 0x003D80)).accessibility(identifier: "category-\(category.id)")
                    }
                    }
                }.padding(.bottom, 24)
            }.frame(width: 90).background(ShopTheme.paleBlue)
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack {
                            Text(viewModel.selected.name).font(ShopTheme.font(16, .bold))
                            Spacer(minLength: 0)
                            FigmaIcon(name: "arrow-right-2", size: 24, color: ShopTheme.text)
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
        .onAppear { haptics.prepare() }
    }
    private func group(_ number: Int, compact: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Sub Category \(number)").font(ShopTheme.font(14, .bold))
                Spacer(minLength: 2)
                SeeAllButton(action: {})
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
            Group {
                VStack(spacing: 8) {
                    ShopImage(name: filter.image, height: compact ? 58 : 70).cornerRadius(12)
                    Text(filter.name == "Bộ lọc trong cabin" ? "Bộ lọc\ntrong\ncabin" : filter.name).font(ShopTheme.font(compact ? 11 : 12)).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity)
            }.buttonStyle(PlainButtonStyle()).foregroundColor(ShopTheme.text)
        } else { Color.clear.frame(maxWidth: .infinity, maxHeight: 1) }
    }
}

private struct InverseCategorySelection: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 20
        let k: CGFloat = 0.55228475
        var path = Path(UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: [.topLeft, .bottomLeft],
                                    cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        path.move(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY - radius),
                      control1: CGPoint(x: rect.maxX - radius + k * radius, y: rect.minY),
                      control2: CGPoint(x: rect.maxX, y: rect.minY - radius + k * radius))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        path.move(to: CGPoint(x: rect.maxX - radius, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.maxY + radius),
                      control1: CGPoint(x: rect.maxX - radius + k * radius, y: rect.maxY),
                      control2: CGPoint(x: rect.maxX, y: rect.maxY + radius - k * radius))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
