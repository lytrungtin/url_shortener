# frozen_string_literal: true

# db/migrate/20221227171400_remove_index_to_urls.rb
class RemoveIndexToUrls < ActiveRecord::Migration[7.0]
  def change
    remove_index :urls, :original_url, unique: true
  end
end
