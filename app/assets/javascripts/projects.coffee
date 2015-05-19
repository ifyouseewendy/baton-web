$(document).on 'ready', ->
  $(".project-delete").on 'click', ->
    return confirm('Are you sure?')

  $(".project-edit").on 'click', ->
    project_id = $(this).closest('tr').attr('data-project-id')
    console.log(project_id)

    edit_project_form = $('#edit-project-form')
    $.ajax
      url: "/projects/"+project_id
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        edit_project_form.find('form').attr('action', '/projects/'+project_id)
        edit_project_form.find('#project_name').attr('value', data['name'])
        edit_project_form.find('#project_platform').attr('value', data['platform'])
        edit_project_form.find('#project_category option:nth-child('+data['category_index']+')').attr('selected', 'selected')

    edit_project_form.modal()
