require 'rails_helper'

RSpec.describe TodoListItem, type: :model do
  let(:todo_list) { TodoList.create!(name: 'Test List') }
  
  describe 'associations' do  
  it { should belong_to(:todo_list) }
  end

  describe 'validations' do
    it { should validate_presence_of(:description) }
  end

  describe 'creation' do
    it 'should be valid with valid attributes' do
      todo_list_item = TodoListItem.new(description: 'Buy groceries', is_done: false, todo_list: todo_list)
      expect(todo_list_item).to be_valid
    end

    it 'should not be valid without a description' do
    todo_list_item = TodoListItem.new(is_done: false, todo_list: todo_list)
      expect(todo_list_item).to_not be_valid
    end
  end
end