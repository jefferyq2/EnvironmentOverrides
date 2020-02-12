import SwiftUI

public extension View {
    func attachEnvironmentOverrides() -> some View {
        modifier(EnvironmentOverridesModifier())
    }
}

struct EnvironmentOverridesModifier: ViewModifier {
    
    @Environment(\.colorScheme) private var defaultColorScheme: ColorScheme
    @Environment(\.sizeCategory) private var defaultSizeCategory: ContentSizeCategory
    @State private var values = EnvironmentValues()
    
    func body(content: Content) -> some View {
        content
            .onAppear { self.copyDefaultSettings() }
            .overlay(EnvironmentOverridesView(params: settings),
                     alignment: .bottomTrailing)
            .environment(\.colorScheme, values.colorScheme)
            .environment(\.locale, values.locale)
            .environment(\.sizeCategory, values.sizeCategory)
    }
    
    private func copyDefaultSettings() {
        values.colorScheme = defaultColorScheme
        values.sizeCategory = defaultSizeCategory
        if let locale = EnvironmentValues.currentLocale {
            values.locale = locale
        }
    }
    
    private var settings: SettingsView.Params {
        return SettingsView.Params(
            locales: EnvironmentValues.supportedLocales,
            locale: $values.map(\.locale),
            colorScheme: $values.map(\.colorScheme),
            textSize: $values.map(\.sizeCategory))
    }
}

// MARK: -

struct EnvironmentOverridesView: View {
    
    @State private var isExpanded = false
    @State private var viewHeight: CGFloat = SettingsView.ContentHeight.defaultValue
    private let params: SettingsView.Params
    
    init(params: SettingsView.Params) {
        self.params = params
    }
    
    var body: some View {
        BaseView(isExpanded: isExpanded, height: $viewHeight)
            .onTapGesture {
                self.isExpanded.toggle()
            }
            .overlay(Group {
                if isExpanded {
                    SettingsView(params: params)
                }
            })
            .onPreferenceChange(SettingsView.ContentHeight.self) {
                self.viewHeight = $0
            }
            .padding(8)
    }
}

#if DEBUG

struct EnvironmentOverridesView_Previews: PreviewProvider {
    static var previews: some View {
        Color(UIColor.systemBackground)
            .overlay(EnvironmentOverridesView(params: .preview()),
                     alignment: .bottomTrailing)
            .colorScheme(.light)
    }
}

extension Binding {
    init(wrappedValue: Value) {
        var value = wrappedValue
        self.init(get: { value }, set: { value = $0 })
    }
}

#endif