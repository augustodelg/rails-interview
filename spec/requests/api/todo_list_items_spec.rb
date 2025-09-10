require 'rails_helper'

RSpec.describe "TodoListItems", type: :request do
  let(:todo_list) { TodoList.create!(name: 'Test List') }
  
  describe "POST /api/todolists/:todo_list_id/items" do
    it "successfully creates a todo list item" do
      post "/api/todolists/#{todo_list.id}/items", params: { todo_list_item: { description: 'Test item', is_done: false } }, as: :json
      
      expect(response).to have_http_status(:success)
      
      todo_list_item = TodoListItem.last
      response_data = JSON.parse(response.body)

      aggregate_failures 'includes the correct data' do
        expect(response_data.keys).to match_array(['id', 'description', 'is_done', 'created_at', 'updated_at', 'todo_list_id'])
        expect(response_data['id']).to eq(todo_list_item.id)
        expect(response_data['description']).to eq('Test item')
        expect(response_data['is_done']).to eq(false)
        expect(response_data['created_at']).to eq(todo_list_item.created_at.as_json)
        expect(response_data['updated_at']).to eq(todo_list_item.updated_at.as_json)
        expect(response_data['todo_list_id']).to eq(todo_list.id)
      end
    end
  end

  describe "PUT /api/todolists/:todo_list_id/items/:id" do
    let(:todo_list_item) { TodoListItem.create!(description: 'Test item', is_done: false, todo_list: todo_list) }
    
    it "returns http success" do
      put "/api/todolists/#{todo_list.id}/items/#{todo_list_item.id}", params: { todo_list_item: { description: 'Updated item' } }, as: :json
      expect(response).to have_http_status(:success)

      todo_list_item = TodoListItem.last
      response_data = JSON.parse(response.body)

      aggregate_failures 'includes the correct data' do
        expect(response_data.keys).to match_array(['id', 'description', 'is_done', 'created_at', 'updated_at', 'todo_list_id'])
        expect(response_data['id']).to eq(todo_list_item.id)
        expect(response_data['description']).to eq('Updated item')
        expect(response_data['is_done']).to eq(false)
        expect(response_data['created_at']).to eq(todo_list_item.created_at.as_json)
        expect(response_data['updated_at']).to eq(todo_list_item.updated_at.as_json)
        expect(response_data['todo_list_id']).to eq(todo_list.id)
      end
    end
  end

  describe "DELETE /api/todolists/:todo_list_id/items/:id" do
    let(:todo_list_item_to_delete) { TodoListItem.create!(description: 'Test item', is_done: false, todo_list: todo_list) }
    
    it "returns http success" do
      delete "/api/todolists/#{todo_list.id}/items/#{todo_list_item_to_delete.id}", as: :json
      expect(response).to have_http_status(:success)

      expect { TodoListItem.find(todo_list_item_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)

      response_data = JSON.parse(response.body)

      aggregate_failures 'includes the correct data' do
        expect(response_data.keys).to match_array(['id', 'description', 'is_done', 'created_at', 'updated_at', 'todo_list_id'])
        expect(response_data['id']).to eq(todo_list_item_to_delete.id)
        expect(response_data['description']).to eq('Test item')
        expect(response_data['is_done']).to eq(false)
        expect(response_data['created_at']).to eq(todo_list_item_to_delete.created_at.as_json)
        expect(response_data['updated_at']).to eq(todo_list_item_to_delete.updated_at.as_json)
        expect(response_data['todo_list_id']).to eq(todo_list.id)
      end
    end
  end
end
