var PAGE = (function () {
  var PAGE = {

    MODE: 'PRODUCTION'

  , getParam: function getParam(key) {
      var params = (window.location.search || '').split('&')
        , parts, i = 0

      for (; i < params.length; i += 1) {
        parts = params[i].split('=');
        if (parts[0].indexOf(key) != -1) {
          return parts[1];
        }
      }
      return null;
    }

  , cookieExists: function cookieExists(key) {
      var cookies = document.cookie.split(';')
        , i = 0;

      for (; i < cookies.length; i += 1) {
        if (cookies[i].indexOf(key) != -1) {
          return true;
        }
      }
      return false;
    }

  , setCookie: function setCookie(name, val) {
      document.cookie = name +'='+ val +'; path=/';
    }

  , isProductionDomain: function () {
    return /htmlandcsstutorial.com/.test(window.location.hostname);
  }

  , devmode: function (on) {
      if (on) {
        if (PAGE.MODE === 'PRODUCTION') {
          PAGE.console.log('entering devmode');
        }
        PAGE.setCookie('devmode', 1);
        PAGE.inDevmode = true;
        PAGE.MODE = 'DEV';
        return true;
      } else {
        if (PAGE.MODE === 'DEV') {
          PAGE.console.log('leaving devmode');
        }
        PAGE.MODE = 'PRODUCTION';
        PAGE.inDevmode = false;
        return false;
      }
    }
  };

  PAGE.console = {
    log: function () {
      if (console && typeof console.log === 'function') {
        console.log.apply(console, arguments);
      }
    }
  };
 
  PAGE.devmode(PAGE.cookieExists('devmode') || PAGE.getParam('devmode') || !PAGE.isProductionDomain());
  return PAGE;
}());