# frozen_string_literal: true

require 'spec_helper'

describe Tracecontroller do
  it 'has a version number' do
    expect(Tracecontroller::VERSION).not_to be nil
  end

  after { File.delete '.tracecontroller.yml' if File.exists? '.tracecontroller.yml' }

  describe '#valid?' do
    it 'missing callback.' do
      DummyApp::Application.routes.draw do
        resources :users
        resources :public_pages
        resources :secrets
      end

      # OK
      class UsersController < ApplicationController
        before_action :require_login
      end

      class PublicPagesController < ApplicationController
      end

      # NG
      class SecretsController < ApplicationController
      end

      File.open '.tracecontroller.yml', 'w' do |file|
        file.puts '- path: ^/'
        file.puts '  actions:'
        file.puts '    - before:'
        file.puts '      - require_login'
        file.puts '  ignore_classes:'
        file.puts '    - PublicPagesController'
      end

      trace = Tracecontroller.new(Rails.application)
      expect(trace.valid?).to be_falsey
      expect(trace.errors[:superclass]).to be_blank
      callback_error = {controller_name: 'SecretsController', callbacks: [{kind: :before, filter: :require_login}]}
      expect(trace.errors[:callback]).to eq([callback_error])
    end

    it 'missing superclass.' do
      DummyApp::Application.routes.draw do
        resources :books
        namespace :api do
          resources :books
        end
      end

      class BooksController < ActionController::Base
      end

      class Api::BooksController < ActionController::Base
      end

      File.open '.tracecontroller.yml', 'w' do |file|
        file.puts '- path: ^/'
        file.puts '  superclass: ApplicationController'
        file.puts '  ignore_classes:'
        file.puts '    - Api::BooksController'
        file.puts '- path: ^/api'
        file.puts '  superclass: Api::BaseController'
      end

      trace = Tracecontroller.new(Rails.application)
      expect(trace.valid?).to be_falsey
      expect(trace.errors[:superclass]).to eq(["Api::BooksController", "BooksController"])
      expect(trace.errors[:callback]).to be_blank
    end
  end
end
