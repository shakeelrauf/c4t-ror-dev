$(document).ready(function(){
    $(window).resize(function() { donutChart(); });
    donutChart();

    /*Donut Hole*/
    function donutChart(){
        $.plot('#heardOfUs', heardofus, {
            series: {
                pie: {
                    innerRadius: 0.4,
                    radius: 0.6,
                    show: true,
                    label: {
                        show: true
                    }
                }
            },
            legend: {
                show: false
            }
        });
    };
});
