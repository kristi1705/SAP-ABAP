*&---------------------------------------------------------------------*
*& Include          ZKP_E36_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_pr_management DEFINITION.

  PUBLIC SECTION.

    METHODS:
      constructor,
      execute IMPORTING iv_ok_code TYPE sy-ucomm.

  PRIVATE SECTION.

    CONSTANTS: c_tabname TYPE string VALUE 'EBAN'.

    TYPES: BEGIN OF ty_display_data,
             werks  TYPE eban-werks,
             banfn  TYPE eban-banfn,
             bnfpo  TYPE eban-bnfpo,
             fixkz  TYPE eban-fixkz,
             matnr  TYPE eban-matnr,
             maktx  TYPE makt-maktx,
             menge  TYPE eban-menge,
             bsmng  TYPE eban-bsmng,
             meins  TYPE eban-meins,
             lgort  TYPE eban-lgort,
             erdat  TYPE eban-erdat,
             badat  TYPE eban-badat,
             lpein  TYPE eban-lpein,
             ekgrp  TYPE eban-ekgrp,
             dispo  TYPE eban-dispo,
             matkl  TYPE eban-matkl,
             afnam  TYPE eban-afnam,
             flief  TYPE eban-flief,
             name1  TYPE lfa1-name1,
             lifnr  TYPE eban-lifnr,
             ekorg  TYPE eban-ekorg,
             pstyp  TYPE eban-pstyp,
             plifz  TYPE eban-plifz,
             webaz  TYPE eban-webaz,
             knttp  TYPE eban-knttp,
             idnlf  TYPE eban-idnlf,
             infnr  TYPE eban-infnr,
             edited TYPE abap_bool,
           END OF ty_display_data,
           tt_display_data TYPE STANDARD TABLE OF ty_display_data.

    DATA: mt_display_data TYPE tt_display_data,
          mo_container    TYPE REF TO cl_gui_custom_container,
          mo_grid         TYPE REF TO cl_gui_alv_grid.

    METHODS:
      get_data,
      create_grid,
      build_layout CHANGING cs_layout TYPE lvc_s_layo,
      build_fcat   CHANGING ct_fcat TYPE lvc_t_fcat,
      handle_grid_ucomm FOR EVENT data_changed OF cl_gui_alv_grid IMPORTING er_data_changed.

    METHODS:
      save_to_db,
      edit_date,
      display_rda,
      delete_rda,
      create_oda,
      regroup_rda.

ENDCLASS.

CLASS lcl_pr_management IMPLEMENTATION.

  METHOD constructor.

    get_data( ).

    CREATE OBJECT mo_container EXPORTING container_name = 'GS_SCR_100-CONTAINER'.

    CREATE OBJECT mo_grid EXPORTING i_parent = mo_container.

    create_grid( ).

  ENDMETHOD.

  METHOD execute.

    CASE iv_ok_code.

      WHEN 'FC_BACK'.

        LEAVE TO SCREEN 0.

      WHEN 'FC_SAVE'.

        save_to_db( ).

      WHEN 'FC_DISPLAY'.

        display_rda( ).

      WHEN 'FC_EDIT'.

        edit_date( ).

      WHEN 'FC_CREATE'.

        create_oda( ).

      WHEN 'FC_CANCEL'.

        delete_rda( ).

      WHEN 'FC_GROUP'.

        regroup_rda( ).

    ENDCASE.

  ENDMETHOD.

  METHOD get_data.

    CASE abap_true.

      WHEN  p_total.

        SELECT eban~werks,
               eban~banfn,
               eban~bnfpo,
               eban~fixkz,
               eban~matnr,
               makt~maktx,
               eban~menge,
               eban~bsmng,
               eban~meins,
               eban~lgort,
               eban~erdat,
               eban~badat,
               eban~lpein,
               eban~ekgrp,
               eban~dispo,
               eban~matkl,
               eban~afnam,
               eban~flief,
               lfa1~name1,
               eban~lifnr,
               eban~ekorg,
               eban~pstyp,
               eban~plifz,
               eban~webaz,
               eban~knttp,
               eban~idnlf,
               eban~infnr

          FROM eban

          LEFT JOIN makt ON makt~matnr = eban~matnr
                        AND makt~spras = @sy-langu

          LEFT JOIN lfa1 ON lfa1~lifnr = eban~lifnr

          INTO CORRESPONDING FIELDS OF TABLE @mt_display_data

          WHERE eban~loekz <> @abap_true
            AND eban~ebakz <> @abap_true
            AND eban~lifnr IN @s_lifnr
            AND eban~matnr IN @s_matnr
            AND eban~lgort IN @s_lgort
            AND eban~dispo IN @s_dispo
            AND eban~matkl IN @s_matkl
            AND eban~ekgrp IN @s_ekgrp
            AND eban~banfn IN @s_banfn
            AND eban~badat IN @s_badat
            AND eban~lpein IN @s_lpein
            AND eban~pstyp IN @s_pstyp
            AND eban~knttp IN @s_knttp
            AND eban~fixkz IN @s_fixkz
            AND eban~statu IN ( 'B', 'N' )
            AND eban~estkz   = 'B'
            AND eban~bstyp   = 'B'

          ORDER BY banfn, bnfpo.

      WHEN p_attr.

        SELECT eban~werks,
               eban~banfn,
               eban~bnfpo,
               eban~fixkz,
               eban~matnr,
               makt~maktx,
               eban~menge,
               eban~bsmng,
               eban~meins,
               eban~lgort,
               eban~erdat,
               eban~badat,
               eban~lpein,
               eban~ekgrp,
               eban~dispo,
               eban~matkl,
               eban~afnam,
               eban~flief,
               lfa1~name1,
               eban~lifnr,
               eban~ekorg,
               eban~pstyp,
               eban~plifz,
               eban~webaz,
               eban~knttp,
               eban~idnlf,
               eban~infnr

        FROM eban

        LEFT JOIN makt ON makt~matnr = eban~matnr
                      AND makt~spras = @sy-langu

        LEFT JOIN lfa1 ON lfa1~lifnr = eban~lifnr

        WHERE eban~loekz <> @abap_true
          AND eban~ebakz <> @abap_true
          AND eban~zugba  = @abap_true
          AND eban~lifnr IN @s_lifnr
          AND eban~matnr IN @s_matnr
          AND eban~lgort IN @s_lgort
          AND eban~dispo IN @s_dispo
          AND eban~matkl IN @s_matkl
          AND eban~ekgrp IN @s_ekgrp
          AND eban~banfn IN @s_banfn
          AND eban~badat IN @s_badat
          AND eban~lpein IN @s_lpein
          AND eban~pstyp IN @s_pstyp
          AND eban~knttp IN @s_knttp
          AND eban~fixkz IN @s_fixkz
          AND eban~statu IN ( 'B', 'N' )
          AND eban~estkz   = 'B'
          AND eban~bstyp   = 'B'

        ORDER BY banfn, bnfpo

        INTO CORRESPONDING FIELDS OF TABLE @mt_display_data.

    ENDCASE.

  ENDMETHOD.

  METHOD create_grid.

    DATA: lt_fcat   TYPE lvc_t_fcat,
          ls_layout TYPE lvc_s_layo.

    build_layout( CHANGING cs_layout = ls_layout ).

    build_fcat( CHANGING ct_fcat = lt_fcat ).

    SET HANDLER handle_grid_ucomm FOR mo_grid.

    mo_grid->register_edit_event(
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2 ).

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    ENDIF.

    mo_grid->set_table_for_first_display(
      EXPORTING
        is_layout                     = ls_layout
      CHANGING
        it_outtab                     = mt_display_data
        it_fieldcatalog               = lt_fcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4 ).

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    ENDIF.

  ENDMETHOD.

  METHOD build_layout.

    cs_layout-cwidth_opt = abap_true.
    cs_layout-zebra      = abap_true.

  ENDMETHOD.

  METHOD build_fcat.

    ct_fcat = VALUE #( tabname = c_tabname
  ( fieldname = 'WERKS'   ref_table = 'EBAN' ref_field = 'WERKS' scrtext_m = 'Plant'                                    )
  ( fieldname = 'BANFN'   ref_table = 'EBAN' ref_field = 'BANFN' scrtext_m = 'Numero RdA'                               )
  ( fieldname = 'BNFPO'   ref_table = 'EBAN' ref_field = 'BNFPO' scrtext_m = 'Posizione RdA'                            )
  ( fieldname = 'FIXKZ'   ref_table = 'EBAN' ref_field = 'FIXKZ' scrtext_m = 'Codice fissazione'                        )
  ( fieldname = 'MATNR'   ref_table = 'EBAN' ref_field = 'MATNR' scrtext_m = 'Materiale'                                )
  ( fieldname = 'MAKTX'   ref_table = 'MAKT' ref_field = 'MAKTX' scrtext_m = 'Descrizione materiale'                    )
  ( fieldname = 'MENGE'   ref_table = 'EBAN' ref_field = 'MENGE' scrtext_m = 'Quantità'                   edit = 'X'    )
  ( fieldname = 'BSMNG'   ref_table = 'EBAN' ref_field = 'BSMNG' scrtext_m = 'Quantità ordinata'                        )
  ( fieldname = 'MEINS'   ref_table = 'EBAN' ref_field = 'MEINS' scrtext_m = 'Uom'                        edit = 'X'    )
  ( fieldname = 'LGORT'   ref_table = 'EBAN' ref_field = 'LGORT' scrtext_m = 'Magazzino'                  edit = 'X'    )
  ( fieldname = 'ERDAT'   ref_table = 'EBAN' ref_field = 'ERDAT' scrtext_m = 'Data Modifica'                            )
  ( fieldname = 'BADAT'   ref_table = 'EBAN' ref_field = 'BADAT' scrtext_m = 'Data Richiesta'                           )
  ( fieldname = 'LPEIN'   ref_table = 'EBAN' ref_field = 'LPEIN' scrtext_m = 'Data consegna'              edit = 'X'    )
  ( fieldname = 'EKGRP'   ref_table = 'EBAN' ref_field = 'EKGRP' scrtext_m = 'Gruppo Acquisti'                          )
  ( fieldname = 'DISPO'   ref_table = 'EBAN' ref_field = 'DISPO' scrtext_m = 'Responsabile MRP'                         )
  ( fieldname = 'MATKL'   ref_table = 'EBAN' ref_field = 'MATKL' scrtext_m = 'Gruppo Merci'                             )
  ( fieldname = 'AFNAM'   ref_table = 'EBAN' ref_field = 'AFNAM' scrtext_m = 'Richiedente'                edit = 'X'    )
  ( fieldname = 'FLIEF'   ref_table = 'EBAN' ref_field = 'FLIEF' scrtext_m = 'Fornitore fisso'            edit = 'X'    )
  ( fieldname = 'NAME1'   ref_table = 'LFA1' ref_field = 'NAME1' scrtext_m = 'Descrizione fornitore'                    )
  ( fieldname = 'LIFNR'   ref_table = 'EBAN' ref_field = 'LIFNR' scrtext_m = 'Fornitore richiesto'        edit = 'X'    )
  ( fieldname = 'EKORG'   ref_table = 'EBAN' ref_field = 'EKORG' scrtext_m = 'Organizzazione Acquisti'                  )
  ( fieldname = 'PSTYP'   ref_table = 'EBAN' ref_field = 'PSTYP' scrtext_m = 'Tipo posizione nel doc. d''acquisto'      )
  ( fieldname = 'PLIFZ'   ref_table = 'EBAN' ref_field = 'PLIFZ' scrtext_m = 'Consegna pianificata in giorni'           )
  ( fieldname = 'WEBAZ'   ref_table = 'EBAN' ref_field = 'WEBAZ' scrtext_m = 'Tempo di elaborazione entrata merci'      )
  ( fieldname = 'KNTTP'   ref_table = 'EBAN' ref_field = 'KNTTP' scrtext_m = 'Categoria di contabilizzazione'           )
  ( fieldname = 'IDNLF'   ref_table = 'EBAN' ref_field = 'IDNLF' scrtext_m = 'Cd. materiale presso il fornitore'        )
  ( fieldname = 'INFNR'   ref_table = 'EBAN' ref_field = 'INFNR' scrtext_m = 'Record Info'                              )
).

  ENDMETHOD.

  METHOD save_to_db.

    DATA: lt_error     TYPE STANDARD TABLE OF bapiret2,
          lt_return    TYPE STANDARD TABLE OF bapiret2,
          lt_rda_item  TYPE STANDARD TABLE OF bapimereqitemimp,
          lt_rda_itemx TYPE STANDARD TABLE OF bapimereqitemx,
          ls_return    TYPE bapiret2,
          lt_messages  TYPE esp1_message_tab_type.

    LOOP AT mt_display_data ASSIGNING FIELD-SYMBOL(<ls_display>) WHERE edited = abap_true
      GROUP BY ( banfn = <ls_display>-banfn ) ASSIGNING FIELD-SYMBOL(<lt_banfn>).

      CLEAR: lt_rda_item, lt_rda_itemx, lt_return.

      LOOP AT GROUP <lt_banfn> ASSIGNING FIELD-SYMBOL(<ls_banfn>).

        APPEND VALUE #( preq_item      = <ls_banfn>-bnfpo
                        quantity       = <ls_banfn>-menge
                        unit           = <ls_banfn>-meins
                        store_loc      = <ls_banfn>-lgort
                        del_datcat_ext = <ls_banfn>-lpein
                        fixed_vend     = <ls_banfn>-flief
                        des_vendor     = <ls_banfn>-lifnr
                        preq_name      = <ls_banfn>-afnam ) TO lt_rda_item.

        APPEND VALUE #( preq_item      = <ls_banfn>-bnfpo
                        quantity       = abap_true
                        unit           = abap_true
                        store_loc      = abap_true
                        del_datcat_ext = abap_true
                        fixed_vend     = abap_true
                        des_vendor     = abap_true
                        preq_name      = abap_true ) TO lt_rda_itemx.

        <ls_banfn>-edited = abap_false.

      ENDLOOP.

      CALL FUNCTION 'BAPI_PR_CHANGE'
        EXPORTING
          number  = <lt_banfn>-banfn
        TABLES
          return  = lt_return
          pritem  = lt_rda_item
          pritemx = lt_rda_itemx.

      LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).

        IF <ls_return>-type CA 'AEX'.

          DATA(lv_error) = abap_true.

        ENDIF.

        APPEND VALUE #( msgid  = <ls_return>-id
                          msgty  = <ls_return>-type
                          msgno  = <ls_return>-number
                          msgv1  = <ls_return>-message_v1
                          msgv2  = <ls_return>-message_v2
                          msgv3  = <ls_return>-message_v3
                          msgv4  = <ls_return>-message_v4
                          lineno = Lines( lt_messages ) ) TO lt_messages.
      ENDLOOP.

      IF lv_error IS NOT INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      ELSE.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = abap_true
          IMPORTING
            return = ls_return.

      ENDIF.

    ENDLOOP.

    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        i_message_tab = lt_messages.

  ENDMETHOD.

  METHOD display_rda.

    DATA: lt_rows TYPE lvc_t_row.

    mo_grid->get_selected_rows( IMPORTING et_index_rows = lt_rows ).

    IF lines( lt_rows ) <> 1.

      MESSAGE 'Only one row can be selected!' TYPE 'S' DISPLAY LIKE 'E'.

    ELSE.

      READ TABLE lt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>) INDEX 1.

      IF sy-subrc = 0.

        READ TABLE mt_display_data ASSIGNING FIELD-SYMBOL(<ls_display>)
        INDEX <ls_rows>-index.

        IF sy-subrc = 0.

          DATA(lv_banfn) = <ls_display>-banfn.

          SET PARAMETER ID 'BAN' FIELD lv_banfn.

          CALL TRANSACTION 'ME53N'.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD edit_date.

    DATA: lt_rows TYPE lvc_t_row,
          lt_sval TYPE STANDARD TABLE OF sval.

    mo_grid->get_selected_rows( IMPORTING et_index_rows = lt_rows ).

    IF lines( lt_rows ) <> 0.

      lt_sval = VALUE #( ( tabname = 'EBAN' fieldname = 'LPEIN' field_obl = abap_true ) ).

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title     = 'Inserimento / Modifica massiva data di consegna.'
        TABLES
          fields          = lt_sval
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.

      LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).

        READ TABLE mt_display_data ASSIGNING FIELD-SYMBOL(<ls_display>)
        INDEX <ls_rows>-index.

        IF sy-subrc = 0.

          READ TABLE lt_sval ASSIGNING FIELD-SYMBOL(<ls_sval>)
          WITH KEY fieldname = 'LPEIN'.

          IF sy-subrc = 0.

            <ls_display>-lpein  = <ls_sval>-value.
            <ls_display>-edited = abap_true.

          ENDIF.

        ENDIF.

      ENDLOOP.

      mo_grid->refresh_table_display(
          EXPORTING
            i_soft_refresh = abap_true
          EXCEPTIONS
            finished       = 1
            OTHERS         = 2 ).

      IF sy-subrc <> 0.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

      ENDIF.

    ELSE.

      MESSAGE 'Select at least one row!' TYPE 'S' DISPLAY LIKE 'E'.

    ENDIF.

  ENDMETHOD.

  METHOD delete_rda.

    DATA: lv_choice(1)  TYPE c,
          lt_rows       TYPE lvc_t_row,
          lv_offset     TYPE i,
          lv_index      TYPE i,
          ls_return     TYPE bapiret2,
          lt_return     TYPE STANDARD TABLE OF bapireturn,
          lt_delete_rda TYPE STANDARD TABLE OF bapieband,
          lt_messages   TYPE esp1_message_tab_type.

    CLEAR lt_delete_rda.

    mo_grid->get_selected_rows( IMPORTING et_index_rows = lt_rows ).

    IF lines( lt_rows ) > 0.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = 'Confermi la cancellazione degli RdA selezionati?'
          text_button_1         = 'Si'(001)
          text_button_2         = 'No'(002)
          display_cancel_button = ' '
        IMPORTING
          answer                = lv_choice
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.

      IF lv_choice = 1.

        LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).

          READ TABLE mt_display_data ASSIGNING FIELD-SYMBOL(<ls_display>)
          INDEX <ls_rows>-index.

          IF sy-subrc = 0.

            APPEND VALUE #( preq_item  = <ls_display>-bnfpo
                            delete_ind = abap_true
                            closed     = abap_true ) TO lt_delete_rda.

            CALL FUNCTION 'BAPI_REQUISITION_DELETE'
              EXPORTING
                number                      = <ls_display>-banfn
              TABLES
                requisition_items_to_delete = lt_delete_rda
                return                      = lt_return.

            LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).

              IF <ls_return>-type CA 'AEX'.

                DATA(lv_error) = abap_true.

              ENDIF.

              APPEND VALUE #( msgid  = <ls_return>-code
                              msgty  = <ls_return>-type
                              msgno  = <ls_return>-log_no
                              msgv1  = <ls_return>-message(50)
                              msgv2  = <ls_return>-message+50(50)
                              msgv3  = <ls_return>-message+100(50)
                              msgv4  = <ls_return>-message+150(50)
                              lineno = Lines( lt_messages ) ) TO lt_messages.

            ENDLOOP.

            IF lv_error IS NOT INITIAL.

              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

            ELSE.

              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait   = abap_true
                IMPORTING
                  return = ls_return.

              lv_index = <ls_rows>-index - lv_offset.
              DELETE mt_display_data INDEX lv_index.
              lv_offset += 1.

            ENDIF.

          ENDIF.

        ENDLOOP.

        mo_grid->refresh_table_display(
          EXPORTING
            i_soft_refresh = abap_true
          EXCEPTIONS
            finished       = 1
            OTHERS         = 2 ).

        IF sy-subrc <> 0.

          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ENDIF.

        CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
          TABLES
            i_message_tab = lt_messages.

      ENDIF.

    ELSE.

      MESSAGE 'Select at least one row to delete!' TYPE 'S' DISPLAY LIKE 'E'.

    ENDIF.

  ENDMETHOD.

  METHOD create_oda.

    DATA: lt_rows       TYPE lvc_t_row,
          ls_return     TYPE bapiret2,
          lt_messages   TYPE esp1_message_tab_type,
          ls_po_header  TYPE bapimepoheader,
          ls_po_headerx TYPE bapimepoheaderx,
          lt_po_item    TYPE STANDARD TABLE OF bapimepoitem,
          lt_po_itemx   TYPE STANDARD TABLE OF bapimepoitemx,
          lv_ebeln      TYPE bapimepoheader-po_number,
          lt_return     TYPE STANDARD TABLE OF bapiret2.

    mo_grid->get_selected_rows( IMPORTING et_index_rows = lt_rows ).

    IF lines( lt_rows ) > 0.

      LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).

        READ TABLE mt_display_data ASSIGNING FIELD-SYMBOL(<ls_display>) INDEX <ls_rows>-index.

        IF sy-subrc = 0.

          ls_po_header = VALUE #(  comp_code   = 'R001'
                                   purch_org   = <ls_display>-ekorg
                                   pur_group   = '001'
                                   doc_type    = 'NB'
                                   creat_date  = <ls_display>-erdat
                                   created_by  = sy-uname
                                   vendor      = <ls_display>-lifnr
                                   currency    = 'INR'
                                   langu       = sy-langu           ).

          ls_po_headerx = VALUE #(  comp_code   = abap_true
                                    purch_org   = abap_true
                                    pur_group   = abap_true
                                    doc_type    = abap_true
                                    creat_date  = abap_true
                                    created_by  = abap_true
                                    vendor      = abap_true
                                    currency    = abap_true
                                    langu       = abap_true      ).

          APPEND VALUE #( po_item    = '00010'
                          plant      = 'DE11'
                          stge_loc   = 'IMRM'
                          po_unit    = 'PC'
                          batch      = ''
                          quantity   = 10
                          material   = 'TF 3RD 1'
                          tax_code   = 'K0'
                          vendrbatch = ''
                          preq_no    = <ls_display>-banfn
                          preq_item  = <ls_display>-bnfpo   ) TO lt_po_item.

          APPEND VALUE #( po_item    = '00010'
                          material   = abap_true
                          plant      = abap_true
                          stge_loc   = abap_true
                          po_unit    = abap_true
                          batch      = abap_true
                          quantity   = abap_true
                          tax_code   = abap_true
                          vendrbatch = abap_true
                          preq_no    = abap_true
                          preq_item  = abap_true  ) TO lt_po_itemx.

          CALL FUNCTION 'BAPI_PO_CREATE1'
            EXPORTING
              poheader         = ls_po_header
              poheaderx        = ls_po_headerx
            IMPORTING
              exppurchaseorder = lv_ebeln
            TABLES
              return           = lt_return
              poitem           = lt_po_item
              poitemx          = lt_po_itemx.

          LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).

            IF <ls_return>-type CA 'AEX'.

              DATA(lv_error) = abap_true.

            ENDIF.

            APPEND VALUE #( msgid  = <ls_return>-id
                            msgty  = <ls_return>-type
                            msgno  = <ls_return>-number
                            msgv1  = <ls_return>-message_v1
                            msgv2  = <ls_return>-message_v2
                            msgv3  = <ls_return>-message_v3
                            msgv4  = <ls_return>-message_v4
                            lineno = Lines( lt_messages ) ) TO lt_messages.

          ENDLOOP.

          IF lv_error IS NOT INITIAL.

            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          ELSE.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait   = abap_true
              IMPORTING
                return = ls_return.

          ENDIF.

        ENDIF.

      ENDLOOP.

      CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
        TABLES
          i_message_tab = lt_messages.

    ELSE.

      MESSAGE 'Select at least one row to create PO!' TYPE 'S' DISPLAY LIKE 'E'.

    ENDIF.

  ENDMETHOD.

  METHOD regroup_rda.



  ENDMETHOD.

  METHOD handle_grid_ucomm.

    LOOP AT er_data_changed->mt_mod_cells ASSIGNING FIELD-SYMBOL(<ls_cells>).

      READ TABLE mt_display_data ASSIGNING FIELD-SYMBOL(<ls_display>) INDEX <ls_cells>-row_id.

      IF sy-subrc = 0.

        CASE <ls_cells>-fieldname.

          WHEN 'MENGE' OR 'MEINS' OR 'LGORT' OR 'LPEIN' OR 'AFNAM' OR 'FLIEF' OR 'LIFNR'.

            ASSIGN COMPONENT <ls_cells>-fieldname OF STRUCTURE <ls_display> TO FIELD-SYMBOL(<lv_value>).

            IF sy-subrc = 0.

              <lv_value> = <ls_cells>-value.
              <ls_display>-edited = abap_true.

            ENDIF.

        ENDCASE.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
