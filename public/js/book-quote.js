$(document).ready(function() {
    $('.payment-select').on('change', function() {
        var id =  $(this).data("id");
        var value =  this.value;
        hideOrShow(id, value)

    });
    $(".payment-select").each(function () {
        var id =  $(this).data("id");
        var value =  this.value;
        hideOrShow(id, value)
    })
    function hideOrShow(id, value){
        if(value == "eft"){
            $(".customer_email"+id).show()
            $("#customer_email"+id+"-error").show()
        }else{
            $(".customer_email"+id).hide()
            $("#customer_email"+id+"-error").hide()
        }
    }
    $("#the_form").validate()
    $(".customer_emails").each(function () {
       $(this).rules("add", "required");
       $(this).rules("add", EMAIL_METHOD);
    });
  $('.date-field').dateDropper(
    { format: 'Y-m-d' }
  );
  $('.nav-item').click(function() {
    var tabId = $(this).prop('id');
    var carId = tabId.split('-')[1];
    $('.tab-pane').hide();
    $("#tabpanel-" + carId).show();
  });

  // Calc the towable status
  $(".drivetrain-select").change(onChangeDriveTrain);
  $(".tires-select").change(onChangeTires);
  $(".towable-select").change(onChangeTowable);

  // Decide on showing the prompt
  showAllPrompts();
});

function onChangeDriveTrain() {
  var n = $(this).prop('name');
  var carId = n.substring("drivetrain-".length, n.length);
  var driveVal = $("select[name=drivetrain-" + carId + "]").val();

  if (driveVal == "4x4") {
    $(".prompt-line").show();
    $(".2wd-ability").show();
    confirm2wd(carId);
  } else if (driveVal == "flatbed" || driveVal == "unk") {
    makeCarNotTowable(carId);
  }
}

function onChangeTires() {
  var n = $(this).prop('name');
  var carId = n.substring("tiresCondition-".length, n.length);
  var driveVal = $("select[name=drivetrain-" + carId + "]").val();
  var tiresVal = $("select[name=tiresCondition-" + carId + "]").val();

  if (driveVal == "rwd" && tiresVal == "front_flat") {
    $(".prompt-line").show();
    $(".can-go-neutral").show();
    confirmNeutral(carId);
  } else if (driveVal == "fwd" && tiresVal == "rear_flat") {
    $(".prompt-line").show();
    $(".can-go-neutral").show();
    confirmNeutral(carId);
  } else if (tiresVal == "all_flat" ||
             tiresVal == "seized" ||
             tiresVal == "none" ||
             tiresVal == "backseat" ||
             tiresVal == "broken" ||
             tiresVal == "unk") {
    makeCarNotTowable(carId);
  }
}

function onChangeTowable() {
  // Nothing for now
}


function confirm2wd(carId) {
    $.confirm({
        title: 'Can the car go in 2 wheel drive?',
        content: '',
        buttons: {
            yes2wd: {
                text: 'Yes',
                btnClass: 'btn-blue',
                action: function () {
                  $("input[name=canDo2wd-" + carId + "]").filter('[value="1"]').prop('checked', 'checked');
                }
            },
            no2wd: {
                text: 'No',
                btnClass: 'btn-blue',
                action: function () {
                  $("input[name=canDo2wd-" + carId + "]").filter('[value="0"]').prop('checked', 'checked');
                  makeCarNotTowable(carId);
                }
            },
        }
    });
}

function confirmNeutral(carId) {
    $.confirm({
        title: 'Can the car go in neutral?',
        content: '',
        buttons: {
            yes2wd: {
                text: 'Yes',
                btnClass: 'btn-blue',
                action: function () {
                  $("input[name=canGoNeutral-" + carId + "]").filter('[value="1"]').prop('checked', 'checked');
                }
            },
            no2wd: {
                text: 'No',
                btnClass: 'btn-blue',
                action: function () {
                  $("input[name=canGoNeutral-" + carId + "]").filter('[value="0"]').prop('checked', 'checked');
                  makeCarNotTowable(carId);
                }
            },
        }
    });
}

function showAllPrompts() {
  $(".tab-pane").each(function() {
    var id = $(this).prop('id');
    var carId = id.substr("tabpanel-".length, id.length);
    var driveVal = $("select[name=drivetrain-" + carId + "]").val();
    var tiresVal = $("select[name=tiresCondition-" + carId + "]").val();

    if (driveVal == "4x4") {
      $(".prompt-line").show();
      $(".2wd-ability").show();
    }
    if((driveVal == "rwd" && tiresVal == "front_flat") ||
       (driveVal == "fwd" && tiresVal == "rear_flat")) {
      $(".prompt-line").show();
      $(".can-go-neutral").show();
    }
  });
}

function makeCarNotTowable(carId) {
  var towable = $("input[name=isTowable-" + carId + "]").filter('[value="1"]').prop('checked');
  $("input[name=isTowable-" + carId + "]").filter('[value="0"]').prop('checked', 'checked');
  doGrowlingMessage("The car will be set to not towable");
}

function gotoEditQuote(quoteId) {
    if(confirm("Are you sure you want to leave this page? Current quote will be lost.")) {
        document.location = "/quotes/" + quoteId + "/edit" ;
    }
}

function saveBooking(callback) {
  var serialized = $("#the_form").serializeArray();
  if($("#the_form").valid()){
      apost({
          method: "POST",
          url: "/bookings",
          data: serialized
      }, function(data) {
          if (callback) {
              callback();
          } else {
              doGrowlingMessage(data.message);
          }
      });
  }

}

function scheduleBooking(quoteId) {
  saveBooking(function() {
    document.location = "/dispatch/quote/" + quoteId ;
  });
}
