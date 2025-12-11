REPORT zkp_batch_input_bapi
       NO STANDARD PAGE HEADING LINE-SIZE 255.

* Include bdcrecx1_s:
* The call transaction using is called WITH AUTHORITY-CHECK!
* If you have own auth.-checks you can use include bdcrecx1 instead.
*include bdcrecx1_s.

CLASS lcl_binput_bapi DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_ekpo,
             ebeln TYPE ekko-ebeln,
             ebelp TYPE ekpo-ebelp,
             txz01 TYPE ekpo-txz01,
           END OF ty_ekpo,
           tt_ekpo TYPE STANDARD TABLE OF ty_ekpo.

    DATA: mt_ekpo TYPE tt_ekpo,
          ms_ekpo TYPE ty_ekpo.

    METHODS: execute IMPORTING iv_choice TYPE i iv_file TYPE ibipparms-path.

    METHODS: convert_data IMPORTING iv_fpath TYPE ibipparms-path.

    METHODS: batch_input IMPORTING iv_path TYPE ibipparms-path, bapi IMPORTING iv_path TYPE ibipparms-path.

ENDCLASS.

CLASS lcl_binput_bapi IMPLEMENTATION.

  METHOD execute.

    CASE iv_choice.

      WHEN 1.

        batch_input( EXPORTING iv_path = iv_file ).

      WHEN 2.

        bapi( EXPORTING iv_path = iv_file ).

    ENDCASE.

  ENDMETHOD.

  METHOD convert_data.

    DATA: lt_data     TYPE solix_tab,
          lv_filepath TYPE string,
          lv_index    TYPE i.

    lv_filepath = iv_fpath.

    FIELD-SYMBOLS: <lt_excel> TYPE STANDARD TABLE.

    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = lv_filepath
        filetype                = 'BIN'
      CHANGING
        data_tab                = lt_data
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19 ).

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    DATA(lv_bin_data) = cl_bcs_convert=>solix_to_xstring(
                        it_solix   = lt_data  ).

    DATA(lo_excel) = NEW cl_fdt_xl_spreadsheet(
        document_name     =  lv_filepath
        xdocument         = lv_bin_data ).

    lo_excel->if_fdt_doc_spreadsheet~get_worksheet_names( IMPORTING worksheet_names = DATA(lt_worksheet) ).

    IF lt_worksheet IS INITIAL.

      MESSAGE 'No worksheets found' TYPE 'E'.
      RETURN.

    ENDIF.

    DATA(lo_worksheet_table) = lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet( lt_worksheet[ 1 ] ).
    ASSIGN lo_worksheet_table->* TO <lt_excel>.

    LOOP AT <lt_excel> ASSIGNING FIELD-SYMBOL(<ls_excel>) FROM 2.
      APPEND INITIAL LINE TO mt_ekpo ASSIGNING FIELD-SYMBOL(<ls_file>).
      DO 3 TIMES.
        lv_index = sy-index.
        ASSIGN COMPONENT lv_index OF STRUCTURE <ls_excel> TO FIELD-SYMBOL(<lv_col>).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        CASE lv_index.
          WHEN 1.
            <ls_file>-ebeln = <lv_col>.
          WHEN 2.
            <ls_file>-ebelp = <lv_col>.
          WHEN 3.
            <ls_file>-txz01 = <lv_col>.
        ENDCASE.
      ENDDO.
    ENDLOOP.
    IF mt_ekpo IS INITIAL.
      MESSAGE 'The Excel file is empty!' TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ENDMETHOD.

  METHOD batch_input.

    DATA: lt_bdcdata TYPE STANDARD TABLE OF bdcdata,
          lt_messtab TYPE STANDARD TABLE OF bdcmsgcoll.

    convert_data( EXPORTING iv_fpath = iv_path ).

    LOOP AT mt_ekpo INTO ms_ekpo GROUP BY ( ebeln = ms_ekpo-ebeln ) ASSIGNING FIELD-SYMBOL(<gt_group>).

      CLEAR lt_bdcdata.

      APPEND VALUE #( program = 'SAPMM06E' dynpro = '0105' dynbegin = 'X' ) TO lt_bdcdata.

      APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RM06E-BSTNR' ) TO lt_bdcdata.

      APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '/00' ) TO lt_bdcdata.

      APPEND VALUE #( fnam = 'RM06E-BSTNR' fval = <gt_group>-ebeln ) TO lt_bdcdata.

      LOOP AT GROUP <gt_group> ASSIGNING FIELD-SYMBOL(<gs_group>).

        APPEND VALUE #( program = 'SAPMM06E' dynpro = '0120' dynbegin = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'RM06E-EBELP' ) TO lt_bdcdata.

        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '/00' ) TO lt_bdcdata.

        APPEND VALUE #( fnam = 'RM06E-EBELP' fval =  <gs_group>-ebelp ) TO lt_bdcdata.

        APPEND VALUE #( program = 'SAPMM06E' dynpro = '0120' dynbegin = 'X' ) TO lt_bdcdata.

        APPEND VALUE #( fnam = 'BDC_CURSOR' fval =  'EKPO-TXZ01(01)' ) TO lt_bdcdata.

        APPEND VALUE #( fnam = 'BDC_OKCODE' fval =  '/00' ) TO lt_bdcdata.

        APPEND VALUE #( fnam = 'EKPO-TXZ01(01)' fval =  <gs_group>-txz01 ) TO lt_bdcdata.

      ENDLOOP.

      APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=BU' ) TO lt_bdcdata.

      CALL TRANSACTION 'ME22' USING lt_bdcdata MODE 'E' UPDATE 'S' MESSAGES INTO lt_messtab.

    ENDLOOP.

  ENDMETHOD.

  METHOD bapi.

    DATA: ls_po           TYPE bapimepoheader-po_number,
          ls_po_header    TYPE bapimepoheader,
          ls_po_headerx   TYPE bapimepoheaderx,
          ls_return       TYPE  bapiret2,
          lt_return       TYPE STANDARD TABLE OF bapiret2,
          lt_item         TYPE STANDARD TABLE OF bapimepoitem,
          lt_itemx        TYPE STANDARD TABLE OF bapimepoitemx,
          lt_extensionin  TYPE STANDARD TABLE OF bapiparex,
          ls_te_mepoitem  TYPE bapi_te_mepoitem,
          ls_te_mepoitemx TYPE bapi_te_mepoitemx.

    convert_data( EXPORTING iv_fpath = iv_path ).

    LOOP AT mt_ekpo INTO ms_ekpo GROUP BY ( ebeln = ms_ekpo-ebeln ) ASSIGNING FIELD-SYMBOL(<lt_group>).

      ls_po = <lt_group>-ebeln.
      ls_po_header-po_number = <lt_group>-ebeln.
      ls_po_headerx-po_number = abap_true.

      LOOP AT GROUP <lt_group> ASSIGNING FIELD-SYMBOL(<ls_group>).

        APPEND VALUE #( po_item = <ls_group>-ebelp ) TO lt_item.

        APPEND VALUE #( po_item = <ls_group>-ebelp po_itemx = abap_true ) TO lt_itemx.


        ls_te_mepoitem-po_item = <ls_group>-ebelp.
        ls_te_mepoitem-zzkp_comment = <ls_group>-txz01.

        ls_te_mepoitem-po_item = <ls_group>-ebelp.
        ls_te_mepoitem-zzkp_comment = <ls_group>-txz01.

        ls_te_mepoitemx-po_item = <ls_group>-ebelp.
        ls_te_mepoitemx-zzkp_comment = abap_true.

        lt_extensionin = VALUE #( BASE lt_extensionin
                                  ( structure = 'BAPI_TE_MEPOITEM' valuepart1 = ls_te_mepoitem )
                                  ( structure = 'BAPI_TE_MEPOITEMX' valuepart1 = ls_te_mepoitemx ) ).

      ENDLOOP.

      CALL FUNCTION 'BAPI_PO_CHANGE'
        EXPORTING
          purchaseorder = ls_po
          poheader      = ls_po_header
          poheaderx     = ls_po_headerx
        TABLES
          return        = lt_return
          poitem        = lt_item
          poitemx       = lt_itemx
          extensionin   = lt_extensionin.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = abap_true
        IMPORTING
          return = ls_return.

      CLEAR: ls_po, ls_po_header, ls_po_headerx, ls_te_mepoitem.

      REFRESH: lt_item, lt_itemx, lt_extensionin.

    ENDLOOP.

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).

      MESSAGE <ls_return>-message TYPE 'S'.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

PARAMETERS: p_binput RADIOBUTTON GROUP rbg1 DEFAULT 'X',
            p_bapi   RADIOBUTTON GROUP rbg1,
            p_file   TYPE ibipparms-path.

DATA: gv_choice      TYPE i,
      go_binput_bapi TYPE REF TO lcl_binput_bapi.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = ' '
    IMPORTING
      file_name     = p_file.

START-OF-SELECTION.

  CREATE OBJECT go_binput_bapi.

  IF p_binput = abap_true.

    gv_choice = 1.

  ELSE.

    gv_choice = 2.

  ENDIF.

  go_binput_bapi->execute( iv_choice = gv_choice iv_file = p_file ).
