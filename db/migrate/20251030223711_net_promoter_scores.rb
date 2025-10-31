class NetPromoterScores < ActiveRecord::Migration[7.2]
  def change
    create_table :net_promoter_scores do |t|
      t.references :company, foreign_key: true
      t.integer :promoters_count
      t.integer :passives_count
      t.integer :detractors_count
      t.integer :daily_score
      t.integer :reviews_count
      t.timestamps
    end
  end
end
