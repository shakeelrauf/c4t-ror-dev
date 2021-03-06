# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_15_131525) do

  create_table "address", primary_key: "idAddress", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "idClient"
    t.text "address", null: false
    t.text "city", null: false
    t.text "postal", null: false
    t.text "province", null: false
    t.text "distance", null: false
    t.index ["idClient"], name: "Address_idClient_idx"
  end

  create_table "authentications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "token"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "business", primary_key: "idClient", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "name", null: false
    t.text "description", null: false
    t.text "contactPosition", null: false
    t.text "pstTaxNo", null: false
    t.text "gstTaxNo", null: false
    t.boolean "usersFlatFee"
    t.index ["idClient"], name: "business-client_idx"
  end

  create_table "charities", primary_key: "idCharitie", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "name", null: false
    t.text "address"
    t.text "phone"
    t.text "email"
    t.text "info"
  end

  create_table "clients", primary_key: "idClient", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "idHeardOfUs", null: false
    t.text "firstName", null: false
    t.text "lastName", null: false
    t.text "type", null: false
    t.text "email"
    t.text "phone", null: false
    t.text "extension"
    t.text "cellPhone"
    t.text "secondaryPhone"
    t.text "note", null: false
    t.string "grade"
    t.text "customDollarCar", null: false
    t.text "customDollarSteel", null: false
    t.text "customPercCar", null: false
    t.text "customPercSteel", null: false
    t.string "phone_type"
    t.index ["idHeardOfUs"], name: "Clients-HeardsOfUs_idx"
  end

  create_table "contacts", primary_key: "idContact", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "idBusiness", null: false
    t.text "firstName", null: false
    t.text "lastName", null: false
    t.text "paymentMethod", null: false
    t.index ["idBusiness"], name: "Contacts-Business_idx"
  end

  create_table "heardsofus", primary_key: "idHeardOfUs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "type", limit: 60, null: false
    t.string "source"
    t.index ["type"], name: "type_UNIQUE", unique: true
  end

  create_table "quote_cars", primary_key: "idQuoteCars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "idQuote", null: false
    t.integer "idCar", null: false
    t.integer "idAddress"
    t.text "donation"
    t.text "gettingMethod", null: false
    t.text "vin"
    t.integer "gotKeys", limit: 1
    t.text "drivetrain"
    t.text "tiresCondition"
    t.integer "ownership", limit: 1
    t.integer "running", limit: 1
    t.integer "complete", limit: 1
    t.text "color"
    t.text "receipt"
    t.text "ownershipName"
    t.text "ownershipAddress"
    t.integer "cashRegular"
    t.text "timeBooked"
    t.text "carNotes"
    t.text "driverNotes"
    t.date "dateBooked"
    t.integer "missingWheels", default: 0
    t.boolean "missingBattery"
    t.boolean "missingCat"
    t.integer "isTowable", limit: 1
    t.integer "canDo2wd", limit: 1
    t.integer "canGoNeutral", limit: 1
    t.decimal "distance", precision: 10, scale: 2
    t.decimal "price", precision: 10, scale: 2
    t.boolean "still_driving"
    t.integer "platesOn"
    t.float "weight"
    t.boolean "by_weight"
    t.float "new_price"
    t.index ["idAddress"], name: "Address_idAddress_idx"
    t.index ["idCar"], name: "VehiclulesInfo_idCar_idx"
    t.index ["idQuote"], name: "Quotes_idQuote_idx"
  end

  create_table "quotes", primary_key: "idQuote", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "idUser"
    t.integer "idClient"
    t.integer "idStatus", default: 1, null: false
    t.datetime "dtStatusUpdated"
    t.datetime "dtCreated"
    t.text "note"
    t.text "referNo"
    t.decimal "bonus", precision: 10, scale: 2
    t.integer "isSatisfactionSMSQuoteSent", limit: 1
    t.decimal "smallCarPrice", precision: 10, scale: 2, null: false
    t.decimal "midCarPrice", precision: 10, scale: 2, null: false
    t.decimal "largeCarPrice", precision: 10, scale: 2, null: false
    t.decimal "steelPrice", precision: 10, scale: 2, null: false
    t.decimal "wheelPrice", precision: 10, scale: 2, null: false
    t.decimal "batteryPrice", precision: 10, scale: 2, null: false
    t.decimal "catPrice", precision: 10, scale: 2, null: false
    t.decimal "pickup", precision: 10, scale: 2, null: false
    t.decimal "freeDistance", precision: 10, scale: 2, null: false
    t.decimal "excessCost", precision: 10, scale: 2, null: false
    t.boolean "is_published", default: false
    t.string "payment_method"
    t.index ["idClient"], name: "Clients_idClient_idx"
    t.index ["idStatus"], name: "Status_idStatus_idx"
    t.index ["idUser"], name: "Users_idUser_idx"
  end

  create_table "satisfactions", primary_key: "idSatisfaction", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "idClient", null: false
    t.datetime "dtAdded"
    t.text "from", null: false
    t.integer "satisfaction", null: false
    t.index ["idClient"], name: "Satisfactions_Clients_idClient_idx"
  end

  create_table "schedules", primary_key: "idSchedule", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "idCar", null: false
    t.text "truck", null: false
    t.datetime "dtStart", null: false
    t.datetime "dtEnd"
    t.index ["idCar"], name: "Schedules_idCar_idx"
  end

  create_table "settings", primary_key: "idSettings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "label", null: false
    t.text "name", null: false
    t.text "value", null: false
    t.datetime "dtCreated"
    t.text "grade"
  end

  create_table "status", primary_key: "idStatus", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "name", null: false
    t.text "color", null: false
  end

  create_table "trucks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "make"
    t.string "model"
    t.integer "year"
    t.boolean "flatbed"
    t.integer "flatbed_type"
    t.integer "car_capacity"
    t.string "weight_capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "upsell_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "price_increase"
    t.integer "deduction_money_figure"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "pw_reinit_key"
    t.datetime "pw_reinit_exp"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", primary_key: "idUser", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "username", null: false
    t.text "password", null: false
    t.text "roles", null: false
    t.text "firstName", null: false
    t.text "lastName", null: false
    t.text "email", null: false
    t.text "phone"
    t.datetime "dtCreated"
    t.datetime "dtLastLogin"
    t.text "accessToken"
    t.integer "isActive", limit: 1, default: 1, null: false
    t.integer "isSuperadmin", limit: 1, default: 0, null: false
    t.text "avatar"
    t.boolean "force_new_pw"
    t.string "salt"
  end

  create_table "vehicle_infos", primary_key: "idVehiculeInfo", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "year"
    t.text "make"
    t.text "model"
    t.text "trim"
    t.text "body"
    t.text "drive"
    t.text "transmission"
    t.text "seats"
    t.text "doors"
    t.text "weight"
    t.string "ref_id"
    t.string "length"
    t.string "width"
    t.string "height"
    t.string "wheelbase"
    t.string "engine_type"
    t.string "searchable"
  end

  add_foreign_key "address", "clients", column: "idClient", primary_key: "idClient", name: "Address_idClient"
  add_foreign_key "business", "clients", column: "idClient", primary_key: "idClient", name: "business-client"
  add_foreign_key "clients", "heardsofus", column: "idHeardOfUs", primary_key: "idHeardOfUs", name: "Clients-HeardsOfUs"
  add_foreign_key "contacts", "business", column: "idBusiness", primary_key: "idClient", name: "Contacts-Business"
  add_foreign_key "quote_cars", "address", column: "idAddress", primary_key: "idAddress", name: "Address_idAddress"
  add_foreign_key "quote_cars", "quotes", column: "idQuote", primary_key: "idQuote", name: "Quotes_idQuote"
  add_foreign_key "quote_cars", "vehicle_infos", column: "idCar", primary_key: "idVehiculeInfo", name: "VehiclesInfo_idCar"
  add_foreign_key "quotes", "clients", column: "idClient", primary_key: "idClient", name: "Clients_idClient"
  add_foreign_key "quotes", "status", column: "idStatus", primary_key: "idStatus", name: "Status_idStatus"
  add_foreign_key "quotes", "users", column: "idUser", primary_key: "idUser", name: "Users_idUser"
  add_foreign_key "satisfactions", "clients", column: "idClient", primary_key: "idClient", name: "Satisfactions_Clients_idClient"
  add_foreign_key "schedules", "quote_cars", column: "idCar", primary_key: "idQuoteCars", name: "Schedules_idQuoteCar"
end
