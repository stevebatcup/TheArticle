class AddRatingsCacheFields < ActiveRecord::Migration[5.2]
  def change
  	add_column	:articles, :ratings_well_written_cache, :integer, default: 0
  	add_column	:articles, :ratings_valid_points_cache, :integer, default: 0
  	add_column	:articles, :ratings_agree_cache, :integer, default: 0
  end
end
