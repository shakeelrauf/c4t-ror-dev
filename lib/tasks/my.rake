# Mysql stuff
namespace :my do
	desc "Reindex the cars"
  task :reindex_cars => :environment do
		VehicleInfo.all.each do |v|
      v.save!
    end
  end
end
