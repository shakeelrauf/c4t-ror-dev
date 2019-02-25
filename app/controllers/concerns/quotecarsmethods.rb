module Quotecarsmethods
  def vehicles_search limit_p=nil, offset_p=nil, filter=nil
    limit = 30
    offset = 0
    limit = (limit_p.present? ? limit_p.to_i : 30)
    offset = ((offset_p.to_i) * limit) if offset_p != "-1"
    if filter.present?
      filter = + filter.gsub(/[\s]/, "% %") + "%"
      filters = filter.split(' ')
      query = "Select * from vehicle_infos where"
      count_query = "Select COUNT(*) from vehicle_infos where"
      filters.each do |fil|
        query.concat(" year LIKE '#{fil}' OR make LIKE '#{fil}' OR model LIKE '#{fil}' OR trim LIKE '#{fil}' OR body LIKE '#{fil}' OR drive LIKE '#{fil}' OR transmission LIKE '#{fil}' OR seats LIKE '#{fil}' OR doors LIKE '#{fil}' OR weight LIKE '#{fil}'")
        query.concat(" AND ") if !fil.eql?(filters.last)
        count_query.concat(" year LIKE '#{fil}' OR make LIKE '#{fil}' OR model LIKE '#{fil}' OR trim LIKE '#{fil}' OR body LIKE '#{fil}' OR drive LIKE '#{fil}' OR transmission LIKE '#{fil}' OR seats LIKE '#{fil}' OR doors LIKE '#{fil}' OR weight LIKE '#{fil}'")
        count_query.concat(" AND ") if !fil.eql?(filters.last)
      end
      r_vehicles = VehicleInfo.run_sql_query(query, offset, limit )
      count = (VehicleInfo.run_sql_query(count_query).rows.first.first/limit).ceil
      return [r_vehicles,count]
    end
    r_vehicles = VehicleInfo.all.limit(limit).offset(offset) if !filter.present?
    count = (VehicleInfo.count/limit).ceil if !filter.present?
    return [r_vehicles,count]
  end
end
