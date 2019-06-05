tinymce.PluginManager.add('placeholder', function(editor) {
  var placeholder_text = editor.getElement().getAttribute("data-placeholder") || editor.settings.placeholder;

  editor.on('init', function() {
    var doc = editor.getDoc(),
      body = editor.getBody(),
      element = editor.getElement();

    element.setAttribute('data-placeholder', '');

    var style = doc.createElement('style');
    style.id = 'mcePlaceholderStyle';
    style.type = 'text/css';
    style.innerHTML = '.mce-content-body:before{ content: attr(data-placeholder); color: rgba(0,0,0,0.4)}';
    doc.getElementsByTagName('head')[0].appendChild(style);

    editor.on('focus', onFocus);
    editor.on('blur', onBlur);
    // editor.on('change', onBlur);
    // editor.on('setContent', onBlur);

    function onFocus() {
      body.setAttribute('data-placeholder', '');
    }

    function onBlur() {
      if(editor.getContent() === '') {
        body.setAttribute('data-placeholder', placeholder_text); 
      } else {
        body.setAttribute('data-placeholder', '');
      }
    }

    onBlur();
  });
});
