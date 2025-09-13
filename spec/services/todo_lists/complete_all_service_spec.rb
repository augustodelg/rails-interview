require 'rails_helper'

RSpec.describe TodoLists::CompleteAllService do
  let(:todo_list) { TodoList.create!(name: "Test List") }
  let!(:incomplete_item) { TodoListItem.create!(todo_list: todo_list, description: "Item 1", is_done: false) }
  let!(:completed_item) { TodoListItem.create!(todo_list: todo_list, description: "Item 2", is_done: true) }

  describe "#call" do
    context "when todo list exists and has incomplete items" do
      it "returns success" do
        service = described_class.call(todo_list_id: todo_list.id)
        
        expect(service.success?).to be true
      end

      it "queues the CompleteAllItemsJob" do
        expect {
          described_class.call(todo_list_id: todo_list.id)
        }.to have_enqueued_job(CompleteAllItemsJob).with(todo_list.id)
      end

      it "returns the job information" do
        allow_any_instance_of(CompleteAllItemsJob).to receive(:job_id).and_return("job_123")
        
        service = described_class.call(todo_list_id: todo_list.id)
        
        expect(service.result[:job_id]).to eq("job_123")
        expect(service.result[:todo_list_id]).to eq(todo_list.id.to_s)
        expect(service.result[:message]).to eq("Complete all items job queued successfully")
      end

      it "logs the job enqueuing" do
        allow(Rails.logger).to receive(:info)
        allow_any_instance_of(CompleteAllItemsJob).to receive(:job_id).and_return("job_123")
        
        described_class.call(todo_list_id: todo_list.id)
        
        expect(Rails.logger).to have_received(:info).with("Enqueued CompleteAllItemsJob with job_id: job_123 for TodoList ##{todo_list.id}")
      end
    end

    context "when todo list does not exist" do
      it "returns failure with not found error" do
        service = described_class.call(todo_list_id: 999)
        
        expect(service.failure?).to be true
        expect(service.errors[:messages]).to include("Todo list not found")
        expect(service.errors[:status]).to eq(:not_found)
      end

      it "does not queue any job" do
        expect {
          described_class.call(todo_list_id: 999)
        }.not_to have_enqueued_job(CompleteAllItemsJob)
      end
    end

    context "when todo list has no incomplete items" do
      let(:todo_list_completed) { TodoList.create!(name: "Completed List") }
      let!(:completed_item_only) { TodoListItem.create!(todo_list: todo_list_completed, description: "Done Item", is_done: true) }

      it "returns failure with appropriate error" do
        service = described_class.call(todo_list_id: todo_list_completed.id)
        
        expect(service.failure?).to be true
        expect(service.errors[:messages]).to include("No incomplete items to mark as complete")
        expect(service.errors[:status]).to eq(:unprocessable_entity)
      end

      it "does not queue any job" do
        expect {
          described_class.call(todo_list_id: todo_list_completed.id)
        }.not_to have_enqueued_job(CompleteAllItemsJob)
      end
    end

    context "when an error occurs" do
      it "handles exceptions and returns failure" do
        allow(TodoList).to receive(:find).and_raise(StandardError, "Database error")
        
        service = described_class.call(todo_list_id: todo_list.id)
        
        expect(service.failure?).to be true
        expect(service.errors[:messages]).to include("Error queueing complete all job: Database error")
      end
    end
  end
end