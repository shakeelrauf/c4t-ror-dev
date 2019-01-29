function callModal() {
    $(".map").on("click", function () {
        var $this = $(this),
            id = $this.data("id");
        callMap(id);
    })
}

callModal();
var getLatLang = function (address) {
    address =address + " Canada";
    geocoder = new google.maps.Geocoder()
    geocoder.geocode({'address': address}, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            var latlng = new google.maps.LatLng(39.305, -76.617);
            map = new google.maps.Map(document.getElementById('google_map'), {
                center: latlng,
                zoom: 12
            });
            //In this case it creates a marker, but you can get the lat and lng from the location.LatLng
            map.setCenter(results[0].geometry.location);
            var marker = new google.maps.Marker({
                map: map,
                position: results[0].geometry.location
            });
        } else {
            alert('Geocode was not successful for the following reason: ' + status);
        }
    });
}

function callMap(id) {
    if (($("#car-location" + id).children("option") != undefined) && ($("#car-location" + id).children("option").val() != undefined) && ($("#car-location" + id).children("option").val().length > 0)) {
        var last = $("#car-location" + id).children("option").length - 1
        var option = $("#car-location" + id).children("option")[last]
        var postal = $(option).text()
        getLatLang(postal);
        $("#modalMap").attr("data-id", id).modal("toggle");
    }
}