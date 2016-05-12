class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.string :url
      t.string :title
      t.string :source

      t.timestamps null: false
    end
  end
end
