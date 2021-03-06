var tab = 0;

//Update status of a particular quote.
$(document).ready(function() {
	$("body").on("change", ".quote-status-list",function() {
	    var mySelect = this;
	    $.ajax({
	        url: "/quotes/"+$(this).data("quote-no")+"/status",
	        method: "POST",
	        data: {
	            status: $(this).val()
	        }
	    }).done(function(response) {
	        if(response.error) {
	            growling("An error occur: " + response.error, "danger");
	        } else {
	            //Reset timer.
	            $(mySelect).closest("tr").find(".timerFromLast").attr("data-timer", "0");
	            $(mySelect).closest("tr").find(".timerFromLastStatus" + response.idQuote).text("0m");
	            $(".timerFromLastStatus" + response.idQuote).text("0m");
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
});

//On searching quote.
$(".search-bar-quote").keyup(function() {
    $(".shortcut-date-quotes option").first().prop("selected", true);
    tab = 0
    filtingQuotes();
});

$(".pagination.bootpag li").click(t => {
    switchTab(t);
});

$(".filter-quote, input[name=dtStart], input[name=dtEnd]").change(function() {
    $(".shortcut-date-quotes option").first().prop("selected", true);
    tab = 0
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
    tab = 0
    filtingQuotes();
});

function filtingQuotes() {
    var ascDesc;
    var sortColumn;
    if($(".sorting_asc").length == 1){
        ascDesc = "asc";
        sortColumn = $(".sorting_asc").data('sortby')
    }else{
        if($(".sorting_desc").length == 1){
            ascDesc = "desc";
            sortColumn = $(".sorting_desc").data('sortby')
        }
    }
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
    if(sortColumn == undefined){
        var quotesUrl = "/quotes/search?beforeDate=" + beforeDate + "&afterDate=" + afterDate + "&limit=15&offset="+tab+"&filter="+filter;
    }else{
        var quotesUrl = "/quotes/search?orderBy="+sortColumn+"&ascDesc="+ascDesc+"&beforeDate=" + beforeDate + "&afterDate=" + afterDate + "&limit=15&offset="+tab+"&filter="+filter;
    }
    if($(".table-quotes").first().hasClass("user-profile")) {
        quotesUrl = "/quotes/user/json?limit=15&offset="+tab+"&filter="+filter;
    } else if($(".table-quotes").first().hasClass("client-profile")) {
        quotesUrl = "/quotes/client/json?limit=15&offset="+tab+"&filter="+filter;
    }
    $.ajax("/quotes/status").done(function(status) {
        $.ajax(quotesUrl).done(function(res) {
            resizePagination(res.count,res.quotes, false);
            // set_active();
            $(".table-quotes").html("");
            res.quotes.forEach(function(quote) {
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
                var firstName="",
                    lastName="",
                    phone="";
                if(quote["customer"] !=undefined) {
                    firstName = quote["customer"]["firstName"];
                    lastName = quote["customer"]["lastName"];
                    if (quote["customer"]["phone"] != undefined) {
                        phone = quote["customer"]["phone"].substring(0, 3) + "-" + quote['customer']['phone'].substring(3, 6) + "-" + quote["customer"]["phone"].substring(6)
                    }
                }
                $(".table-quotes").append(`
                    <tr>`+
                        (!$(".table-quotes").first().hasClass("client-profile") ?
                        `<td>` + quote["referNo"] + `</td>
                        <td>`+firstName+` `+lastName+`</td>
                        <td>
                            <a href="tel:+`+phone+`">
                                `+phone+`
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
                        <td class="timerFromLastStatus`+quote["idQuote"]+`"  data-timer="` + (moment().diff(moment(quote["dtStatusUpdated"]), "s") || 0) + `"></td>
                        <td class="faq-table-btn">
                            <a href="/quotes/`+quote["idQuote"]+`/edit" class="btn btn-primary waves-effect waves-light" data-toggle="tooltip" data-placement="top" title="" data-original-title="Edit">
                                <i class="icofont icofont-ui-edit"></i>
                            </a>
                        </td>
                    </tr>`);
                status.forEach(function(stat) {
                    $("select.quote-status-list[data-quote-no='"+quote["idQuote"]+"']").append(`
                                <option value="`+stat["idStatus"]+`" `+(stat["idStatus"] == quote["status"]["idStatus"] ? "selected" : "")+`>
                                    `+stat["name"]+`
                                </option>`);
                });
                date_quotes(quote["idQuote"], quote["dtStatusUpdated"]);
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

function switchTab(t) {

  if($(t.currentTarget).hasClass("disabled")) {
      return;
  }
  //Switch tab.
  if($(t.currentTarget).data("lp") == "prev") {
      tab--;
  } else if($(t.currentTarget).data("lp") == "next") {
      tab++;
  } else {
      tab = Number($(t.currentTarget).data("lp"))-1;
  }
  $(".pagination.bootpag li").removeClass("active");
  //Get new list.
  filtingQuotes();
}

function set_active() {
  $(".pagination.bootpag li").each(function(){
		if(parseInt($(this).text().trim()) == tab + 1){
			$(this).addClass("active")
		}
	});
	if(parseInt($(".page.active").text()) > 1){
		$(".first").removeClass("disabled");
		$(".prev").removeClass("disabled");
	}
	else{
		$(".first").addClass("disabled");
		$(".prev").addClass("disabled");
	}
}

function remove_active(){
  $(".pagination.bootpag li").each(function(){
		if($(this).hasClass("active")){
			$(this).removeClass("active")
		}
	});
}


function resizePagination(total, res,type) {
	var visiblePages = 10;
	startPage = 1;
	if (tab >= 9){
		startPage = tab + 1
	}
  if (total == 0 && res.length != 0){
      total = 1
      visiblePages = 1;
  }
  if (total != 0 && res.length != 0){
		$(".no-record").css({"display": "none"});
	  $('.pagination-demo').twbsPagination('destroy');
	  $('.pagination-demo').twbsPagination({
	    totalPages: total,
	    // the current page that show on start
	    startPage: startPage,

	    // maximum visible pages
	    visiblePages: visiblePages,


	    // template for pagination linksa
	    href: false,

	    // variable name in href template for page number
	    hrefVariable: '{{number}}',

	    // Text labels
	    first: 'First',
	    prev: '',
	    next: '',
	    last: 'Last',

	    // carousel-style pagination
	    loop: false,

	    // callback function
	    onPageClick: function (event, page) {
	      if (type != false){
					remove_active()
	        tab = page - 1
	        filtingQuotes();
	      }
	      else{
	          type = true
	      }
	    },

	    // pagination Classes
	    paginationClass: 'pagination',
	    nextClass: 'next',
	    prevClass: 'prev',
	    lastClass: 'last',
	    firstClass: 'first',
	    pageClass: 'page',
	    activeClass: 'active',
	    disabledClass: 'disabled'
	  });
	  remove_active();
	  set_active();
	}
	else{
		$('.pagination-demo').twbsPagination('destroy');
		$(".no-record").css({"display": "block"});
	}
}