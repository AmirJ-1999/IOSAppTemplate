//
//  ContentView.swift
//  IOSAppTemplate
//
//  Created by Amir on 05/03/2026.
//

import SwiftUI

struct TaskItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isDone: Bool
}

struct ContentView: View {
    private static let storageKey = "saved_tasks_v1"
    private static let defaultTasks: [TaskItem] = [
        TaskItem(title: "Set up project icons", isDone: true),
        TaskItem(title: "Build first screen", isDone: false),
        TaskItem(title: "Run app in iOS Simulator", isDone: false)
    ]

    @State private var newTaskTitle = ""
    @State private var tasks: [TaskItem] = ContentView.loadTasks()

    private var completedCount: Int {
        tasks.filter(\.isDone).count
    }

    private var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(tasks.count)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Template Task Tracker")
                        .font(.headline)
                    Text("\(completedCount) of \(tasks.count) completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    ProgressView(value: progress)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                HStack(spacing: 8) {
                    TextField("Add a task", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)

                    Button("Add") {
                        addTask()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                List {
                    ForEach($tasks) { $task in
                        HStack {
                            Button {
                                task.isDone.toggle()
                            } label: {
                                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isDone ? .green : .gray)
                            }
                            .buttonStyle(.plain)

                            Text(task.title)
                                .strikethrough(task.isDone)
                                .foregroundColor(task.isDone ? .secondary : .primary)
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(.plain)
            }
            .padding()
            .navigationTitle("My Starter App")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetTasks()
                    }
                }
            }
        }
        .onChange(of: tasks) { _ in
            saveTasks()
        }
    }

    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        tasks.append(TaskItem(title: title, isDone: false))
        newTaskTitle = ""
    }

    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    private func resetTasks() {
        tasks = ContentView.defaultTasks
        newTaskTitle = ""
    }

    private func saveTasks() {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

    private static func loadTasks() -> [TaskItem] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([TaskItem].self, from: data)
        else {
            return defaultTasks
        }
        return decoded
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
