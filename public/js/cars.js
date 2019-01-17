var tab = 0;
$(document).ready(() => {
    $(".search-bar-car").keyup(function() {
        updateList();
    });

    $(".pagination.bootpag li").click(t => {
        switchTab(t);
    });
});

function updateList() {
    $.ajax("/cars-select2?filter="+$(".search-bar-car").val()+"&limit=15&offset="+tab).done(list => {
        showList(list.results);
        resizePagination(list.count, list.results.length);
    });
}

function showList(list) {
    $(".table-list").html("");
    list.forEach(item => {
        $(".table-list").append(`
            <tr data-car="` + item.id + `">
                <td>` + item.year + `</td>
                <td>` + item.make + `</td>
                <td>` + item.model + `</td>
                <td>` + item.trim + `</td>
                <td>` + item.body + `</td>
                <td>` + item.drive + `</td>
                <td>` + item.transmission + `</td>
                <td>` + item.seats + `</td>
                <td>` + item.doors + `</td>
                <td>` + item.weight + `</td>
            </tr>`);
    });
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
    updateList();
}

function resizePagination(total, res) {
    if(total > 10) {
        total = 10;
    }
    if (total == 0 && res != 0){
        total = 1
    }
    $(".pagination.bootpag").html(`
        <li data-lp="prev" class="prev">
            <a href="javascript:void(0);">«</a>
        </li>`);
    for(var i = 1; i <= total; i++) {
        var ck = "";
        if(i == 1){
            ck = "active"
        }
        $(".pagination.bootpag").append(`
            <li data-lp="`+i+`" class="`+ck+`">
                <a href="javascript:void(0);">`+i+`</a>
            </li>`);
    }
    $(".pagination.bootpag").append(`
        <li data-lp="next" class="next">
            <a href="javascript:void(0);">»</a>
        </li>`);
    //If current tab is after total, set current tab to last one.
    if(tab >= total-1) {
        tab = total-1;
    }

    $(".pagination.bootpag li[data-lp="+(tab+1)+"]").addClass("active");
    //disabled prev/next if at start or at end of tabs.
    if(tab <= 0) {
        $(".pagination.bootpag li[data-lp=prev]").addClass("disabled");
    }
    if(tab >= Number($(".pagination.bootpag li").last().prev().data("lp"))-1) {
        $(".pagination.bootpag li[data-lp=next]").addClass("disabled");
    }
    $(".pagination.bootpag li").click(t => {
        switchTab(t);
    });
}
