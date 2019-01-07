$(document).ready(function() {
    //Update status of a particular quote.
    $(".quote-status-list").change(function() {
        var mySelect = this;
        $.ajax({
            url: "/quote/"+$(this).data("quote-no")+"/status",
            method: "POST",
            data: {
                status: $(this).val()
            }
        }).done(function(response) {
            if(response.error) {
                growling("An error occur: " + response.error, "danger");
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

    //On searching quote.
    $(".search-bar-quote").keyup(function() {
        $(".shortcut-date-quotes option").first().prop("selected", true);
        filtingQuotes();
    });

    $(".filter-quote, input[name=dtStart], input[name=dtEnd]").change(function() {
        $(".shortcut-date-quotes option").first().prop("selected", true);
        filtingQuotes();
    });

    $(".shortcut-date-quotes").change(function() {
        var choosed = $(this).val();
        if(choosed == "Today") {
            $("input[name=dtStart]").val(moment().format("YYYY-MM-DD"));
            $("input[name=dtEnd]").val(moment().format("YYYY-MM-DD"));
        } else if(choosed == "Yesterday") {
            $("input[name=dtStart]").val(moment().subtract(1, "day").format("YYYY-MM-DD"));
            $("input[name=dtEnd]").val(moment().subtract(1, "day").format("YYYY-MM-DD"));
        } else if(choosed == "Last week") {
            $("input[name=dtStart]").val(moment().subtract(1, "week").format("YYYY-MM-DD"));
            $("input[name=dtEnd]").val(moment().format("YYYY-MM-DD"));
        } else if(choosed == "Last month") {
            $("input[name=dtStart]").val(moment().subtract(1, "month").format("YYYY-MM-DD"));
            $("input[name=dtEnd]").val(moment().format("YYYY-MM-DD"));
        }
        filtingQuotes();
    });

    function filtingQuotes() {
        var filter = $(".filter-quote").val() + " " + $(".search-bar-quote").val();
        filter = $.trim(filter);
        var beforeDate = moment().format("YYYY-MM-DD");
        var afterDate = "2000-01-01";
        if(moment($("input[name=dtStart]").val(), "YYYY-MM-DD").isValid()) {
            afterDate = $("input[name=dtStart]").val();
        }
        if(moment($("input[name=dtEnd]").val(), "YYYY-MM-DD").isValid()) {
            beforeDate = $("input[name=dtEnd]").val();
        }

        var quotesUrl = "/quotes/json?beforeDate=" + beforeDate + "&afterDate=" + afterDate + "&limit=20&offset=0&filter="+filter;
        if($(".table-quotes").first().hasClass("user-profile")) {
            quotesUrl = "/quotes/user/json?limit=20&offset=0&filter="+filter;
        } else if($(".table-quotes").first().hasClass("client-profile")) {
            quotesUrl = "/quotes/client/json?limit=20&offset=0&filter="+filter;
        }

        $(".table-quotes").html("");
        $.ajax("/status/json").done(function(status) {
            $.ajax(quotesUrl).done(function(quotes) {
                debugger
                quotes.forEach(function(quote) {
                    var backgroundType = "muted";
                    if(quote["status"]["color"] == "yellow") {
                        backgroundType = "warning";
                    } else if(quote["status"]["color"] == "blue") {
                        backgroundType = "info";
                    } else if(quote["status"]["color"] == "green") {
                        backgroundType = "success";
                    } else if(quote["status"]["color"] == "red") {
                        backgroundType = "danger";
                    } else if(quote["status"]["color"] == "orange") {
                        backgroundType = "primary";
                    }
                    $(".table-quotes").append(`
                        <tr>`+
                            (!$(".table-quotes").first().hasClass("client-profile") ?
                            `<td>` + quote["idQuote"] + `</td>
                            <td>`+quote["customer"]["firstName"]+` `+quote["customer"]["lastName"]+`</td>
                            <td>
                                <a href="tel:+`+quote["customer"]["phone"]+`">
                                    +`+quote["customer"]["phone"].substring(0, 3) + " " + quote['customer']['phone'].substring(3, 6) + "-" + quote["customer"]["phone"].substring(6)+`
                                </a>
                            </td>`
                            : "")+
                            `<td>`+(new Date(Date.parse(quote["dtCreated"])).toLocaleString("fr-CA"))+`</td>`+
                            (!$(".table-quotes").first().hasClass("user-profile") ?
                            `<td>`+quote["dispatcher"]["firstName"]+" "+quote["dispatcher"]["lastName"]+`</td>`
                            : "")+
                            `<td>
                                <select class="quote-status-list form-control badge badge-`+backgroundType+`" data-quote-no="`+quote["idQuote"]+`">
                                </select>
                            </td>
                            <td class="timerFromLastStatus" data-timer="` + (moment().diff(moment(quote["dtStatusUpdated"]), "s") || 0) + `">0m</td>
                            <td class="faq-table-btn">
                                <a href="/quotes/`+quote["idQuote"]+`/edit" class="btn btn-primary waves-effect waves-light" data-toggle="tooltip" data-placement="top" title="" data-original-title="Edit">
                                    <i class="icofont icofont-ui-edit"></i>
                                </a>
                                <a href="/quotes/`+quote["idQuote"]+`/view" class="btn btn-success waves-effect waves-light" data-toggle="tooltip" data-placement="top" title="" data-original-title="View">
                                    <i class="icofont icofont-eye-alt"></i>
                                </a>
                            </td>
                        </tr>`);
                    status.forEach(function(stat) {
                        $("select.quote-status-list[data-quote-no='"+quote["idQuote"]+"']").append(`
                                    <option value="`+stat["idStatus"]+`" `+(stat["idStatus"] == quote["status"]["idStatus"] ? "selected" : "")+`>
                                        `+stat["name"]+`
                                    </option>`);
                    });
                });
            });
        });
    }

    //In editing quote, we fill all fields
    if(typeof lstCars != 'undefined') {
        setTimeout(() => {
            lstCars.forEach(function(car) {
                car.missingParts.forEach(part => {
                    if(part.type == "wheels") {
                        $("#tab"+car.id+" input[name=wheels]").val(part.amount);
                    } else if(part.type == "tires") {
                        $("#tab"+car.id+" input[name=tires]").val(part.amount);
                    } else if(part.type == "Battery") {
                        $("#option"+car.id+"-Battery").prop("checked", true);
                    } else if(part.type == "Catalyzer") {
                        $("#option"+car.id+"-Catalyzer").prop("checked", true);
                    }
                });
                if(car.gettingMethod != "pickup") {
                    $("#option"+car.id+"-Pickup").removeAttr("checked");
                    $("#option"+car.id+"-Dropoff").attr("checked", "checked");
                }
                if(car.flatBedTruckRequired) {
                    $("#option"+car.id+"-FlatBedTruck").prop("checked", true);
                }
                $("#option"+car.id+"-Donation").val(car.donation);
            });
        }, 300);
    }
});
