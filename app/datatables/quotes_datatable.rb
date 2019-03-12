class QuotesDatatable < ApplicationTable
  delegate :edit_quote_path, to: :@view
  delegate :select_tag, to:  :@view
  include CustomersHelper
  private

  def data
    quotes.map do |quote|
      [].tap do |column|
      	customer_number  = quote.customer.present? ? quote.customer.phone.present? ? quote.customer.phone : quote.customer.cellPhone.present? ? quote.customer.cellPhone : "" : "" 
      	customer_name = quote.customer.present? ? quote.customer.lastName + quote.customer.firstName : ""
        dispatcher_name = quote.dispatcher.present? ? quote.dispatcher.firstName.to_s + quote.dispatcher.lastName.to_s : ""
        status = quote.status.present? ? quote.status.id : ""
        no_link = link_to customer_number, "tel:+#{customer_number}"
        column << quote.referNo
        column << customer_name
        column << no_link
        column << quote.dtCreated.to_datetime.strftime("%Y-%m-%d %H:%M")
        column << dispatcher_name
        column << status_select_tag(quote, Status.all)
				column << time_diff(Time.now.to_datetime,quote.dtStatusUpdated.to_datetime)
        links = []
        links << link_to('<i class="icofont icofont-ui-edit"></i>'.html_safe, edit_quote_path(quote), inner_html: {class: "btn btn-primary waves-effect waves-light"}, class: "btn btn-primary waves-effect waves-light")
        column << links.join(' | ')
      end
    end
  end

	def time_diff(start_time, end_time)
	  seconds_diff = ((start_time - end_time)* 24 * 60 * 60).to_i.abs

	  hours = seconds_diff / 3600
	  seconds_diff -= hours * 3600

	  minutes = seconds_diff / 60
	  seconds_diff -= minutes * 60
	  display = 0
	  seconds = seconds_diff
		days = hours/24
	  display = "#{seconds}s" if seconds.to_f > 0
	  display = "#{minutes}m" if minutes.to_f > 0
	  display = "#{hours}h" if hours.to_f > 0
	  display = "#{days}d" if days.to_f > 0
	  display
	end

  def status_select_tag(quote, status)
  	str= ""
  	str += "<select class='quote-status-list selectcash form-control badge badge-"
  	str += "#{background_color(quote.status.color)}' " 
  	str += "data-quote-no='#{quote.id}'>"
    status.each do |stat|
      str +=  "<option value='#{stat.id}'"
      str +=  " selected" if (stat.id == quote.status.id)
      str +=  ">#{stat.name}</option>"
    end
    str += "</select>"
    str.html_safe
  end

  def count
    Quote.count
  end

  def total_entries
    quotes.total_count
  end

  def quotes
    @quotes ||= fetch_quotes
  end

  def fetch_quotes
    search_string = []
    columns.each do |term|
      search_string << "#{term} like :search"
    end
    quotes = Quote.joins(:dispatcher, :customer, :status).order("#{sort_column("quote")} #{sort_direction}")
    quotes = quotes.page(page).per(per_page)
    quotes = quotes.where(search_string.join(' or '), search: "%#{params[:search][:value]}%")
  end

  def columns
    %w(referNo clients.firstName clients.lastName clients.phone clients.cellPhone clients.secondaryPhone users.firstName users.lastName status.name)
  end

  def sorting_columns
    %w(referNo clients.firstName clients.lastName clients.phone dtCreated clients.cellPhone clients.secondaryPhone users.firstName users.lastName status.name dtStatusUpdated)
  end
end
