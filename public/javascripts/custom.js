$(document).ready(function(){

    //When Mouse rolls over li
    $("li").mouseover(function(){
        $(this).stop().animate({height:'60px'},{queue:false, duration:600, easing: 'easeOutBounce'})
    });

    //When Mouse cursor removed from li
    $("li").mouseout(function(){
        $(this).stop().animate({height:'30px'},{queue:false, duration:600, easing: 'easeOutBounce'})
    });

});