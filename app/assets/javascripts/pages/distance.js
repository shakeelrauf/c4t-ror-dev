function getDistanceForCar(postal, carId, callback) {
    $.ajax({
        type: "GET",
        url: "/distance/" + postal,
    }).done(function(txt) {
        callback(txt, carId);
    });
    // callback("0", carId);
}

function getDistanceForAddress(addressId, carId, callback) {
    $.ajax({
        type: "GET",
        url: "/address/" + addressId + "/json",
    }).done(function(json) {
        getDistanceForCar(JSON.parse(json).postal, carId, function(txt, carId) {
            callback(txt, carId);
        });
    });
    // callback("0", carId);
}

function getDistanceDiff(origin, destination, callback) {
    $.ajax({
        type: "POST",
        url: "/distancediff",
        data: {
            origin: origin,
            destination: destination
        }
    }).done(function(distance) {
        callback(distance);
    });
    // callback("0");
}