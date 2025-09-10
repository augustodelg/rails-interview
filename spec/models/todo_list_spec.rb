require 'rails_helper'

RSpec.describe TodoList, type: :model do
  describe 'associations' do
    it { should have_many(:todo_list_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'creation' do
    it 'should be valid with valid attributes' do
      todo_list = TodoList.new(name: 'Test List')
      expect(todo_list).to be_valid
    end

    it 'should not be valid without a name' do
      todo_list = TodoList.new(name: nil)
      expect(todo_list).to_not be_valid
    end
  end

  describe 'destruction' do
    it 'should destroy associated todo list items' do
      todo_list = TodoList.create!(name: 'Test List')
      todo_list_item = TodoListItem.create!(description: 'Buy groceries', is_done: false, todo_list: todo_list)
      expect { todo_list.destroy }.to change(TodoListItem, :count).by(-1)
    end
  end
end