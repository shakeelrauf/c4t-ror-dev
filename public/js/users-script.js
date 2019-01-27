/////////////////////////////////////////////////////////////////
//Blacklist user
/////////////////////////////////////////////////////////////////

$(".blacklistContactDialog").dialog({
    autoOpen: false,
    draggable: false,
    modal: true,
    resizable: false
});

$(".crm-action-delete").click(function() {
    $(".loading").removeClass("hidden");
    var noUserToGet = $(this).data('contact-no');
    var userData = $("#usernameOf"+noUserToGet);
    // var active = ($(userData).hasClass("notActive") ? "0" : "1");
    var active = $(this).data('status');
    $(".userToBlacklist").text($(userData).text());
    $(".blacklistDialogYes").data('contact-no', noUserToGet);
    $(".blacklistDialogYes").data('contact-isactive', active);
    $(".blacklistContactDialog").dialog("open");
});

$(".blacklistDialogYes").click(function() {
    var userNo = $(this).data('contact-no');
    var isActive = $(this).data('contact-isactive');
    if(isActive == "1") {
        isActive = "0";
    } else {
        isActive = "1";
    }
    $(".blacklistContactDialog").dialog("close");
    $.ajax({
      url: "/users/"+ userNo + "/blacklist/",
      type: "POST",
      data: {
          isActive: isActive
      }
    }).done(function(data) {
        if(data.error) {

            $(".loading").addClass("hidden");
            $.growl({
                message: data.error
            },{
                type: "danger",
                allow_dismiss: true,
                label: 'Cancel',
                className: 'btn-xs btn-inverse',
                delay: 0,
                animate: { enter: 'animated fadeInDown' }
            });
        } else {
            document.location = "/users?statechange=true";
        }
    });
});

$(".blacklistDialogNo").click(function() {
    document.location = "/users";
    
});
/////////////////////////////////////////////////////////////////
//Edit user
/////////////////////////////////////////////////////////////////

function deleteAvatar() {
	if (confirm('Are you sure you want to delete this Avatar?')) {
		$.ajax({
	      url: "/avatar-upload/" + userId,
	      type: "POST"
	    }).done(function(data) {
	        if(data.error) {
	            alert(data.error);
	        } else {
	            location.reload();
	        }
	    });
	}
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
    $("#txtPwd").val("");
    $("#txtPwdValidation").val("");
}
var stringConstructor = "test".constructor;
var arrayConstructor = [].constructor;
var objectConstructor = {}.constructor;

$("#btnSaveUser").click(function() {
    if($(".the_form").valid()) {
        if ($("#txtUsername").val() == "" ||
            $("#txtEmail").val() == "") {
            growling("Please fill field Username and email.");
        } else if ($("#txtPwd").val() != $("#txtPwdValidation").val()) {
            growling("Password is different of validation.");
        } else {
            var noUserToGet = $(this).data('id-user');
            var url = "";
            $(".loading").removeClass("hidden");
            if (noUserToGet == "new") {
                url = "/users";
            } else {
                url = "/users/" + noUserToGet;
            }
            var phone =  $("#txtPhone").val().replace(/-/g, '');
            $.ajax({
                url: url,
                type: url == "/users" ? "POST" : "PUT",
                data: {
                    username: $("#txtUsername").val(),
                    firstName: $("#txtFirstName").val(),
                    lastName: $("#txtLastName").val(),
                    roles: $("#txtRole").val(),
                    email: $("#txtEmail").val(),
                    phoneNumber: phone,
                    pwd: $("#txtPwd").val()
                }
            }).done(function (data) {
                if (data["error"]) {
                    if (data.error === null) {
                        growling("Something went wrong")
                    }
                    else if (data.error === undefined) {
                        growling("Something went wrong")
                    }
                    else if (data.error.constructor === stringConstructor) {
                        growling(data.error)
                    }
                    else if (data.error.constructor === objectConstructor) {
                        for (var i in data.error) {
                            growling(data.error[i])
                        }
                    }
                    $(".loading").addClass("hidden");

                } else {
                    var nextURL = "/users";
                    if (noUserToGet == "new") {
                        document.location = nextURL + "?added=true";
                    } else {
                        if ($("#txtRole").val() != "admin") {
                            nextURL = "/users";
                        }
                        document.location = nextURL + "?edited=true";
                    }
                }
            });
        }
    }
});

$( document ).ready(function() {
    var params = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    if (params[0].length == 16){
        doGrowlingMessage("User state is changed!");
    }
});