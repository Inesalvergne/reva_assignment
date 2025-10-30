class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.date :date
      t.integer :rating, null: false
      t.integer :channel, null: false
      t.string :title
      t.text :description
      t.references :company, null: false, foreign_key: true
      t.timestamps
    end

    add_index :reviews, :channel
    add_index :reviews, :rating
    add_index :reviews, :date
    add_index :reviews,
              %i[date rating channel description company_id],
              unique: true,
              name: 'index_reviews_on_unique_combination'
  end
end
