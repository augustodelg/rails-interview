require 'rails_helper'

RSpec.describe "TodoListItems", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/todo_list_item/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/todo_list_item/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/todo_list_item/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
