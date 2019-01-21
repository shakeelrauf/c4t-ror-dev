
$(document).ready(function() {
    $('#txtVehicleFilter').select2({
        dataType: 'json',
        ajax: {
            // Select2 error handling
            transport: function (params, success, failure) {
              var $request = $.ajax('/vehicles-select2', {
                data: params.data,
              });
              $request.then(function(data, textStatus, jqXHR) {
                // We have redirected to the login page
                if (jqXHR.responseText.trim().startsWith('<!DOCTYPE html>')) {
                  alert("Session timed out.");
                  document.location = "/login?redirect=" + document.location;
                }
                success(data);
              });
              $request.fail(function(jqXHR, textStatus, error) {
                // Interruption in the middle of a request, ignore
                if (textStatus != 'abort') {
                  alert(error + " please contact a system administrator");
                }
              });
              return $request;
            }
        },
    });

    $('#txtVehicleFilter').on('select2:select', function (e) {
      $.ajax("/vehicles/" + $("#txtVehicleFilter option:selected:last").val() + "/json").done(function(veh) {
        $.ajax({method: "POST", url: "/car-create",
               data: { "quote": quoteNo,
                       "veh": veh.idVehiculeInfo}}).done(function(car) {
            $.ajax("/render-vehicle-parameters?vehicle=" + veh.idVehiculeInfo + "&car=" + car.idQuoteCars).done(function(html) {

                $(".vehicle-parameters .tab-pane, .tab-details .nav-item .nav-link").removeClass("active");
                $(".vehicle-parameters").append(html);
                $(".tab-details").append(`
                <li id="car-tab` + car.idQuoteCars + `" class="nav-item car"` + car.idQuoteCars + ` veh-`+ veh.idVehiculeInfo + `" style="display:block">
                    <a class="nav-link active" data-toggle="tab" href="#tab` + car.idQuoteCars + `" role="tab">
                        <button onclick="removeCar(` + car.idQuoteCars + `);">x</button>
                        ` + veh.make + " " + veh.year + `
                    </a>
                    <div class="slide"></div>
                </li>`);
                $(".map").on("click", function () {
                    var $this  = $(this),
                        id = $this.data("id");
                    $("#modalMap").attr("data-id", id).modal("toggle");
                })
                $(".cars-total-list").append(`
                    <div id="car-price`+ car.idQuoteCars + `" class="row car` + veh.idVehiculeInfo + ` index` + car.idQuoteCars + `">
                        <div class="col-lg-6">
                            ` + veh.make + " " + veh.model + " " + veh.year + `
                        </div>
                        <div id="car-price-pickup-` + car.idQuoteCars + `" class="col-lg-3 text-right car-price-pickup" style="display: inline-flex;padding: 0 5px;">
                          missing info
                        </div>
                        <div id="car-price-dropoff-` + car.idQuoteCars + `" class="col-lg-3 text-right car-price-dropoff" style="display: inline-flex;padding: 0 5px;">
                          missing info
                        </div>
                    </div>`);
                $("input[name=allPickup]:checked").prop("checked", false);
                // sumTotal();
                calcPrice(car.idQuoteCars,car.idQuote);
                $('#txtVehicleFilter').html("");
                $("#car-location" + car.idQuoteCars).val($(".hiddenaddress").data("customeraddress"))
                $(".selectcashcar .select2-selection__rendered").html("");
                // Make the car postal selecter a select2
                // createPostalSelect2($("#car-location" + car.idQuoteCars));
            });
        });
      });
    });

    $("select[name=phone]").select2({
        tags: true,
        createTag: function (params) {
            var phone = unformatPhone(params.term);
            //Validate phone number.
            if(phone.length < 10) {
                return null;
            }
            return {
                id: null,
                text: phone,
                newTag: true
            }
        },
        dataType: 'json',
        ajax: {
            url: '/phone-numbers-select2',
            data: function (params) {
                var query = {
                    search: unformatPhone(params.term||""),
                    offset: params.page||0,
                    limit: 10
                }
                return query;
            }
        }
    });

    $("select[name=phone]").on('select2:select', function (e) {
        var clientId = $("select[name=phone] option:selected").val();
        $.ajax("/customers/id/" + clientId + "/json").done(client => {
            fillCustomer(client);
        })
        .fail(function(jqXHR, textStatus, errorThrown) {
          alert(textStatus);
        });
    });

    $(".btn-edit-customer").click(function() {
        var clientId = $("select[name=phone]").val();
        if(clientId == null) {
            window.open("/customers/new?firstName="+$("input[name=firstName]").val()+
            "&lastName="+$("input[name=lastName]").val()+
            "&postal="+$("input[name=postal]").val()+
            "&heardOfUs="+$("select[name=heardOfUs]").val(), "_blank");
        } else {
            window.open("/customers/"+clientId+"/edit?firstName="+$("input[name=firstName]").val()+
            "&lastName="+$("input[name=lastName]").val()+
            "&postal="+$("input[name=postal]").val()+
            "&heardOfUs="+$("select[name=heardOfUs]").val(), "_blank");
        }
    });

    $(".car-location-select2").each(function(index) {
      createPostalSelect2($(this));
    });

    // Select the first tab, if there's one
    $('#tab-a-0') ? $('#tab-a-0').tab('show'): null;

    calcPrices();
});
function createPostalSelect2(s) {
  var clientId = $("select[name=phone] option:selected").val();
  if (!clientId) {
    // There's no client selected, make a "no results" client
    clientId = 0;
  }
  var carId = s.prop('id').substring("car-location".length, s.prop('id').length);
  s.select2({
      tags: true,
      createTag: function (params) {
        var postal = params.term.trim().replace(/\s/g, '');
        if(postal.length != 6) {
            $("input[name=car-postal" + carId +" ]").val(postal)
            return null;
        }
        // Get the distance to this postal code
        getDistanceForCar(postal, carId, function(distance, carId) {
          $("#car-distance" + carId).val(distance);
          updateCarWithDistance(distance, carId);
          // sumTotal();

          // Show the new address sub-form
          showCarNewAddress(postal, carId);
        });

        return {
            id: postal,
            text: postal,
            newTag: true
        }
      },
      dataType: 'json',
      ajax: {
          url: '/customers/' + clientId + '/postal-select2',
          data: function (params) {
              var query = {
                  search: params.term,
                  offset: params.page||0,
                  limit: 10
              }
              return query;
          }
      }
  });

  s.on('select2:select', function (e) {
    var addressId = $(this).val();
    if (!isNaN(parseInt(addressId))) {
      // It's an int (addressid)
      getDistanceForAddress(addressId, carId, function(distance, carId) {
        updateCarWithDistance(distance, carId);
        // sumTotal();
        showCarExistingAddress(addressId, carId);
      });
    } else {
      // A postal was filled up
      var postal = addressId;
      getDistanceForCar(postal, carId, function(distance, carId) {
        updateCarWithDistance(distance, carId);
        // sumTotal();
        // Here the addressId is a postal code
        showCarNewAddress(postal, carId);
      });
    }
  });
}

function updateCarWithDistance(distance, carId) {
  // The price structure
  var price = $("#tab"+carId).data('price');
  $("#car-distance" + carId).val(distance);
  // $("#distance" + carId).html(distance);    // The display as well

  // The excess
  // price.excessDistance = 0;
  // if (!isNaN(price.freeDistance) && (distance > parseInt(price.freeDistance))) {
  //   price.excessDistance = distance - price.freeDistance
  //   $("#excessDistance" + carId).html(price.excessDistance);    // The display as well
  // }

  // The excess cost
  // price.excessCost = parseFloat($("#excessCost" + carId).html());
  // if (!isNaN(price.excessCost)) {
  //   $("#distanceCost" + carId).html((price.excessCost * price.excessDistance).toFixed(2));
  // }

  // The net price
  calcPrice(carId);
}

function showCarExistingAddress(addressId, carId) {
  $.ajax({method: "GET", url: "/address/" + addressId + "/json"}).done(function(address) {
    address = JSON.parse(address);
    $("input[name=car-street" + carId + "]").val(address.address)
    $("input[name=car-city" + carId + "]").val(address.city)
    $("#car-province" + carId).val(address.province); // Doesn't work by name
    $("input[name=car-postal" + carId + "]").val(address.postal)
    $(".car-ex-address" + carId).each(function() {
      $(this).show();
    });
  });
}

function showCarNewAddress(postal, carId) {
  $(".car-ex-address" + carId).each(function() {
    $(this).show();
    $("input[name=car-postal" + carId +" ]").val(postal)
  });
}

function removeCar(quoteCarId) {
  $.ajax({method: "POST", url: "/car-remove", data: { "car": quoteCarId }}).done(function(car) {
    $("#tab" + quoteCarId).remove();
    $("#car-price" + quoteCarId).remove();
    $("#car-tab" + quoteCarId).remove();
    sumTotal();
  });
}

function calcPrice(carId,quote_id) {
    var t = $("#tab" + carId);
    if( quote_id == undefined){
        quote_id = $("#quote").data("id");
    }
    // Get the distance from the input field
    var distance = $("#car-distance" + carId).val();
    if (isNaN(parseInt(distance))) {
        distance = 0;
    }

    var missingCat = "";
    if (missingCatVal && missingCatVal != "") {
        missingCat = (missingCatVal == "1") ? 1 : 0;
    }

    var missingCatVal = $("#tab" + carId + " input[name=cat"+carId+"]:checked").val();
    var missingCat = "";
    if (missingCatVal && missingCatVal != "") {
        missingCat = (missingCatVal == "1") ? 1 : 0;
    }
    var missingBatVal = $("#tab" + carId + " input[name=bat"+carId+"]:checked").val();
    var missingBat = "";
    if (missingBatVal && missingBatVal != "") {
        missingBat = (missingBatVal == "1") ? 1 : 0;
    }
    var missingStilVal = $("#tab" + carId + " input[name=still_driving"+carId+"]:checked").val();
    var missingStil = "";
    if (missingStilVal && missingStilVal != "") {
        missingStil = (missingStilVal == "1") ? 1 : 0;
    }
    // Car price data
    var data = {
        "car":            carId,
        "quoteId":        quote_id,
        "weight":         (t.attr("data-weight")),
        "missingWheels":  (t.find("input[name=wheels"+carId+"]").val()),
        "missingBattery": missingBat,
        "missingCat":     missingCat,
        "still_driving":  missingStil,
        "gettingMethod":  (t.find("input[name=pickup"+carId+"]").prop("checked") ? "pickup" : "dropoff"),
        "distance":       distance
    }
    $.ajax({
        method: "POST",
        url: "/car-price",
        data: data
    }).done(function(json) {
        if (json.trim && json.trim().startsWith("<!DOCTYPE html>")) {
            document.location = "/login?redirect=" + document.location;
        } else if (json.netPrice != null) {
            $("#tab"+carId).data('price', json);

            // Pricing details
            $("#weight"+carId).html(json.weight);
            $("#steelPrice"+carId).html(json.steelPrice);
            $("#weightPrice"+carId).html(json.weightPrice);
            $("#excessCost"+carId).html(json.excessCost);
            $("#distanceCost"+carId).html(json.distanceCost);
            $("#distance"+carId).html(json.distance);
            $("#freeDistance"+carId).html(parseInt(json.freeDistance));
            $("#excessDistance"+carId).html(parseInt(json.excessDistance));
            $("#excessCost"+carId).html(json.excessCost);
            $("#distanceCost"+carId).html(json.distanceCost);

            $("#missingCatCost"+carId).html(json.missingCatCost);
            $("#missingBatCost"+carId).html(json.missingBatCost);
            $("#missingCat"+carId).html(json.missingCat);
            $("#missingBat"+carId).html(json.missingBat);

            $("#missingWheelsCost"+carId).html(json.missingWheelsCost);
            $("#missingWheels"+carId).html(json.missingWheels);

            $("#pickupCost"+carId).html(json.pickupCost);
            // $("#pickup"+carId).html(json.pickup);

            $("#carPrice"+carId).html(json.carPrice);

            sumTotal();
        }
    });
}

function calcPrice(carId) {
    var t = $("#tab" + carId);
    quote_id = $("#quote").data("id");
    // Get the distance from the input field
    var distance = $("#car-distance" + carId).val();
    if (isNaN(parseInt(distance))) {
        distance = 0;
    }

    var missingCat = "";
    if (missingCatVal && missingCatVal != "") {
        missingCat = (missingCatVal == "1") ? 1 : 0;
    }

    var missingCatVal = $("#tab" + carId + " input[name=cat"+carId+"]:checked").val();
    var missingCat = "";
    if (missingCatVal && missingCatVal != "") {
        missingCat = (missingCatVal == "1") ? 1 : 0;
    }
    var missingBatVal = $("#tab" + carId + " input[name=bat"+carId+"]:checked").val();
    var missingBat = "";
    if (missingBatVal && missingBatVal != "") {
        missingBat = (missingBatVal == "1") ? 1 : 0;
    }
    var missingStilVal = $("#tab" + carId + " input[name=still_driving"+carId+"]:checked").val();
    var missingStil = "";
    if (missingStilVal && missingStilVal != "") {
        missingStil = (missingStilVal == "1") ? 1 : 0;
    }
    // Car price data
    var data = {
        "car":            carId,
        "quoteId":        quote_id,
        "weight":         (t.attr("data-weight")),
        "missingWheels":  (t.find("input[name=wheels"+carId+"]").val()),
        "missingBattery": missingBat,
        "missingCat":     missingCat,
        "still_driving":  missingStil,
        "gettingMethod":  (t.find("input[name=pickup"+carId+"]").prop("checked") ? "pickup" : "dropoff"),
        "distance":       distance
    }
    $.ajax({
        method: "POST",
        url: "/car-price",
        data: data
    }).done(function(json) {
        if (json.trim && json.trim().startsWith("<!DOCTYPE html>")) {
            document.location = "/login?redirect=" + document.location;
        } else if (json.netPrice != null) {
            $("#tab"+carId).data('price', json);

            // Pricing details
            $("#weight"+carId).html(json.weight);
            $("#steelPrice"+carId).html(json.steelPrice);
            $("#weightPrice"+carId).html(json.weightPrice);
            $("#excessCost"+carId).html(json.excessCost);
            $("#distanceCost"+carId).html(json.distanceCost);
            $("#distance"+carId).html(json.distance);
            $("#freeDistance"+carId).html(parseInt(json.freeDistance));
            $("#excessDistance"+carId).html(parseInt(json.excessDistance));
            $("#excessCost"+carId).html(json.excessCost);
            $("#distanceCost"+carId).html(json.distanceCost);

            $("#missingCatCost"+carId).html(json.missingCatCost);
            $("#missingBatCost"+carId).html(json.missingBatCost);
            $("#missingCat"+carId).html(json.missingCat);
            $("#missingBat"+carId).html(json.missingBat);

            $("#missingWheelsCost"+carId).html(json.missingWheelsCost);
            $("#missingWheels"+carId).html(json.missingWheels);

            $("#pickupCost"+carId).html(json.pickupCost);
            // $("#pickup"+carId).html(json.pickup);

            $("#carPrice"+carId).html(json.carPrice);

            sumTotal();
        }
    });
}

function unformatPhone(term) {
    term = $.trim(term);
    var phone = "";
    var NumberRegex = /^[0-9]+$/;
    //Separate digit from format.
    for (var digit of term) {
        if(NumberRegex.test(digit)) {
            phone += digit;
        }
    }
    return phone;
}

function calcPrices() {
  // $(".row.tab-content.tab-content-details.vehicle-parameters > .tab-pane").each(function() {
  $(".tab-pane").each(function() {
    if ($(this).hasClass("car-pane")) {
      const carId = $(this).attr("id").substr(3);
      calcPrice(carId);
    }
  });
}

function sumTotal() {
    var totalPrice = 0;
    // $(".row.tab-content.tab-content-details.vehicle-parameters > .tab-pane").each(function() {
    $(".tab-pane").each(function() {
      if ($(this).hasClass("car-pane")) {
        const carId = $(this).attr("id").substr(3);
        const tab = $(this);
        const vehId = $(tab).attr("class").substr($(tab).attr("class").indexOf("veh-")+4).split(" ")[0];

        var d = $("#tab"+carId).data('price');
        if (d && d.netPrice) {
          var netPrice     = d.netPrice;
          var dropoffPrice = d.dropoffPrice;
          var pickupPrice  = d.pickupPrice;

          totalPrice += Math.max(netPrice, 0.0);

          // Update the list price
          $("#car-price-dropoff-" + carId).html(toDollar(dropoffPrice) + " $");
          $("#car-price-pickup-" + carId).html(toDollar(pickupPrice) + " $");

          showTotal();
        }
      }
    });

    function showMissingPrice(carId) {
      $("#car-price-dropoff-" + carId).html("missing info");
      $("#car-price-pickup-" + carId).html("missing info");
      showTotal();
    }

    function showTotal() {
      if(totalPrice < 0) {
          totalPrice = 0;
      }
      $(".totalPriceRounded").text((Math.round(totalPrice / 5) * 5).toFixed(0) + " $");
    }

    showTotal();
}
// SAVE AND BOOK, save the form, navigate to booking
function bookCars(quoteId) {
  saveCar(function() {
    document.location = "/quotes/" + quoteId + "/book";
  });
}

function saveCar(callback) {
    var cars = [];
    $(".card.tab-pane").each(function() {
        var tab = $(this);
        var carId = $(this).prop("id").substr(3);
        var netPrice = null;
        var price = $(this).data('price');
        if (price) {
          netPrice = price.netPrice;
        }
        cars.push({
            "car": carId,
            "weight":         ($(this).attr("data-weight")),
            "missingWheels":  ($(this).find("input[name=wheels"+carId+"]").val()),
            "missingBattery": ($(this).find("input[name=bat"+carId+"]:checked").val() == "1") ? "1" : "0",
            "missingCat":     ($(this).find("input[name=cat"+carId+"]:checked").val() == "1") ? "1" : "0",
            "gettingMethod":  ($(this).find("input[name=pickup"+carId+"]").prop("checked") ? "pickup" : "dropoff"),
            "carAddressId":   ($(this).find("select[name=car-location"+carId+"] option:selected").val()),
            "carStreet":      ($(this).find("input[name=car-street"+carId+"]").val()),
            "carCity":        ($(this).find("input[name=car-city"+carId+"]").val()),
            "carProvince":    ($(this).find("select[name=car-province"+carId+"]").val()),
            "carPostal":      ($(this).find("input[name=car-postal"+carId+"]").val()),
            "distance":       ($(this).find("input[name=car-distance"+carId+"]").val()),
            "price":          netPrice
        });
    });
    $.ajax({
        method: "POST",
        url: "/quote",
        data: {
            "quote": quoteNo,
            "cars": cars,
            "phone": unformatPhone($("select[name=phone] option:selected").text()),
            "firstName": $("input[name=firstName]").val(),
            "lastName": $("input[name=lastName]").val(),
            "heardofus": $("select[name=heardOfUs]").val(),
            "postal": $("input[name=postal]").val(),
            "note": $("#note_").val()
        }
    }).done(function(s) {
      if (callback) {
        callback();
      } else {
          if(s.error){
              doGrowlingDanger(s.error);
          }else{
              doGrowlingMessage("Saved");
          }
      }
    }).catch(function(data) {
        doGrowlingDanger(data.responseJSON.error);
    });
}

function gotoListOfQuotes() {
    if (confirm("Are you sure you want to leave this page? Current quote will be lost.")) {
        document.location = "/quotes";
    }
}

function fillCustomer(data) {
    $("#select2-phone-fi-container.select2-selection__rendered").text(data.phone.substr(0,3) + "-" + data.phone.substr(3,3) + "-" + data.phone.substr(6) + " " + data.firstName + " " + data.lastName);
    $("select[name=phone] option:selected").text(data.phone + " " + data.firstName + " " + data.lastName);
    $("input[name=firstName]").val(data.firstName);
    $("input[name=lastName]").val(data.lastName);
    $(".hiddenaddress").attr("data-customeraddress", data.address.address)
    if (data.has_quote == true) {
      $("select[name=heardOfUs]").val("Repeat Customer");
      $('.has_quote option:eq(1)').prop('selected', true);
      $(".has_quote").attr('disabled',true);
    } else {
      $("select[name=heardOfUs]").val(data.heardofus.type);
    }
    if (data.address.length > 0) {
      $("input[name=postal]").val((data.address[0] && data.address[0].postal) ? data.address[0].postal : "");
    } else {
      $("input[name=postal]").val("");
    }
}