function growlOfSuccess(message) {
    $.growl({
        message: message
    },{
        type: "success",
        allow_dismiss: true,
        label: 'Cancel',
        className: 'btn-xs btn-inverse',
        delay: 0,
        placement: {
            from: 'top',
            align: 'center'
        },
        animate: { enter: 'animated fadeInDown' }
    });
}

function growling(message) {
    $.growl({
        message: message
    },{
        type: "danger",
        allow_dismiss: true,
        label: 'Cancel',
        className: 'btn-xs btn-inverse',
        placement: {
            from: 'top',
            align: 'center'
        },
        delay: 0,
        animate: { enter: 'animated fadeInDown' }
    });
}

function removeAddress(addressId) {
    if (confirm("Are you sure?")) {
      if (!addressId.toString().includes("math")){
         $.ajax({
             method: "POST",
             url: "/api/v1/address-remove",
             data: {
                addressId: addressId
             },
             success: function(json){
                 if (json.error) {
                   growling(json.error);
                 } else {
                   growlOfSuccess(json.message);
                   $("#address" + addressId).remove();
                 }
             }
         });
      }
      else {
         $("#" + addressId).remove();
      }
    }
}

function checkContactToRemove(contact){
   var contactLength = contact.length;
   if(contact[contactLength-1].attributes[6].value!=0){
       alert('Contact Can not be deleted');
       return false;
   }else{
       $(contact).closest('.contact-edit').remove();
   }
}


function addContact(contactData) {
   
   $(".contact-edit-list").append(`
       <div class="col-lg-12 row contact-edit">
           <div class="col-lg-4 md-group-add-on">
               <span class="md-add-on">
                   <i class="icofont icofont-ui-user"></i>
               </span>
               <div class="md-input-wrapper">
                   <input type="text" class="md-form-control first-name contact-fn md-static" value="`+(contactData.firstName || "")+`" name="contacts[firstName][]">
                   <input type="hidden" class="md-form-control idContact md-static" value="`+(contactData.id || "")+`">
                   <label>Contact First Name <span class="required">*</span></label>
               </div>
           </div>
           <div class="col-lg-4 md-group-add-on">
               <span class="md-add-on">
                   <i class="icofont icofont-ui-user"></i>
               </span>
               <div class="md-input-wrapper">
                   <input type="text" class="md-form-control last-name contact-ln md-static" value="`+(contactData.lastName || "")+`" name="contacts[lastName][]">
                   <label>Contact Last Name <span class="required">*</span></label>
               </div>
           </div>
           <div class="col-lg-3 md-group-add-on">
               <span class="md-add-on">
                   <i class="icofont icofont-ui-user"></i>
               </span>
               <div class="md-input-wrapper">
                   <select class="md-form-control payment-method md-static selectcash contact-selectcash" name="contacts[paymentMethod][]">
                       <option disabled selected style="display:none"></option>
                       <option`+(contactData.paymentMethod == "By Check" ? " selected" : "")+`>By Check</option>
                       <option`+(contactData.paymentMethod == "Cash" ? " selected" : "")+`>Cash</option>
                       <option`+(contactData.paymentMethod == "Electronic Transfer" ? " selected" : "")+`>Electronic Transfer</option>
                   </select>
                   <label>Contact Prefered Payment Method <span class="required">*</span></label>
               </div>
           </div>
           <div class="col-lg-1 md-group-add-on">                     

           
               <span onclick="checkContactToRemove($(this));" class="btn btn-danger waves-effect waves-light" data-toggle="tooltip" data-placement="top" title="" data-original-title="Remove" value="`+(contactData.id || "")+`">
                   <i class="icofont icofont-ui-remove"></i>
               </span>
           </div>
       </div>`);
}

function rand(){
 return Math.random().toString(36).substring(7)
}

function addCusAddress(address) {
     $(".address-edit-list").append(`
               <div class="col-lg-12 row address-edit" id="mathaddress`+(address.rand)+`" >
                 <div class="col-lg-4 md-group-add-on">
                     <span class="md-add-on">
                         <i class="icofont icofont-address-book"></i>
                     </span>
                     <div class="md-input-wrapper">
                           <input type="text" class="md-form-control txtAddress md-static" id="txtAddress" value="`+(
                             address.address || "")+`" name="addresses[address][]">
                            <input type="hidden" class="md-form-control idAddress md-static" id="txtAddress" value="`+(
                             address.id || "")+`" name="addresses[idAddress][]">
                         <label>Address <span class="required">*</span></label>
                     </div>
                  </div>
 
                 <div class="row">
                     <div class="col-lg-4 md-group-add-on">
                         <span class="md-add-on">
                             <i class="icofont icofont-address-book"></i>
                         </span>
                         <div class="md-input-wrapper">
                              <input type="text" class="md-form-control txtCity md-static" id="txtCity" value="`+(address.city || "")+`" name="addresses[city][]">
                             <label>City <span class="required">*</span></label>
                         </div>
                     </div>
                     <div class="col-lg-4 md-group-add-on">
                         <span class="md-add-on">
                             <i class="icofont icofont-address-book"></i>
                         </span>
                         <div class="md-input-wrapper">
                             <select class="md-form-control province txtProvince md-static selectcash" id="txtProvince" name="addresses[province][]">
                                 <option value="ON"`+(address.province == "ON" ? " selected" : "")+`>Ontario</option>
                                 <option value="BC"`+(address.province == "BC" ? " selected" : "")+`>British Columbia</option>
                                 <option value="QC"`+(address.province == "QC" ? " selected" : "")+`>Quebec</option>
                                 <option value="AL"`+(address.province == "AL" ? " selected" : "")+`>Alberta</option>
                                 <option value="NS"`+(address.province == "NS" ? " selected" : "")+`>Nova Scotia</option>
                                 <option value="NL"`+(address.province == "NL" ? " selected" : "")+`>Newfoundland and Labrador</option>
                                 <option value="SA"`+(address.province == "SA" ? " selected" : "")+`>Saskatchewan</option>
                                 <option value="MA"`+(address.province == "MA" ? " selected" : "")+`>Manitoba</option>
                                 <option value="NB"`+(address.province == "NB" ? " selected" : "")+`>New Brunswick</option>
                                 <option value="PE"`+(address.province == "PE" ? " selected" : "")+`>Prince Edward Island</option>
                             </select>
                             <label>Province <span class="required">*</span></label>
                         </div>
                     </div>
                     <div class="col-lg-3 md-group-add-on">
                         <span class="md-add-on">
                             <i class="icofont icofont-ui-message" onclick="validateAddress()"></i>
                         </span>
                         <div class="md-input-wrapper">
                              <input type="text" class="md-form-control txtPostal md-static" id="txtPostal"
                                    value="` + (address.postal ? (address.postal.substr(0,3) + " " + address.postal.substr(3)) : "") + `" name="addresses[postal][]">
                             <label>Postal Code <span class="required">*</span></label>
                         </div>
                     </div>
 
                     <div class="col-lg-1 md-group-add-on" id="addressRemove">
                         <span onclick="removeAddress('mathaddress`+(address.rand)+`')" class="btn btn-danger waves-effect waves-light" data-toggle="tooltip" data-placement="top" title="" data-original-title="Remove" value="`+(address.id || "")+`">
                             <i class="icofont icofont-ui-remove"></i>
                         </span>
                     </div>
                 </div><!-- row -->
               </div>`);
 }

$(document).ready(function(){
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

   function address_validates(){
      var flag = true;
      $('.txtAddress, .txtCity, .txtProvince, .txtPostal').filter(function() {
       if (this.value == '') {
         flag = false;
         return false;
       }
      });
     return flag;
   }

   function contacts_validates(){
      var flag = true;
      $('.contact-fn, contact-ln, .contact-selectcash').filter(function() {
       if (this.value == '') {
         flag = false;
         return false;
       }
      });
     return flag;
   }

   function company_validates(){
      var flag = true;
      if(!$(".company-data").hasClass("force-hidden")){
         $('#txtContactPosition, #txtCompanyName, #txtPST, #txtGST').filter(function() {
          if (this.value == '') {
            flag = false;
            return false;
          }
         });
      }
     return flag;
   }

    function valid_fields(){
        var $phone_num = $("#txtPhone").val();
        var $first_name = $("#txtFirstName").val();
        var $address = $("#txtAddress").val();
        var $city = $("#txtCity").val();
        var $province = $("#txtProvince").val();
        var $postal = $("#txtPostal").val();
        var $heard = $("#txtHeardOfUs").val();
        if ($phone_num == ""  ||
            $first_name == "" ||
            $address == ""    ||
            $city == ""       ||
            $province == ""   ||
            $postal == ""     ||
            $heard == ""      ||
            $heard == null    ||
            address_validates() == false ||
            contacts_validates() == false ||
            company_validates() == false
            )
        {
            growling("Please send all required attributes");
            return false;
        }
        else if($phone_num != ""  &&
                $phone_num.length < 10
               )
        {
            growling("Phone number must be atleast 10 digits");
            return false;
        }

        else{
            return true;
        }
    }

    $("#customer-form").validate(RULES);
      $("input[class*='phone']").each(function () {
          $(this).rules('add', PHONE_METHOD);
          $(this).keydown(function () {
          updatePhone($(this));
      });
    });

    $("#saveCustomerButton").click(function(e){
      if(valid_fields() && $("#customer-form").valid()){
          $(".phone").each(function(a){
               $(this).rules("remove", "phoneNo")
               $(this).val($(this).val().replace(/-/g, ''));
           });
          $("#customer-form").submit()
      }
      else{
        e.preventDefault();
      }
    });


    //  $("#saveCustomerButton").click(function(e){
    //      if($(".the_form").valid()) {
    //          if (valid_fields()) {
    //              $(".phone").each(function(a){
    //                  $(this).rules("remove", "phoneNo")
    //                  $(this).val($(this).val().replace(/-/g, ''));
    //              });

    //              $("#customer-form").submit();
    //          }
    //          else {
    //              e.preventDefault();
    //          }
    //      }else{
    //          e.preventDefault();
    //      }
    // });
    // $("#customer-form").submit(function(e){
    //     e.preventDefault();
    //     if (valid_fields()){
    //         $('#saveCustomerButton').attr('disabled','disabled')
    //         $.ajax({
    //             method: $(this).attr("method"),
    //             url: $(this).attr("action"),
    //             data: $(this).serialize(),
    //             dataType: "json",
    //             success: function(res){
    //                 $('#saveCustomerButton').removeAttr('disabled');
    //                 if(res.response.idClient != undefined){
    //                     growlOfSuccess(success_response);
    //                 }
    //                 else{
    //                     growling(res.response.error)
    //                 }
    //             }
    //         });
    //     }
    // });
    $("#txtType").change(function() {
        changeViewType();
    });

    $("#txtGrade").change(function() {
      custom_grade();
    });
});


$("#search-bar-quote").keyup(function(){
  $("#quote-datatable_filter").find("input").val($(this).val());
  $("#quote-datatable_filter").find("input").trigger("keyup");
});
$(".quote-status-list").change(function() {
  var mySelect = this;
  $.ajax({
      url: "/api/v1/quotes/"+$(this).data("quote-no")+"/status",
      method: "patch",
      data: {
          status: $(this).val()
      }
  }).done(function(response) {
      if(response.error) {
          growlOfSuccess("An error occur: " + response.error, "danger");
      } else {
          //Reset timer.
          $(mySelect).closest("tr").find(".timerFromLastStatus").attr("data-timer", "0");
          $(mySelect).closest("tr").find(".timerFromLastStatus").text("0m");
          //Remove badge-color.
          $(mySelect).removeClass(mySelect.className.split(' ').pop());
          //Set new color from type of status.
          if($(mySelect).val() == "1") {
              $(mySelect).addClass("badge-primary");
          } else if($(mySelect).val() == "2") {
              $(mySelect).addClass("badge-warning");
          } else if($(mySelect).val() == "3") {
              $(mySelect).addClass("badge-success");
          } else if($(mySelect).val() == "4") {
              $(mySelect).addClass("badge-info");
          } else if($(mySelect).val() == "5") {
              $(mySelect).addClass("badge-info");
          } else if($(mySelect).val() == "6") {
              $(mySelect).addClass("badge-success");
          } else if($(mySelect).val() == "7") {
              $(mySelect).addClass("badge-primary");
          } else if($(mySelect).val() == "8") {
              $(mySelect).addClass("badge-danger");
          } else {
              $(mySelect).addClass("badge-muted");
          }
      }
  });
});

// $(document).on('turbolinks:load', function() {
$(document).ready(function() {
  $("#quote-datatable").DataTable({
    "paging": false,
    "searching": true,
    "info":     false,
    "order": [],
    "fixedHeader": true,
    "destroy": true,
  });
  $("#quote-datatable_filter").css({"visibility": "hidden","height": "0px"});
  $("#quote-datatable_length").css({"visibility": "hidden","height": "0px"});
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
});
