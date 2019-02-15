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

ActiveRecord::Schema.define(version: 2019_02_15_063305) do

  create_table "QuotesCars", primary_key: "idQuoteCars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
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
    t.string "payment_method"
    t.string "customer_email"
    t.index ["idAddress"], name: "Address_idAddress_idx"
    t.index ["idCar"], name: "VehiclulesInfo_idCar_idx"
    t.index ["idQuote"], name: "Quotes_idQuote_idx"
  end

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
    t.index ["type"], name: "type_UNIQUE", unique: true
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

  create_table "vehiculesinfo", primary_key: "idVehiculeInfo", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
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
  end

  add_foreign_key "QuotesCars", "address", column: "idAddress", primary_key: "idaddress", name: "Address_idAddress"
  add_foreign_key "QuotesCars", "quotes", column: "idQuote", primary_key: "idquote", name: "Quotes_idQuote"
  add_foreign_key "QuotesCars", "vehiculesinfo", column: "idCar", primary_key: "idvehiculeinfo", name: "VehiclesInfo_idCar"
  add_foreign_key "address", "clients", column: "idClient", primary_key: "idclient", name: "Address_idClient"
  add_foreign_key "business", "clients", column: "idClient", primary_key: "idclient", name: "business-client"
  add_foreign_key "clients", "heardsofus", column: "idHeardOfUs", primary_key: "idheardofus", name: "Clients-HeardsOfUs"
  add_foreign_key "contacts", "business", column: "idBusiness", primary_key: "idclient", name: "Contacts-Business"
  add_foreign_key "quotes", "clients", column: "idClient", primary_key: "idclient", name: "Clients_idClient"
  add_foreign_key "quotes", "status", column: "idStatus", primary_key: "idstatus", name: "Status_idStatus"
  add_foreign_key "quotes", "users", column: "idUser", primary_key: "iduser", name: "Users_idUser"
  add_foreign_key "satisfactions", "clients", column: "idClient", primary_key: "idclient", name: "Satisfactions_Clients_idClient"
  add_foreign_key "schedules", "quotescars", column: "idCar", primary_key: "idquotecars", name: "Schedules_idQuoteCar"
end
