class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :body
      t.references :parent, index: true
      t.string :source

      t.timestamps null: false
    end
  end
end
