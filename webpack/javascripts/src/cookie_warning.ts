$(document).ready(function(){
    setTimeout(function () {
        if (localStorage.getItem('openProject-cookie-accepted') !== 'true') {
            $("#cookie-warning").fadeIn(200);
        }
    }, 1500);
    $(".cookie-warning--submit").click(function() {
        localStorage.setItem('openProject-cookie-accepted', 'true');
        $("#cookie-warning").fadeOut(200);
    });
});