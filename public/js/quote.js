
$(document).ready(function() {
    var new_data = false;
    $('#txtVehicleFilter').select2({
        dataType: 'json',
        ajax: {
            // Select2 error handling
            transport: function (params, success, failure) {
              var $request = $.ajax('/quotes/vehicle_search', {
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
      $.ajax("/vehicles/" + $("#txtVehicleFilter option:selected:last").val()).done(function(veh) {
        $.ajax({method: "POST", url: "/quotes/"+ quoteNo+"/create_car",
               data: { "quote": quoteNo,
                       "veh": veh.idVehiculeInfo}}).done(function(car) {
            $.ajax("/vehicles/"+veh.idVehiculeInfo+"/partial?vehicle=" + veh.idVehiculeInfo + "&car=" + car.idQuoteCars).done(function(html) {

                $(".vehicle-parameters .tab-pane, .tab-details .nav-item .nav-link").removeClass("active");
                $(".vehicle-parameters").append(html);
                // $(".car-location-select2").each(function(index) {
                    createPostalSelect2($("#car-location"+car.idQuoteCars));
                // });
                if(new_data==true){
                    var address = {id: 'new', text: $("input[name=postal]").val()}
                    if(address.text != "") {
                        if (address.text.trim().replace(/\s/g, '').length == 6){
                            $("#car-location" + car.idQuoteCars).append("<option data-select2-tag='true' value=" + address.id + " selected>" + address.text + "</option>");
                            $("#car-location" + car.idQuoteCars).data('select2').trigger('select', {
                                data: {id: address.id, text: address.text}
                            });
                            $("#car-location" + car.idQuoteCars).val(address.id)
                            getDistanceForCar(address.text, car.idQuoteCars, function (distance, carId) {
                                $("#car-distance" + carId).val(distance);
                                updateCarWithDistance(distance, car.idQuoteCars);
                                showCarNewAddress(address.text, carId);
                            });
                        }
                    }
                }
                if(($("select[name=phone]").select2('data')[0] != undefined) && Number.isInteger(Number($("select[name=phone]").select2('data')[0].id)) && $(".hiddenaddress").html().trim().length > 0){
                    var addresses = JSON.parse($(".hiddenaddress").html());
                    if(addresses.length >= 1){
                        var address = addresses[0];
                        var text = " ";
                        if(address.address != undefined && address.address != "" ){
                            text += address.address+", "
                        }
                        if(address.city != undefined && address.city != "" ){
                            text += address.city+", "
                        }
                        if(address.province != undefined && address.province != "" ){
                            text += address.province+", "
                        }
                        if(address.postal != undefined && address.postal != "" ){
                            text += address.postal
                        }
                        $("#car-location"+car.idQuoteCars).append("<option data-select2-tag='true' value="+address.idAddress+" selected>"+text+"</option>");
                        $("#car-location"+car.idQuoteCars).data('select2').trigger('select', {
                            data:  {id: address.idAddress, text: address.address+", "+address.city + ", "+address.province + ", " +address.postal }
                        });
                        $("#car-location"+car.idQuoteCars).val(address.idAddress)
                        getDistanceForCar(address.postal, car.idQuoteCars, function(distance, carId) {
                            $("#car-distance" + carId).val(distance);
                            updateCarWithDistance(distance, car.idQuoteCars);
                            // showCarExistingAddress(address.idAddress, carId)
                        });
                    }
                }
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
                callModal();
                $(".selectcashcar .select2-selection__rendered").html("");
                // Make the car postal selecter a select2
                // createPostalSelect2($("#car-location" + car.idQuoteCars));
            });
        });
      });
    });
    function updatePhoneNumber(f) {
        var v = f;
        if (v.length == 0)
            return;
        if (v.length >= 10) {
            v = v.substring(0, 3) + "-"+ v.substring(3, 6) + "-" + v.substring(6, 10)
        }
        return v;
    }

    $("select[name=phone]").select2({
        tags: true,
        createTag: function(params) {

            var phone = unformatPhone(params.term)
            return null
        },
        dataType: 'json',
        ajax: {
            url: '/quotes/phone_numbers',
            data: function (params) {
                var query = {
                    search: unformatPhone(params.term||""),
                    offset: params.page||0,
                    limit: 10
                }
                return query;
            },
            processResults: function(data, params) {
                if(params.term){
                    var found = false;
                    var phone = unformatPhone(params.term)
                    if(phone.length == 10) {
                        tag = {
                            id: "new" + Math.floor(Math.random() * 1000000000),
                            text: updatePhoneNumber(phone) + " New Customer",
                        }
                        data.results.forEach(function (no) {
                            if (parseInt(no.text.replace(/-/g,'')) == parseInt(phone)) {
                                found = true;
                            } else {
                                $("#new_customer").val(false)
                                new_data = false;
                                resetCustomer()
                            }
                        });
                        if (!found) {
                            new_data = true;
                            $("#new_customer").val(true)
                            data.results.push(tag)
                            resetCustomer()
                        }
                        return {
                            results: data.results,
                            pagination:  data.pagination

                        }
                    }else{
                        $("#new_customer").val(false)
                        new_data = false;

                        return {
                            results: data.results,
                            pagination:  data.pagination
                        }
                    }
                }else{
                    $("#new_customer").val(false)
                    new_data = false;
                    return {

                        results: data.results,
                        pagination:  data.pagination
                    }
                }
            }
        }
    });

    function dup_select_val_remove(){
      $("select").each(function(){
          var usedNames = {};
          $("option", this).each(function () {
              if(usedNames[this.text]) {
                  $(this).remove();
              } else {
                  usedNames[this.text] = this.value;
              }
          });
       }); 
    }


    $("select[name=phone]").on('select2:select', function (e) {
      if($(".selection").text().trim().includes("New Customer")){
        // $("select[name=customerType]").val("Individual");
        $('select[name=phoneType]').prepend("<option>Select an option</option>");
        $('select[name=phoneType] option:eq(0)').prop('selected', true);
        dup_select_val_remove();
      }
        $("#new_customer_id").val("false");
        var clientId = $("select[name=phone]").select2('data')[0].id;
        if(Number.isInteger(Number(clientId))){
            $.ajax("/customers/id/" + clientId + "/json").done(client => {
                fillCustomer(client);
            })
            .fail(function(jqXHR, textStatus, errorThrown) {
              alert(textStatus);
            });
        }
    });

    $(".btn-edit-customer").click(function() {
        var clientId = Number($("select[name=phone]").val());
        if(clientId == 0 || clientId == null) {
            window.open("/customers/new?firstName="+$("input[name=firstName]").val()+
            "&lastName="+$("input[name=lastName]").val()+
            "&postal="+$("input[name=postal]").val()+
            "&heardOfUs="+$("select[name=heardOfUs]").val(), "_blank");
        } else if (!isNaN(clientId)) {
            window.open("/customers/"+clientId+"/edit?firstName="+$("input[name=firstName]").val()+
            "&lastName="+$("input[name=lastName]").val()+
            "&postal="+$("input[name=postal]").val()+
            "&heardOfUs="+$("select[name=heardOfUs]").val(), "_blank");
        }
        else if ($("#new_customer_id").val() != "false"){
          window.open("/customers/"+$("#new_customer_id").val()+"/edit?firstName="+$("input[name=firstName]").val()+
            "&lastName="+$("input[name=lastName]").val()+
            "&postal="+$("input[name=postal]").val()+
            "&heardOfUs="+$("select[name=heardOfUs]").val(), "_blank");
        }
        else{
          edit_for_new_customer();
        }
    });

    function edit_for_new_customer(){
      var number = $(".selection").text().trim().split(" ")[0];
      $.ajax({
          method: "get",
          url: "/number_exist",
          data: { phone: $(".selection").text().trim().split(" ")[0] },
          dataType: "json",
          async: false,
          success: function(res){
            if(res.client_id == null){
              window.open("/customers/new?firstName="+$("input[name=firstName]").val()+
              "&lastName="+$("input[name=lastName]").val()+
              "&postal="+$("input[name=postal]").val()+
              "&heardOfUs="+$("select[name=heardOfUs]").val(), "_blank");
            }
            else{
              window.open("/customers/"+res.client_id.idClient+"/edit?firstName="+$("input[name=firstName]").val()+
              "&lastName="+$("input[name=lastName]").val()+
              "&postal="+$("input[name=postal]").val()+
              "&heardOfUs="+$("select[name=heardOfUs]").val(), "_blank");
            }
          }
      });
    }

    $(".car-location-select2").each(function(index) {
      createPostalSelect2($(this));
    });

    // Select the first tab, if there's one
    $('#tab-a-0') ? $('#tab-a-0').tab('show'): null;

    calcPrices();
});
function customerUrl(){
    var clientId = $("select[name=phone]").select2('data')[0];
    if (!clientId) {
        // There's no client selected, make a "no results" client
        clientId = 0;
    }else{
        clientId = clientId.id
    }
    var  url = '/customers/' + clientId + '/postal-select2'
    return url
}
function createPostalSelect2(s) {
  var clientId = $("select[name=phone]").select2('data')[0];
  if (!clientId) {
    // There's no client selected, make a "no results" client
    clientId = 0;
  }else{
    clientId = clientId.id
  }
  var carId = s.prop('id').substring("car-location".length, s.prop('id').length);
  s.select2({
      tags: true,
      createTag: function (params) {
        var postal = params.term.trim().replace(/\s/g, '');
        if(postal.length != 6) {
            $("input[name=car-postal" + carId +" ]").text(postal)
            return null;
        }
        getDistanceForCar(postal, carId, function(distance, carId) {
          $("#car-distance" + carId).val(distance);
          updateCarWithDistance(distance, carId);
          resetAddress(carId)
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
          url: customerUrl(),
          data: function (params) {
              var query = {
                  search: params.term,
                  offset: params.page||0,
                  limit: 10
              }
              return query;
          }
      },
      // processResults: function(data, params) {
      //     var postal = params.term.trim().replace(/\s/g, '');
      //     if(postal.length == 6) {
      //         tag = {
      //             id: postal,
      //             text: postal
      //         }
      //         data.results.push(tag)
      //     }
      //     return {
      //         results: data.results,
      //         pagination:  data.pagination
      //
      //     }
      // }
    })


    s.on("select2:open", function (e) { console.log("select2:open");
    });
    s.on("select2:close", function (e) { console.log("select2:close"); });
    s.on("select2:select", function (e) {
        console.log("select")
        var addressId = $(this).val();
        if (!isNaN(parseInt(addressId))) {
            getDistanceForAddress(addressId, carId, function(distance, carId) {
                updateCarWithDistance(distance, carId);
                hideCarExistingAddress(addressId, carId)
                showCarExistingAddress(addressId, carId);
            });
        } else {
            var postal = addressId;
            getDistanceForCar(postal, carId, function(distance, carId) {
                updateCarWithDistance(distance, carId);
                resetAddress(carId)
                showCarNewAddress(postal, carId);
            });
        }
        calcPrice(carId)
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
    try{
      address = JSON.parse(address);
    }catch(e){
      address =  address
    }

    $("input[name=car-street" + carId + "]").val(address.address)
    $("input[name=car-city" + carId + "]").val(address.city)
    $("#car-province" + carId).val(address.province); // Doesn't work by name
    $("input[name=car-postal" + carId + "]").val(address.postal)
    // $(".car-ex-address" + carId).each(function() {
    //   $(this).show();
    // });
  });
}

function hideCarExistingAddress(addressId, carId){
    $(".car-ex-address" + carId).each(function() {
      $(this).hide();
    })
}
function showCarNewAddress(postal, carId) {
    $(".car-ex-address" + carId).each(function() {
        $(this).show();
        $("input[name=car-postal" + carId +" ]").val(postal)
    });
}

function resetAddress(carId) {
    $(".car-ex-address" + carId).each(function() {
        $("input[name=car-city" + carId +" ]").val("")
        $("input[name=car-province" + carId +" ]").val("")
        $("input[name=car-street" + carId +" ]").val("")
        $("input[name=car-postal" + carId +" ]").val(" ")
    });
}

function removeCar(quoteCarId) {
  $.ajax({method: "POST", url: "/quotes/"+quoteCarId+"/remove_car", data: { "car": quoteCarId }}).done(function(car) {
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
    // by weight
    var byWeightVal = $("#tab" + carId + " input[name=cat"+carId+"]:checked").val();
    var byWeight = "";
    if (byWeightVal && byWeightVal != "") {
        byWeight = (byWeightVal == "1") ? 1 : 0;
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
    var newPrice = $("#carNewPrice"+carId).val();
    var data = {
        "car":            carId,
        "quoteId":        quote_id,
        "weight":         (t.attr("data-weight")),
        "missingWheels":  (t.find("input[name=wheels"+carId+"]").val()),
        "missingBattery": missingBat,
        "missingCat":     missingCat,
        "byWeight":       byWeight,
        "new_price":      newPrice,
        "still_driving":  missingStil,
        "gettingMethod":  (t.find("input[name=pickup"+carId+"]").prop("checked") ? "pickup" : "dropoff"),
        "distance":       distance
    }
    $.ajax({
        method: "POST",
        url: "/quotes/car_price",
        data: data
    }).done(function(json) {
        if (json.trim && json.trim().startsWith("<!DOCTYPE html>")) {
            document.location = "/login?redirect=" + document.location;
        } else if (json.netPrice != null) {
            $("#tab"+carId).data('price', json);

            // Pricing details
            $("#weight"+carId).html(json.weight);
            $("#carNewPrice"+carId).val(json.car_new_price);
            $("#increase_in_price"+carId).html(json.increase_in_price);

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
function onWeightChange(carId){
    var weight = $('#weight'+carId)
    if(parseFloat(weight.val()) > 0 ){
        var t = $("tab"+carId);
        t.attr("data-weight", parseFloat(weight.val()))
        var t = $("#tab" + carId);
        quote_id = $("#quote").data("id"),
            customer_id = $("#customer").data("id");

        // Get the distance from the input field
        var distance = $("#car-distance" + carId).val();
        if (isNaN(parseInt(distance))) {
            distance = 0;
        }
        // by weight

        var byWeightVal = $("#tab" + carId + " input[name=byweight"+carId+"]:checked").val();
        var byWeight = "";
        if (byWeightVal && byWeightVal != "") {
            if(byWeightVal == "1"){
                if(t.attr("data-weightold") == undefined){
                    t.attr("data-weightold",t.attr("data-weight") );
                }
                t.attr("data-weight", parseFloat(weight.val())* 1000)
                byWeight = 1
            }else{
                t.attr("data-weight",t.attr("data-weightold") );
                byWeight=0
            }
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
        var newPrice = $("#carNewPrice"+carId).val();
        debugger
        // Car price data
        var data = {
            "car":            carId,
            "customer_id":    customer_id,
            "quoteId":        quote_id,
            "weight":         (t.attr("data-weight")),
            "missingWheels":  (t.find("input[name=wheels"+carId+"]").val()),
            "missingBattery": missingBat,
            "byWeight":       byWeight,
            "missingCat":     missingCat,
            "new_price":      newPrice,
            "still_driving":  missingStil,
            "gettingMethod":  (t.find("input[name=pickup"+carId+"]").prop("checked") ? "pickup" : "dropoff"),
            "distance":       distance
        }
        $.ajax({
            method: "POST",
            url: "/quotes/car_price",
            data: data
        }).done(function(json) {
            if (json.trim && json.trim().startsWith("<!DOCTYPE html>")) {
                document.location = "/login?redirect=" + document.location;
            } else if (json.netPrice != null) {
                if(json.bonus!=undefined){
                    // if(json.bonus[0]=="custom"){
                    //
                    //     $("#flatfee"+carId).html(" ")
                    //     $("#bonuscar"+carId).html(" ")
                    //     $("#bonussteel"+carId).html(" ")
                    //     $("#customFee"+carId).html("Applied")
                    //     $("#bonus"+carId).html(json.bonus[1])
                    // }


                    if(json.bonus.bonus.type =="carprice"){
                        $("#bonuscar"+carId).html("Applied")
                        $("#cusflatfee"+carId).html(" ")
                        $("#flatfee"+carId).html(" ")
                        $("#bonussteel"+carId).html(" ")
                        $("#customFee"+carId).html(" ")
                        $("#bonus"+carId).html(json.bonus.bonus.value)
                    }
                    if(json.bonus.bonus.type=="steelprice"){
                        $("#cusflatfee"+carId).html(" ")
                        $("#customFee"+carId).html(" ")
                        $("#bonuscar"+carId).html(" ")
                        $("#bonussteel"+carId).html("Applied")
                        $("#bonus"+carId).html(json.bonus.bonus.value)
                    }
                    if(json.bonus.bonus.type == "no"){
                        $("#bonuscar"+carId).html(" ")
                        $("#bonussteel"+carId).html(" ")

                    }
                    if(json.bonus.user_flat_fee== true){
                        $("#cusflatfee"+carId).html(json.doorPrice)
                        if(json.bonus.bonus.type == "flatfee"){
                            $("#flatfee"+carId).html("Applied")
                            $("#bonuscar"+carId).html(" ")
                            $("#bonussteel"+carId).html(" ")
                            $("#customFee"+carId).html(" ")
                            $("#bonus"+carId).html(json.bonus.bonus.value)

                        }
                    }else{
                        $("#cusflatfee"+carId).html(" ")
                        $("#flatfee"+carId).html(" ")
                        $("#bonus"+carId).html(" ")
                    }
                }
                $("#tab"+carId).data('price', json);
                // Pricing details
                if(byWeight == 1){
                    $("#weight"+carId).val(json.weight);
                }else{
                    $("#weight"+carId).html(json.weight);
                }

                $("#carNewPrice"+carId).html(json.car_new_price);
                $("#increase_in_price"+carId).html(json.increase_in_price);

                $("#steelPrice"+carId).html(json.steelPrice);
                $("#weightPrice"+carId).html(json.weightPrice);
                $("#excessCost"+carId).html(json.excessCost);
                $("#distanceCost"+carId).html(json.distanceCost);
                $("#distance"+carId).html(json.distance);
                $("#freeDistance"+carId).html(parseInt(json.freeDistance));
                $("#excessDistance"+carId).html(parseInt(json.excessDistance));
                $("#excessCost"+carId).html(json.excessCost);
                $("#distanceCost"+carId).html(json.distanceCost);
                $("#carNewPrice"+carId).val(json.car_new_price);

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
}


function calcPrice(carId) {
    var t = $("#tab" + carId);
    quote_id = $("#quote").data("id"),
        customer_id = $("#customer").data("id");

    // Get the distance from the input field
    var distance = $("#car-distance" + carId).val();
    if (isNaN(parseInt(distance))) {
        distance = 0;
    }
    // by weight

    var byWeightVal = $("#tab" + carId + " input[name=byweight"+carId+"]:checked").val();
    var byWeight = "";
    if (byWeightVal && byWeightVal != "") {
        if(byWeightVal == "1"){
            $(".wheels"+carId).hide()

            $(".cat"+carId).hide()
            $(".bat"+carId).hide()
            $("#weight-wrapper-dv").css({"padding-right": "0px","padding-left": "0px"});
            var input =   "<input type='number' step='0.1' onchange='onWeightChange("+carId+")' name='weight"+carId+"' id='weight"+carId+"' style='width: 100%;text-align: right;'>"
            $("#weight"+carId).replaceWith(input)
            // $("input[name=cat"+carId+"]").val(0)
            // $("input[name=bat"+carId+"]").val(0)
            $("input[name=wheels"+carId+"]").val(0)
            $("input[name=cat"+carId+"]").prop('checked',false)
            $("input[name=bat"+carId+"]").prop('checked',false)

            byWeight = 1
        }else{
            $("#weight-wrapper-dv").css({"padding-right": "14px","padding-left": "0px"});
            var div = "<div class='n' id='weight"+carId+"'></div>"

            t.attr("data-weight",t.attr("data-weightold") );
            $(".wheels"+carId).show()
            $(".cat"+carId).show()
            $(".bat"+carId).show()
            $("#weight"+carId).replaceWith(div)
            $("#weight"+carId).html("");
            $("#steelPrice"+carId).html(" ");
            $("#weightPrice"+carId).html(" ");
            $("#excessCost"+carId).html(" ");
            $("#distanceCost"+carId).html(" ");
            $("#distance"+carId).html(" ");
            $("#freeDistance"+carId).html(" ");
            $("#excessDistance"+carId).html(" ");
            $("#excessCost"+carId).html(" ");
            $("#distanceCost"+carId).html("");

            $("#carNewPrice"+carId).html("");
            $("#increase_in_price"+carId).html("");

            $("#tab"+carId).data('price', {});

            $("#missingCatCost"+carId).html(" ");
            $("#missingBatCost"+carId).html(" ");
            $("#missingCat"+carId).html("");
            $("#missingBat"+carId).html(" ");

            $("#flatfee"+carId).html(" ")
            $("#bonuscar"+carId).html(" ")
            $("#bonussteel"+carId).html(" ")
            $("#customFee"+carId).html(" ")
            $("#bonus"+carId).html(" ")
            $("#missingWheelsCost"+carId).html(" ");
            $("#missingWheels"+carId).html(" ");

            $("#pickupCost"+carId).html(" ");
            // $("#pickup"+carId).html(json.pickup);

            $("#carPrice"+carId).html(" ");
            sumTotal();
            byWeight=0
        }
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
    var newPrice = $("#carNewPrice"+carId).val();
    // Car price data
    var data = {
        "car":            carId,
        "customer_id":    customer_id,
        "quoteId":        quote_id,
        "missingWheels":  (t.find("input[name=wheels"+carId+"]").val()),
        "missingBattery": missingBat,
        "byWeight":       byWeight,
        "missingCat":     missingCat,
        "still_driving":  missingStil,
        "new_price":      newPrice,
        "gettingMethod":  (t.find("input[name=pickup"+carId+"]").prop("checked") ? "pickup" : "dropoff"),
        "distance":       distance
    }
    if(byWeight == 1){
        data["weight"] = t.attr("data-byweight")
    }else{
        data["weight"] = t.attr("data-notbyweight")
    }
    $.ajax({
        method: "POST",
        url: "/quotes/car_price",
        data: data
    }).done(function(json) {
        if (json.trim && json.trim().startsWith("<!DOCTYPE html>")) {
            document.location = "/login?redirect=" + document.location;
        } else if (json.netPrice != null) {
            saveCarAuto(function(e) {
                console.log("saved")
            });
            if(json.bonus!=undefined){
                // if(json.bonus[0]=="custom"){
                //
                //     $("#flatfee"+carId).html(" ")
                //     $("#bonuscar"+carId).html(" ")
                //     $("#bonussteel"+carId).html(" ")
                //     $("#customFee"+carId).html("Applied")
                //     $("#bonus"+carId).html(json.bonus[1])
                // }


                if(json.bonus.bonus.type =="carprice"){
                    $("#bonuscar"+carId).html("Applied")
                    $("#cusflatfee"+carId).html(" ")
                    $("#flatfee"+carId).html(" ")
                    $("#bonussteel"+carId).html(" ")
                    $("#customFee"+carId).html(" ")
                    $("#bonus"+carId).html(json.bonus.bonus.value)
                }
                if(json.bonus.bonus.type=="steelprice"){
                    $("#cusflatfee"+carId).html(" ")
                    $("#customFee"+carId).html(" ")
                    $("#bonuscar"+carId).html(" ")
                    $("#bonussteel"+carId).html("Applied")
                    $("#bonus"+carId).html(json.bonus.bonus.value)
                }
                if(json.bonus.bonus.type == "no"){
                    $("#bonuscar"+carId).html(" ")
                    $("#bonussteel"+carId).html(" ")

                }
                if(json.bonus.user_flat_fee== true){
                    $("#cusflatfee"+carId).html(json.doorPrice)
                    if(json.bonus.bonus.type == "flatfee"){
                        $("#flatfee"+carId).html("Applied")
                        $("#bonuscar"+carId).html(" ")
                        $("#bonussteel"+carId).html(" ")
                        $("#customFee"+carId).html(" ")
                        $("#bonus"+carId).html(json.bonus.bonus.value)

                    }
                }else{
                    $("#cusflatfee"+carId).html(" ")
                    $("#flatfee"+carId).html(" ")
                    $("#bonus"+carId).html(" ")
                }
            }
            $("#tab"+carId).data('price', json);
            // Pricing details
            if(byWeight == 1){
                $("#weight"+carId).val(json.weight);
            }else{
                $("#weight"+carId).html(json.weight);
            }
            $("#steelPrice"+carId).html(json.steelPrice);
            $("#weightPrice"+carId).html(json.weightPrice);
            $("#excessCost"+carId).html(json.excessCost);
            $("#distanceCost"+carId).html(json.distanceCost);
            $("#distance"+carId).html(json.distance);
            $("#freeDistance"+carId).html(parseInt(json.freeDistance));
            $("#excessDistance"+carId).html(parseInt(json.excessDistance));
            $("#excessCost"+carId).html(json.excessCost);
            $("#distanceCost"+carId).html(json.distanceCost);

            $("#carNewPrice"+carId).val(json.car_new_price);
            $("#increase_in_price"+carId).html(json.increase_in_price);

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
    // Update the list price
    // $(".row.tab-content.tab-content-details.vehicle-parameters > .tab-pane").each(function() {
    $(".tab-pane").each(function() {
      if ($(this).hasClass("car-pane")) {
        var carId = $(this).attr("id").substr(3);
        var tab = $(this);
        var vehId = $(tab).attr("class").substr($(tab).attr("class").indexOf("veh-")+4).split(" ")[0];

        var d = $("#tab"+carId).data('price');
          if (d && (d.netPrice != undefined)) {
          var netPrice     = d.netPrice;
          var dropoffPrice = d.dropoffPrice;
          var pickupPrice  = d.pickupPrice;

          totalPrice += Math.max(netPrice, 0.0);
          // Update the list price
          $("#car-price-dropoff-" + carId).html(toDollar(dropoffPrice) + " $");
          $("#car-price-pickup-" + carId).html(toDollar(pickupPrice) + " $");

          showTotal();
        }else{

              $("#car-price-dropoff-" + carId).html(0 + " $");
              $("#car-price-pickup-" + carId).html(0 + " $");
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
  saveCar(function(e) {
      if(e.error){
          doGrowlingDanger(e.error)
      }else{
          document.location = "/bookings/" + quoteId + "/quotes";
      }
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
        var carAddressId = "";
        if($(this).find("select[name=car-location"+carId+"] option").length >= 1){
            if($("#car-location"+carId).select2('data') != undefined){
                if(Number.isInteger(Number($(this).find("select[name=car-location"+carId+"]").select2('data')[0].id))){
                    carAddressId = Number($(this).find("select[name=car-location"+carId+"]").select2('data')[0].id)
                }
            }
        }
        var byWeightVal = $("#tab" + carId + " input[name=byweight"+carId+"]:checked").val();
        var byWeight = "";
        if (byWeightVal && byWeightVal != "") {
            if(byWeightVal == "1"){
                byWeight = 1
            }else{
                byWeight = 0
            }
        }
        car = {
            "car": carId,
            "missingWheels":  ($(this).find("input[name=wheels"+carId+"]").val()),
            "missingBattery": ($(this).find("input[name=bat"+carId+"]:checked").val() != undefined) ? $(this).find("input[name=bat"+carId+"]:checked").val() : " ",
            "missingCat":     ($("input[name=cat"+carId+"]:checked").val()),
            "gettingMethod":  ($(this).find("input[name=pickup"+carId+"]").prop("checked") ? "pickup" : "dropoff"),
            "carAddressId":   (carAddressId),
            "byWeight":       byWeight,
            "carStreet":      ($(this).find("input[name=car-street"+carId+"]").val()),
            "still_driving":  ($(this).find("input[name=still_driving"+carId+"]:checked").val() == "1") ? "1" : "",
            "carCity":        ($(this).find("input[name=car-city"+carId+"]").val()),
            "carProvince":    ($(this).find("select[name=car-province"+carId+"]").val()),
            "carPostal":      ($(this).find("input[name=car-postal"+carId+"]").val()),
            "distance":       ($(this).find("input[name=car-distance"+carId+"]").val()),
            "price":          netPrice
        }
        car["still_driving"] = $(this).find("input[name=still_driving"+carId+"]:checked").val()

        if(byWeight == 1){
            car["weight"] = $(this).attr("data-byweight")
        }else{
            car["weight"] = $(this).attr("data-notbyweight")
        }
        cars.push(car);
    });
    $.ajax({
        method: "POST",
        url: "/quotes",
        data: {
            "quote": quoteNo,
            "cars": cars,
            "phone": unformatPhone($("select[name=phone] option:selected").text()),
            "firstName": $("input[name=firstName]").val(),
            "lastName": $("input[name=lastName]").val(),
            "heardofus": $("select[name=heardOfUs]").val(),
            "postal": $("input[name=postal]").val(),
            "phoneType": $("select[name=phoneType]").val(),
            "customerType": $("select[name=customerType]").val(),
            "new_customer": $("#new_customer").val(),
            "new_customer_id": $("#new_customer_id").val(),
            "note": CKEDITOR.instances['note_'].getData()
        }
    }).done(function(s) {
      if($(".selection").text().trim().includes("New Customer")){
        if(s.q != undefined && s.q.idClient != undefined){
          $("#new_customer_id").val(s.q.idClient);
        }
      }
      else{
        $("#new_customer_id").val("false");
      }
        if (callback) {
            callback(s);
        } else {
            if(s.error){
                if(s.car){
                    $("#tab-a-"+s.car).click();
                    doGrowlingDanger(s.error);
                }else{
                    doGrowlingDanger(s.error);
                }
            }else{
                doGrowlingMessage("Saved");
            }
        }
    }).catch(function(data) {
        doGrowlingDanger(data.responseJSON.error);
    });
}
function saveCarAuto(callback) {
    var cars = [];
    $(".card.tab-pane").each(function() {
        var tab = $(this);
        var carId = $(this).prop("id").substr(3);
        var netPrice = null;
        var price = $(this).data('price');
        if (price) {
            netPrice = price.netPrice;
        }
        var carAddressId = "";
        if($(this).find("select[name=car-location"+carId+"] option").length >= 1){
            if($("#car-location"+carId).select2('data') != undefined){
                if(Number.isInteger(Number($(this).find("select[name=car-location"+carId+"]").select2('data')[0].id))){
                    carAddressId = Number($(this).find("select[name=car-location"+carId+"]").select2('data')[0].id)
                }
            }
        }
        var byWeightVal = $("#tab" + carId + " input[name=byweight"+carId+"]:checked").val();
        var byWeight = "";
        if (byWeightVal && byWeightVal != "") {
            if(byWeightVal == "1"){
                byWeight = 1
            }else{
                byWeight = 0
            }
        }
        car = {
            "car": carId,
            "missingWheels":  ($(this).find("input[name=wheels"+carId+"]").val()),
            "missingBattery": ($(this).find("input[name=bat"+carId+"]:checked").val() != undefined) ? $(this).find("input[name=bat"+carId+"]:checked").val() : " ",
            "missingCat":     ($("input[name=cat"+carId+"]:checked").val()),
            "gettingMethod":  ($(this).find("input[name=pickup"+carId+"]").prop("checked") ? "pickup" : "dropoff"),
            "carAddressId":   (carAddressId),
            "byWeight":       byWeight,
            "carStreet":      ($(this).find("input[name=car-street"+carId+"]").val()),
            "still_driving":  ($(this).find("input[name=still_driving"+carId+"]:checked").val() != undefined) ? $(this).find("input[name=still_driving"+carId+"]:checked").val() : "",
            "carCity":        ($(this).find("input[name=car-city"+carId+"]").val()),
            "carProvince":    ($(this).find("select[name=car-province"+carId+"]").val()),
            "carPostal":      ($($(this).find("input[name=car-postal"+carId+"]")).val()),
            "distance":       ($(this).find("input[name=car-distance"+carId+"]").val()),
            "price":          netPrice
        }
        if(byWeight == 1){
            car["weight"] = $(this).attr("data-byweight")
        }else{
            car["weight"] = $(this).attr("data-notbyweight")
        }
        cars.push(car);
    });
    $.ajax({
        method: "POST",
        url: "/quotes_save_without_validations",
        data: {
            "quote": quoteNo,
            "cars": cars,
            "phone": unformatPhone($("select[name=phone] option:selected").text()),
            "firstName": $("input[name=firstName]").val(),
            "lastName": $("input[name=lastName]").val(),
            "heardofus": $("select[name=heardOfUs]").val(),
            "postal": $("input[name=postal]").val(),
            "phoneType": $("select[name=phoneType]").val(),
            "customerType": $("select[name=customerType]").val(),
            "new_customer": $("#new_customer").val(),
            "new_customer_id": $("#new_customer_id").val(),
            "note": CKEDITOR.instances['note_'].getData()
        }
    }).done(function(s) {
        if($(".selection").text().trim().includes("New Customer")){
          if(s != undefined && s.customer_id != undefined){
            $("#new_customer_id").val(s.customer_id);
          }
        }
        else{
          $("#new_customer_id").val("false");
        }
        if (callback) {
            callback(s);
        } else {
            if(s.error){
                if(s.car){
                    $("#tab-a-"+s.car).click();
                    doGrowlingDanger(s.error);
                }else{
                    doGrowlingDanger(s.error);
                }
            }else{
                $("#customer").data("id", s.customer_id)
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

function set_phone_type(data){
  if (data.phone == unformatPhone($("select[name=phone] option:selected").text())){
    $("#cus_phoneType").val("primary");
  }
  else if (data.cellPhone == unformatPhone($("select[name=phone] option:selected").text())){
    $("#cus_phoneType").val("cell");
  }
  else if (data.secondaryPhone == unformatPhone($("select[name=phone] option:selected").text())) {
    $("#cus_phoneType").val("other");
  }
}


function capitalize_Words(str)
{
 return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}
function fillCustomer(data) {
    $(".car-location-select2").each(function(index) {
        $(this).select2('destroy');
        createPostalSelect2($(this));
    });
    $("#customer").data("id", data.idClient)
    $("#select2-phone-fi-container.select2-selection__rendered").text(data.phone.substr(0,3) + "-" + data.phone.substr(3,3) + "-" + data.phone.substr(6) + " " + data.firstName + " " + data.lastName);
    $("input[name=firstName]").val(data.firstName);
    $("input[name=lastName]").val(data.lastName);
    $("#cus_customerType").val(capitalize_Words(data.type));
    $("#cus_customerType").attr('disabled',true);
    set_phone_type(data);
    $("select[name=phoneType]").attr('disabled',true);
    $(".hiddenaddress").html(JSON.stringify(data.address))
    if (data.quotes.length >= 1) {
      $('.has_quote option:eq(1)').prop('selected', true);
      $(".has_quote").attr('disabled',true);
      $("select[name=customerType]").attr('disabled',true);
      $("select[name=phoneType]").attr('disabled',true);
        $("select[name=heardOfUs]").val(data.heardofus.type);
        $("select[name=heardOfUs] option:selected").text("Repeat Customer");
    } else {
      $(".has_quote").attr('disabled',false);
      $("select[name=heardOfUs]").val(data.heardofus.type);
    }
    if (data.address.length > 0) {
      $("input[name=postal]").val((data.address[0] && data.address[0].postal) ? data.address[0].postal : "");
    } else {
      $("input[name=postal]").val("");
    }
}
function resetCustomer(){
    $("input[name=postal]").val("");
    $("input[name=firstName]").val("");
    $("input[name=lastName]").val("");
    $("select[name=customerType]").val("");
    $("select[name=phoneType]").val("");
    $('.has_quote option:eq(1)').prop('selected', false);
    $("select[name=customerType]").attr('disabled',false);
    $("select[name=phoneType]").attr('disabled',false);
    $(".has_quote").attr('disabled',false);

}