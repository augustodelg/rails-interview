require 'rails_helper'

RSpec.describe CompleteAllItemsJob, type: :job do
  let(:todo_list) { TodoList.create!(name: "Test List") }
  let!(:item1) { TodoListItem.create!(todo_list: todo_list, description: "Item 1", is_done: false) }
  let!(:item2) { TodoListItem.create!(todo_list: todo_list, description: "Item 2", is_done: false) }
  let!(:item3) { TodoListItem.create!(todo_list: todo_list, description: "Item 3", is_done: true) }

  describe "#perform" do
    context "when todo list exists" do
      it "marks all incomplete items as completed" do
        expect {
          described_class.perform_now(todo_list.id)
        }.to change { todo_list.todo_list_items.reload.where(is_done: false).count }.from(2).to(0)
      end

      it "does not change already completed items" do
        described_class.perform_now(todo_list.id)
        
        item3.reload
        expect(item3.is_done).to be true
      end

      it "updates the updated_at timestamp for modified items" do
        freeze_time do
          expect {
            described_class.perform_now(todo_list.id)
          }.to change { item1.reload.updated_at }
        end
      end

      it "logs the job execution" do
        allow(Rails.logger).to receive(:info)
        
        described_class.perform_now(todo_list.id)
        
        expect(Rails.logger).to have_received(:info).with("Starting CompleteAllItemsJob for TodoList ##{todo_list.id}")
        expect(Rails.logger).to have_received(:info).with("Completed 2 items for TodoList ##{todo_list.id}")
      end

      it "broadcasts the update via Turbo Stream" do
        allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
        allow(Turbo::StreamsChannel).to receive(:broadcast_append_to)
        
        described_class.perform_now(todo_list.id)
        
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
          "todo_list_#{todo_list.id}",
          target: "todo_list_#{todo_list.id}_items",
          partial: "shared/todo_list_items",
          locals: { todo_list: todo_list }
        )
        
        expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to).with(
          "todo_list_#{todo_list.id}",
          target: "notifications",
          partial: "shared/notification",
          locals: { message: "All items marked as complete!", type: "success" }
        )
      end
    end

    context "when todo list does not exist" do
      it "does not raise an error" do
        expect {
          described_class.perform_now(999)
        }.not_to raise_error
      end

      it "logs the job start but not completion" do
        allow(Rails.logger).to receive(:info)
        
        described_class.perform_now(999)
        
        expect(Rails.logger).to have_received(:info).with("Starting CompleteAllItemsJob for TodoList #999")
        expect(Rails.logger).not_to have_received(:info).with(/Completed \d+ items/)
      end
    end
  end
end