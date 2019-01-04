// App wide functions
// Custom ajax, in failure, redirect to login
function apost(options, onDone) {
  $.ajax(options)
  .done(function(data) {
    if (data.trim && data.trim().startsWith('<!DOCTYPE html>')) {
      alert("Session timed out, or an error occurred.");
      document.location = "/login?redirect=" + document.location;
    } else {
        onDone(JSON.parse(data));
    }
  })
  .fail(function() {
    doGrowlingDanger("Error, contact a system administrator");
  });
}

function doGrowlingDanger(message) {
  doGrowling(message, "danger");
}

// There's a typo in this...
function doGrowlinWarning(message) {
  doGrowlingWarning(message)
}
function doGrowlingWarning(message) {
  // Warning seems to have the right color
  doGrowling(message, "warning");
}

function doGrowlingMessage(message) {
  doGrowlingSuccess(message);
}

function doGrowlingSuccess(message) {
  // Warning seems to have the right color
  doGrowling(message, "success");
}

function doGrowling(message, type) {
    // Remove the previous alert
    $.growl({
        message: message
    },{
        type: type,
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
    setTimeout(function() {
      $(".alert").remove();
    }, 5000);
}

/** Rounds and strips the cents */
function toDollar(x) {
  if (!x)
    return "0"
  return Math.round(x).toFixed(0);
}
