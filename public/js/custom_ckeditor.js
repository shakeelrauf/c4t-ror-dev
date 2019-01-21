/**
 * Copyright (c) 2003-2018, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license
 */

/* exported initSample */
function initCKEditor() {

    if ( CKEDITOR.env.ie && CKEDITOR.env.version < 9 ) {
        CKEDITOR.tools.enableHtml5Elements( document );
    }

    // The trick to keep the editor in the sample quite small
    // unless user specified own height.
    CKEDITOR.config.height = 200;
    CKEDITOR.config.width = 'auto';
    CKEDITOR.config.enterMode = CKEDITOR.ENTER_BR;
}

function isWysiwygareaAvailable() {
    // If in development mode, then the wysiwygarea must be available.
    // Split REV into two strings so builder does not replace it :D.
    if ( CKEDITOR.revision == ( '%RE' + 'V%' ) ) {
        return true;
    }

    return !!CKEDITOR.plugins.get( 'wysiwygarea' );
}


function initCKEditorArea(areaId) {

    var wysiwygareaAvailable = isWysiwygareaAvailable();
    // var isBBCodeBuiltIn = !!CKEDITOR.plugins.get( 'bbcode' );

    var editorElement = CKEDITOR.document.getById(areaId);

    // Depending on the wysiwygare plugin availability initialize classic or inline editor.
    if ( wysiwygareaAvailable ) {
        CKEDITOR.replace(areaId);
    } else {
        editorElement.setAttribute( 'contenteditable', 'true' );
        CKEDITOR.inline(areaId);
    }
}
