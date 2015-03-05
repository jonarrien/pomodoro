class Pomodoro
  current_task: null

  constructor: () ->
    console.log(':::::::::::::::::::::::::::::::::::::')
    console.log(':: Starting pomodoro app');
    console.log(':::::::::::::::::::::::::::::::::::::')

    @fbase = new Firebase("https://brilliant-heat-2062.firebaseio.com/")
    @tasks_index = @fbase.child('tasks')
    do @enableFirebaseEvents

  startStop: () ->
    if @current_task
      do @stopCurrentTask
      @current_task = null
    else
      if $('#task-title').val() != ''
        @current_task = new Task
          title: $('#task-title').val()
        @startTask(@current_task)
      else
        alert 'Please, add a title for this task'

  startTask: (@current_task) ->
    @current_task.start_time = Date.now()
    @tasks_index.push
      id: @current_task.id
      title: @current_task.title
      date: @current_task.start_time

    setInterval @updateTimer, 1000
    $('.pomodoro-app .panel-heading').show()
    $('.pomodoro-app .panel-body input').attr('disabled', true)
    $('#startstop').addClass('btn-danger').removeClass('btn-success').html('Stop')

  stopCurrentTask: () ->
    $('.pomodoro-app .panel-heading').hide()
    $('.pomodoro-app .panel-body input').attr('disabled', false).val('')
    $('#startstop').removeClass('btn-danger').addClass('btn-success').html('Start')

  updateTimer: () ->
    spent_time = Date.now() - pomodoro.current_task.start_time
    minutes = Math.floor(spent_time / 60000)
    minutes = '0'+minutes if minutes < 10
    seconds = ((spent_time % 60000) / 1000).toFixed(0)
    seconds = '0'+seconds if seconds < 10
    $('#timer').html minutes+":"+seconds

  enableFirebaseEvents: ->
    @tasks_index.on 'value', (snapshot) ->
      $('#tasks').html('')
      tasks = snapshot.val()
      for key in Object.keys(tasks)
        new Task(tasks[key]).render()
    , (errorObject) ->
      console.log("The read failed: " + errorObject.code);

class Task
  id: null
  start_time: null
  end_time: null

  constructor: (@obj) ->
    _.extend @, obj
    @id = do generateId unless @id

  render: () ->
    li = $('<li>').addClass('list-group-item')
    btn = $('<a>').addClass('btn btn-xs btn-danger pull-right')
    btn.append $('<i>').addClass('fa fa-times')
    btn.append '&nbsp;Delete'
    li.append(btn).append(@title)
    $('#tasks').append(li)

  generateId = ->
    chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    today = new Date()
    result = today.valueOf().toString 16
    result += chars.substr Math.floor(Math.random() * chars.length), 1
    result += chars.substr Math.floor(Math.random() * chars.length), 1

$ ->

  window.pomodoro = new Pomodoro
  $('#startstop').on 'click', $.proxy(pomodoro.startStop, pomodoro)

