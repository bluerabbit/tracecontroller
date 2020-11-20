# frozen_string_literal: true

require 'rails/all'
require 'action_controller/railtie'

require 'tracecontroller'

module DummyApp
  class Application < Rails::Application
    config.root = File.expand_path(__dir__)
  end
end

class ApplicationController < ActionController::Base
end

module Api
end

class Api::BaseController < ApplicationController
  before_action :require_login_for_api

  def require_login_for_api
  end
end
