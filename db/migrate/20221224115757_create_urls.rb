# frozen_string_literal: true

# db/migrate/20221224115757_create_urls.rb
class CreateUrls < ActiveRecord::Migration[7.0]
  def change
    create_table :urls do |t|
      t.string :original_url
      t.string :slug

      t.timestamps
    end

    add_index :urls, :original_url, unique: true
    add_index :urls, :slug, unique: true
  end
end
