module QuoteHelper

  def preselected_quotes(customer, quote)
    @customer.present? && @customer.try(:quotes).count > 0 || @quote.try(:customer).try(:heardofus).present?
  end

  def phone_type_for_quote(customer)
    val = ""
    if customer.phone.present?
    	val = "primary"
    elsif customer.cellPhone.present?
      val = "cell"
    elsif customer.secondaryPhone.present?
      val = "other"
    else
      val = "primary"
    end
    val
  end

end
