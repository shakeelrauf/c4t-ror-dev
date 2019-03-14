namespace :import do
	require 'roo'

	desc "Imprting Cars from xml sheet"
  task :cars_from_xlsx => :environment do
  	puts "deleting previous quotes "
		Quote.destroy_all
		puts "deleting previous cars data"
		VehicleInfo.destroy_all
		xlsx = Roo::Spreadsheet.open(Rails.root.join( 'lib','data','cars.xlsx').to_s)
		model = ""
		year = ""
		xlsx.each_row_streaming do |row|
			car = VehicleInfo.new
			if row.first.value != "Model"
				puts "Found a new car row" 
				model = row.first.value if row.first.value.present? 
				year = row.second.value if row.second.value.present? 
				ref_id = row[2].value
				make = row[3].value
				trim = row[6].value
				body = row[7].value
				length = row[8].value
				width = row[9].value
				height = row[10].value
				wheelsbase = row[11].value
				weight = row[12].value
				drive = row[13].value
				transmission = row[14].value
				engine_type = row[15].value
				car.model = model
				car.year = year
				car.ref_id = ref_id
				car.trim = trim
				car.body = body
				car.length = length
				car.width = width
				car.height = height
				car.wheelbase = wheelsbase
				car.weight = weight
				car.drive = drive
				car.transmission = transmission
				car.make = make
				car.engine_type = engine_type
				car.save!
				puts "............................................................................."
				puts car.inspect
				puts "#{car.id} ...................................................................."
			end
		end
  end
end
