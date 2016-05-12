class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.references :comment, index: true, foreign_key: true
      t.string :extract
      t.string :pattern

      t.timestamps null: false
    end
  end
end
