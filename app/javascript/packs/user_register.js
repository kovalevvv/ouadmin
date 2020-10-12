$(document).ready(function(){
  $('form').on('keyup change paste', 'input, select, textarea', function(){
    $('#alert').slideUp()
  })
})