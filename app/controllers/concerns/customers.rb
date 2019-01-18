module Customers
  def get_heard_of_us
    count = Customer.joins(:heardofus).select("heardsofus.type ").group("idHeardOfUs")
    last_data = []
    letters = [*'0'..'9',*'A'..'F']
    color = ""
    count.each.with_index(1) do |counter, index|
      color = "#"
      color+=(0...6).map{ letters.sample }.join
      last_data.push({label: counter["type"],
                      data: index,
                      color: color})
    end
    last_data
  end
end