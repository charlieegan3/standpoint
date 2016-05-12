class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :discussion, index: true, foreign_key: true
      t.references :parent, index: true
      t.string :user
      t.text :text
      t.integer :votes

      t.timestamps null: false
    end
  end
end
