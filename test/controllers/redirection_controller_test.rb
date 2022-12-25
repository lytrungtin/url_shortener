# frozen_string_literal: true

require 'test_helper'

class RedirectionControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect to original url' do
    react = urls(:react)
    get shortened_url(slug: react.slug)
    assert_redirected_to react.original_url
  end
end
