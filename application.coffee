class Pomodoro
  constructor: () ->
    console.log(':::::::::::::::::::::::::::::::::::::')
    console.log(':: Starting pomodoro app');
    console.log(':::::::::::::::::::::::::::::::::::::')

    @fbase = new Firebase("https://brilliant-heat-2062.firebaseio.com/")
    @tasks_index = @fbase.child('tasks')
    do @enableEvents

  startTask: (task) ->
    console.log(':: Task started')
    task.start_time = Date.now()

    @tasks_index.push
      id: task.id
      title: task.title
      date: task.start_time

  enableEvents: ->
    @tasks_index.on 'value', (snapshot) ->
      tasks = snapshot.val()
      $('#tasks').html('')
      for key in Object.keys(tasks)
        li = $('<li>').addClass('list-group-item')
        obj = tasks[key]
        li.append obj.title
        $('#tasks').append(li)
    , (errorObject) ->
      console.log("The read failed: " + errorObject.code);

class Task
  id: null
  start_time: null
  end_time: null

  constructor: (@title) ->
    @id = do generateId

  generateId = ->
    chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    today = new Date()
    result = today.valueOf().toString 16
    result += chars.substr Math.floor(Math.random() * chars.length), 1
    result += chars.substr Math.floor(Math.random() * chars.length), 1

$ ->

  pomodoro = new Pomodoro

  $('#startstop').on 'click', (e) ->
    if $('#task-title').val() != ''
      task = new Task $('#task-title').val()
      pomodoro.startTask(task)
    else
      alert 'Please, add a title for this task'
