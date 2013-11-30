class @Game
  constructor: () -> 
    @players = []
    @currPlayer = 0
    @rollOutput = $('#roll-output')
    @board = new Board
    @boardTransform = {
      transform: {
        x: 0
        y: 0
      }
      scale: {
        x: 0
        y: 0
      }
      rotation: 0
    }
    @tableWidth = window.innerWidth
    @tableHeight = window.innerHeight

    $('#roll-button').on("click", @turn)

  movePlayer: (player, steps, callback) ->
    if steps is 0
        callback()   
        return    

    position = player.move()
    tile = @board.tiles[position]
    playerMove = =>
      tween = new Kinetic.Tween {
        node: player.node
        x: @board.tiles[player.position].x * @board.edgeLength
        y: @board.tiles[player.position].y * @board.edgeLength
        duration: 0.3
        onFinish: =>
          steps = steps - 1
          @_movePlayer(player, steps, callback)        
      }
      tween.play()

    @rotateToTile(tile)
    @zoomToTile(tile, playerMove)

  _movePlayer: (player, steps, callback) ->
    if steps is 0
        callback()   
        return  
    
    position = player.move()
    tile = @board.tiles[position]
    tween = new Kinetic.Tween {
      node: player.node
      x: @board.tiles[player.position].x * @board.edgeLength
      y: @board.tiles[player.position].y * @board.edgeLength
      easing: Kinetic.Easings.EaseInOut
      duration: 0.3
      onFinish: =>
        steps = steps - 1
        @movePlayer(player, steps, callback)
    }
    tween.play()

    @rotateToTile(tile)
    @zoomToTile(tile)

  rotateToTile: (tile, callback) ->
    originX = 0.5
    originY = 0.5
    angle = Math.atan((tile.x-originX)/(tile.y-originY))
    # Always stay below origin (text upright)
    if originY > tile.y
      angle -= Math.PI

    # angle %= Math.PI
    @_rotateBoard({rotation: angle}, callback)

  zoomToTile: (tile, callback) ->
    tween = new Kinetic.Tween {
      node: @board.node
      offsetX: tile.x * @board.edgeLength
      offsetY: tile.y * @board.edgeLength
      scaleX: 5
      scaleY: 5
      duration: 0.3
      easing: Kinetic.Easings.EaseInOut
      onFinish: callback
    }
    tween.play()

  _rotateBoard: (transform, callback) ->
    tween = new Kinetic.Tween {
      node: @board.node
      x: @tableWidth/2
      y: @tableHeight/2
      offsetX: @tableWidth/2
      offsetY: @tableHeight/2
      rotation: transform.rotation
      easing: Kinetic.Easings.EaseInOut
      onFinish: callback
      duration: 0.3
    }
    tween.play()

  roll: =>
    roll = Math.ceil((Math.random())*6)
    @rollOutput.html(roll)

    roll

  turn: =>
    playerRoll = @roll()
    console.log playerRoll
    # TODO: Run player callback from previous turn if it exists
    @movePlayer @players[@currPlayer], playerRoll, () =>
        # TODO: Add miss turn logic to player
        tileResult = @board.tiles[@players[@currPlayer].position];
        console.log tileResult

        @currPlayer += 1
        if @currPlayer >= @players.length
          @currPlayer = 0
