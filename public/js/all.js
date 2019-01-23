PHONE_METHOD      = "phoneNo";
PHONE_RE = "^([\\d][-]{1})?(\\d{3}[-]{1}){2}(\\d{4})$";
PHONE_FORMAT = "514-888-9999";
RULES = {};

$.validator.addMethod(PHONE_METHOD, function(value, element) {
    return validPhone(value);
}, "Invalid Phone No" + ": " + PHONE_FORMAT);

function updatePhone(f) {
    var v = f.val();
    if (v.length == 0)
        return;

    if (v.length >= 2) {
        if (v.charAt(0) == '1') {
            if (v.charAt(1) != '-') {
                v = "1-" + v.substring(1, v.length);
            }
            if (v.length >= 6 && v.charAt(5) != '-') {
                v = v.substring(0, 5) + "-" + v.substring(5, v.length);
            }
            if (v.length >= 10 && v.charAt(9) != '-') {
                v = v.substring(0, 9) + "-" + v.substring(9, v.length);
            }
        } else if (v.length >= 9) {
            // Abort after 9 chars
            return;
        } else if (v.length >= 4) {
            if (v.charAt(3) != '-') {
                v = v.substring(0, 3) + "-" + v.substring(3, v.length);
            }
            if (v.length >= 8 && v.charAt(7) != '-') {
                v = v.substring(0, 7) + "-" + v.substring(7, v.length);
            }
        }
    }
    f.val(v);
}

function formatPhone(v) {
    if (v.length == 0)
        return;

    if (v.length >= 2) {
        if (v.charAt(0) == '1') {
            if (v.charAt(1) != '-') {
                v = "1-" + v.substring(1, v.length);
            }
            if (v.length >= 6 && v.charAt(5) != '-') {
                v = v.substring(0, 5) + "-" + v.substring(5, v.length);
            }
            if (v.length >= 10 && v.charAt(9) != '-') {
                v = v.substring(0, 9) + "-" + v.substring(9, v.length);
            }
        } else if (v.length >= 9) {
            // Abort after 9 chars
            return v;
        } else if (v.length >= 4) {
            if (v.charAt(3) != '-') {
                v = v.substring(0, 3) + "-" + v.substring(3, v.length);
            }
            if (v.length >= 8 && v.charAt(7) != '-') {
                v = v.substring(0, 7) + "-" + v.substring(7, v.length);
            }
        }
    }
    return v;
}

function validPhone(str) {
    return validString(str, PHONE_RE);
}


function validString(str, re) {
    if (str == "") {
        return true;
    }
    var patt = new RegExp(re);
    return patt.test(str);
}

if ($(".the_form").length) {
    $(".the_form").validate(RULES);
    $("input[class*='phone']").each(function () {
        $(this).rules('add', PHONE_METHOD);
        $(this).keydown(function () {
            updatePhone($(this));
        });
    });

    $(".save-form").click(function(e){
        if($(".the_form").valid()){
            $(".phone").each(function(a){
                 $(this).rules("remove", "phoneNo")
                 $(this).val($(this).val().replace(/-/g, ''));
             });
            $(".the_form").submit()
        }
    })
}