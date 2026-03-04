import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    quadrantGrid(geometry: geometry)
                    
                    bottomBar
                }
                .background(Color(nsColor: .windowBackgroundColor))
            }
            .ignoresSafeArea()
            
            if viewModel.showCompleted {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.showCompleted = false
                        }
                    }
                
                VStack {
                    Spacer()
                    CompletedTasksView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 && viewModel.showCompleted {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showCompleted = false
                    }
                    return nil
                }
                return event
            }
        }
    }
    
    private func quadrantGrid(geometry: GeometryProxy) -> some View {
        let bottomBarHeight: CGFloat = 50
        let topPadding: CGFloat = 60
        let availableHeight = geometry.size.height - bottomBarHeight - topPadding - 32 // 32 for padding
        
        return VStack(spacing: 16) {
            HStack(spacing: 16) {
                QuadrantView(quadrant: .q1)
                QuadrantView(quadrant: .q2)
            }
            .frame(height: availableHeight / 2)
            
            HStack(spacing: 16) {
                QuadrantView(quadrant: .q3)
                QuadrantView(quadrant: .q4)
            }
            .frame(height: availableHeight / 2)
        }
        .padding(.top, topPadding)
        .padding(.horizontal, 16)
    }
    
    private var bottomBar: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.showCompleted.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                    Text("显示已完成")
                }
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}
