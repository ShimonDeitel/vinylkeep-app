import XCTest
@testable import Vinylkeep

@MainActor
final class VinylkeepTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataLoadedOnFreshInstall() {
        XCTAssertFalse(store.entries.isEmpty)
    }

    func testSeedCountIsBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(RecordEntry(title: "Test", detail1: "A", detail2: "B", note: "", date: Date()))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testDeleteEntryDecreasesCount() {
        store.add(RecordEntry(title: "ToDelete", detail1: "A", detail2: "B", note: "", date: Date()))
        let before = store.entries.count
        store.delete(store.entries[0])
        XCTAssertEqual(store.entries.count, before - 1)
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreWhenAtLimitAndNotPro() {
        while store.entries.count < Store.freeLimit {
            store.add(RecordEntry(title: "Filler", detail1: "A", detail2: "B", note: "", date: Date()))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testCanAddMoreWhenProRegardlessOfLimit() {
        store.isPro = true
        while store.entries.count < Store.freeLimit {
            store.add(RecordEntry(title: "Filler", detail1: "A", detail2: "B", note: "", date: Date()))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testUpdateEntryChangesTitle() {
        store.add(RecordEntry(title: "Original", detail1: "A", detail2: "B", note: "", date: Date()))
        var entry = store.entries[0]
        entry.title = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries[0].title, "Updated")
    }
}
