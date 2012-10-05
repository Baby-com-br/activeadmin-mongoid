class ActiveAdmin::FilterFormBuilder
  def default_input_type(method, options = {})
    if (column = column_for(method))
      case column.type
      when :date, :datetime
        return :date_range
      when :string, :text
        return :string
      when :integer
        return :select if reflection_for(method.to_s.gsub('_id','').to_sym)
        return :numeric
      when :float, :decimal
        return :numeric
      when :boolean
        return :select
      when :object
        return :select
      end
    end

    if reflection = reflection_for(method)
      return :select if reflection.macro == :belongs_to && !reflection.options[:polymorphic]
    end
  end

  def reflection_for(method)
    return @object.class.reflect_on_association(method) if @object.class.respond_to?(:reflect_on_association)
    @object.base.reflect_on_association(method) if @object.base.respond_to?(:reflect_on_association)
  end
end
