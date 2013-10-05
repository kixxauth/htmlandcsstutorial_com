jQuery(function ($) {
  $('.subscribe-button').find('a').on('click', function (ev) {
    var $link = $(this);
    if (!/subscribe/.test($link.attr('href'))) {
      return;
    }
    ev.preventDefault();
    _kmq.push(['record', 'open subscription form', {'newsletter name': 'Promotional Developers'}]);
    $link.hide(600, showSubscriptionForm);
    return false;
  });

  $('#subscribe').on('submit', function (ev) {
    ev.preventDefault();

    var $form = $(this)
      , $email = $form.find('input[name="email"]')
      , email = $email.val()

    if (email.length < 3) {
      alert('The email part is required.');
      $email.focus().select();
      return false;
    }
    postSubscription($form, onSubscriptionSuccess);
    $form.fadeOut(200);
    return false;
  })

  function showSubscriptionForm() {
    $('#subscribe').slideDown(600);
  }

  function postSubscription($form, callback) {
    var url = $form.attr('action')
      , data = $form.serialize()
      , email = $form.find('input[name="email"]').val()
      , firstName = $form.find('input[name="first_name"]').val()

    _kmq.push(['identify', email]);
    _kmq.push(['set', {'first name': firstName || 'not provided'}]);
    _kmq.push(['record', 'subscribed to newsletter', {'newsletter name': 'Promotional Developers'}]);
    _kmq.push(['record', 'activated']);
    jQuery.post(url, data).always(callback);
  }

  function onSubscriptionSuccess() {
    $('.subscribe-thank-you').fadeIn(400);
  }
})
