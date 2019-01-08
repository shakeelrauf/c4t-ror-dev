function validForNumbers(str) {
    var patt = new RegExp("[0-9]");
    var r = patt.test(str);
    if (r) {
        $("#pw_number_label").addClass('li_pw_ok');
    } else {
        $("#pw_number_label").removeClass('li_pw_ok');
    }
    return r;
}
function validForLength(str) {
    var r = (str.length >= 8);
    if (r) {
        $("#pw_length_label").addClass('li_pw_ok');
    } else {
        $("#pw_length_label").removeClass('li_pw_ok');
    }
    return r;
}
function validForCap(str) {
    var patt = new RegExp("[A-Z]");
    var r = patt.test(str);
    if (r) {
        $("#pw_cap_label").addClass('li_pw_ok');
    } else {
        $("#pw_cap_label").removeClass('li_pw_ok');
    }
    return r;
}
function validForMatch(str1,str2) {
    var r = (str1 === str2);
    if (r) {
        $("#pw_confirm_label").addClass('li_pw_ok');
    } else {
        $("#pw_confirm_label").removeClass('li_pw_ok');
    }
    return r;
}

function validNew() {
    var p = $("#pw_new").val();
    v1 = validForNumbers(p);
    v2 = validForLength(p);
    v3 = validForCap(p);
    return (v1 && v2 && v3);
}

function onChangePw() {
    var p = $("#pw_new").val();

    if (validNew(p)) {
        $("#pw_new_label").addClass('li_pw_ok');
    } else {
        $("#pw_new_label").removeClass('li_pw_ok');
        return false;
    }

    if (validNew(p) &&
        validForMatch(p, $("#pw_confirm").val())) {
        $("#pw_confirm_label").addClass('li_pw_ok');
        $("#pw_save").show();
        return true;
    } else {
        $("#pw_confirm_label").removeClass('li_pw_ok');
        $("#pw_save").hide();
        return false
    }
}

$(document).ready(function () {
    $("#pw_new").keyup(onChangePw);
    $("#pw_confirm").keyup(onChangePw);

    $("#the_form").submit(function(e) {
        if (!onChangePw()) {
            e.preventDefault();
        }
    });
})
