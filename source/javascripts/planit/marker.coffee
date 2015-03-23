class Planit.Marker

  constructor: (@container, id) ->

    # Set Options
    @markersContainer = @container.find(".#{Planit.markerContainerClass}")
    if @container.find(".#{Planit.imageContainer} > img").length > 0
      @image = @container.find(".#{Planit.imageContainer} > img").first()

    # Find Marker
    @marker = @markersContainer.find(
      ".#{Planit.markerClass}[data-marker='#{id}']"
    ).first()

    # Return this
    @

  # ======================================================== Create New Marker

  @create: (options) ->
    # local references
    container = options.container
    markersContainer = container.find(".#{Planit.markerContainerClass}").first()
    # set options
    options.planitID = Planit.randomString(20) unless options.planitID
    if options.color then color = options.color else color = '#FC5B3F'
    # find position
    left = ((parseFloat(options.coords[0]) / 100) * container.width()) - 15
    top = ((parseFloat(options.coords[1]) / 100) * container.height()) - 15
    # create the marker
    markersContainer.append(
      $('<div></div>')
        .addClass(Planit.markerClass)
        .attr
          'data-marker': options.planitID
          'data-xPc': options.coords[0]
          'data-yPc': options.coords[1]
        .css
          left: "#{left}px"
          top: "#{top}px"
          backgroundColor: color
    )
    # find the marker
    marker = markersContainer.find(".#{Planit.markerClass}").last()
    # add content and styles if passed as options
    if options.id
      marker.attr('data-id': options.id)
    if options.class
      marker.addClass(options.class)
    if options.html
      marker.html(options.html)
    if options.size
      marker.css
        width: "#{options.size}px"
        height: "#{options.size}px"
    # setup draggable if necessary
    if options.draggable
      marker.addClass('draggable')
      marker.on 'mousedown', (e) =>
        if e.which == 1
          marker = $(e.target).closest(".#{Planit.markerClass}")
          marker.addClass(Planit.draggingClass)
          marker.attr
            'data-drag-start-x': e.pageX
            'data-drag-start-y': e.pageY
    # setup infobox if necessary
    if options.infobox
      id = Planit.randomString(16)
      # set style options on infobox
      infobox = options.infobox
      if infobox.position then position = infobox.position else position = 'top'
      if infobox.arrow then arrow = true else arrow = false
      if arrow == true then arrowClass = 'arrow' else arrowClass = ''
      classes = "#{Planit.infoboxClass} #{position} #{arrowClass}"
      # add infobox
      container.find(".#{Planit.infoboxContainerClass}").append """
        <div class="#{classes}" id="info-#{id}"
          data-position="#{position}">
            #{infobox.html}
        </div>
          """
      # add post-options if necessary
      if infobox.offsetX
        container.find(".#{Planit.infoboxClass}").last().attr
          'data-offset-x': infobox.offsetX
      if infobox.offsetY
        container.find(".#{Planit.infoboxClass}").last().attr
          'data-offset-y': infobox.offsetY
      marker.attr('data-infobox', "info-#{id}")
      m = new Planit.Marker(container, options.planitID)
      m.positionInfobox()
      m

  # ------------------------------------------ Calculations

  position: =>
    xPx = @marker.position().left + (@marker.outerWidth() / 2)
    yPx = @marker.position().top + (@marker.outerHeight() / 2)
    if @image
      wImg = @image.width()
      hImg = @image.height()
      xImg = parseInt(@image.css('left'))
      yImg = parseInt(@image.css('top'))
      xPc = ((xPx + Math.abs(xImg)) / wImg) * 100
      yPc = ((yPx + Math.abs(yImg)) / hImg) * 100
    else
      xPc = (xPx / @container.width()) * 100
      yPc = (yPx / @container.height()) * 100
    [xPc, yPc]

  relativePosition: =>
    xPx = @marker.position().left + (@marker.outerWidth() / 2)
    yPx = @marker.position().top + (@marker.outerHeight() / 2)
    xPc = (xPx / @container.width()) * 100
    yPc = (yPx / @container.height()) * 100
    [xPc, yPc]

  # ------------------------------------------ Attributes

  color: =>
    @marker.css('backgroundColor')

  planitID: =>
    @marker.attr('data-marker')

  id: =>
    @marker.attr('data-id')

  # ------------------------------------------ Infobox

  infobox: =>
    infobox = @container.find("##{@marker.attr('data-infobox')}")
    if infobox.length > 0 then infobox else null

  infoboxHTML: =>
    if @infobox() && @infobox().length > 0 then @infobox().html() else null

  infoboxVisible: =>
    @infobox() && @infobox().hasClass('active')

  hideInfobox: =>
    @infobox().addClass('hidden') if @infoboxVisible()

  showInfobox: =>
    @infobox().addClass('active') if @infobox() && !@infoboxVisible()
    @unhideInfobox()

  unhideInfobox: =>
    @infobox().removeClass('hidden') if @infoboxVisible()

  infoboxCoords: =>
    infobox = @container.find("##{@marker.attr('data-infobox')}")
    markerCenterX = (parseFloat(@relativePosition()[0] / 100) * @container.width())
    markerCenterY = (parseFloat(@relativePosition()[1] / 100) * @container.height())
    iWidth = infobox.outerWidth()
    iHalfWidth = iWidth / 2
    iHeight = infobox.outerHeight()
    iHalfHeight = iHeight / 2
    cWidth = @container.width()
    cHeight = @container.height()
    mWidth = @marker.outerWidth()
    mHalfWidth = mWidth / 2
    mHeight = @marker.outerHeight()
    mHalfHeight = mHeight / 2
    buffer = 5
    offsetX = parseInt(infobox.attr('data-offset-x'))
    offsetX = 0 unless offsetX
    offsetY = parseInt(infobox.attr('data-offset-y'))
    offsetY = 0 unless offsetY
    switch infobox.attr('data-position')
      when 'top'
        infoLeft = markerCenterX - iHalfWidth
        infoTop = markerCenterY - iHeight - mHalfHeight - buffer
      when 'right'
        infoLeft = markerCenterX + mHalfWidth + buffer
        infoTop = markerCenterY - iHalfHeight
      when 'bottom'
        infoLeft = markerCenterX - iHalfWidth
        infoTop = markerCenterY + mHalfHeight + buffer
      when 'left'
        infoLeft = markerCenterX - iWidth - mHalfWidth - buffer
        infoTop = markerCenterY - iHalfHeight
      when 'top-left'
        infoLeft = markerCenterX - iWidth - mHalfWidth + buffer
        infoTop = markerCenterY - iHeight - mHalfHeight + buffer
      when 'top-right'
        infoLeft = markerCenterX + mHalfWidth - buffer
        infoTop = markerCenterY - iHeight - mHalfHeight + buffer
      when 'bottom-left'
        infoLeft = markerCenterX - iWidth - mHalfWidth + buffer
        infoTop = markerCenterY + mHalfHeight - buffer
      when 'bottom-right'
        infoLeft = markerCenterX + mHalfWidth - buffer
        infoTop = markerCenterY + mHalfHeight - buffer
    left: infoLeft + offsetX
    top: infoTop + offsetY

  positionInfobox: =>
    coords = @infoboxCoords()
    @container.find("##{@marker.attr('data-infobox')}").css
      left: "#{coords.left}px"
      top: "#{coords.top}px"
    @position()

  animateInfobox: =>
    coords = @infoboxCoords()
    @container.find("##{@marker.attr('data-infobox')}").animate
      left: "#{coords.left}px"
      top: "#{coords.top}px"
    , 250, () =>
      return @position()

  # ------------------------------------------ Dragging

  isDraggable: =>
    @marker.hasClass('draggable')

  # ------------------------------------------ Actions

  set: =>
    left = (@image.width() * (@marker.attr('data-xPc') / 100)) +
      parseFloat(@image.css('left')) - (@marker.outerWidth() / 2)
    top = (@image.height() * (@marker.attr('data-yPc') / 100)) +
      parseFloat(@image.css('top')) - (@marker.outerHeight() / 2)
    @marker.css
      left: "#{left}px"
      top: "#{top}px"
    @positionInfobox()
    [left, top]

  savePosition: =>
    coords = @position()
    @marker.attr
      'data-xPc': coords[0]
      'data-yPc': coords[1]

  update: (options) =>
    if options.color
      @marker.css(backgroundColor: options.color)
    if options.infobox
      @marker.find(".#{Planit.infoboxClass}").html(options.infobox)
      @positionInfobox()
    if options.draggable
      @marker.removeClass('draggable')
      @marker.addClass('draggable') if options.draggable == true
    if options.coords
      left = ((parseFloat(options.coords[0]) / 100) * @container.width()) - 15
      top = ((parseFloat(options.coords[1]) / 100) * @container.height()) - 15
      @marker.css
        left: "#{left}px"
        top: "#{top}px"

  remove: =>
    @infobox().remove() if @infobox()
    @marker.remove()
