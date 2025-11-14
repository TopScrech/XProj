import ScrechKit
import Charts

struct CodeLineList: View {
    @State private var vm = CodeLineListVM()
    @EnvironmentObject private var store: ValueStore
    
    @Binding var path: String?
    
    init(_ path: Binding<String?>) {
        _path = path
    }
    
    var sortedItems: [FileLines] {
        vm.fileLineItems.sorted {
            $0.lines > $1.lines
        }
    }
    
    var top16: [FileLines] {
        Array(sortedItems.prefix(16))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if !top16.isEmpty {
                Chart(top16) { item in
                    BarMark(
                        x: .value("Lines", item.lines),
                        y: .value("File", item.url.lastPathComponent)
                    )
                    .annotation(position: .trailing) {
                        Text(item.lines)
                            .caption2()
                            .monospacedDigit()
                    }
                }
                .frame(height: 280)
                .padding(.horizontal)
            }
            
            List {
                Section("Files by lines") {
                    ForEach(sortedItems) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.url.lastPathComponent)
                                    .monospaced()
                                    .lineLimit(1)
                                
                                Text(item.path)
                                    .caption2()
                                    .secondary()
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Text("\(item.lines)")
                                .callout()
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
        .task {
            await vm.countLines(store.codeLineCountingExtensions, at: path)
        }
    }
}

#Preview {
    CodeLineList(.constant("Preview/Preview"))
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
