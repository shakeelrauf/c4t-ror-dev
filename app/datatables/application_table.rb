class ApplicationTable
	delegate :params, to: :@view
  delegate :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      recordsTotal: count,
      recordsFiltered: total_entries,
      data: data
    }
  end


	private

  def page
    params[:start].to_i / per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column(name=nil)
  	return sorting_columns[4] if params[:order].nil?
    return sorting_columns[params[:order]['0'][:column].to_i] if name.nil? or !params[:order].present?
    if (params[:order]['0'][:column].to_i == 2)
      return sorting_columns[3] 
    elsif (params[:order]['0'][:column].to_i == 3)
      return sorting_columns[4] 
    elsif (params[:order]['0'][:column].to_i == 4)
      return sorting_columns[7] 
    elsif (params[:order]['0'][:column].to_i == 5)
      return sorting_columns[9] 
    elsif (params[:order]['0'][:column].to_i == 6)
      return sorting_columns[10] 
    else
    	return sorting_columns[params[:order]['0'][:column].to_i]
    end
  end

  def sort_direction
  	return "desc" if params[:order].nil?
    params[:order]['0'][:dir] == "desc" ? "desc" : "asc"
  end
end