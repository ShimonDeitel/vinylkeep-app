import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: RecordEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    VStack(spacing: 12) {
                        Text("No entries yet")
                            .font(Theme.font(20, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        Text("Tap + to log your first record.")
                            .font(Theme.font(15))
                            .foregroundStyle(Theme.muted)
                    }
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            Button {
                                editingEntry = entry
                            } label: {
                                EntryRow(entry: entry)
                            }
                            .listRowBackground(Theme.background)
                            .accessibilityIdentifier("entryRow_\(entry.title)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                }
            }
            .navigationTitle("Vinylkeep")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .tint(Theme.accent)
            .sheet(isPresented: $showAdd) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryRow: View {
    let entry: RecordEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title)
                .font(Theme.font(17, weight: .semibold))
                .foregroundStyle(Theme.ink)
            Text("\(entry.detail1) · \(entry.detail2)")
                .font(Theme.font(13))
                .foregroundStyle(Theme.muted)
            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(Theme.font(13))
                    .foregroundStyle(Theme.muted)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var detail1: String
    @State private var detail2: String
    @State private var note: String
    @State private var date: Date
    let existingID: UUID?
    let onSave: (RecordEntry) -> Void
    @FocusState private var focusedField: Field?

    enum Field { case title, detail1, detail2, note }

    init(entry: RecordEntry?, onSave: @escaping (RecordEntry) -> Void) {
        _title = State(initialValue: entry?.title ?? "")
        _detail1 = State(initialValue: entry?.detail1 ?? "")
        _detail2 = State(initialValue: entry?.detail2 ?? "")
        _note = State(initialValue: entry?.note ?? "")
        _date = State(initialValue: entry?.date ?? Date())
        existingID = entry?.id
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Record Details") {
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .accessibilityIdentifier("titleField")
                    TextField("Artist", text: $detail1)
                        .focused($focusedField, equals: .detail1)
                        .accessibilityIdentifier("detail1Field")
                    TextField("Label", text: $detail2)
                        .focused($focusedField, equals: .detail2)
                        .accessibilityIdentifier("detail2Field")
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note", text: $note, axis: .vertical)
                        .focused($focusedField, equals: .note)
                        .accessibilityIdentifier("noteField")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(existingID == nil ? "Add Record" : "Edit Record")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry = RecordEntry(title: title, detail1: detail1, detail2: detail2, note: note, date: date)
                        if let existingID { entry.id = existingID }
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
