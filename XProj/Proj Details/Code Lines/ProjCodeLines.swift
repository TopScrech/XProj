import SwiftUI

struct ProjCodeLines: View {
    private var vm = ProjCodeLinesVM()
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.openWindow) private var openWindow
    
    private let proj: Proj
    
    init(_ proj: Proj) {
        self.proj = proj
    }
    
    var body: some View {
        Section {
            if vm.totalLines > 0 {
                HStack {
                    Text(vm.totalLines)
                    
                    Spacer()
                    
                    Button("Details...") {
                        openWindow(id: "code_lines", value: proj.path)
                    }
                    .footnote()
                    .secondary()
                    .buttonStyle(.plain)
                }
            } else {
                Text("-")
            }
        } header: {
            Text("Code lines")
                .title2()
        }
        .task {
            await countLines()
        }
        .onChange(of: proj) {
            Task {
                await countLines()
            }
        }
    }
    
    private func countLines() async {
        await vm.countLines(store.codeLineCountingExtensions, proj: proj)
    }
}

#Preview {
    ProjCodeLines(previewProj1)
        .environmentObject(ValueStore())
}
