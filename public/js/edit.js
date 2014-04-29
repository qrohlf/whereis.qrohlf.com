$(document).ready(function() {
  $('.items-edit').on('keyup', 'span[contenteditable]', function(e) {
    var item = $(this).closest('[data-id]');
    window.clearTimeout(item.data('timer'));
    var timer = setTimeout(function() {updateItem(item.attr('data-id'));}, 500);
    item.data('timer', timer);
  });

  $('.items-edit').on('click', 'button.delete', function(e) {
    var item = $(this).closest('[data-id]');
    var status = $(".status-icon", item);
    spinner(status);
    return true; //let the click event propagate and submit the form
  });

  function updateItem(id) {
    var div = $('[data-id="'+id+'"]');
    var title = $(".item-title", div).text();
    var content = $(".item-content", div).text();
    var status = $(".status-icon", div);
    spinner(status);
    var data = {_method:"put", title: title, content: content};
    $.post("/"+id, data, function(response) {
        trash(status);
    });
  }

  function spinner(span) {
    $('.icon-remove', span).css('opacity', '0');
    $('.spinner', span).css({display: 'inline-block', opacity: '1'});
  }

  function trash(span) {
    $('.spinner', span).css({opacity: '0'});
    setTimeout(function() {$('.spinner', span).hide()}, 300); //set display: none for performance reasons
    $('.icon-remove', span).css('opacity', '1');
  }

});