require 'active_admin'
require 'inherited_resources'

ActiveAdmin::Resource # autoload
class ActiveAdmin::Resource
  def resource_table_name
    resource_class.respond_to?(:collection_name) ?  resource_class.collection_name : resource_class.table_name
  end
end

ActiveAdmin::ResourceController # autoload
class ActiveAdmin::ResourceController
  # Use #desc and #asc for sorting.
  def sort_order(chain)
    params[:order] ||= active_admin_config.sort_order
    if params[:order] && params[:order] =~ /^([\w\_\.]+)_(desc|asc)$/
      return chain.order_by({$1 => $2}) if chain.respond_to? :order_by

      column = $1
      order  = $2
      table  = active_admin_config.resource_table_name
      table_column = (column =~ /\./) ? column :
        "#{table}.#{active_admin_config.resource_quoted_column_name(column)}"

      chain.reorder("#{table_column} #{order}")
    else
      chain # just return the chain
    end
  end

  def search(chain)
    if chain.respond_to? :collection_name
      @search = ActiveAdmin::Mongoid::Adaptor::Search.new(chain, clean_search_params(params[:q]))
    else
      @search = chain.metasearch(clean_search_params(params[:q]))
      @search.relation
    end
  end

end
