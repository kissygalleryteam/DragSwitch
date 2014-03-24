## 综述

DragSwitch是一个拖拽切换组件。

* 版本：1.0
* 作者：筱谷
* demo：[http://gallery.kissyui.com/DragSwitch/1.0/demo/index.html](http://gallery.kissyui.com/DragSwitch/1.0/demo/index.html)

## 初始化组件
		
    S.use('gallery/dragswitch/1.0/index', function (S, DragSwitch) {
         var dragswitch = new DragSwitch(el, config);
    })
	

## API说明

    var dragswitch = new DragSwitch(el, {
        // 敏感度，当两个实例重叠时作为优先级判断用，值越低越优先触发，建议 8 以上
        senDistance : 10,
        // 手势识别角度，建议保持默认
        angle       : Math.PI / 4,
        // 值为 null/undefined 或方法，触摸时判断是否触发组件动作，类似 BeforeMove 事件，值为 null/undefined 或返回 true 时即有效
        checkEnabled  : null,
        // 是否已禁用
        disable     : false,
        // 绑定事件组，顺序为上右下左
        binds       : [
            {
                // 拖拽时是否移动 el
                moveSelf      : false,
                // 拖拽时一并移动的元素
                moveEls       : ['.wrap'],
                // 移动最大距离，注意正负值
                maxDistance   : headBarEl.height(),
                // 移动了多大距离才算是成功的拖拽，不区分正负值
                validDistance : headBarEl.height() / 2,
                // 值为 null/undefined 或方法，触摸时判断是否触发这个方式动作，值为 null/undefined 或返回 true 时即有效
                checkEnabled    : function() {
                    return !wrapEl.hasClass('search');
                },
                // 超过 maxDistance 时是否产生摩擦效果，否则将不移动
                friction       : false
                // 是否使用内置 transition 方法，否则可以自定义 CSS Transition
                transition     : true
            }, null, null, null
        ]
    });

    // 提供的事件类型：
    // touchStart
    // [top|right|bottom|left]BeforeMove
    // [top|right|bottom|left]Move
    // [top|right|bottom|left]TouchEnd
    // [top|right|bottom|left]Passed
    // [top|right|bottom|left]Failed
    // [top|right|bottom|left]MoveEnd

    dragswitch.on('rightBeforeMove', function(ev){
        console.log("Before");
        viewsEl.all('.view-wrap')[nowView - 1].style.cssText="display:block";
    })
    dragswitch.on('rightMoveEnd', function(ev){
        console.log("END!!!");
    })