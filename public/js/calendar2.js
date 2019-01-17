$(document).ready(function() {
  $(".external-events-toggle").click(() => {
    if ($("#external-events").is(':hidden')) {
      $(".lst-assigned").attr("class", "col-xl-10 col-md-12 lst-assigned");
    }
    $("#external-events").slideToggle("slow", () => {
      if ($("#external-events").is(':hidden')) {
        $(".lst-assigned").attr("class", "col-xl-12 col-md-12 lst-assigned");
      }
    });
    if ($(".external-events-toggle").text() == "▴") {
      $(".external-events-toggle").text("▾");
    } else {
      $(".external-events-toggle").text("▴");
    }
  })

  $('#external-events .fc-event').each(function() {
    // store data so the calendar knows to render an event upon drop
    /*
    if ($(this).hasClass("canNotRoll")) {
      $(this).data('event', {
        id: $(this).data('car-no'),
        title: $.trim($(this).find("h4").html()), // use the element's text as the event title
        stick: true, // maintain when user navigates (see docs on the renderEvent method)
        description: $(this).find("img").data('original-title'),
        color: 'red',
        textColor: 'yellow',
        information: nonEvents[$(this).data('car-no')],
        mmy: $.trim($(this).find("h6").html()),      // Use some id instead
        address: $.trim($(this).find("h4").html())   // Use some id inst

      });
    } else {
      $(this).data('event', {
        id: $(this).data('car-no'),
        title: $.trim($(this).find("h4").html()), // use the element's text as the event title
        stick: true, // maintain when user navigates (see docs on the renderEvent method)
        description: $(this).find("img").data('original-title'),
        color: 'black',
        textColor: 'yellow',
        information: nonEvents[$(this).data('car-no')],
        mmy: $.trim($(this).find("h6").html()),     // Use some id inst
        address: $.trim($(this).find("h4").html())  // Use some id inst
      });
    }
    */
    // make the event draggable using jQuery UI
    $(this).draggable({
      zIndex: 999,
      revert: true, // will cause the event to go back to its
      revertDuration: 0 //  original position after the drag
    });
  });

  $('#calendar').fullCalendar({
    header: {
      left: 'prev,next',
      center: 'title',
      right: 'agendaWeek,agendaDayTrucks,agendaTruck'
    },
    views: {
      agendaDayTrucks: {
        type: 'agenda',
        buttonText: 'Day View',
        titleFormat: 'dddd, MMMM Do, YYYY',
        groupByDateAndResource: true
      }
    },
    buttonText: {
      week: 'Week View'
    },
    minTime: "07:00:00",
    schedulerLicenseKey: 'CC-Attribution-NonCommercial-NoDerivatives',
    timezone: 'UTC',
    titleFormat: 'MMMM Do, YYYY',
    columnFormat: 'dddd Do',
    nowIndicator: true,
    defaultDate: moment().format('YYYY-MM-DD'),
    eventLimit: true, // allow "more" link when too many events
    defaultView: 'agendaDayTrucks',
    allDaySlot: false, // Unsupported yet
    slotDuration: '01:00:00',
    snapDuration: '00:10:00',
    unknownResourceTitle: 'Unknown',
    resources: [{
        id: 'truck109',
        title: 'GMC 109'
      },
      {
        id: 'truck110',
        title: 'Chevy 110'
      },
      {
        id: 'truck111',
        title: 'FL 111'
      },
      {
        id: 'truck112',
        title: 'Hino 112'
      },
    ],
    eventOverlap: function(stillEvent, movingEvent) {
      if (stillEvent.information.address.id == movingEvent.information.address.id) {
        return true;
      } else {
        return false;
      }
    },
    editable: true,
    droppable: true, // this allows things to be dropped onto the calendar
    dayClick: function(date, jsEvent) {
      $('#calendar').fullCalendar('gotoDate', date);
      $('#calendar').fullCalendar('changeView', 'agendaDayTrucks');
    },

    // Remove event from calendar
    eventDragStop: function(event, jsEvent, ui, view) {
      var ofs = $("#external-events").offset();
      var x1 = ofs.left;
      var x2 = ofs.left + $("#external-events").outerWidth(true);
      var y1 = ofs.top;
      var y2 = ofs.top + $("#external-events").outerHeight(true);

      if (jsEvent.pageX >= x1 && jsEvent.pageX <= x2 &&
        jsEvent.pageY >= y1 && jsEvent.pageY <= y2) {
        $.ajax({
          url: "/dispatch/remove",
          method: "POST",
          data: {
            idCar: event.id
          }
        }).fail(function() {
          alert("Error!");
        }).done(function(response) {
          if (response.error) {
            alert(response.error);
          } else {
            var isCarCanRoll = true;

            $('#calendar').fullCalendar('removeEvents', event.id);

            $.ajax({
              url: "/dispatch/unsched/" + event.id,
              method: "GET"
            }).fail(function() {
              alert("Error!");
            }).done(function(html) {
                $("#external-events").append(html);

                // Make the unsched car draggable
                $("div.fc-event[data-car-no='" + event.id + "']").draggable({
                  zIndex: 999,
                  revert: true, // will cause the event to go back to its
                  revertDuration: 0 //  original position after the drag
                });
                //Add tooltip map on event.
                $("div.fc-event[data-car-no='" + event.id + "'] img").data("original-title", event.description);
                $("div.fc-event[data-car-no='" + event.id + "'] img").tooltip({
                  title: event.description,
                  html: true,
                  trigger: "click",
                  placement: "top"
                });
                $(".tooltip").tooltip("hide");

            });

            // store data so the calendar knows to render an event upon drop
            var isCarCanRoll = true;
            if (!isCarCanRoll) {
              // Should rely on ids rather
              var mmy     = $("div.fc-event[data-car-no='" + event.id + "']").find("h6").html();
              var address = $("div.fc-event[data-car-no='" + event.id + "']").find("h4").html();
              $("div.fc-event[data-car-no='" + event.id + "']").data('event', {
                id: event.id,
                title: $.trim(title), // use the element's text as the event title
                stick: true, // maintain when user navigates (see docs on the renderEvent method)
                description: event.description,
                color: 'red',
                textColor: 'yellow',
                information: event.information,
                address: address,
                mmy: mmy
              });
            } else {
              $("div.fc-event[data-car-no='" + event.id + "']").data('event', {
                id: event.id,
//                title: $.trim(title), // use the element's text as the event title
                stick: true, // maintain when user navigates (see docs on the renderEvent method)
                description: event.description,
                color: 'black',
                textColor: 'yellow',
                information: event.information,
                address: address,
                mmy: mmy
              });
            }
          }
        });
      }
    },

    // Moving event from calendar to calendar
    eventDrop: function(event, delta, revertFunc, jsEvent, ui, view) {
      $.ajax({
        url: "/dispatch",
        method: "POST",
        data: {
          idCar: event.id,
          truck: event.resourceId,
          dtStart: event.start.format("YYYY-MM-DD HH:mm:ss"),
          dtEnd: (event.end == null ? null : event.end.format("YYYY-MM-DD HH:mm:ss"))
        }
      }).fail(function() {
        alert("Error!");
      });
    },
    // Add event in calendar
    drop: function(date, jsEvent, ui, resourceId) {
      var myCar = $(this);
      var element = ui.helper;
      $.ajax({
        url: "/dispatch",
        method: "POST",
        data: {
          idCar: $(myCar).data("car-no"),
          truck: resourceId,
          dtStart: date.format("YYYY-MM-DD HH:mm:ss"),
          map: $(myCar).find("img").data("original-title")
        }
      }).fail(function() {
        alert("Error!");
      }).done(function() {
        //Remove the element from the "Draggable List of Unscheduled" list
        $(myCar).remove();
      });
    },
    eventAfterRender: function(event, element) {
      $(".tooltip").tooltip("hide");
      element.find('.fc-title').append(`<div class="event-check-info">
                <p class="tag">` + event.information.address.id + `</p>
            </div>`);
  /*      element.find('.fc-title').append(`<div class="event-check-info">
                <i class="fa fa-info-circle fa-2x infoicon" aria-hidden="true"></i>
                <p class="tag">` + event.information.address.id + `</p>
            </div>`);
            */
      element.append(`<i class="fa fa-map-marker fa-2x calendaricon" aria-hidden="true"></i>`);
      /*
      element.find('.calendaricon').tooltip({
        title: event.mmy + '<br>' + event.address,
        html: true,
        trigger: "click",
        placement: "top"
      });

      element.find('.fc-title .infoicon').tooltip({
        title: `
                    <div class="customer-info">
                        <div class="customer-info-button">
                            <div onclick='closepopup();' class='close-popup'>
                                <i class='icofont icofont-close-squared-alt'></i>
                            </div>
                        </div>` + event.information.quote.reference + "-" + event.information.id + `<br>
                        ` + event.address + `<br>
                        <b>` + Math.round(Number(event.information.address.distance) / 1000) + ` Km</b><br>
                        <hr>
                        ` + event.information.quote.customer.firstName + " " + event.information.quote.customer.lastName + ` <br>
                        <a href="tel:` + event.information.quote.customer.phone + `">` + event.information.quote.customer.phone.substr(0, 3) + "-" + event.information.quote.customer.phone.substr(3, 3) + "-" + event.information.quote.customer.phone.substr(7) + `</a><br>
                        <b>` + event.mmy + `</b><br>
                        <u>Missing Parts:</u>
                        <ul>` + (event.information.missingParts.map(oPart => {
            return oPart.type;
          }).indexOf("wheels") !== -1 ? "<li>Wheels: x" + event.information.missingParts.find(oPart => {
            return oPart.type == "wheels"
          }).amount + "</li>" : "") + `
                            ` + (event.information.missingParts.map(oPart => {
            return oPart.type;
          }).indexOf("tires") !== -1 ? "<li>Tires: x" + event.information.missingParts.find(oPart => {
            return oPart.type == "wheels"
          }).amount + "</li>" : "") + `
                            ` + (event.information.missingParts.map(oPart => {
            return oPart.type;
          }).indexOf("Battery") !== -1 ? "<li>Battery</li>" : "") + `
                            ` + (event.information.missingParts.map(oPart => {
            return oPart.type;
          }).indexOf("Catalyzer") !== -1 ? "<li>Catalytic converter</li>" : "") + `
                        </ul>
                        <a href="/quotes/` + event.information.quote.id + `/view">View quote</a>
                    </div>`,
        html: true,
        trigger: "click",
        placement: "top"
      });
      */
    },
    // Resizing event
    eventResize: function(event, delta, revertFunc, jsEvent, ui, view) {
      $.ajax({
        url: "/dispatch",
        method: "POST",
        data: {
          idCar: event.id,
          truck: event.resourceId,
          dtStart: event.start.format("YYYY-MM-DD HH:mm:ss"),
          dtEnd: (event.end == null ? null : event.end.format("YYYY-MM-DD HH:mm:ss"))
        }
      }).fail(function() {
        alert("Error!");
      });
    },
    //escape all html except <br>.
    eventRender: function(event, element) {
      $(element).find(".fc-title").html(event.mmy + "<br>" + event.address);
    },
    eventSources: [{
      events: events,
      color: 'black',
      textColor: 'yellow'
    }]
  });
});

function closepopup() {
  $(".tooltip").tooltip("hide");
}
