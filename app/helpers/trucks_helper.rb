module TrucksHelper

  def flatbed_type(type)
    val = "Aluminum"
    if type == 0
      val = "Steel"
    end
    val
  end

  def flatbed(flat)
    val = "Yes"
    if flat == false
      val = "No"
    end
    val
  end

end
