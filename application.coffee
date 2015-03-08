class Pomodoro
  current_task: null
  timer: null

  constructor: () ->
    @fbase = new Firebase("https://brilliant-heat-2062.firebaseio.com/")
    @tasks_index = @fbase.child('tasks')
    do @enableEvents

  startStop: () ->
    if @current_task
      do @stopCurrentTask
    else
      if $('#task-title').val() != ''
        @current_task = new Task({})
        @current_task.title = $('#task-title').val()
        @startTask(@current_task)
      else
        alert 'Please, add a title for this task'

  startTask: (@current_task) ->
    @current_task.start_time = Date.now()
    @fbase.child('current_task').set @current_task

  stopCurrentTask: ->
    @tasks_index.child(@current_task.id).set
      id: @current_task.id
      title: @current_task.title
      start_time: @current_task.start_time
      end_time: Date.now()
    do @fbase.child('current_task').remove
    @current_task = null

  updateTimer: ->
    if window.pomodoro.current_task
      spent_time = Date.now() - window.pomodoro.current_task.start_time
      $('#timer').html convertMiliToHuman spent_time
      if spent_time >= (25 * 60 * 1000)
        clearInterval(window.pomodoro.timer)
        do window.pomodoro.stopCurrentTask
    else
      clearInterval(window.pomodoro.timer)

  renderTasks: (snapshot) ->
    $('#tasks').html('')
    tasks = snapshot.val()
    for key in Object.keys(tasks)
      new Task(tasks[key]).render()

  displayCurrentTask: (snapshot) ->
    @current_task = snapshot.val()
    if @current_task
      do @updateTimer
      @timer = setInterval @updateTimer, 1000
      $('.pomodoro-app .panel-heading').show()
      $('.pomodoro-app #task-title').attr('disabled', true)
      $('#startstop').addClass('btn-danger').removeClass('btn-success').html('Stop')
      $('#task-title').val @current_task.title
    else
      $('#timer').html 'Pomodoro Finished!'
      $('.pomodoro-app #task-title').attr('disabled', false).val('')
      $('#startstop').removeClass('btn-danger').addClass('btn-success').html('Start')
      setTimeout ()->
        $('#timer').html '00:00'
        $('.pomodoro-app .panel-heading').fadeOut(900)
      , 2000

  enableEvents: ->
    @fbase.child('current_task').on 'value', $.proxy(@displayCurrentTask, @)
    @tasks_index.on 'value', $.proxy(@renderTasks, @)
    , (errorObject) ->
      console.log("The read failed: " + errorObject.code);
    $('.pomodoro-app').on 'click', 'li a.btn-delete', $.proxy(@deleteTask, @)
    $('.pomodoro-app').on 'click', 'li a.btn-play', $.proxy(@repeatTask, @)

  deleteTask: (e) ->
    id = $(e.target).parents('li').attr('id')
    do @tasks_index.child(id).remove

  repeatTask: (e) ->
    if @current_task
      alert 'You can not resume until you finish the current pomodoro'
    else
      @current_task = new Task
        title: $(e.target).parents('li').find('span').html()
        start_time: Date.now()
      delete @current_task.obj
      @fbase.child('current_task').set @current_task

class Task
  id: null
  start_time: null
  end_time: null

  constructor: (@obj) ->
    _.extend @, obj
    @id = do generateId unless @id

  spent_time: ->
    if @end_time then convertMiliToHuman(@end_time - @start_time) else '>>>>'

  render: () ->
    li = $('<li>').addClass('list-group-item').attr 'id', @id
    li.data('start_time', @start_time)

    btn_group = $('<div>').addClass('btn-group pull-right')
    btn_del = $('<a>').addClass('btn btn-xs btn-danger btn-delete')
    btn_del.append($('<i>').addClass('fa fa-times')).append '&nbsp;Delete'
    btn_con = $('<a>').addClass('btn btn-xs btn-default btn-play')
    btn_con.append($('<i>').addClass('fa fa-chevron-right')).append '&nbsp;Repeat'
    li.append btn_group.append(btn_con).append(btn_del)

    li.append $('<strong>').addClass('text-info').append @spent_time()+'&nbsp;'
    li.append $('<span>').append @title

    # li.append(btn_group).append(@spent_time()+'&nbsp;').append(@title)
    $('#tasks').append(li)

  generateId = ->
    chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    today = new Date()
    result = today.valueOf().toString 16
    result += chars.substr Math.floor(Math.random() * chars.length), 1
    result += chars.substr Math.floor(Math.random() * chars.length), 1

convertMiliToHuman = (milisecs) ->
  minutes = Math.floor(milisecs / 60000)
  minutes = '0'+minutes if minutes < 10
  seconds = ((milisecs % 60000) / 1000).toFixed(0)
  seconds = '0'+seconds if seconds < 10
  minutes+":"+seconds


$ ->

  window.pomodoro = new Pomodoro
  $('#startstop').on 'click', $.proxy(pomodoro.startStop, pomodoro)

