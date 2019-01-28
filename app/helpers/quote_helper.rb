module QuoteHelper

  def preselected_quotes(customer, quote)
    @customer.present? && @customer.try(:quotes).count > 0 || @quote.try(:customer).try(:heardofus).present?
  end

end
