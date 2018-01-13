/*!
 * froala_editor v2.6.2 (https://www.froala.com/wysiwyg-editor)
 * License https://froala.com/wysiwyg-editor/terms/
 * Copyright 2014-2017 Froala Labs
 */

(function (factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(['jquery'], factory);
    } else if (typeof module === 'object' && module.exports) {
        // Node/CommonJS
        module.exports = function( root, jQuery ) {
            if ( jQuery === undefined ) {
                // require('jQuery') returns a factory that requires window to
                // build a jQuery instance, we normalize how we use modules
                // that require this pattern but the window provided is a noop
                // if it's defined (how jquery works)
                if ( typeof window !== 'undefined' ) {
                    jQuery = require('jquery');
                }
                else {
                    jQuery = require('jquery')(root);
                }
            }
            return factory(jQuery);
        };
    } else {
        // Browser globals
        factory(window.jQuery);
    }
}(function ($) {

  

  // Extend defaults.
  $.extend($.FE.DEFAULTS, {

  });

  // Exclude double dots using negative lookahead: (?!\\\\.)
  $.FE.URLRegEx = '(^| |\\u00A0)((https?:\\/\\/(www\\.)?)?(([-a-zA-Z0-9@:%_\\+~#=]{2,256}\\.[-a-zA-Z0-9@:%_\\+~#=]{2,256}\\b((\\.|\/)[-a-zA-Z0-9@:%_\\+~#?&/=]{1,})*)|([\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}\\.[\\d]{1,3}([-a-zA-Z0-9@:%_\\+~#?&/=]*))))$';

  $.FE.PLUGINS.url = function (editor) {
    var rel = null;

    /*
     * Transform string into a hyperlink.
     */
    function _linkReplaceHandler (match, p1, p2) {

      var link = p2;

      // Convert email.
      if (editor.opts.linkConvertEmailAddress) {
        var regex = /^[\w._]+@[a-z\u00a1-\uffff0-9_-]+?\.[a-z\u00a1-\uffff0-9]{2,}$/i;

        if (regex.test(link) && !/^mailto:.*/i.test(link)) {
          link = 'mailto:' + link;
        }
      }

      if (!/^((http|https|ftp|ftps|mailto|tel|sms|notes|data)\:)/i.test(link)) {
        link = '//' + link;
      }

      return (p1 ? p1 : '') + '<a' + (editor.opts.linkAlwaysBlank ? ' target="_blank"' : '') + (rel ? (' rel="' + rel + '"') : '') + ' href="' + link + '">' + p2 + '</a>' ;
    }

    function _getRegEx () {
      return new RegExp($.FE.URLRegEx, 'gi');
    }

    /*
     * Convert link paterns from html into hyperlinks.
     */
    function _convertToLink (html) {

      if (editor.opts.linkAlwaysNoFollow) {
        rel = 'nofollow';
      }

      // https://github.com/froala/wysiwyg-editor/issues/1576.
      if (editor.opts.linkAlwaysBlank) {
        if (!rel) rel = 'noopener noreferrer';
        else rel += ' noopener noreferrer';
      }

      return html.replace(_getRegEx(), _linkReplaceHandler);
    }

    function _isA (node) {
      if (!node) return false;

      if (node.tagName === 'A') return true;

      if (node.parentNode && node.parentNode != editor.el) return _isA(node.parentNode);

      return false;
    }

    function _inlineType () {
      var range = editor.selection.ranges(0);
      var node = range.startContainer;

      if (!node || node.nodeType !== Node.TEXT_NODE) return false;

      if (_isA(node)) return false;

      if (_getRegEx().test(node.textContent)) {
        $(node).before(_convertToLink(node.textContent));

        node.parentNode.removeChild(node);
      }
      else if (node.previousSibling && node.previousSibling.tagName === 'A') {
        var text = node.previousSibling.innerText + node.textContent;

        if (_getRegEx().test(text)) {
          $(node.previousSibling).replaceWith(_convertToLink(text));

          node.parentNode.removeChild(node);
        }
      }
    }

    /*
     * Initialize.
     */
    function _init () {
      editor.events.on('paste.afterCleanup', function (html) {
        if ((new RegExp($.FE.URLRegEx,'gi')).test(html)) {

          return _convertToLink(html);
        }
      });

      editor.events.on('keydown', function (e) {
        var keycode = e.which;

        if (editor.selection.isCollapsed() && (keycode == $.FE.KEYCODE.ENTER || keycode == $.FE.KEYCODE.SPACE || keycode == $.FE.KEYCODE.PERIOD)) {
          _inlineType();
        }
      }, true);
    }

    return {
      _init: _init
    }
  }

}));
