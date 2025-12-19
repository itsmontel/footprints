//
//  JournalNoteView.swift
//  Footprints
//
//  Journal note section with editing capabilities
//

import SwiftUI
import CoreData

struct JournalNoteView: View {
    @ObservedObject var viewModel: WalkDetailViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.lavender)
                    
                    Text("Journal")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                if !viewModel.isEditingJournal && viewModel.walk.hasJournal {
                    Button(action: { viewModel.isEditingJournal = true }) {
                        Text("Edit")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }
            }
            
            buildContent()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: AppColors.shadowGreen, radius: 10, y: 5)
        )
    }
    
    private func buildContent() -> some View {
        if viewModel.isEditingJournal {
            return AnyView(editingView)
        } else if viewModel.walk.hasJournal {
            return AnyView(journalTextView)
        } else {
            return AnyView(addButtonView)
        }
    }
    
    private var editingView: some View {
        VStack(spacing: 14) {
            TextEditor(text: $viewModel.journalText)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)
                .frame(minHeight: 120)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.softBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primaryGreen.opacity(0.3), lineWidth: 1)
                )
                .focused($isTextFieldFocused)
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.cancelJournalEdit()
                    isTextFieldFocused = false
                }) {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppColors.softBackground)
                        )
                }
                
                Button(action: {
                    viewModel.saveJournal()
                    isTextFieldFocused = false
                }) {
                    Text("Save")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppColors.primaryGreen)
                        )
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
    }
    
    private var journalTextView: some View {
        Text(viewModel.walk.journalNote ?? "")
            .font(.body)
            .foregroundColor(AppColors.textPrimary)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.softBackground)
            )
    }
    
    private var addButtonView: some View {
        Button(action: { viewModel.isEditingJournal = true }) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryGreen.opacity(0.6))
                
                Text("Add a note about this walk...")
                    .font(.body)
                    .foregroundColor(AppColors.textMuted)
                    .italic()
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.softBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                            )
                            .foregroundColor(AppColors.primaryGreen.opacity(0.3))
                    )
            )
        }
    }
}

#Preview {
    let walk = Walk(context: PersistenceController.preview.container.viewContext)
    walk.journalNote = "Beautiful morning walk through the park. Saw some lovely flowers blooming and met a friendly dog on the trail."
    
    JournalNoteView(viewModel: WalkDetailViewModel(walk: walk))
        .padding()
        .background(AppColors.softGreenGradient)
}
