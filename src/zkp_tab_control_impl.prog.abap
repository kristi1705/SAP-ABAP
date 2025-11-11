*&---------------------------------------------------------------------*
*& Include          ZKP_TAB_CONTROL_IMPL
*&---------------------------------------------------------------------*

INCLUDE zkp_tab_control_def.

CLASS lcl_tab_control IMPLEMENTATION.

  METHOD get_ok_code_100.

    CASE iv_ok_code_100.

      WHEN 'FC_ENTER'.

        container_exists( EXPORTING iv_cn_100 = gs_scr_100-cn ).

        IF sy-subrc = 0.

          CLEAR gt_container.
          get_data( EXPORTING iv_cn_100    = gs_scr_100-cn
                    IMPORTING et_container = gt_container
                    CHANGING  cv_cn_110    = gs_scr_110-cn ).

        ENDIF.

    ENDCASE.

  ENDMETHOD.

  METHOD get_ok_code_110.

    CASE iv_ok_code_110.

      WHEN 'FC_SAVE'.

        save_to_db( EXPORTING iv_cn_110    = gs_scr_110-cn
                    CHANGING  ct_container = gt_container ).

      WHEN 'FC_UPLOAD'.

        upload_to_server( ).

      WHEN 'FC_STATUS'.

        screen_status( IMPORTING ev_screen_status = gv_screen_status ).

      WHEN 'FC_DLD'.

        download_excel( ).

      WHEN 'FC_EMAIL'.

        send_via_email( EXPORTING iv_cn_110 = gs_scr_110-cn ).

      WHEN 'FC_SHOW_DEL'.

        show_del_items( EXPORTING iv_cn_110    = gs_scr_110-cn
                                  iv_del_items = gs_scr_110-del
                        CHANGING  ct_container = gt_container ).

    ENDCASE.

  ENDMETHOD.

  METHOD container_exists.

    DATA: lv_cn_exists(6) TYPE c.

    SELECT SINGLE cn
      FROM zkp_container
      INTO lv_cn_exists
      WHERE cn = iv_cn_100.

    IF sy-subrc <> 0.

      confirm_choice( EXPORTING iv_cn_110 = iv_cn_100
                      CHANGING  cv_cn_110 = gs_scr_110-cn ).

    ENDIF.

  ENDMETHOD.

  METHOD confirm_choice.

    DATA: lv_choice TYPE c.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Create Container'
        text_question         = 'Do you want to create the container?'
        text_button_1         = 'Yes'(001)
        icon_button_1         = 'ICON_OKAY'
        text_button_2         = 'No'(002)
        icon_button_2         = 'ICON_CANCEL'
        display_cancel_button = ' '
      IMPORTING
        answer                = lv_choice
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.

    IF lv_choice = 001.

      cv_cn_110 = iv_cn_110.
      CALL SCREEN 110.

    ELSE.

      LEAVE TO SCREEN 100.

    ENDIF.

  ENDMETHOD.

  METHOD screen_status.

    IF ev_screen_status IS INITIAL.

      ev_screen_status = abap_true.

    ELSE.

      ev_screen_status = abap_false.

    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    SELECT mandt
           cn
           matnr
           maktx
           quant
           shift
           dats
           usern
           del
     FROM zkp_container
      INTO CORRESPONDING FIELDS OF TABLE et_container
      WHERE cn = iv_cn_100
      AND del = ' '.

    cv_cn_110 = iv_cn_100.
    CALL SCREEN 110.

  ENDMETHOD.

  METHOD show_del_items.

    DATA: lv_cn_exists(6) TYPE c.

    SELECT SINGLE cn
      FROM zkp_container
      INTO lv_cn_exists
      WHERE cn = iv_cn_110.

    IF sy-subrc = 0.

      CLEAR ct_container.

      CASE iv_del_items.

        WHEN 'X'.

          SELECT mandt
                 cn
                 matnr
                 maktx
                 quant
                 shift
                 dats
                 usern
                 del
          FROM zkp_container
          INTO CORRESPONDING FIELDS OF TABLE ct_container
          WHERE cn = lv_cn_exists.

        WHEN ' '.

          SELECT mandt
                 cn
                 matnr
                 maktx
                 quant
                 shift
                 dats
                 usern
                 del
           FROM zkp_container
           INTO CORRESPONDING FIELDS OF TABLE ct_container
           WHERE cn = lv_cn_exists
           AND del = ' '.

      ENDCASE.

    ENDIF.

  ENDMETHOD.

  METHOD save_to_db.

    DATA: ls_dbtab     TYPE ty_dbtab,
          lt_dbtab     TYPE tt_dbtab,
          ls_container TYPE ty_cl_container.

    CLEAR ls_container.

    LOOP AT ct_container INTO ls_container.

      IF ls_container-matnr IS INITIAL.

        DELETE ct_container INDEX sy-tabix.

      ELSE.

        ls_container-cn    = iv_cn_110.
        ls_container-dats  = sy-datum.
        ls_container-usern = sy-uname.
        MODIFY ct_container FROM ls_container INDEX sy-tabix.
        MOVE-CORRESPONDING ls_container TO ls_dbtab.
        APPEND ls_dbtab TO lt_dbtab.
        CLEAR: ls_dbtab, ls_container.

      ENDIF.

    ENDLOOP.

    MODIFY zkp_container FROM TABLE lt_dbtab.

    IF sy-subrc = 0.

      COMMIT WORK.
      MESSAGE 'Database successfully updated!' TYPE 'S'.
      CLEAR: lt_dbtab.

    ELSE.

      MESSAGE 'Error commiting changes!' TYPE 'S' DISPLAY LIKE 'E'.

    ENDIF.

  ENDMETHOD.

  METHOD convert_to_excel.

    DATA: ls_exceltab  TYPE ty_exceltab,
          lt_exceltab  TYPE tt_exceltab,
          ls_container TYPE ty_cl_container,
          lv_xstring   TYPE xstring.

    CLEAR: ls_container, lv_xstring, ls_exceltab, lt_exceltab.

    LOOP AT ct_container INTO ls_container.

      ls_container-cn    = iv_cn_110.
      ls_container-dats  = sy-datum.
      ls_container-usern = sy-uname.
      MODIFY ct_container FROM ls_container INDEX sy-tabix.
      MOVE-CORRESPONDING ls_container TO ls_exceltab.
      APPEND ls_exceltab TO lt_exceltab.
      CLEAR: ls_exceltab, ls_container.

    ENDLOOP.

    ev_row_count = lines( lt_exceltab ).

    GET REFERENCE OF lt_exceltab INTO DATA(lo_ref_tab).

    FIELD-SYMBOLS: <lt_ref_data> TYPE ANY TABLE.

    ASSIGN lo_ref_tab->* TO <lt_ref_data>.

    TRY.

        cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_tab)
        CHANGING t_table = <lt_ref_data> ).

        lv_xstring = lo_tab->to_xml( xml_type = if_salv_bs_xml=>c_type_xlsx ).

*        DATA(lt_fcat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
*                          r_columns      = lo_tab->get_columns( )
*                          r_aggregations = lo_tab->get_aggregations( ) ).
*
*        DATA(lo_result) = cl_salv_ex_util=>factory_result_data_table(
*                            r_data         = lo_ref_tab
*                            t_fieldcatalog = lt_fcat ).
*
*        CALL METHOD cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform(
*          EXPORTING
*            xml_version   = cl_salv_bs_a_xml_base=>get_version( )
*            r_result_data = lo_result
*            xml_type      = if_salv_bs_xml=>c_type_xlsx
*            xml_flavour   = if_salv_bs_c_tt=>c_tt_xml_flavour_export
*            gui_type      = if_salv_bs_xml=>c_gui_type_gui
*          IMPORTING
*            xml           = mv_xstring ).

      CATCH cx_root INTO DATA(lx_salv).

        MESSAGE lx_salv->get_longtext( ) TYPE 'E'.

    ENDTRY.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_xstring
      IMPORTING
        output_length = ev_filesize
      TABLES
        binary_tab    = mt_bin_tab.

  ENDMETHOD.

  METHOD upload_to_server.

    convert_to_excel( EXPORTING iv_cn_110 = gs_scr_110-cn
                      CHANGING  ct_container = gt_container ).

    CONCATENATE '/tmp/excel' sy-datum sy-uzeit '.excel' INTO DATA(lv_filepath).

    OPEN DATASET lv_filepath FOR OUTPUT IN BINARY MODE.

    IF sy-subrc = 0.

      LOOP AT mt_bin_tab INTO ms_bin_tab.

        TRANSFER ms_bin_tab-data TO lv_filepath.

      ENDLOOP.

      CLOSE DATASET lv_filepath.
      CLEAR: mt_bin_tab.

      MESSAGE 'Data successfully uploaded to server!' TYPE 'S'.

    ENDIF.

  ENDMETHOD.

  METHOD download_excel.

    DATA: lv_fullpath TYPE string,
          lv_filepath TYPE string,
          lv_filename TYPE string,
          lv_filesize TYPE i.

    convert_to_excel( EXPORTING iv_cn_110    = gs_scr_110-cn
                      IMPORTING ev_filesize  = lv_filesize
                      CHANGING  ct_container = gt_container ).

    CONCATENATE 'Excel Table ' sy-datum sy-uzeit '.xlsx' INTO DATA(lv_default_name).

    CALL METHOD cl_gui_frontend_services=>file_save_dialog
      EXPORTING
        window_title              = 'Select location to save Excel file'
        default_extension         = 'xlsx'
        file_filter               = '*.xlsx'
        default_file_name         = lv_default_name
      CHANGING
        filename                  = lv_filename
        path                      = lv_filepath
        fullpath                  = lv_fullpath
      EXCEPTIONS
        cntl_error                = 1
        error_no_gui              = 2
        not_supported_by_gui      = 3
        invalid_default_file_name = 4
        OTHERS                    = 5.
    IF sy-subrc <> 0.
*     Implement suitable error handling here
    ENDIF.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        bin_filesize            = lv_filesize
        filename                = lv_fullpath
        filetype                = 'BIN'
      CHANGING
        data_tab                = mt_bin_tab[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.

    IF sy-subrc = 0.

      MESSAGE: 'Excel file downloaded successfully!' TYPE 'S'.
      CLEAR: mt_bin_tab.

    ENDIF.

  ENDMETHOD.

  METHOD send_via_email.

    DATA: lo_send_request  TYPE REF TO cl_bcs,
          lo_document      TYPE REF TO cl_document_bcs,
          lo_recipient     TYPE REF TO if_recipient_bcs,
          lo_bcs_exception TYPE REF TO cx_bcs,
          lt_main_text     TYPE bcsy_text,
          ls_main_text     TYPE LINE OF bcsy_text,
          lv_subject       TYPE so_obj_des,
          lt_att_head      TYPE soli_tab,
          lv_filename      TYPE string,
          lv_text_line     TYPE soli,
          lv_mail_to       TYPE ad_smtpadr,
          lv_sent_to_all   TYPE os_boolean,
          lv_row_count     TYPE string,
          lv_filesize      TYPE i,
          lv_i_filesize    TYPE sood-objlen.

    convert_to_excel( EXPORTING iv_cn_110    = gs_scr_110-cn
                      IMPORTING ev_filesize  = lv_filesize
                                ev_row_count = lv_row_count
                      CHANGING  ct_container = gt_container ).

    lv_i_filesize = lv_filesize.
    lv_mail_to    = 'prova@gmail.com'.

    TRY.

        lo_send_request = cl_bcs=>create_persistent( ).

        CONCATENATE 'Hello, ' sy-uname INTO ls_main_text.
        APPEND ls_main_text TO lt_main_text.
        CLEAR ls_main_text.
        APPEND ls_main_text TO lt_main_text.
        CONCATENATE 'Please find attached all the materials for container '
        iv_cn_110 '.' INTO ls_main_text.
        APPEND ls_main_text TO lt_main_text.
        CLEAR ls_main_text.
        APPEND ls_main_text TO lt_main_text.
        APPEND 'Best Regards,' TO lt_main_text.
        APPEND 'SAP Team' TO lt_main_text.

        CONCATENATE lv_row_count ' Materials Container.' INTO lv_subject.
        lo_document = cl_document_bcs=>create_document(
                      i_type    = 'RAW'
                      i_text    = lt_main_text
                      i_subject = lv_subject ).

        CONCATENATE 'Excel Container Sheet ' sy-datum ' ' sy-uzeit INTO lv_filename.
        CONCATENATE '&SO_FILENAME=' lv_filename INTO lv_text_line.
        APPEND lv_text_line TO lt_att_head.

        lo_document->add_attachment(
                       i_attachment_type    = 'BIN'
                       i_attachment_subject = lv_subject
                       i_attachment_size    = lv_i_filesize
                       i_att_content_hex    = mt_bin_tab
                       i_attachment_header  = lt_att_head ).

        lo_send_request->set_document( lo_document ).

        lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_mail_to ).

        lo_send_request->add_recipient( lo_recipient ).

        lv_sent_to_all = lo_send_request->send( i_with_error_screen = 'X' ).

        COMMIT WORK.

        IF lv_sent_to_all IS INITIAL.

          MESSAGE i500(sbcoms) WITH lv_mail_to.

        ELSE.

          MESSAGE s022(so).

        ENDIF.

      CATCH cx_bcs INTO lo_bcs_exception.

        MESSAGE i865(so) WITH lo_bcs_exception->error_type.

    ENDTRY.

  ENDMETHOD.

  METHOD set_vrm_values.

    DATA: lt_vrm_values TYPE TABLE OF vrm_value,
          lv_field_name TYPE vrm_id.

    lt_vrm_values = VALUE #( ( key = '1' text = 'Morning' )
                             ( key = '2' text = 'Afternoon' )
                             ( key = '3' text = 'Evening' ) ).

    lv_field_name = 'ZKP_CONTAINER_FINAL-GS_CONTAINER-SHIFT'.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = lv_field_name
        values = lt_vrm_values[]
      EXCEPTIONS
        OTHERS = 2.

  ENDMETHOD.

  METHOD get_maktx.

    IF cs_container-matnr IS NOT INITIAL.

      SELECT SINGLE maktx
        FROM makt
        INTO cs_container-maktx
        WHERE matnr = cs_container-matnr
        AND   spras = sy-langu.

      IF sy-subrc = 0.

        MODIFY ct_container FROM cs_container INDEX iv_curr_line.
        CLEAR cs_container.

      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
