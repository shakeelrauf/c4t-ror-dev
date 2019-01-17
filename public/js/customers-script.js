$("#saveCustomerButton").click(function() {

    if(validateFields()) {
        var heardOfUs = $("#txtHeardOfUs").val();
        if($("#txtHeardOfUs").val() == "Other") {
            heardOfUs = $("#txtHow").val();
        }
        var contactsList = [];
        var addressList = [];
        $(".contact-edit-list > .contact-edit").each(function() {
            contactsList.push({
                idContact:$(this).find("input.idContact").val(),
                firstName: $(this).find("input.first-name").val(),
                lastName: $(this).find("input.last-name").val(),
                paymentMethod: $(this).find("select.payment-method").val()
            })
        });

         $(".address-edit-list > .address-edit").each(function() {
          addressList.push({
                idAddress:$(this).find("input.idAddress").val(),
                address: $(this).find("input.txtAddress").val(),
                city: $(this).find("input.txtCity").val(),
                province: $(this).find("select.txtProvince").val(),
                postal:  $(this).find("input.txtPostal").val()
            })
        });

        if($("#saveCustomerButton").data("id-customer") == "new") {

            /////////////////////////////////////////////////////////////////
            //Add user
            /////////////////////////////////////////////////////////////////
            $.ajax({
              url: "/customers",
              type: "POST",
              data: {
                  firstName: $("#txtFirstName").val(),
                  lastName: $("#txtLastName").val(),
                  type: $("#txtType").val(),
                  email: $("#txtEmail").val(),
                  phoneNumber: $("#txtPhone").val(),
                  extension: $("#txtExtension").val(),
                  phoneNumber2: $("#txtCell").val(),
                  phoneNumber3: $("#txtSecondPhone").val(),
                  address: $("#txtAddress").val(),
                  city: $("#txtCity").val(),
                  postal: $("#txtPostal").val(),
                  province: $("#txtProvince").val(),
                  note: $("#txtNote").val(),
                  grade: $("#txtGrade").val(),
                  heardOfUs: heardOfUs,
                  name: $("#txtCompanyName").val(),
                  description: $("#txtDescription").val(),
                  contactPosition: $("#txtContactPosition").val(),
                  pstTaxNo: $("#txtPST").val(),
                  gstTaxNo: $("#txtGST").val(),
                  customDollarCar:$("#txtCustomDollarCar").val(),
                  customPercCar:$("#txtCustomPercCar").val(),
                  customDollarSteel:$("#txtCustomDollarSteel").val(),
                  customPercSteel:$("#txtCustomPercSteel").val(),
                  contacts: contactsList,
                  addresses: addressList
              }
            }).done(function(data) {
                if(data.error) {
                    doGrowlingDanger(data.error);
                } else {
                    document.location = "/customers?added=true";
                }
            });
        } else {

            /////////////////////////////////////////////////////////////////
            //Edit customer
            /////////////////////////////////////////////////////////////////
            $.ajax({
              url: "/customers/edit/" + $("#saveCustomerButton").data("id-customer"),
              type: "POST",
              data: {
                  firstName: $("#txtFirstName").val(),
                  lastName: $("#txtLastName").val(),
                  type: $("#txtType").val(),
                  email: $("#txtEmail").val(),
                  phoneNumber: $("#txtPhone").val(),
                  extension: $("#txtExtension").val(),
                  phoneNumber2: $("#txtCell").val(),
                  phoneNumber3: $("#txtSecondPhone").val(),
                  address: $("#txtAddress").val(),
                  city: $("#txtCity").val(),
                  postal: $("#txtPostal").val(),
                  province: $("#txtProvince").val(),
                  note: $("#txtNote").val(),
                  grade: $("#txtGrade").val(),
                  heardOfUs: heardOfUs,
                  name: $("#txtCompanyName").val(),
                  description: $("#txtDescription").val(),
                  contactPosition: $("#txtContactPosition").val(),
                  pstTaxNo: $("#txtPST").val(),
                  gstTaxNo: $("#txtGST").val(),
                  customDollarCar:$("#txtCustomDollarCar").val(),
                  customPercCar:$("#txtCustomPercCar").val(),
                  customDollarSteel:$("#txtCustomDollarSteel").val(),
                  customPercSteel:$("#txtCustomPercSteel").val(),
                  contacts: contactsList,
                  addresses: addressList
              }
            }).done(function(data) {
                if(data.error) {
                    doGrowlingDanger(data.error);
                } else {
                    document.location = "/customers?added=false";
                }
            });
        }
    }
});

function validateAddress() {
    /*
    var address = $("#txtAddress").val() + " " + $("#txtCity").val() + " " + $("#txtProvince").val();
    $.ajax("https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyCeEevbx8c8wkGMAL1Ywvk6X85K7lU8Pj0&address=" + address).done(r_address => {
        // if(r_address.results.length > 0 && !r_address.results[0].partial_match) {
        if (r_address.results.length > 0) {
            $("#txtAddress").val(r_address.results[0].formatted_address.split(",")[0]);
            $("#txtCity").val(r_address.results[0].formatted_address.split(",")[1].trim());
            var postal = r_address.results[0].formatted_address.split(",")[2].trim().split(" ")[1] +
                         r_address.results[0].formatted_address.split(",")[2].trim().split(" ")[2]
            $("#txtPostal").val(postal.trim());

            var province = r_address.results[0].formatted_address.split(",")[2].trim().split(" ")[0];
            province = province.substr(0,1) + province.substr(1).toLowerCase();
            $("#txtProvince").val(province);

            console.log("=====> Addr:   " + $("#txtAddress").val());
            console.log("=====> City:   " + $("#txtCity").val());
            console.log("=====> Postal: " + $("#txtPostal").val());
            console.log("=====> Prov:   " + $("#txtProvince").val());
        } else {
          growling("Address not found", "danger");
          console.log("=====> r_address:   " + r_address);
        }
    });
    */
}

function validateFields() {
    if( $("#txtPhone").val() == "" ||
        $("#txtFirstName").val() == "") {
            doGrowlingWarning("Please fill all required fields.");
            return false;
    }
    return true;
}

function changeViewType() {
    if($("#txtType").val() != "Individual") {
        $(".company-data").removeClass("force-hidden");
    } else {
        $(".company-data").addClass("force-hidden");
    }
}

function changeViewHowHearUse() {
    if($("#txtHeardOfUs").val() == "Other") {
        $(".inputFieldsHidden").css("height", "");
        $(".inputFieldsHidden").removeClass("hidden");
    } else {
        $(".inputFieldsHidden").css("height", "0px");
        $(".inputFieldsHidden").addClass("hidden");
    }
}

function removeAddress(addressId) {
    if (confirm("Are you sure? We'll verify if there quotes associated with this address first.")) {
      apost({
        url: "/address-remove",
        method: "POST",
        data: {
          addressId: addressId
        }
      }, (json) => {
        if (json.error) {
          doGrowlingDanger(json.error);
        } else {
          doGrowlingDanger(json.message);
          $("#address" + addressId).remove();
        }
      });
    }
}

function createAddress(clientId) {
    apost({
      url: "/address-create",
      method: "POST",
      data: {
        clientId: clientId
      }
    }, (json) => {
      if (json.error) {
        doGrowlingDanger(json.error);
      } else {
        addAddress(json);
      }
    });
}


$(document).ready(function() {
    //Show or hide grade.
    $("#txtGrade").change(function() {
        if($("#txtGrade").val() != "Custom") {
            $(".custom-grade-data").css("height", "0px");
            $(".custom-grade-data").addClass("force-hidden");
        } else {
            $(".custom-grade-data").css("height", "");
            $(".custom-grade-data").removeClass("force-hidden");
        }
    });
});

//Validate postal code.
$("#txtPostal").change(function() {
    //Validate postal code.
    if(!$(this).val()
    .match("^[a-zA-Z]{1}[0-9]{1}[a-zA-Z]{1}(\-| |){1}[0-9]{1}[a-zA-Z]{1}[0-9]{1}$")) {
        $(this).val("");
    } else {
        //Set toUpperCase all letters.
        $(this).val($(this).val().toUpperCase());
    }
});

$("#txtType").change(function() {
    changeViewType();
});

$("#txtHeardOfUs").change(function() {
    changeViewHowHearUse()
});

//On searching quote.
$(".search-bar-client").keyup(function() {
    var filter = $(this).val();
    $(".table-customers").html("");
    $.ajax("/customers/json?filter="+filter)
    .done(function(clients) {
        clients.forEach(function(customer) {
            $(".table-customers").append(`
                <tr>
                    <td>`+ customer.firstName +`</td>
                    <td>`+ customer.lastName +`</td>
                    <td>`+ customer.type +`</td>
                    <td>`+ customer.phone.substring(0, 3) + "-" + customer.phone.substring(3, 6) + "-" + customer.phone.substring(6) +`</td>
                    <td>`+ customer.extension +`</td>
                    <td>`+ customer.heardofus.type +`</td>
                    <td>`+ customer.grade +`</td>
                    <td class="faq-table-btn">
                    `+($(".designation").text().trim() == "admin" || $(".designation").text().trim() == "dispatcher" ?
                        `<a href="/customers/`+ customer.id +`/edit" class="btn btn-primary waves-effect waves-light" data-toggle="tooltip" data-placement="top" title="" data-original-title="Edit">
                            <i class="icofont icofont-ui-edit"></i>
                        </a>` : "")+`
                        <a href="/customers/`+ customer.id +`" class="btn btn-success waves-effect waves-light" data-toggle="tooltip" data-placement="top" title="" data-original-title="View">
                            <i class="icofont icofont-eye-alt"></i>
                        </a>
                    </td>
                </tr>`);
        });
    });
});

//Check if we load all field for editing:
if($("#saveCustomerButton").data("id-customer") != "new") {
    changeViewType();
    changeViewHowHearUse();
}
