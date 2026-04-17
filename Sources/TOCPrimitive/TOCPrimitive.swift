import SwiftUI
import ContentModelPrimitive
import ReaderChromeThemePrimitive

public struct TOCPresentationState: Sendable, Equatable {
    public var isLoading: Bool
    public var errorDescription: String?
    public var nodeCount: Int

    public init(
        isLoading: Bool = false,
        errorDescription: String? = nil,
        nodeCount: Int = 0
    ) {
        self.isLoading = isLoading
        self.errorDescription = errorDescription
        self.nodeCount = nodeCount
    }
}

@MainActor
public final class TOCController: ObservableObject {
    @Published public private(set) var nodes: [TOCNode] = []
    @Published public private(set) var presentationState = TOCPresentationState()

    public let documentID: DocumentID

    private let provider: any TOCProvider

    public init(provider: any TOCProvider) {
        self.provider = provider
        self.documentID = provider.documentID
    }

    public func load() async {
        presentationState = TOCPresentationState(
            isLoading: true,
            errorDescription: nil,
            nodeCount: nodes.count
        )

        do {
            let loadedNodes = try await provider.tableOfContents()
            nodes = loadedNodes
            presentationState = TOCPresentationState(
                isLoading: false,
                errorDescription: nil,
                nodeCount: loadedNodes.count
            )
        } catch {
            nodes = []
            presentationState = TOCPresentationState(
                isLoading: false,
                errorDescription: String(describing: error),
                nodeCount: 0
            )
        }
    }
}

public struct TOCListView: View {
    public var nodes: [TOCNode]
    public var selectedNodeID: ContentIdentity?
    public var theme: ReaderChromeTheme
    public var emptyTitle: String
    public var onNodeSelected: (TOCNode) -> Void

    public init(
        nodes: [TOCNode],
        selectedNodeID: ContentIdentity?,
        theme: ReaderChromeTheme = .default,
        emptyTitle: String = "No contents",
        onNodeSelected: @escaping (TOCNode) -> Void
    ) {
        self.nodes = nodes
        self.selectedNodeID = selectedNodeID
        self.theme = theme
        self.emptyTitle = emptyTitle
        self.onNodeSelected = onNodeSelected
    }

    public var body: some View {
        Group {
            if nodes.isEmpty {
                emptyState
            } else {
                ScrollViewReader { proxy in
                    List {
                        OutlineGroup(nodes, children: \.outlineChildren) { node in
                            tocRow(for: node)
                                .id(node.id)
                        }
                    }
                    .listStyle(.plain)
                    .onAppear {
                        scrollToSelectedNode(with: proxy)
                    }
                    .onChange(of: selectedNodeID) { _ in
                        scrollToSelectedNode(with: proxy)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: theme.spacing.small) {
            Image(systemName: "list.bullet.rectangle")
                .font(theme.typography.title3)
                .foregroundStyle(theme.colors.secondaryText)

            Text(emptyTitle)
                .font(theme.typography.callout)
                .foregroundStyle(theme.colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(theme.spacing.large)
    }

    private func tocRow(for node: TOCNode) -> some View {
        let isSelected = node.id == selectedNodeID

        return Button {
            onNodeSelected(node)
        } label: {
            HStack(spacing: theme.spacing.small) {
                Text(node.title)
                    .font(isSelected ? theme.typography.captionEmphasis : theme.typography.callout)
                    .foregroundStyle(
                        isSelected
                            ? theme.colors.infoTint
                            : theme.colors.primaryText
                    )
                    .multilineTextAlignment(.leading)

                Spacer(minLength: theme.spacing.small)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.infoTint)
                }
            }
            .padding(.vertical, theme.spacing.xSmall)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func scrollToSelectedNode(with proxy: ScrollViewProxy) {
        guard let selectedNodeID else { return }
        DispatchQueue.main.async {
            proxy.scrollTo(selectedNodeID, anchor: .center)
        }
    }
}

private extension TOCNode {
    var outlineChildren: [TOCNode]? {
        children.isEmpty ? nil : children
    }
}

public struct TOCPopoverButton: View {
    public var label: String
    public var popoverTitle: String
    public var systemImage: String
    public var nodes: [TOCNode]
    public var selectedNodeID: ContentIdentity?
    public var theme: ReaderChromeTheme
    public var emptyTitle: String
    public var onNodeSelected: (TOCNode) -> Void

    @State private var showingPopover = false

    public init(
        label: String = "Contents",
        popoverTitle: String = "Contents",
        systemImage: String = "list.bullet",
        nodes: [TOCNode],
        selectedNodeID: ContentIdentity?,
        theme: ReaderChromeTheme = .default,
        emptyTitle: String = "No contents",
        onNodeSelected: @escaping (TOCNode) -> Void
    ) {
        self.label = label
        self.popoverTitle = popoverTitle
        self.systemImage = systemImage
        self.nodes = nodes
        self.selectedNodeID = selectedNodeID
        self.theme = theme
        self.emptyTitle = emptyTitle
        self.onNodeSelected = onNodeSelected
    }

    public var body: some View {
        Button {
            showingPopover.toggle()
        } label: {
            Label(label, systemImage: systemImage)
        }
        .popover(isPresented: $showingPopover, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Text(popoverTitle)
                    .font(theme.typography.title3)
                    .foregroundStyle(theme.colors.primaryText)
                    .padding(theme.spacing.large)

                Divider()

                TOCListView(
                    nodes: nodes,
                    selectedNodeID: selectedNodeID,
                    theme: theme,
                    emptyTitle: emptyTitle,
                    onNodeSelected: { node in
                        onNodeSelected(node)
                        showingPopover = false
                    }
                )
            }
            .frame(width: 320, height: 420)
        }
    }
}
