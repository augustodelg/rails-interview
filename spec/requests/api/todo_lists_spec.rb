require 'rails_helper'

RSpec.describe "Api::TodoLists", type: :request do
  let(:todo_list) { TodoList.create!(name: "Test List") }
  let!(:incomplete_item) { TodoListItem.create!(todo_list: todo_list, description: "Item 1", is_done: false) }
  let!(:completed_item) { TodoListItem.create!(todo_list: todo_list, description: "Item 2", is_done: true) }

  describe "GET /api/todolists" do
    it "returns http success" do
      get "/api/todolists", as: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /api/todolists/:id/complete_all" do
    context "when todo list exists and has incomplete items" do
      it "returns accepted status" do
        post "/api/todolists/#{todo_list.id}/complete_all", as: :json
        
        expect(response).to have_http_status(:accepted)
      end

      it "returns success message with job information" do
        post "/api/todolists/#{todo_list.id}/complete_all", as: :json
        
        response_data = JSON.parse(response.body)
        
        aggregate_failures 'includes the correct response' do
          expect(response_data['message']).to eq("Complete all job queued successfully")
          expect(response_data['job_id']).to be_present
          expect(response_data['todo_list_id']).to eq(todo_list.id.to_s)
        end
      end

      it "enqueues the CompleteAllItemsJob" do
        expect {
          post "/api/todolists/#{todo_list.id}/complete_all", as: :json
        }.to have_enqueued_job(CompleteAllItemsJob).with(todo_list.id)
      end
    end

    context "when todo list does not exist" do
      it "returns not found status" do
        post "/api/todolists/999/complete_all", as: :json
        
        expect(response).to have_http_status(:not_found)
      end

      it "returns error message" do
        post "/api/todolists/999/complete_all", as: :json
        
        response_data = JSON.parse(response.body)
        expect(response_data['errors']).to include("Todo list not found")
      end

      it "does not enqueue any job" do
        expect {
          post "/api/todolists/999/complete_all", as: :json
        }.not_to have_enqueued_job(CompleteAllItemsJob)
      end
    end

    context "when todo list has no incomplete items" do
      let(:completed_list) { TodoList.create!(name: "All Done List") }
      let!(:done_item) { TodoListItem.create!(todo_list: completed_list, description: "Done Item", is_done: true) }

      it "returns unprocessable entity status" do
        post "/api/todolists/#{completed_list.id}/complete_all", as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns appropriate error message" do
        post "/api/todolists/#{completed_list.id}/complete_all", as: :json
        
        response_data = JSON.parse(response.body)
        expect(response_data['errors']).to include("No incomplete items to mark as complete")
      end

      it "does not enqueue any job" do
        expect {
          post "/api/todolists/#{completed_list.id}/complete_all", as: :json
        }.not_to have_enqueued_job(CompleteAllItemsJob)
      end
    end
  end
end