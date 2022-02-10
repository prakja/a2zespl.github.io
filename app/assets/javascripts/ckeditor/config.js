/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.plugins.addExternal( 'texzilla', '/assets/ckeditor/plugins/texzilla/', 'plugin.js' );
CKEDITOR.plugins.addExternal( 'autogrow', '/assets/ckeditor/plugins/autogrow/', 'plugin.js' );
CKEDITOR.plugins.addExternal( 'mathjax', '/assets/ckeditor/plugins/mathjax/', 'plugin.js' );
CKEDITOR.plugins.addExternal( 'youtube', '/assets/ckeditor/plugins/youtube/', 'plugin.js' );
//CKEDITOR.plugins.addExternal( 'katex', '/assets/ckeditor/plugins/katex/', 'plugin.js' );
//

CKEDITOR.stylesSet.add( 'my_styles', [
  // Block-level styles.
  { name: 'Blue Title', element: 'h2', styles: { color: 'Blue' } },
  { name: 'Red Title',  element: 'h3', styles: { color: 'Red' } },

  // Inline styles.
  { name: 'CSS Style', element: 'span', attributes: { 'class': 'my_style' } },
  { name: 'Marker: Yellow', element: 'span', styles: { 'background-color': 'Yellow' } },
  { name: 'Math: No Break', element: 'span', styles: { 'white-space': 'nowrap' } }
]);

CKEDITOR.editorConfig = function( config )
{
  config.extraPlugins = 'texzilla,autogrow,mathjax,youtube';
  config.mathJaxLib = '//cdn.jsdelivr.net/npm/mathjax@2.7.5/MathJax.js?config=TeX-MML-AM_CHTML';

  config.autoGrow_minHeight = 200;
  config.autoGrow_maxHeight = 600;
  config.autoGrow_bottomSpace = 50;
  config.allowedContent = true;
  config.contentsCss = 'https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css';
  config.enterMode = CKEDITOR.ENTER_BR;
  config.autoParagraph = false;
  config.fillEmptyBlocks = false;
  config.youtube_responsive = true;
  config.youtube_related = false;
  config.youtube_privacy = true;

  config.youtube_disabled_fields = ['chkAutoplay', 'chkResponsive', 'chkRelated', 'chkOlderCode', 'chkPrivacy', 'chkNoEmbed', 'chkControls'];

  // Define changes to default configuration here. For example:
  // config.language = 'fr';
  // config.uiColor = '#AADC6E';

  /* Filebrowser routes */
  // The location of an external file browser, that should be launched when "Browse Server" button is pressed.
  config.filebrowserBrowseUrl = "/ckeditor/attachment_files";

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Flash dialog.
  config.filebrowserFlashBrowseUrl = "/ckeditor/attachment_files";

  // The location of a script that handles file uploads in the Flash dialog.
  config.filebrowserFlashUploadUrl = "/ckeditor/attachment_files";

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Link tab of Image dialog.
  config.filebrowserImageBrowseLinkUrl = "/ckeditor/pictures";

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Image dialog.
  config.filebrowserImageBrowseUrl = "/ckeditor/pictures";

  // The location of a script that handles file uploads in the Image dialog.
  config.filebrowserImageUploadUrl = "/generics/ckeditor/file-upload?";

  // The location of a script that handles file uploads.
  config.filebrowserUploadUrl = "/ckeditor/attachment_files";

  config.allowedContent = true;
  config.filebrowserUploadMethod = 'form';

  // For inline style definition.
  config.stylesSet = 'my_styles';

  // Toolbar groups configuration.
  config.toolbar = [
    { name: 'document', groups: [ 'mode', 'document', 'doctools' ], items: [ 'Source'] },
    { name: 'clipboard', groups: [ 'clipboard', 'undo' ], items: [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ] },
    // { name: 'editing', groups: [ 'find', 'selection', 'spellchecker' ], items: [ 'Find', 'Replace', '-', 'SelectAll', '-', 'Scayt' ] },
    // { name: 'forms', items: [ 'Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField' ] },
    { name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] },
    { name: 'insert', items: [ 'Image', 'Youtube' ,'Flash', 'Table', 'HorizontalRule', 'SpecialChar', 'texzilla', 'Mathjax' ] },
    { name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ], items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock' ] },
    '/',
    { name: 'styles', items: [ 'Styles', 'Format', 'Font', 'FontSize' ] },
    { name: 'colors', items: [ 'TextColor', 'BGColor' ] },
    { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ], items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] }
  ];

  config.toolbar_mini = [
    { name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ], items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock' ] },
    { name: 'styles', items: [ 'Font', 'FontSize' ] },
    { name: 'colors', items: [ 'TextColor', 'BGColor' ] },
    { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ], items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
    { name: 'insert', items: [ 'Image', 'Table', 'HorizontalRule', 'SpecialChar' ] }
  ];
};
