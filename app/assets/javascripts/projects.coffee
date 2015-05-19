$(document).on 'ready', ->
  $(".project-delete").on 'click', ->
    return confirm('Are you sure?')

