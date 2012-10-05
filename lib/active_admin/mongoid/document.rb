require 'mongoid'
require 'ostruct'

module ActiveAdmin::Mongoid::Document
  extend ActiveSupport::Concern

  module ClassMethods
    def columns_hash
      fields.inject({}) do |result, (name, object)|
        result.merge name => OpenStruct.new(:type => object.type.to_s.underscore.to_sym, :name => name)
      end
    end

    def content_columns
      @content_columns ||= fields.map(&:second).select {|f| f.name !~ /(^_|^(created|updated)_at)/}
    end

    def columns
      @columns ||= fields.map(&:second)
    end

    def reorder *args
      scoped
    end
  end
end

Mongoid::Document.send :include, ActiveAdmin::Mongoid::Document
