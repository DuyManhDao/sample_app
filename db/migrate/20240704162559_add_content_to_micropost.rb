class AddContentToMicropost < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :content, :string
  end
end
