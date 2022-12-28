# frozen_string_literal: true

class RemoveIndexToUrls < ActiveRecord::Migration[7.0]
  def change
    remove_index :urls, :original_url, unique: true
  end
end
