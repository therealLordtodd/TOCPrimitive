import Testing
import SwiftUI
import ContentModelPrimitive
import ReaderChromeThemePrimitive
@testable import TOCPrimitive

private struct StubTOCProvider: TOCProvider {
    let documentID: DocumentID
    let nodes: [TOCNode]

    init(
        documentID: DocumentID = "doc-1",
        nodes: [TOCNode]
    ) {
        self.documentID = documentID
        self.nodes = nodes
    }

    func tableOfContents() async throws -> [TOCNode] {
        nodes
    }
}

@Test func tocPresentationStateDefaultsAreStable() {
    let state = TOCPresentationState()

    #expect(state.isLoading == false)
    #expect(state.errorDescription == nil)
    #expect(state.nodeCount == 0)
}

@MainActor
@Test func tocControllerLoadsProviderNodes() async {
    let provider = StubTOCProvider(nodes: [
        TOCNode(
            id: "chapter-1",
            title: "Chapter 1",
            anchor: .epub(EPUBAnchor(chapterID: "chapter-1")),
            children: [
                TOCNode(
                    id: "chapter-1.1",
                    title: "Section 1.1",
                    anchor: .epub(EPUBAnchor(chapterID: "chapter-1.1"))
                )
            ]
        )
    ])

    let controller = TOCController(provider: provider)
    await controller.load()

    #expect(controller.presentationState.isLoading == false)
    #expect(controller.presentationState.errorDescription == nil)
    #expect(controller.presentationState.nodeCount == 1)
    #expect(controller.nodes.first?.title == "Chapter 1")
    #expect(controller.nodes.first?.children.first?.title == "Section 1.1")
}

@MainActor
@Test func tocViewsPublicSurfaceLoads() {
    let nodes = [
        TOCNode(
            id: "chapter-1",
            title: "Chapter 1",
            anchor: .epub(EPUBAnchor(chapterID: "chapter-1"))
        )
    ]

    _ = TOCListView(
        nodes: nodes,
        selectedNodeID: "chapter-1",
        onNodeSelected: { _ in }
    )

    _ = TOCPopoverButton(
        label: "Chapters",
        popoverTitle: "Chapters",
        nodes: nodes,
        selectedNodeID: "chapter-1",
        onNodeSelected: { _ in }
    )
    .readerChromeTheme(.dark)
}
