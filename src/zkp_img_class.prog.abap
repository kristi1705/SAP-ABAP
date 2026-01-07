*&---------------------------------------------------------------------*
*& Include          ZKP_IMG_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_image_viewer DEFINITION.

  PUBLIC SECTION.

    METHODS: constructor IMPORTING iv_url  TYPE char255 OPTIONAL
                                   iv_html TYPE abap_bool,

      execute IMPORTING iv_ok_code TYPE syucomm.

  PRIVATE SECTION.

    TYPES: tt_html TYPE STANDARD TABLE OF char255.

    DATA: mo_container TYPE REF TO cl_gui_custom_container,
          mv_url       TYPE char255.

    METHODS: create_container,

      html_display,

      build_html EXPORTING et_html TYPE tt_html,

      image_display.

ENDCLASS.

CLASS lcl_image_viewer IMPLEMENTATION.

  METHOD constructor.

    mv_url = iv_url.

    create_container( ).

    CASE iv_html.

      WHEN abap_true.

        html_display( ).

      WHEN abap_false.

        image_display( ).

    ENDCASE.

  ENDMETHOD.

  METHOD execute.

    CASE iv_ok_code.

      WHEN 'FC_BACK'.

        LEAVE TO SCREEN 0.

    ENDCASE.

  ENDMETHOD.

  METHOD create_container.

    IF mo_container IS INITIAL.

      CREATE OBJECT mo_container
        EXPORTING
          container_name              = 'GS_SCR_100-CONTAINER'
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          OTHERS                      = 6.

      IF sy-subrc <> 0.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD html_display.

    DATA: lo_html_cont  TYPE REF TO cl_gui_html_viewer,
          lv_url(255)   TYPE c,
          lt_html_table TYPE STANDARD TABLE OF char255.

    IF lo_html_cont IS INITIAL.

      CREATE OBJECT lo_html_cont
        EXPORTING
          parent             = mo_container
        EXCEPTIONS
          cntl_error         = 1
          cntl_install_error = 2
          dp_install_error   = 3
          dp_error           = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

      ENDIF.

    ENDIF.

    build_html( IMPORTING et_html = lt_html_table ).

    lo_html_cont->load_data(
      EXPORTING
        type                   = 'text'
        subtype                = 'html'
      IMPORTING
        assigned_url           = lv_url
      CHANGING
        data_table             = lt_html_table[]
      EXCEPTIONS
        dp_invalid_parameter   = 1
        dp_error_general       = 2
        cntl_error             = 3
        html_syntax_notcorrect = 4
        OTHERS                 = 5
    ).

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    ENDIF.

    lo_html_cont->show_url(
      EXPORTING
        url                    = lv_url
      EXCEPTIONS
        cntl_error             = 1
        cnht_error_not_allowed = 2
        cnht_error_parameter   = 3
        dp_error_general       = 4
        OTHERS                 = 5 ).

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    ENDIF.

  ENDMETHOD.

  METHOD build_html.

    DATA: lv_image_tag TYPE char255.

    APPEND '<html>' TO et_html.
  APPEND '<title>Image Viewer</title>' TO et_html.
  APPEND '<style type="text/css">' TO et_html.

  APPEND 'table { border-collapse: collapse; width: 100%; }' TO et_html.
  APPEND 'td { border: 1px solid #ddd; padding: 20px; text-align: center; }' TO et_html.
  APPEND 'img { max-width: 100%; max-height: 500px; }' TO et_html.

  APPEND '</style>' TO et_html.
  APPEND '<body>' TO et_html.

  APPEND '<table>' TO et_html.
  APPEND '<tr><td>' TO et_html.

  IF mv_url IS NOT INITIAL.
    CONCATENATE '<img src="' mv_url '" alt="Image">' INTO lv_image_tag.
    APPEND lv_image_tag TO et_html.
  ENDIF.

  APPEND '</td></tr>' TO et_html.
  APPEND '</table>' TO et_html.
  APPEND '</body></html>' TO et_html.

  ENDMETHOD.

  METHOD image_display.

    DATA: lo_img_cont TYPE REF TO cl_gui_picture,
          lv_objid    TYPE w3objid VALUE 'ZKP_IMAGE',
          lv_url      TYPE cndp_url.

    IF lo_img_cont IS INITIAL.

      CREATE OBJECT lo_img_cont
        EXPORTING
          parent = mo_container
        EXCEPTIONS
          error  = 1
          OTHERS = 2.

      IF sy-subrc <> 0.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

      ENDIF.

    ENDIF.

    IF lo_img_cont IS NOT INITIAL.

      CALL FUNCTION 'DP_PUBLISH_WWW_URL'
        EXPORTING
          objid                 = lv_objid
          lifetime              = cndp_lifetime_transaction
        IMPORTING
          url                   = lv_url
        EXCEPTIONS
          dp_invalid_parameters = 1
          no_object             = 2
          dp_error_publish      = 3
          OTHERS                = 4.

      IF sy-subrc = 0.

        lo_img_cont->load_picture_from_url_async(
          EXPORTING
            url    = lv_url
          EXCEPTIONS
            error  = 1
            OTHERS = 2 ).

        IF sy-subrc <> 0.

          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
