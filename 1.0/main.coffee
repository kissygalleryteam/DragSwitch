KISSY.add (S, Node, Event, UA) ->

  $ = KISSY.all
  abs = Math.abs

  if UA.webkit
    cPrefix = "-webkit-"
    jPrefix = "webkit"
  else if UA.firefox
    cPrefix = "-moz-"
    jPrefix = "moz"
  else if UA.ie
    cPrefix = "-ms-"
    jPrefix = "ms"
  else
    cPrefix = jPrefix = ""

  defaultConfig =
    senDistance : 1
    angle       : Math.PI / 4
    isEnabled   : null
    disable     : false
    binds       : [null, null, null, null,
            moveSelf       : true
            moveEls        : []
            maxDistance    : 99999    # 注意正负值
            validDistance  : null   
            # passCallback : null  # 改为自定义事件
            # failCallback : null
            isEnabled      : null
            friction       : false
            transition     : true
    ]

  # DOM.addStyleSheet """
  #   .disableTransition {
  #     #{cPrefix}transition: none !important;
  #   }
  # """ 
  
  getMatrix = (el)->
    el.css "#{cPrefix}transform"

  setMatrix = (el, matrix)->
    el[0].style["#{jPrefix}Transform"] = matrix

  saveMatrixState = (els)->
    for el in els
      el.matrixState = getMatrix el

  restoreMatrixState = (els)->
    for el in els
      setMatrix el, el.matrixState

  cleanMatrix = (els)->
    for el in els
      el[0].style["#{jPrefix}Transform"] = ""

  getTransition = (el)->
    el[0].style["#{jPrefix}Transition"]

  setTransition = (el, transition)->
    el[0].style["#{jPrefix}Transition"] = transition 

  disableTransition = (els)->
    for el in els
      el.transitionState = getTransition el
      setTransition el, "none"

  restoreTransition = (els)->
    for el in els
      setTransition el, el.transitionState

  translate = (currentMatrix, distance, hori)->
    matrix = parseMartix currentMatrix
    matrix[4] += distance * hori
    matrix[5] += distance * (1 - hori)
    "matrix(" + matrix.join(',') + ")"
#      if UA.webkit
#        (new WebKitCSSMatrix(currentMatrix)).translate(distance * hori, distance * (1 - hori)).toString()

  parseMartix = (currentMatrix)->
    currentMatrix = "matrix(1,0,0,1,0,0)" if !currentMatrix
    matrix = currentMatrix.match /[0-9\.\-]+/g
    matrix = [1,0,0,1,0,0] if !matrix
    matrix.forEach (item, key)-> matrix[key] = parseFloat(item)
    return matrix
  


  class DragSwitch
    constructor: (@el, @config)->
      S.mix @, S.Event.Target
      @init()

    init: ->
      @config = S.merge(defaultConfig, @config)
      @disable = @config.disable
      @isSelector = true if typeof @el is "string"
      @el = $(@el) if !@isSelector
      @realEl = $ @el
      @tanAngel = Math.tan(@config.angle)
      for item in @config.binds
        continue if !item or !item.moveEls
        item.moveSelf = true if !item.moveSelf?
        for value, key in item.moveEls
          item.moveEls[key] = $(value)
      @bindEvents()

    bindEvents: ->
      if @isSelector
        $('body').delegate "touchstart", @el, (ev) => @touchStart(ev)
        $('body').delegate "touchmove", @el, (ev) => @touchMove(ev)
        $('body').delegate "touchend", @el, (ev) => @touchEnd(ev)
      else
        @el.on "touchstart", (ev) => @touchStart(ev)
        @el.on "touchmove", (ev) => @touchMove(ev)
        @el.on "touchend", (ev) => @touchEnd(ev)

    touchStart: (e)->
      return if @disable
      @fire "touchStart", e
      @enabled = if @config.isEnabled then @config.isEnabled() else true # 外部检查
      return if !@enabled
      ev = e.originalEvent || e # kissy mini 只有原生事件对象
      @istouchStart = true
      @isSendStart = false
      @eventType = null
      @key = null
      @actuMoveEls = []
      @startPoint = [ev.touches[0].pageX, ev.touches[0].pageY]
      @originalEl = if @isSelector && parent = $(ev.target).parent(@el) then parent else $(ev.currentTarget)

    touchMove: (e)->
      return if !@istouchStart
      return if @isSendStart && !@effectBind
      ev = e.originalEvent || e # kissy mini 只有原生事件对象
      point = [ev.touches[0].pageX, ev.touches[0].pageY]
      oPoint = @startPoint
      angleDelta = abs((oPoint[1] - point[1]) / (point[0] - oPoint[0])) # 这是水平方向的
      distance = [point[0] - oPoint[0], point[1] - oPoint[1]]
      if !@isSendStart and angleDelta > @tanAngel and 1 / angleDelta > @tanAngel
        @istouchStart = false
        return
      else if !@eventType
        if angleDelta <= @tanAngel && abs(distance[0]) > @config.senDistance # 水平
          @eventType = (if distance[0] > 0 then "left" else "right")
        else if 1 / angleDelta <= @tanAngel && abs(distance[1]) > @config.senDistance # 垂直
          @eventType = (if distance[1] > 0 then "top" else "bottom")
        else
          return
        @key = (if @eventType is "top" then 0 else (if @eventType is "right" then 1 else (if @eventType is "bottom" then 2 else (if @eventType is "left" then 3 else null))))
        @isVertical = 1 - @key % 2
        @effectBind = @config.binds[@key]
        return if !@effectBind
        @effectBind.passed = false
        @moveEls = @effectBind.moveEls
        @actuMoveEls = @moveEls.slice()
        @actuMoveEls.push @originalEl if @effectBind.moveSelf
        saveMatrixState @actuMoveEls
        @enabled = do=>
          if @effectBind.isEnabled 
            @effectBind.isEnabled.call @, e 
          else 
            true
        disableTransition(@actuMoveEls);

      return if !@eventType or !@enabled or !@effectBind

      # 已进入，禁止继续传递 
      e.stopPropagation()

      if !@isSendStart
        @isSendStart = true
        @fire @eventType + "BeforeMove", e
      @fire @eventType + "Move", e
      if !e.isDefaultPrevented()
        e.halt()
        @move point

    touchEnd: (e)->
      return if !@eventType or !@enabled or !@effectBind
      if @istouchStart and @isSendStart
        @touchEndHandler(e)
      # @istouchStart = false
      # @isSendStart = false
      # @eventType = null

    touchEndHandler: (e)->
      restoreTransition(@actuMoveEls)
      if @effectBind.transition
        @transitionEndHandler()        

      if abs(@distance) >= abs(@effectBind.validDistance)
        @effectBind.passed = true
        cleanMatrix(@actuMoveEls)
        @fire "#{@eventType}Passed", e
      else
        # 复原
        restoreMatrixState(@actuMoveEls)
      @fire @eventType + "TouchEnd touchEnd", e

    transitionEndHandler: ->
      # 计算时间
      speed = abs(@_startPoint - @_lastPoint) / (@startTimeS - @lastTimeS)
      speed = 4
      remain = abs(@effectBind.maxDistance - @distance)
      duration = remain / speed + "ms"
      @actuMoveEls.forEach (el)->
        setTransition el, "#{cPrefix}transform #{duration} ease"

      # 只取第一个触发 transitionEnd 事件
      transitionEnd = =>
        @fire "#{@eventType}MoveEnd", e
        # cleanTransition(@actuMoveEls)
        @actuMoveEls[0].detach "#{jPrefix}TransitionEnd", transitionEnd

      @actuMoveEls[0].on "#{jPrefix}TransitionEnd", transitionEnd

    # 需要去除 sense 值
    move: (@endPoint)->
      if @effectBind.transition
        # 保存状态
        @lastTimeS = if @startTimeS then @startTimeS else null
        @startTimeS = new Date
        @_lastPoint = if @_startPoint then @_startPoint else null
        @_startPoint = 
          (if @isVertical then @endPoint[1] else @endPoint[0])
      
      _distance = 
        (if @isVertical then @endPoint[1] - @startPoint[1] else @endPoint[0] - @startPoint[0])
      positiveDirt = @key is 0 or @key is 3
      if positiveDirt
        @distance = _distance - @config.senDistance
      else
        @distance = _distance + @config.senDistance

      # 摩擦力效果
      if @effectBind.friction && @effectBind.maxDistance && abs(@distance) > abs(@effectBind.maxDistance)
        dis = Math.sqrt(abs(rawDistance - @effectBind.maxDistance) * 5)
        dis = -dis if !positiveDirt
        @distance = rawDistance = @effectBind.maxDistance + dis

      for el in @actuMoveEls
        setMatrix el, translate(el.matrixState, @distance, !@isVertical)
,
  requires: ["node", "event", "ua"]

