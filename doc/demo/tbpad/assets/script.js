setTimeout(function(){

    KISSY.config({
        debug: true,
        packages: {
            "libs": {
                path: "./assets"
            },
            "gallery/dragswitch" : {
                path: "../../../",
                ignorePackageNameInUri: true
            }
        }
    })

    KISSY.ready(function(S){

        Flipsnap('.slide');


        S.use(["node", "event", "gallery/dragswitch/1.0/"], function(S, Node, Event,DS){
            var $ = Node.all;

            var leftScrollEl = $('#J_LeftbarL'),
                sideEl = $('.slide'),
                articleEl = $('#J_ArticleContent');


            new IScroll(leftScrollEl[0]);
            new IScroll(articleEl[0]);


            leftScrollEl[0].addEventListener('touchstart', function(ev){
                ev.stopPropagation();
            }, false);

            sideEl[0].addEventListener('touchstart', function(ev){
                ev.stopPropagation();
            }, false)

            // leftScrollEl[0].addEventListener('touchmove', function(ev){
            //     ev.stopPropagation();
            // }, false);

            $('body').delegate('touchstart', '.J_TouchFB', function(ev){
                var el = $(ev.target),
                    disabled = false,
                    showed = false,
                    moved = false;
                // window.touchEnd = false;

                // 持续按着
                if(window.feedBackTimer) clearTimeout(feedBackTimer);
                window.feedBackTimer = setTimeout(function(){
                    if(!moved) {
                        el.addClass('touch-feedback');
                        showed = true;
                    }
                    // 100ms 内如果没有移动，且还在按着，则显示
                }, 100);

                el.on('touchmove', function(){
                    moved = true;
                    el.removeClass('touch-feedback');
                });

                // 快速点按
                el.on('touchend', function(){
                    clearTimeout(feedBackTimer);
                    if(!moved && !showed) {
                        el.addClass('touch-feedback');
                        // clearTimeout(feedBackTimer);
                        // 至少停留 100ms
                        window.feedBackTimer = setTimeout(function(){
                            el.removeClass('touch-feedback');
                            el.detach('touchend touchmove');
                        }, 100);
                    }
                    else {
                        el.removeClass('touch-feedback');
                        el.detach('touchend touchmove');
                    }
                });

            });



            document.documentElement.addEventListener('touchmove', function(ev){
                ev.preventDefault();
            });


            var wrapEl = $('.wrap'),
                headBarEl = wrapEl.one('.head-bar'),
                viewsEl = wrapEl.one('.views-content'),
                nowView = 1;
            var ds1 = new DS(viewsEl, {
                senDistance : 10,
                angle       : Math.PI / 4,
                checkEnabled  : null,
                inertiaMove : false,
                disable     : false,
                binds       : [
                    {
                        moveSelf      : false,
                        moveEls       : ['.wrap'],
                        maxDistance   : headBarEl.height(),    //注意正负值
                        validDistance : headBarEl.height() / 2,  
                        checkEnabled    : function() {
                            return !wrapEl.hasClass('search');
                        },
                        friction      : false,
                        transition    : true
                    }, 
                    {
                        moveSelf      : true,
                        moveEls       : [],
                        maxDistance   : wrapEl.width(),    //注意正负值
                        validDistance : 20, //wrapEl.width() / 10,   
                        checkEnabled    : function() {
                            return !(nowView === 3);
                        },
                        friction      : true,
                        transition    : true
                    }, 
                        null,
                    {
                        moveSelf      : true,
                        moveEls       : [],
                        maxDistance   : wrapEl.width(),    //注意正负值
                        validDistance : 20, //wrapEl.width() / 10, 
                        checkEnabled    : function() {
                            return !(nowView === 1);
                        },
                        friction      : true,
                        transition    : true
                    }
                ]
            });

            ds1.on('rightBeforeMove', function(ev){
                console.log("Before");
                viewsEl.all('.view-wrap')[nowView - 1].style.cssText="display:block";
            })
            ds1.on('rightMoveEnd', function(ev){
                console.log("END!!!");
            })
            ds1.on('rightPassed', function(ev){
                console.log("rightPassed");
                nowView++;
                viewsEl.removeClass("inview1 inview2 inview3");
                viewsEl.addClass("inview" + nowView);
            });
            ds1.on('leftPassed', function(ev){
                console.log("leftPassed");
                nowView--;
                viewsEl.removeClass("inview1 inview2 inview3");
                viewsEl.addClass("inview" + nowView);
            });
            ds1.on('topPassed', function(ev){
                wrapEl.attr("style", "");
                wrapEl.addClass('search');
                headBarEl.removeClass('before');
            });

            var leftBarEl = wrapEl.one('.left-bar'),
                barBGEl = leftBarEl.one('.bg'),
                barIcon = wrapEl.one('.left-bar-icon');

            barIcon.on('touchstart', function(ev){
                wrapEl.toggleClass('show-leftbar');
            });

            headBarEl.on('touchstart', function(ev){
                wrapEl.toggleClass('search');
                headBarEl.addClass('before');
            })

            // $('body').delegate('touchstart', '.J_NavLink', function(ev){
            //     ev.halt();
            //     wrapEl.addClass('show-article');
            // })
            // $('.article-detail').on('doubleTap', function(){
            //     wrapEl.addClass('close-article');
            //     wrapEl.on('webkitAnimationEnd', function(){
            //         wrapEl.removeClass('show-article close-article');
            //         wrapEl.detach('webkitAnimationEnd');
            //     })
            // })
        });
    });
}, 0);

