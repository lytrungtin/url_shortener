# frozen_string_literal: true

require 'test_helper'

class RedirectionControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect to original url' do
    react = urls(:react)
    get shortened_url(slug: react.slug)
    assert_redirected_to react.original_url
  end

  test 'access with wrong slug format should render to not found' do
    get shortened_url(slug: 'fckeditor')
    assert_response :not_found
  end

  test 'access with not existed slug should render to not found' do
    get shortened_url(slug: '1a2b3c')
    assert_response :not_found
  end
end
