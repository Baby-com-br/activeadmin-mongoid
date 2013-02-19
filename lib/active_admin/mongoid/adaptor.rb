module ActiveAdmin
  module Mongoid
    module Adaptor
      class Search
        attr_reader :base, :query, :query_hash, :search_params

        def initialize(object, search_params = {})
          @base = object
          @search_params = search_params.reject {|k,v| @base.all.respond_to? k }
          @query_hash = get_query_hash(@search_params)
          @query = @base.where(@query_hash)

          search_params.each do |k,v|
            @query = @query.send(k,v) if @query.respond_to? k
          end
        end

        def respond_to?(method_id)
          if @base.is_a? ::Mongoid::Criteria
            @base.klass.send(:respond_to?, method_id)
          else
            @base.send(:respond_to?, method_id)
          end
        end

        def method_missing(method_id, *args, &block)
          if is_query(method_id)
            @search_params[method_id.to_s]
          else
            @query.send(method_id, *args, &block)
          end
        end

        private

        def is_query(method_id)
          method_id.to_s =~ /(_contains|_eq)$/
        end

        def get_query_hash(search_params)
          searches = search_params.map do|k, v|
            mongoidify_search(k,v)
          end
          Hash[searches]
        end

        def mongoidify_search(k, v)
          if k =~ /_contains$/
            [get_attribute(k), Regexp.new(Regexp.escape("#{v}"), Regexp::IGNORECASE)]
          elsif k =~ /_eq$/
            [get_attribute(k), v]
          else
            [k, v]
          end
        end

        def get_attribute(k)
          k.match(/^(.*)(_contains|_eq)$/)[1]
        end
      end
    end
  end
end
