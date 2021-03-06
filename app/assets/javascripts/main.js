$(document).ready(function() {
    $(".loading").addClass("hidden");

    //sidebar dropdown open
    $(".designation").on('click', function() {
        $(".extra-profile-list").slideToggle();
    });

    $("[data-toggle='utility-menu']").on('click', function() {
        $(this).next().slideToggle(300);
        $(this).toggleClass('open');
        return false;
    });

});

$(window).on('hashchange', function(e){
    $(".loading").removeClass("hidden");
});

/*Show tooltip*/
$('[data-toggle="tooltip"]').tooltip();
$('[data-toggle="popover"]').popover({
    animation: true,
    delay: {
        show: 100,
        hide: 100
    }
});


// wave effect js

Waves.init();
Waves.attach('.flat-buttons', ['waves-button']);
Waves.attach('.float-buttons', ['waves-button', 'waves-float']);
Waves.attach('.float-button-light', ['waves-button', 'waves-float', 'waves-light']);
Waves.attach('.flat-buttons', ['waves-button', 'waves-float', 'waves-light', 'flat-buttons']);

// side button js code start
$.pushMenu = {
    activate: function(toggleBtn) {

        //Enable sidebar toggle
        $(toggleBtn).on('click', function(e) {
            e.preventDefault();

            //Enable sidebar push menu
            if ($(window).width() > (767)) {
                if ($("body").hasClass('sidebar-collapse')) {
                    $("body").removeClass('sidebar-collapse').trigger('expanded.pushMenu');
                } else {
                    $("body").addClass('sidebar-collapse').trigger('collapsed.pushMenu');
                }
            }
            //Handle sidebar push menu for small screens
            else {
                if ($("body").hasClass('sidebar-open')) {
                    $("body").removeClass('sidebar-open').removeClass('sidebar-collapse').trigger('collapsed.pushMenu');
                } else {
                    $("body").addClass('sidebar-open').trigger('expanded.pushMenu');
                }
            }
            if ($('body').hasClass('fixed') && $('body').hasClass('sidebar-mini') && $('body').hasClass('sidebar-collapse')) {
                $('.sidebar').css("overflow", "visible");
                $('.main-sidebar').find(".slimScrollDiv").css("overflow", "visible");
            }
            if ($('body').hasClass('only-sidebar')) {
                $('.sidebar').css("overflow", "visible");
                $('.main-sidebar').find(".slimScrollDiv").css("overflow", "visible");
            };
        });

        $(".content-wrapper").on('click', function() {
            //Enable hide menu when clicking on the content-wrapper on small screens
            if ($(window).width() <= (767) && $("body").hasClass("sidebar-open")) {
                $("body").removeClass('sidebar-open');
            }
        });
    }
};
$.tree = function(menu) {
    var _this = this;
    var animationSpeed = 200;
    $(document).on('click', menu + ' li a', function(e) {
        //Get the clicked link and the next element
        var $this = $(this);
        var checkElement = $this.next();

        //Check if the next element is a menu and is visible
        if ((checkElement.is('.treeview-menu')) && (checkElement.is(':visible'))) {
            //Close the menu
            checkElement.slideUp(animationSpeed, function() {
                checkElement.removeClass('menu-open');
                //Fix the layout in case the sidebar stretches over the height of the window
                //_this.layout.fix();
            });
            checkElement.parent("li").removeClass("active");
        }
        //If the menu is not visible
        else if ((checkElement.is('.treeview-menu')) && (!checkElement.is(':visible'))) {
            //Get the parent menu
            var parent = $this.parents('ul').first();
            //Close all open menus within the parent
            var ul = parent.find('ul:visible').slideUp(animationSpeed);
            //Remove the menu-open class from the parent
            ul.removeClass('menu-open');
            //Get the parent li
            var parent_li = $this.parent("li");

            //Open the target menu and add the menu-open class
            checkElement.slideDown(animationSpeed, function() {
                //Add the class active to the parent li
                checkElement.addClass('menu-open');
                parent.find('li.active').removeClass('active');
                parent_li.addClass('active');
            });
        }
        //if this isn't a link, prevent the page from being redirected
        if (checkElement.is('.treeview-menu')) {
            e.preventDefault();
        }
    });
};
// Activate sidenav treemenu
$.tree('.sidebar');
$.pushMenu.activate("[data-toggle='offcanvas']");
// side button js code end

// toggle full screen
function toggleFullScreen() {
    if (!document.fullscreenElement && // alternative standard method
        !document.mozFullScreenElement && !document.webkitFullscreenElement) { // current working methods
        if (document.documentElement.requestFullscreen) {
            document.documentElement.requestFullscreen();
        } else if (document.documentElement.mozRequestFullScreen) {
            document.documentElement.mozRequestFullScreen();
        } else if (document.documentElement.webkitRequestFullscreen) {
            document.documentElement.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
        }
    } else {
        if (document.cancelFullScreen) {
            document.cancelFullScreen();
        } else if (document.mozCancelFullScreen) {
            document.mozCancelFullScreen();
        } else if (document.webkitCancelFullScreen) {
            document.webkitCancelFullScreen();
        }
    }
}

// viral
// chat-sidebar
var ost = 0;
$(window).scroll(function() {
    var $window = $(window);
    var windowHeight = $(window).innerHeight();
    if ($window.width() <= 767) {
        var cOst = $(this).scrollTop();
        if (cOst == 0) {
            $('.showChat').removeClass('top-showChat').addClass('fix-showChat');
        } else if (cOst > ost) {
            $('.showChat').removeClass('fix-showChat').addClass('top-showChat');
        }
        ost = cOst;
    }
});

// Start [ Menu-bottom ]
$(document).ready(function() {
    $(".dropup-mega, .dropup").hover(function() {
        var dropdownMenu = $(this).children(".dropdown-menu");
        $(this).toggleClass("open");
    });
});


// End [ Menu ]
