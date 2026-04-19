# TOCPrimitive

`TOCPrimitive` is the shared table-of-contents surface for the portfolio. It provides `TOCController` (an `@MainActor` `ObservableObject` that loads and presents TOC nodes from a `TOCProvider` conformance) plus shared SwiftUI views for the TOC tree.

Use it when a reader surfaces a chapter / section / page navigator. Do not rebuild a TOC tree per host.

## What The Package Gives You

- `TOCController` — owns TOC state for a single document; loads nodes via `TOCProvider`
- `TOCPresentationState` — typed state (isLoading, errorDescription, nodeCount)
- shared SwiftUI views for rendering TOC trees with expand/collapse and current-location highlighting

## When To Use It

- You are using `ReaderView` — TOC is composed internally when the renderer provides a `TOCProvider`
- You are building a custom reader surface and want the same navigator UX
- You are implementing a `TOCProvider` in a renderer primitive and want the reference controller

## When Not To Use It

- You want an arbitrary navigation tree (use a plain SwiftUI `List` or `OutlineGroup`)
- You need document outline *extraction* logic — that belongs in the renderer primitive's `TOCProvider` conformance

## Install

```swift
dependencies: [
    .package(path: "../TOCPrimitive"),
],
targets: [
    .target(
        name: "MyReaderHost",
        dependencies: ["TOCPrimitive"]
    )
]
```

Depends on `ContentModelPrimitive` (for `TOCProvider` and `TOCNode`) and `ReaderChromeThemePrimitive` (for theming).

## Basic Usage

Inside `ReaderView`: already wired via `ReaderComposer.currentTOCController`.

Custom reader:

```swift
import TOCPrimitive
import ContentModelPrimitive
import SwiftUI

struct CustomReader: View {
    @StateObject private var controller: TOCController

    init(provider: any TOCProvider) {
        _controller = StateObject(wrappedValue: TOCController(provider: provider))
    }

    var body: some View {
        HStack {
            TOCTreeView(controller: controller)
                .task { await controller.load() }

            ReaderContent(/* ... */)
        }
    }
}
```

## Integration Guide

How TOC fits into the broader reader stack (renderer conformance, host composition, navigator chrome):

- `Packages/ReaderKit/docs/reader-stack-integration-guide.md`

## Design Notes

`TOCController` is per-document. Multi-document readers hold multiple controllers and route between them via `ReaderComposer.tocController(for:)`.

TOC extraction is deliberately pushed to the renderer primitive via `TOCProvider`. PDF outlines come from PDFKit's `PDFOutline`, EPUB chapters come from spine/nav documents, markdown comes from heading parsing. Each renderer knows its own structure; this primitive just presents whatever the provider returns.
