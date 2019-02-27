# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('vendor/assets-libs')
Rails.application.config.assets.paths << Rails.root.join('vendor/assets-libs')
Rails.application.config.assets.paths << Rails.root.join('vendor/assets-libs')
Rails.application.config.assets.paths << Rails.root.join('assets/plugins')
Rails.application.config.assets.paths << Rails.root.join('assets/icon')
Rails.application.config.assets.precompile += %w( ckeditor/*)
Rails.application.config.assets.precompile += %w( login.css login.js dashboard.css dashboard.js)
Rails.application.config.assets.precompile += %w( waves/js/waves.min.js main.min.js)
Rails.application.config.assets.precompile += %w( moment/js/moment.js main.min.js menu.js common.js  dropify-master/dist/js/dropify.min.js classie/js/classie.js fullcalendar-scheduler-1.9.0/scheduler.min.js fullcalendar/js/fullcalendar.min.js charts/flot/js/jquery.flot.js charts/flot/js/jquery.flot.categories.js charts/flot/js/jquery.flot.pie.js)
# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
