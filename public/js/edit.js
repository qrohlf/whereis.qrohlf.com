$(document).ready(function() {
  console.log('js load');
  $('.items-edit').on('keyup', 'span', function(e) {
    var item = $(this).closest('[data-id]');
    window.clearTimeout(item.data('timer'));
    var timer = setTimeout(function() {updateItem(item.attr('data-id'));}, 500);
    item.data('timer', timer);
    console.log('keyup event');
    console.log(item);
  });

  function updateItem(id) {
    console.log('updating '+id);
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
    $('.spinner', span).css({display: 'inline-block', opacity: '1'});
    $('.icon-remove', span).css('opacity', '0');
  }

  function trash(span) {
    $('.spinner', span).css({opacity: '0'});
    setTimeout(function() {$('.spinner', span).hide()}, 300); //set display: none for performance reasons
    $('.icon-remove', span).css('opacity', '1');
  }

});