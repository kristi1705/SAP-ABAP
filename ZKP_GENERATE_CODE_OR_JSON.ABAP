*&---------------------------------------------------------------------*
*& Report ZKP_GENERATE_CODE_OR_JSON
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_generate_code_or_json.

DATA: BEGIN OF gs_scr_100,
        ok_code TYPE syucomm,
      END OF gs_scr_100.


PARAMETERS: p_fmname TYPE rs38l-name.
DATA:
*      gs_json     TYPE ty_json,
*      gs_json_std TYPE ty_json_std,
  gt_file        TYPE STANDARD TABLE OF string,
  gv_json        TYPE string,
  gv_filename    TYPE string,
  gt_return      TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY,
  lt_exc         TYPE STANDARD TABLE OF rsexc,
  lt_expo        TYPE STANDARD TABLE OF rsexp,
  lt_impo        TYPE STANDARD TABLE OF rsimp,
  lt_chan        TYPE STANDARD TABLE OF rscha,
  lt_tab         TYPE STANDARD TABLE OF rstbl,
  lt_components  TYPE abap_component_tab,
  lr_data        TYPE REF TO data,
  lt_output      TYPE STANDARD TABLE OF string,
  lt_out_fm      TYPE STANDARD TABLE OF string,
  lt_out_fm_decl TYPE STANDARD TABLE OF string,
  lt_output_pp   TYPE STANDARD TABLE OF string,
  go_abap        TYPE REF TO cl_gui_abapedit,
  go_html        TYPE REF TO cl_gui_html_viewer,
  go_splitter    TYPE REF TO cl_gui_splitter_container.


FIELD-SYMBOLS: <lt_tab_type> TYPE ANY TABLE,
               <gs_json>     TYPE any.

CLASS lcl_generate_types DEFINITION.
  PUBLIC SECTION.
    METHODS get_components IMPORTING iv_parameter        TYPE parameter
                                     iv_dbfield          TYPE likefield
                                     iv_typ              TYPE rs38l_typ
                                     iv_param_type       TYPE c
                           RETURNING VALUE(rs_component) TYPE LINE OF abap_component_tab.

    METHODS get_type IMPORTING iv_dbfield     TYPE likefield
                               iv_typ         TYPE rs38l_typ
                               iv_comp_name   TYPE string
                     RETURNING VALUE(rv_type) TYPE string.
    METHODS status_0100.

ENDCLASS.

DATA lo_generate_types TYPE REF TO lcl_generate_types.

CLASS lcl_generate_types IMPLEMENTATION.
  METHOD get_components.

    DATA: lo_type       TYPE REF TO cl_abap_typedescr.

    lo_type = COND #( WHEN iv_dbfield IS NOT INITIAL
                      THEN cl_abap_typedescr=>describe_by_name( iv_dbfield )
                      WHEN iv_typ IS NOT INITIAL
                      THEN cl_abap_typedescr=>describe_by_name( iv_typ )
                      ELSE cl_abap_elemdescr=>get_string( )
    ).

    CASE iv_param_type.
      WHEN 'T'.
        DATA(lo_table) = cl_abap_tabledescr=>create(
          p_line_type  = CAST #( lo_type )
          p_table_kind = cl_abap_tabledescr=>tablekind_std
          p_key_kind   = cl_abap_tabledescr=>keydefkind_default
        ).
        lo_type ?= lo_table.
    ENDCASE.


    rs_component = VALUE #( name = |{ iv_param_type }{ SWITCH #( lo_type->kind
                                       WHEN lo_type->kind_table  THEN 'T'
                                       WHEN lo_type->kind_struct THEN 'S'
                                       ELSE 'V' ) }_{ iv_parameter }|
                            type = CAST #( lo_type )
    ).

  ENDMETHOD.
  METHOD get_type.

    DATA(lv_type_name) = COND #( WHEN iv_dbfield IS NOT INITIAL THEN iv_dbfield
                                 WHEN iv_typ     IS NOT INITIAL THEN iv_typ
                                 ELSE 'string' ).

    CASE iv_comp_name+1(1).
      WHEN 'V' OR 'S'.
        rv_type = lv_type_name.
      WHEN 'T'.
        rv_type = |STANDARD TABLE OF { lv_type_name } WITH DEFAULT KEY|.
    ENDCASE.

  ENDMETHOD.
  METHOD status_0100.

    IF go_abap IS BOUND.
      RETURN.
    ENDIF.

    DATA: lo_cont TYPE REF TO cl_gui_custom_container.

    CREATE OBJECT lo_cont
      EXPORTING
        container_name              = 'MAIN_CONT'
      EXCEPTIONS
        cntl_error                  = 1                " CNTL_ERROR
        cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
        create_error                = 3                " CREATE_ERROR
        lifetime_error              = 4                " LIFETIME_ERROR
        lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CREATE OBJECT go_splitter
      EXPORTING
        parent            = lo_cont
        rows              = 1
        columns           = 2
      EXCEPTIONS
        cntl_error        = 1                  " See Superclass
        cntl_system_error = 2                  " See Superclass
        OTHERS            = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CREATE OBJECT go_abap
      EXPORTING
        parent = go_splitter->get_container( row = 1 column = 1 )
*       max_number_chars = 72               " Maximum Number of Characters
      .

    APPEND |PROGRAM.  | TO lt_output.
    APPEND |PARAMETERS: p_json TYPE rlgrap-filename.  | TO lt_output.
    APPEND |                                          | TO lt_output.
    APPEND |TYPES: BEGIN OF ty_json,                  | TO lt_output.

    CALL FUNCTION 'FUNCTION_IMPORT_INTERFACE'
      EXPORTING
        funcname           = p_fmname
      TABLES
        exception_list     = lt_exc
        export_parameter   = lt_expo
        import_parameter   = lt_impo
        changing_parameter = lt_chan
        tables_parameter   = lt_tab
      EXCEPTIONS
        error_message      = 1
        function_not_found = 2
        invalid_name       = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    APPEND |CALL FUNCTION '{ p_fmname }'| TO lt_out_fm.

    LOOP AT lt_impo ASSIGNING FIELD-SYMBOL(<ls_import>).
      AT FIRST.
        APPEND |EXPORTING| TO lt_out_fm.
      ENDAT.
      APPEND INITIAL LINE TO lt_components ASSIGNING FIELD-SYMBOL(<ls_component>).
      <ls_component> = lo_generate_types->get_components(
        iv_parameter  = <ls_import>-parameter
        iv_dbfield    = <ls_import>-dbfield
        iv_typ        = <ls_import>-typ
        iv_param_type = 'I'
      ).

      DATA(lv_type) = lo_generate_types->get_type(
        iv_dbfield   = <ls_import>-dbfield
        iv_typ       = <ls_import>-typ
        iv_comp_name = <ls_component>-name
      ).

      APPEND |{ <ls_component>-name } TYPE { lv_type },| TO lt_output.
      APPEND |{ <ls_import>-parameter }  = gs_json-{ <ls_component>-name } | TO lt_out_fm.

    ENDLOOP.

    LOOP AT lt_expo ASSIGNING FIELD-SYMBOL(<ls_export>).
      AT FIRST.
        APPEND |IMPORTING| TO lt_out_fm.
      ENDAT.

      DATA(ls_comp) = lo_generate_types->get_components(
        iv_parameter  = <ls_export>-parameter
        iv_dbfield    = <ls_export>-dbfield
        iv_typ        = <ls_export>-typ
        iv_param_type = 'L'
      ).

      lv_type = lo_generate_types->get_type(
        iv_dbfield   = <ls_export>-dbfield
        iv_typ       = <ls_export>-typ
        iv_comp_name = ls_comp-name
      ).

      APPEND |{ ls_comp-name } TYPE { lv_type }| TO lt_out_fm_decl.
      APPEND |{ <ls_export>-parameter }  = { ls_comp-name } | TO lt_out_fm.

    ENDLOOP.

    IF lt_out_fm_decl IS NOT INITIAL.

      LOOP AT lt_out_fm_decl ASSIGNING FIELD-SYMBOL(<lv_out_fm_decl>).
        IF sy-tabix = lines( lt_out_fm_decl ).
          CONCATENATE <lv_out_fm_decl> '.' INTO <lv_out_fm_decl>.
        ELSE.
          CONCATENATE <lv_out_fm_decl> ',' INTO <lv_out_fm_decl>.
        ENDIF.
      ENDLOOP.

      INSERT |DATA:| INTO lt_out_fm_decl INDEX 1.
      APPEND INITIAL LINE TO lt_out_fm_decl.

    ENDIF.

    INSERT LINES OF lt_out_fm_decl INTO lt_out_fm INDEX 1.

    LOOP AT lt_chan ASSIGNING FIELD-SYMBOL(<ls_change>).
      AT FIRST.
        APPEND |CHANGING| TO lt_out_fm.
      ENDAT.

      APPEND INITIAL LINE TO lt_components ASSIGNING <ls_component>.
      <ls_component> = lo_generate_types->get_components(
        iv_parameter  = <ls_change>-parameter
        iv_dbfield    = <ls_change>-dbfield
        iv_typ        = <ls_change>-typ
        iv_param_type = 'C'
      ).

      lv_type = lo_generate_types->get_type(
        iv_dbfield   = <ls_change>-dbfield
        iv_typ       = <ls_change>-typ
        iv_comp_name = <ls_component>-name
      ).

      APPEND |{ <ls_component>-name } TYPE { lv_type },| TO lt_output.
      APPEND |{ <ls_change>-parameter }  = gs_json-{ <ls_component>-name } | TO lt_out_fm.
    ENDLOOP.

    LOOP AT lt_tab ASSIGNING FIELD-SYMBOL(<ls_tab>).
      AT FIRST.
        APPEND |TABLES| TO lt_out_fm.
      ENDAT.

      ls_comp = lo_generate_types->get_components(
        iv_parameter  = <ls_tab>-parameter
        iv_dbfield    = <ls_tab>-dbstruct
        iv_typ        = <ls_tab>-typ
        iv_param_type = 'T'
      ).

      lv_type = lo_generate_types->get_type(
        iv_dbfield   = <ls_tab>-dbstruct
        iv_typ       = <ls_tab>-typ
        iv_comp_name = ls_comp-name
      ).

      APPEND |{ ls_comp-name } TYPE { lv_type },| TO lt_output.

      IF <ls_tab>-dbstruct = 'BAPIRET2'.
        APPEND |{ <ls_tab>-parameter }  = gt_return | TO lt_out_fm.
        DATA(lv_bapiret) = abap_true.
        CONTINUE.
      ENDIF.

      APPEND ls_comp TO lt_components.

      APPEND |{ <ls_tab>-parameter }  = gs_json-{ ls_comp-name } | TO lt_out_fm.

    ENDLOOP.

    LOOP AT lt_exc ASSIGNING FIELD-SYMBOL(<ls_exc>).

      DATA(lv_tabix) = sy-tabix.
      AT FIRST.
        APPEND |EXCEPTIONS| TO lt_out_fm.
      ENDAT.

      APPEND |{ <ls_exc>-exception } = { lv_tabix } | TO lt_out_fm.

    ENDLOOP.

    READ TABLE lt_out_fm ASSIGNING FIELD-SYMBOL(<lv_out_fm>) INDEX lines( lt_out_fm ).
    CONCATENATE <lv_out_fm> '.' INTO <lv_out_fm>.

    DATA(ls_json_struct) = cl_abap_structdescr=>create( lt_components ).

    CREATE DATA lr_data TYPE HANDLE ls_json_struct.
    ASSIGN lr_data->* TO <gs_json>.

    LOOP AT lt_components ASSIGNING <ls_component>.
      IF <ls_component>-name+1(1) = 'T'.
        ASSIGN COMPONENT <ls_component>-name OF STRUCTURE <gs_json> TO <lt_tab_type>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        INSERT INITIAL LINE INTO TABLE <lt_tab_type>.
      ENDIF.
    ENDLOOP.

    APPEND |END OF ty_json.                                                     | TO lt_output.
    lt_output = VALUE #( BASE lt_output
( |                                                                            | )
( |    DATA gs_json     TYPE ty_json.                                         | )
( COND #( WHEN lv_bapiret IS NOT INITIAL THEN |DATA gt_return   TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY. | ) )
( |                                                                            | )
( |    AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_json.                        | )
( |                                                                            | )
( |      CALL FUNCTION 'KD_GET_FILENAME_ON_F4'                                 | )
( |        CHANGING                                                            | )
( |          file_name = p_json.                                               | )
( |                                                                            | )
( |    START-OF-SELECTION.                                                     | )

( |      PERFORM upload_json.                                                  | )
( |      PERFORM execute_fm.                                                   | )
( |                                                                            | )
( |      FORM upload_json.                                                     | )
( |      DATA: lv_filename TYPE string,                                        | )
( |            lt_file     TYPE STANDARD TABLE OF string,                      | )
( |            lv_json     TYPE string.                                        | )
( |                                                                            | )
( |      lv_filename = p_json.                                                 | )
( |                                                                            | )
( |      CALL FUNCTION 'GUI_UPLOAD'                                            | )
( |        EXPORTING                                                           | )
( |          filename                = lv_filename                             | )
( |        TABLES                                                              | )
( |          data_tab                = lt_file                                 | )
( |        EXCEPTIONS                                                          | )
( |          file_open_error         = 1                                       | )
( |          file_read_error         = 2                                       | )
( |          no_batch                = 3                                       | )
( |          gui_refuse_filetransfer = 4                                       | )
( |          invalid_type            = 5                                       | )
( |          no_authority            = 6                                       | )
( |          unknown_error           = 7                                       | )
( |          bad_data_format         = 8                                       | )
( |          header_not_allowed      = 9                                       | )
( |          separator_not_allowed   = 10                                      | )
( |          header_too_long         = 11                                      | )
( |          unknown_dp_error        = 12                                      | )
( |          access_denied           = 13                                      | )
( |          dp_out_of_memory        = 14                                      | )
( |          disk_full               = 15                                      | )
( |          dp_timeout              = 16                                      | )
( |          OTHERS                  = 17.                                     | )
( |      IF sy-subrc <> 0.                                                     | )
( |*     Implement suitable error handling here                                | )
( |      ENDIF.                                                                | )
( |                                                                            | )
( |      CONCATENATE LINES OF lt_file INTO lv_json.                            | )
( |                                                                            | )
( |        /ui2/cl_json=>deserialize(                                          | )
( |          EXPORTING                                                         | )
( |            json        = lv_json                 " JSON string             | )
( |            pretty_name = /ui2/cl_json=>pretty_mode-camel_case              | )
( |          CHANGING                                                          | )
( |            data        = gs_json                 " Data to serialize       | )
( |        ).                                                                  | )
( |       ENDFORM.                                                             | )
( |                                                                    | )
( |       FORM execute_fm.                                                  | )
).

    APPEND LINES OF lt_out_fm TO lt_output.

    IF lv_bapiret IS NOT INITIAL.
      lt_output = VALUE #( BASE lt_output
     ( |                                                                            | )
     ( |      LOOP AT gt_return TRANSPORTING NO FIELDS WHERE type CA 'EAX'.         | )
     ( |        EXIT.                                                               | )
     ( |      ENDLOOP.                                                              | )
     ( |      IF sy-subrc = 0.                                                      | )
     ( |        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.                          | )
     ( |      ELSE.                                                                 | )
     ( |        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'                             | )
     ( |          EXPORTING                                                         | )
     ( |            wait = 'X'.                                                     | )
     ( |      ENDIF.                                                                | )
     ( |                                                                            | )
     ( |      cl_demo_output=>display(                                              | )
     ( |        data = gt_return                                                    | )
     ( |      ). | )
     ).
    ENDIF.

    APPEND | ENDFORM. |  TO lt_output.

    CALL FUNCTION 'PRETTY_PRINTER'
      EXPORTING
        inctoo             = abap_false
      TABLES
        ntext              = lt_output_pp
        otext              = lt_output
      EXCEPTIONS
        enqueue_table_full = 1
        include_enqueued   = 2
        include_readerror  = 3
        include_writeerror = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.



    DATA: mess     TYPE string,
          lin      TYPE i ##needed,
          wrd      TYPE string ##needed,
          warnings TYPE  STANDARD TABLE OF rslinlmsg.


    SYNTAX-CHECK FOR lt_output_pp MESSAGE mess LINE lin WORD wrd
                     ID 'MSG' TABLE warnings
                     PROGRAM sy-repid.

    IF sy-subrc <> 0.
      MESSAGE mess TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.

    DELETE lt_output_pp INDEX 1.

    go_abap->set_text(
      EXPORTING
        table           = lt_output_pp
      EXCEPTIONS
        error_dp        = 1                " Error while sending R/3 table to TextEdit control!
        error_dp_create = 2                " ERROR_DP_CREATE
        error_code_page = 3                " Code Page Error
        OTHERS          = 4
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    go_abap->set_readonly_mode(
      EXPORTING
        readonly_mode          = go_abap->true             " read-only mode; eq 0: OFF ; ne 0: ON
      EXCEPTIONS
        error_cntl_call_method = 1                " Error while setting read-only mode!
        invalid_parameter      = 2                " INVALID_PARAMETER
        error_dp               = 3                " Error from Data Provider
        OTHERS                 = 4
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    CREATE OBJECT go_html
      EXPORTING
        parent             = go_splitter->get_container( row = 1 column = 2 )
      EXCEPTIONS
        cntl_error         = 1                " error in call method of ooCFW
        cntl_install_error = 2                " HTML control was not installed properly
        dp_install_error   = 3                " DataProvider was not installed properly
        dp_error           = 4                " error in call of DataProvider function
        OTHERS             = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    /ui2/cl_json=>serialize(
      EXPORTING
        data        = <gs_json>
        pretty_name = /ui2/cl_json=>pretty_mode-low_case
      RECEIVING
        r_json      = gv_json
    ).

    cl_demo_output=>write_json( json = gv_json ).
    cl_demo_output=>get(
      RECEIVING
        output = DATA(lv_html)                  " Output
    ).

    DATA   lt_lines_split TYPE TABLE OF swastrtab.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string         = lv_html
        max_component_length = 255
      TABLES
        string_components    = lt_lines_split.

    TYPES: BEGIN OF ty_html,
             html TYPE swastrtab-str,
           END OF ty_html.


    DATA lv_url TYPE c LENGTH 100.
    DATA lt_html TYPE STANDARD TABLE OF ty_html.

    lt_html = VALUE #( FOR <l> IN lt_lines_split ( html = <l>-str ) ).

    go_html->load_data(
      IMPORTING
        assigned_url           = lv_url                " URL
      CHANGING
        data_table             = lt_html                 " data table
      EXCEPTIONS
        dp_invalid_parameter   = 1                " invalid parameter in a DP call
        dp_error_general       = 2                " gerneral error in a DP call
        cntl_error             = 3                " error
        html_syntax_notcorrect = 4                " HTML data is invalid and check all the tags' syntax
        OTHERS                 = 5
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    go_html->show_url(
      EXPORTING
        url                    = lv_url
      EXCEPTIONS
        cntl_error             = 1                " Error in CFW Call
        cnht_error_not_allowed = 2                " Navigation outside R/3 is not allowed
        cnht_error_parameter   = 3                " Incorrect parameters
        dp_error_general       = 4                " Error in DP FM call
        OTHERS                 = 5
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.



  ENDMETHOD.
ENDCLASS.



START-OF-SELECTION.

  CREATE OBJECT lo_generate_types.

  CALL SCREEN 100.

*
*    CALL FUNCTION p_fmname
*      EXPORTING
*        documentheader    = gs_json_std-s_documentheader    " Header
*        customercpd       = gs_json_std-s_customercpd       " One-time customer
*        contractheader    = gs_json_std-s_contractheader    " Additional Contract Accounts Recievable and Payable Header Line
*      TABLES
*        accountgl         = gs_json_std-t_accountgl         " G/L account item
*        accountreceivable = gs_json_std-t_accountreceivable " Customer Item
*        accountpayable    = gs_json_std-t_accountpayable    " Vendor Item
*        accounttax        = gs_json_std-t_accounttax        " Tax item
*        currencyamount    = gs_json_std-t_currencyamount    " Currency Items
*        criteria          = gs_json_std-t_criteria          " CO-PA Account Assignment Characteristics
*        valuefield        = gs_json_std-t_valuefield        " CO-PA Account Assignment Value Fields
*        extension1        = gs_json_std-t_extension1        " Container for 'Customer Exit' Parameter
*        return            = gt_return                       " Return parameter
*        paymentcard       = gs_json_std-t_paymentcard       " Payment Card Information
*        contractitem      = gs_json_std-t_contractitem      " Additional Contract Accounts Recieviable and Payable Document Line Item
*        extension2        = gs_json_std-t_extension2        " Reference Structure for BAPI Parameters EXTENSIONIN/EXTENSIONOUT
*        realestate        = gs_json_std-t_realestate        " Real Estate Account Assignment Data
*        accountwt         = gs_json_std-t_accountwt.        " Withholding tax information for FI Interface
*
*  ELSE.


*
*    /ui2/cl_json=>deserialize(
*      EXPORTING
*        json        = gv_json                 " JSON string
*        pretty_name = /ui2/cl_json=>pretty_mode-camel_case                  " Pretty Print property names
*      CHANGING
*        data        = gs_json                 " Data to serialize
*    ).
*
*    CALL FUNCTION 'ZBAPI_ACC_INVOICE_RECEIPT_POST'
*      EXPORTING
*        documentheader = gs_json-s_documentheader
*        customercpd    = gs_json-s_customercpd
*      TABLES
*        accountpayable = gs_json-t_accountpayable
*        accountgl      = gs_json-t_accountgl
*        accounttax     = gs_json-t_accounttax
*        currencyamount = gs_json-t_currencyamount
*        purchaseorder  = gs_json-t_purchaseorder
*        purchaseamount = gs_json-t_purchaseamount
*        return         = gt_return
*        criteria       = gs_json-t_criteria
*        valuefield     = gs_json-t_valuefield
*        extension1     = gs_json-t_extension1
**       ze1bpache03    = gs_json-t_ze1bpache03
**       zacc_invoice_receipt03 = gs_json-t_zacc_invoice_receipt03
*        idoc_status    = gs_json-t_idoc_status.
*  ENDIF.
*
*  LOOP AT gt_return TRANSPORTING NO FIELDS WHERE type CA 'EAX'.
*    EXIT.
*  ENDLOOP.
*  IF sy-subrc = 0.
*    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*  ELSE.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        wait = 'X'.
*  ENDIF.
*
*  cl_demo_output=>display(
*    data = gt_return
*  ).
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'MAIN'.
  SET TITLEBAR 'TITLE_100'.

  lo_generate_types->status_0100( ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gs_scr_100-ok_code.
    WHEN 'FC_BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.



ENDMODULE.
