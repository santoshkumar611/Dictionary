class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :word
      t.string :meaning1
      t.string :meaning2
      t.string :meaning3
      t.boolean :bookmarked,:default=>false

      t.timestamps null: false
    end
  end
end
