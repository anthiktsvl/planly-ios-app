//
//  AnalyticsView.swift
//  planly-app
//
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var dataViewModel: AppDataViewModel

    var completionRate: Double {
        let total = dataViewModel.tasks.count
        guard total > 0 else { return 0 }
        return Double(dataViewModel.completedTasks.count) / Double(total)
    }

    var body: some View {
        NavigationView {
            List {
                Section("Overview") {
                    HStack {
                        Text("Total Tasks")
                        Spacer()
                        Text("\(dataViewModel.tasks.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Completed Tasks")
                        Spacer()
                        Text("\(dataViewModel.completedTasks.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Completion Rate")
                        Spacer()
                        Text("\(Int(completionRate * 100))%")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Analytics")
        }
    }
}
