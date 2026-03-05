*&---------------------------------------------------------------------*
*& Include          ZKP_E37_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_po_management DEFINITION.

  PUBLIC SECTION.

    METHODS:
      constructor,
      execute IMPORTING iv_code TYPE sy-ucomm.

  PRIVATE SECTION.

    CONSTANTS: c_tabname1 TYPE string VALUE 'MT_ALV_1',
               c_tabname2 TYPE string VALUE 'MT_ALV_2'.

    TYPES: BEGIN OF ty_alv_1,
             ebeln         TYPE ekko-ebeln,
             lifnr         TYPE ekko-lifnr,
             bstyp         TYPE ekko-bstyp,
             bsart         TYPE ekko-bsart,
             aedat         TYPE ekko-aedat,
             ekgrp         TYPE ekko-ekgrp,
             verkf         TYPE ekko-verkf,
             waers         TYPE ekko-waers,
             ebelp         TYPE ekpo-ebelp,
             matkl         TYPE ekpo-matkl,
             lgort         TYPE ekpo-lgort,
             matnr         TYPE ekpo-matnr,
             txz01         TYPE ekpo-txz01,
             werks         TYPE ekpo-werks,
             netpr         TYPE ekpo-netpr,
             infnr         TYPE ekpo-infnr,
             konnr         TYPE ekpo-konnr,
             elikz         TYPE ekpo-elikz,
             menge         TYPE ekpo-menge,
             peinh         TYPE ekpo-peinh,
             idnlf         TYPE ekpo-idnlf,
             labnr         TYPE ekpo-labnr,
             beskz         TYPE marc-beskz,
             sobsl         TYPE marc-sobsl,
             etenr         TYPE eket-etenr,
             banfn         TYPE eket-banfn,
             eket_menge    TYPE eket-menge,
             eket_eindt    TYPE eket-eindt,
             eket_wemng    TYPE eket-wemng,
             fixkz         TYPE eket-fixkz,
             ekes_eindt    TYPE ekes-eindt,
             ekes_menge    TYPE ekes-menge,
             name1         TYPE lfa1-name1,
             confirmed_qty TYPE ekpo-menge,
             ebtyp         TYPE ekes-ebtyp,
             edited        TYPE abap_bool,
           END OF ty_alv_1,
           tt_alv_1 TYPE STANDARD TABLE OF ty_alv_1.

    TYPES: BEGIN OF ty_alv_2,
             lifnr             TYPE ekko-lifnr,
             name1             TYPE lfa1-name1,
             ebeln             TYPE ekko-ebeln,
             ebelp             TYPE ekpo-ebelp,
             matnr             TYPE ekpo-matnr,
             txz01             TYPE ekpo-txz01,
             werks             TYPE ekpo-werks,
             aedat             TYPE ekpo-aedat,
             eket_eindt        TYPE eket-eindt,
             plifz             TYPE ekpo-plifz,
             granted_time      TYPE i,
             remaining_time    TYPE i,
             ekes_eindt        TYPE ekes-eindt,
             erdat             TYPE ekes-erdat,
             confirmed_time    TYPE i,
             date_changed      TYPE abap_bool,
             prev_date(254)    TYPE c,
             labnr             TYPE ekpo-labnr,
             budat             TYPE ekbe-budat,
             lead_time         TYPE i,
             lead_vs_confirmed TYPE i,
             delay_vs_granted  TYPE i,
             eket_menge        TYPE eket-menge,
             ekes_menge        TYPE ekes-menge,
             wemng             TYPE eket-menge,
             dlv_qty           TYPE eket-menge,
             con_qty           TYPE ekpo-menge,
           END OF ty_alv_2,
           tt_alv_2 TYPE STANDARD TABLE OF ty_alv_2.

    DATA: mt_alv_1      TYPE tt_alv_1,
          mt_alv_2      TYPE tt_alv_2,
          mo_container1 TYPE REF TO cl_gui_custom_container,
          mo_container2 TYPE REF TO cl_gui_custom_container,
          mo_grid_1     TYPE REF TO cl_gui_alv_grid,
          mo_grid_2     TYPE REF TO cl_gui_alv_grid.

    METHODS: get_data.

    METHODS:
      build_alv_1,
      build_alv_2,
      build_layout CHANGING cs_layout TYPE lvc_s_layo,
      build_fcat_1 CHANGING ct_fcat TYPE lvc_t_fcat,
      build_fcat_2 CHANGING ct_fcat TYPE lvc_t_fcat,
      open_oda     IMPORTING iv_button TYPE sy-ucomm,
      cancel_oda,
      edit_conf_date,
      save_to_db,
      import_date,
      download_excel,
      handle_grid_ucomm FOR EVENT data_changed OF cl_gui_alv_grid IMPORTING er_data_changed.

ENDCLASS.

CLASS lcl_po_management IMPLEMENTATION.

  METHOD constructor.

    get_data( ).

    CASE abap_true.

      WHEN p_slines.

        CREATE OBJECT mo_container2 EXPORTING container_name = 'GS_SCR_200-CONTAINER'.

        CREATE OBJECT mo_grid_2 EXPORTING i_parent = mo_container2.

        import_date( ).

        build_alv_2( ).

      WHEN OTHERS.

        CREATE OBJECT mo_container1 EXPORTING container_name = 'GS_SCR_100-CONTAINER'.

        CREATE OBJECT mo_grid_1 EXPORTING i_parent = mo_container1.

        build_alv_1( ).

    ENDCASE.

  ENDMETHOD.

  METHOD execute.

    CASE iv_code.

      WHEN 'FC_BACK'.

        LEAVE TO SCREEN 0.

      WHEN 'FC_DISPLAY'.

        open_oda( EXPORTING iv_button = iv_code ).

      WHEN 'FC_EDIT'.

        open_oda( EXPORTING iv_button = iv_code ).

      WHEN 'FC_CANCEL'.

        cancel_oda( ).

      WHEN 'FC_SAVE'.

        save_to_db( ).

      WHEN 'FC_CONFD'.

        edit_conf_date( ).

      WHEN 'FC_DLD'.

        download_excel( ).

    ENDCASE.

  ENDMETHOD.

  METHOD get_data.

    DATA: lv_elikz TYPE abap_bool,
          lv_quant TYPE ekes-menge,
          lv_ebeln TYPE ekpo-ebeln.

    CASE abap_true.

      WHEN p_alines.

        SELECT ekko~ebeln,
               ekpo~ebelp,
               ekko~lifnr,
               ekko~bstyp,
               ekko~bsart,
               ekko~aedat,
               ekko~ekgrp,
               ekko~verkf,
               ekko~waers,
               ekpo~matkl,
               ekpo~lgort,
               ekpo~matnr,
               ekpo~txz01,
               ekpo~werks,
               ekpo~netpr,
               ekpo~infnr,
               ekpo~konnr,
               ekpo~elikz,
               ekpo~menge,
               ekpo~peinh,
               ekpo~idnlf,
               ekpo~labnr,
               marc~beskz,
               marc~sobsl,
               eket~etenr,
               eket~banfn,
               eket~menge AS eket_menge,
               eket~eindt AS eket_eindt,
               eket~wemng AS eket_wemng,
               eket~fixkz,
               ekes~eindt AS ekes_eindt,
               ekes~menge AS ekes_menge,
               lfa1~name1

        FROM ekko

          JOIN ekpo      ON ekpo~ebeln = ekko~ebeln

          LEFT JOIN lfa1 ON lfa1~lifnr = ekko~lifnr

          JOIN marc      ON marc~werks = ekpo~werks
                        AND marc~matnr = ekpo~matnr

          JOIN eket      ON eket~ebeln = ekpo~ebeln
                        AND eket~ebelp = ekpo~ebelp

          LEFT JOIN ekes ON ekes~ebeln = ekpo~ebeln
                        AND ekes~ebelp = ekpo~ebelp

        INTO CORRESPONDING FIELDS OF TABLE @mt_alv_1

              WHERE ekpo~loekz  = @abap_false
                AND ekpo~matnr IN @s_matnr
                AND ekpo~werks IN @s_werks
                AND marc~beskz IN @s_beskz
                AND marc~sobsl IN @s_sobsl
                AND marc~dispo IN @s_dispo
                AND ekpo~matkl IN @s_matkl
                AND ekko~lifnr IN @s_lifnr
                AND ekko~ebeln IN @s_ebeln
                AND ekpo~ebelp IN @s_ebelp
                AND ekko~bukrs IN @s_bukrs
                AND ekko~bstyp IN @s_bstyp
                AND ekko~bsart IN @s_bsart
                AND ekko~ekgrp IN @s_ekgrp
                AND ekpo~idnlf IN @s_idnlf
                AND eket~eindt IN @s_dlv_d
                AND ekko~aedat IN @s_aedat
                AND eket~wemng IN @s_wemng
                AND eket~fixkz IN @s_fixkz
                AND ekes~eindt IN @s_con_d
                AND ekpo~labnr IN @s_labnr

         ORDER BY ekko~ebeln,
                  ekpo~ebelp.

        IF sy-subrc <> 0.

          MESSAGE 'No records found!' TYPE 'S' DISPLAY LIKE 'E'.

        ELSE.

          LOOP AT mt_alv_1 ASSIGNING FIELD-SYMBOL(<ls_display>).

            AT FIRST.

              lv_ebeln = <ls_display>-ebeln.

            ENDAT.

            IF lv_ebeln <> <ls_display>-ebeln.

              <ls_display>-confirmed_qty = <ls_display>-menge - lv_quant.

              CLEAR lv_quant.

            ENDIF.

            lv_quant += <ls_display>-ekes_menge.
            lv_ebeln  = <ls_display>-ebeln.

          ENDLOOP.

        ENDIF.

      WHEN p_slines.

        SELECT ekko~lifnr,
               lfa1~name1,
               ekko~ebeln,
               ekpo~ebelp,
               ekpo~matnr,
               ekpo~txz01,
               ekpo~werks,
               ekko~aedat,
               eket~eindt AS eket_eindt,
               ekpo~plifz,
               days_between( eket~eindt, ekko~aedat ) AS granted_time,
               days_between( @sy-datum,  eket~eindt ) AS remaining_time,
               ekes~eindt AS ekes_eindt,
               ekes~erdat,
               days_between( ekes~eindt, ekko~aedat ) AS confirmed_time,
               ekpo~labnr,
               ekbe~budat,
               days_between( ekbe~budat, ekko~aedat ) AS lead_time,
               days_between( ekes~eindt, ekbe~budat ) AS lead_vs_confirmed,
               days_between( eket~eindt, ekbe~budat ) AS delay_vs_granted,
               eket~menge AS eket_menge,
               ekes~menge AS ekes_menge,
               eket~wemng,
               ( CAST( eket~menge AS QUAN ) - CAST( eket~wemng AS QUAN ) ) AS dlv_qty,
               ( CAST( eket~menge AS QUAN ) - CAST( ekes~menge AS QUAN ) ) AS con_qty

          FROM ekko

          JOIN      ekpo ON ekpo~ebeln = ekko~ebeln

          LEFT JOIN eket ON eket~ebeln = ekko~ebeln
                        AND eket~ebelp = ekpo~ebelp

          LEFT JOIN ekes ON ekes~ebeln = ekko~ebeln
                        AND ekes~ebelp = ekpo~ebelp

          LEFT JOIN ekbe ON ekbe~ebeln = ekko~ebeln
                        AND ekbe~ebelp = ekpo~ebelp

          LEFT JOIN lfa1 ON lfa1~lifnr = ekko~lifnr

              WHERE ekpo~loekz  = @abap_false
                AND ekpo~matnr IN @s_matnr
                AND ekpo~werks IN @s_werks
                AND ekpo~matkl IN @s_matkl
                AND ekko~lifnr IN @s_lifnr
                AND ekko~ebeln IN @s_ebeln
                AND ekpo~ebelp IN @s_ebelp
                AND ekko~bukrs IN @s_bukrs
                AND ekko~bstyp IN @s_bstyp
                AND ekko~bsart IN @s_bsart
                AND ekko~ekgrp IN @s_ekgrp
                AND ekpo~idnlf IN @s_idnlf
                AND eket~eindt IN @s_dlv_d
                AND ekko~aedat IN @s_aedat
                AND eket~wemng IN @s_wemng
                AND eket~fixkz IN @s_fixkz
                AND ekes~eindt IN @s_con_d
                AND ekpo~labnr IN @s_labnr

                ORDER BY ekko~ebeln,
                  ekpo~ebelp

          INTO CORRESPONDING FIELDS OF TABLE @mt_alv_2.

        IF sy-subrc <> 0.

          MESSAGE 'No records found!' TYPE 'S' DISPLAY LIKE 'E'.

        ENDIF.

      WHEN OTHERS.

        CASE abap_true.

          WHEN p_clines.

            lv_elikz = abap_true.

          WHEN p_olines.

            lv_elikz = abap_false.

        ENDCASE.

        SELECT ekko~ebeln,
               ekpo~ebelp,
               ekko~lifnr,
               ekko~bstyp,
               ekko~bsart,
               ekko~aedat,
               ekko~ekgrp,
               ekko~verkf,
               ekko~waers,
               ekpo~matkl,
               ekpo~lgort,
               ekpo~matnr,
               ekpo~txz01,
               ekpo~werks,
               ekpo~netpr,
               ekpo~infnr,
               ekpo~konnr,
               ekpo~elikz,
               ekpo~menge,
               ekpo~peinh,
               ekpo~idnlf,
               ekpo~labnr,
               marc~beskz,
               marc~sobsl,
               eket~etenr,
               eket~banfn,
               eket~menge AS eket_menge,
               eket~eindt AS eket_eindt,
               eket~wemng AS eket_wemng,
               eket~fixkz,
               ekes~eindt AS ekes_eindt,
               ekes~menge AS ekes_menge,
               lfa1~name1

       FROM ekko

         JOIN ekpo      ON ekpo~ebeln = ekko~ebeln

         LEFT JOIN lfa1 ON lfa1~lifnr = ekko~lifnr

         JOIN marc      ON marc~werks = ekpo~werks
                       AND marc~matnr = ekpo~matnr

         JOIN eket      ON eket~ebeln = ekpo~ebeln
                       AND eket~ebelp = ekpo~ebelp

         LEFT JOIN ekes ON ekes~ebeln = ekpo~ebeln
                       AND ekes~ebelp = ekpo~ebelp

       INTO CORRESPONDING FIELDS OF TABLE @mt_alv_1

             WHERE ekpo~loekz  = @abap_false
               AND ekpo~elikz  = @lv_elikz
               AND ekpo~matnr IN @s_matnr
               AND ekpo~werks IN @s_werks
               AND marc~beskz IN @s_beskz
               AND marc~sobsl IN @s_sobsl
               AND marc~dispo IN @s_dispo
               AND ekpo~matkl IN @s_matkl
               AND ekko~lifnr IN @s_lifnr
               AND ekko~ebeln IN @s_ebeln
               AND ekpo~ebelp IN @s_ebelp
               AND ekko~bukrs IN @s_bukrs
               AND ekko~bstyp IN @s_bstyp
               AND ekko~bsart IN @s_bsart
               AND ekko~ekgrp IN @s_ekgrp
               AND ekpo~idnlf IN @s_idnlf
               AND eket~eindt IN @s_dlv_d
               AND ekko~aedat IN @s_aedat
               AND eket~wemng IN @s_wemng
               AND eket~fixkz IN @s_fixkz
               AND ekes~eindt IN @s_con_d
               AND ekpo~labnr IN @s_labnr

        ORDER BY ekko~ebeln,
                 ekpo~ebelp.

        IF sy-subrc <> 0.

          MESSAGE 'No records found!' TYPE 'S' DISPLAY LIKE 'E'.

        ELSE.

          LOOP AT mt_alv_1 ASSIGNING FIELD-SYMBOL(<ls_display1>).

            AT FIRST.

              lv_ebeln = <ls_display1>-ebeln.

            ENDAT.

            IF lv_ebeln <> <ls_display1>-ebeln.

              <ls_display1>-confirmed_qty = <ls_display1>-menge - lv_quant.

              CLEAR lv_quant.

            ENDIF.

            lv_quant += <ls_display1>-ekes_menge.
            lv_ebeln  = <ls_display1>-ebeln.

          ENDLOOP.

        ENDIF.

    ENDCASE.

  ENDMETHOD.

  METHOD build_alv_1.

    DATA: lt_fcat   TYPE lvc_t_fcat,
          ls_layout TYPE lvc_s_layo.

    build_layout( CHANGING cs_layout = ls_layout ).

    build_fcat_1( CHANGING ct_fcat = lt_fcat ).

    SET HANDLER handle_grid_ucomm FOR mo_grid_1.

    mo_grid_1->register_edit_event(
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2 ).

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    ENDIF.

    mo_grid_1->set_table_for_first_display(
      EXPORTING
        is_layout                     = ls_layout
      CHANGING
        it_outtab                     = mt_alv_1
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

  METHOD build_alv_2.

    DATA: lt_fcat   TYPE lvc_t_fcat,
          ls_layout TYPE lvc_s_layo.

    build_layout( CHANGING cs_layout = ls_layout ).

    build_fcat_2( CHANGING ct_fcat = lt_fcat ).

    mo_grid_2->set_table_for_first_display(
      EXPORTING
        is_layout                     = ls_layout
      CHANGING
        it_outtab                     = mt_alv_2
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

  METHOD build_fcat_1.

    ct_fcat = VALUE #(
      ( fieldname = 'LIFNR'         tabname = c_tabname1 ref_table = 'EKKO' ref_field = 'LIFNR' scrtext_m = 'Fornitore'                key = abap_true )
      ( fieldname = 'NAME1'         tabname = c_tabname1 ref_table = 'LFA1' ref_field = 'NAME1' scrtext_m = 'Ragione sociale'          key = abap_true )
      ( fieldname = 'EBELN'         tabname = c_tabname1 ref_table = 'EKKO' ref_field = 'EBELN' scrtext_m = 'Documento acquisti'       key = abap_true )
      ( fieldname = 'EBELP'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'EBELP' scrtext_m = 'Posizione'                key = abap_true )
      ( fieldname = 'MATNR'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'MATNR' scrtext_m = 'Materiale'                                )
      ( fieldname = 'TXZ01'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'TXZ01' scrtext_m = 'Descrizione'                              )
      ( fieldname = 'WERKS'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'WERKS' scrtext_m = 'Divisione'                                )
      ( fieldname = 'BESKZ'         tabname = c_tabname1 ref_table = 'MARC' ref_field = 'BESKZ' scrtext_m = 'Tipo approvv.'                            )
      ( fieldname = 'SOBSL'         tabname = c_tabname1 ref_table = 'MARC' ref_field = 'SOBSL' scrtext_m = 'Approvvigion. speciale'                   )
      ( fieldname = 'ETENR'         tabname = c_tabname1 ref_table = 'EKET' ref_field = 'ETENR' scrtext_m = 'Schedulazione'                            )
      ( fieldname = 'EKET_MENGE'    tabname = c_tabname1 ref_table = 'EKET' ref_field = 'MENGE' scrtext_m = 'Quantità schedulata'      edit = 'X'      )
      ( fieldname = 'EKET_EINDT'    tabname = c_tabname1 ref_table = 'EKET' ref_field = 'EINDT' scrtext_m = 'Data consegna schedulata'                 )
      ( fieldname = 'WEMNG'         tabname = c_tabname1 ref_table = 'EKET' ref_field = 'WEMNG' scrtext_m = 'Quantità entrata'                         )
      ( fieldname = 'NETPR'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'NETPR' scrtext_m = 'Prezzo netto'                             )
      ( fieldname = 'WAERS'         tabname = c_tabname1 ref_table = 'EKKO' ref_field = 'WAERS' scrtext_m = 'Divisa'                                   )
      ( fieldname = 'PEINH'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'PEINH' scrtext_m = 'Unità prezzo'                             )
      ( fieldname = 'FIXKZ'         tabname = c_tabname1 ref_table = 'EKET' ref_field = 'FIXKZ' scrtext_m = 'Sched.fissata'                            )
      ( fieldname = 'AEDAT'         tabname = c_tabname1 ref_table = 'EKKO' ref_field = 'AEDAT' scrtext_m = 'Data creazione Ord'                       )
      ( fieldname = 'IDNLF'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'IDNLF' scrtext_m = 'Materiale fornitore'                      )
      ( fieldname = 'LABNR'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'LABNR' scrtext_m = 'Nr.conferma'              edit = 'X'      )
      ( fieldname = 'EKES_EINDT'    tabname = c_tabname1 ref_table = 'EKES' ref_field = 'EINDT' scrtext_m = 'Data conferma'            edit = 'X'      )
      ( fieldname = 'EKES_MENGE'    tabname = c_tabname1 ref_table = 'EKES' ref_field = 'MENGE' scrtext_m = 'Data conferma'            edit = 'X'      )
      ( fieldname = 'CONFIRMED_QTY' tabname = c_tabname1 ref_table = 'EKES' ref_field = 'MENGE' scrtext_m = 'Quantità confermata'      edit = 'X'      )
      ( fieldname = 'BSTYP'         tabname = c_tabname1 ref_table = 'EKKO' ref_field = 'BSTYP' scrtext_m = 'Cat.Doc.Acquisto'                         )
      ( fieldname = 'BSART'         tabname = c_tabname1 ref_table = 'EKKO' ref_field = 'BSART' scrtext_m = 'Tipo Doc.Acquisto'                        )
      ( fieldname = 'EKGRP'         tabname = c_tabname1 ref_table = 'EKKO' ref_field = 'EKGRP' scrtext_m = 'Gruppo acquisti'                          )
      ( fieldname = 'MATKL'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'MATKL' scrtext_m = 'Gruppo merci'                             )
      ( fieldname = 'LGORT'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'LGORT' scrtext_m = 'Magazzino'                                )
      ( fieldname = 'VERKF'         tabname = c_tabname1 ref_table = 'EKKO' ref_field = 'VERKF' scrtext_m = 'Res. Vendite For.'                        )
      ( fieldname = 'BANFN'         tabname = c_tabname1 ref_table = 'EKET' ref_field = 'BANFN' scrtext_m = 'RdA'                                      )
      ( fieldname = 'INFNR'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'INFNR' scrtext_m = 'Record Info'                              )
      ( fieldname = 'KONNR'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'KONNR' scrtext_m = 'Contratto'                                )
      ( fieldname = 'ELIKZ'         tabname = c_tabname1 ref_table = 'EKPO' ref_field = 'ELIKZ' scrtext_m = 'Chiusura ordine'          edit = 'X'      )
    ).

  ENDMETHOD.

  METHOD build_fcat_2.

    ct_fcat = VALUE #(
      ( fieldname = 'LIFNR'             tabname = c_tabname2 ref_table = 'EKKO' ref_field = 'LIFNR' scrtext_m = 'Fornitore'                key = abap_true )
      ( fieldname = 'NAME1'             tabname = c_tabname2 ref_table = 'LFA1' ref_field = 'NAME1' scrtext_m = 'Ragione sociale'          key = abap_true )
      ( fieldname = 'EBELN'             tabname = c_tabname2 ref_table = 'EKKO' ref_field = 'EBELN' scrtext_m = 'Documento acquisti'       key = abap_true )
      ( fieldname = 'EBELP'             tabname = c_tabname2 ref_table = 'EKPO' ref_field = 'EBELP' scrtext_m = 'Posizione'                key = abap_true )
      ( fieldname = 'MATNR'             tabname = c_tabname2 ref_table = 'EKPO' ref_field = 'MATNR' scrtext_m = 'Materiale'                                )
      ( fieldname = 'TXZ01'             tabname = c_tabname2 ref_table = 'EKPO' ref_field = 'TXZ01' scrtext_m = 'Descrizione'                              )
      ( fieldname = 'WERKS'             tabname = c_tabname2 ref_table = 'EKPO' ref_field = 'WERKS' scrtext_m = 'Divisione'                                )
      ( fieldname = 'AEDAT'             tabname = c_tabname2 ref_table = 'EKKO' ref_field = 'AEDAT' scrtext_m = 'Data creazione Ord'                       )
      ( fieldname = 'EKET_EINDT'        tabname = c_tabname2 ref_table = 'EKET' ref_field = 'EINDT' scrtext_m = 'Data consegna schedulata'                 )
      ( fieldname = 'PFLIZ'             tabname = c_tabname2 ref_table = 'EKPO' ref_field = 'PFLIZ' scrtext_m = 'Lead time di consegna concordato'         )
      ( fieldname = 'GRANTED_TIME'      tabname = c_tabname2 scrtext_m = 'Lead time realmente concesso'                                                    )
      ( fieldname = 'EKET_EINDT'        tabname = c_tabname2 ref_table = 'EKET' ref_field = 'EINDT' scrtext_m = 'Data consegna schedulata'                 )
      ( fieldname = 'REMAINING_TIME'    tabname = c_tabname2 scrtext_m = 'Lead time rimanente sulla base dei giorni già trascorsi'                         )
      ( fieldname = 'EKES_EINDT'        tabname = c_tabname2 ref_table = 'EKES' ref_field = 'EINDT' scrtext_m = 'Data conferma'                            )
      ( fieldname = 'ERDAT'             tabname = c_tabname2 ref_table = 'EKES' ref_field = 'ERDAT' scrtext_m = 'Data inserimento conferma'                )
      ( fieldname = 'CONFIRMED_TIME'    tabname = c_tabname2 scrtext_m = 'Lead time confermato'                                                            )
      ( fieldname = 'DATE_CHANGED'      tabname = c_tabname2 scrtext_m = 'Data di conferma modificata?'                                                    )
      ( fieldname = 'PREV_DATE'         tabname = c_tabname2 scrtext_m = 'Data di conferma precedente'                                                     )
      ( fieldname = 'LABNR'             tabname = c_tabname2 ref_table = 'EKPO' ref_field = 'LABNR' scrtext_m = 'Nr.conferma'                              )
      ( fieldname = 'BUDAT'             tabname = c_tabname2 ref_table = 'EKBE' ref_field = 'BUDAT' scrtext_m = 'Data Entrata merci'                       )
      ( fieldname = 'LEAD_TIME'         tabname = c_tabname2 scrtext_m = 'Lead time totale'                                                                )
      ( fieldname = 'LEAD_VS_CONFIRMED' tabname = c_tabname2 scrtext_m = 'Ritardo rispetto a data confermata'                                              )
      ( fieldname = 'DELAY_VS_GRANTED'  tabname = c_tabname2 scrtext_m = 'Ritardo rispetto lead time concesso'                                             )
      ( fieldname = 'EKET_MENGE'        tabname = c_tabname2 ref_table = 'EKET' ref_field = 'MENGE' scrtext_m = 'Quantità schedulata'                      )
      ( fieldname = 'EKES_MENGE'        tabname = c_tabname2 ref_table = 'EKES' ref_field = 'MENGE' scrtext_m = 'Quantità confermata'                      )
      ( fieldname = 'WEMNG'             tabname = c_tabname2 ref_table = 'EKET' ref_field = 'WEMNG' scrtext_m = 'Quantità entrata'                         )
      ( fieldname = 'DLV_QTY'           tabname = c_tabname2 ref_table = 'EKET' ref_field = 'MENGE' scrtext_m = 'Quantità da consegnare'                   )
      ( fieldname = 'CON_QTY'           tabname = c_tabname2 ref_table = 'EKPO' ref_field = 'MENGE' scrtext_m = 'Quantità da confermare'                   )
     ).

  ENDMETHOD.

  METHOD open_oda.

    DATA: lt_rows TYPE lvc_t_row.

    mo_grid_1->get_selected_rows( IMPORTING et_index_rows = lt_rows ).

    IF lines( lt_rows ) <> 1.

      MESSAGE 'Only one row can be selected!' TYPE 'S' DISPLAY LIKE 'E'.

    ELSE.

      READ TABLE lt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>) INDEX 1.

      IF sy-subrc = 0.

        READ TABLE mt_alv_1 ASSIGNING FIELD-SYMBOL(<ls_display>)
        INDEX <ls_rows>-index.

        IF sy-subrc = 0.

          DATA(lv_ebeln) = <ls_display>-ebeln.

          SET PARAMETER ID 'BES' FIELD lv_ebeln.

          CASE iv_button.

            WHEN 'FC_DISPLAY'.

              CALL TRANSACTION 'ME23N'.

            WHEN 'FC_EDIT'.

              CALL TRANSACTION 'ME22N'.

          ENDCASE.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD cancel_oda.

    DATA: lv_choice(1) TYPE c,
          lt_rows      TYPE lvc_t_row,
          lv_offset    TYPE i,
          lv_index     TYPE i,
          ls_return    TYPE bapiret2,
          lt_return    TYPE STANDARD TABLE OF bapiret2,
          lt_poitem    TYPE STANDARD TABLE OF bapimepoitem,
          lt_poitemx   TYPE STANDARD TABLE OF bapimepoitemx,
          lt_messages  TYPE esp1_message_tab_type.

    mo_grid_1->get_selected_rows( IMPORTING et_index_rows = lt_rows ).

    IF lines( lt_rows ) > 0.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = 'Confermi la cancellazione degli OdA selezionati?'
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

          READ TABLE mt_alv_1 ASSIGNING FIELD-SYMBOL(<ls_display>)
          INDEX <ls_rows>-index.

          IF sy-subrc = 0.

            APPEND VALUE #( po_item    = <ls_display>-ebelp
                            delete_ind = abap_true ) TO lt_poitem.

            APPEND VALUE #( po_item    = <ls_display>-ebelp
                            po_itemx   = abap_true
                            delete_ind = abap_true ) TO lt_poitemx.

            CALL FUNCTION 'BAPI_PO_CHANGE'
              EXPORTING
                purchaseorder = <ls_display>-ebeln
              TABLES
                return        = lt_return
                poitem        = lt_poitem
                poitemx       = lt_poitemx.

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

              lv_index = <ls_rows>-index - lv_offset.
              DELETE mt_alv_1 INDEX lv_index.
              lv_offset += 1.

            ENDIF.

          ENDIF.

          CLEAR: lt_poitem, lt_poitemx.

        ENDLOOP.

        mo_grid_1->refresh_table_display(
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

  METHOD edit_conf_date.

    DATA: lt_rows TYPE lvc_t_row,
          lt_sval TYPE STANDARD TABLE OF sval.

    mo_grid_1->get_selected_rows( IMPORTING et_index_rows = lt_rows ).

    IF lines( lt_rows ) > 0.

      lt_sval = VALUE #( ( tabname = 'EKES' fieldname = 'EINDT' field_obl = abap_true )
                         ( tabname = 'EKPO' fieldname = 'LABNR' ) ).

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title     = 'Inserimento / Modifica massiva data di conferma.'
        TABLES
          fields          = lt_sval
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.

      LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls_rows>).

        READ TABLE mt_alv_1 ASSIGNING FIELD-SYMBOL(<ls_display>)
        INDEX <ls_rows>-index.

        IF sy-subrc = 0.

          READ TABLE lt_sval ASSIGNING FIELD-SYMBOL(<ls_sval>)
          WITH KEY fieldname = 'EINDT'.

          IF sy-subrc = 0.

            <ls_display>-ekes_eindt = <ls_sval>-value.

          ENDIF.

          READ TABLE lt_sval ASSIGNING <ls_sval>
           WITH KEY fieldname = 'LABNR'.

          IF sy-subrc = 0.

            IF <ls_sval>-value IS NOT INITIAL.

              <ls_display>-labnr = <ls_sval>-value.

            ENDIF.

          ENDIF.

          <ls_display>-ekes_menge = <ls_display>-eket_menge.
          <ls_display>-ebtyp      = 'AB'.
          <ls_display>-edited     = abap_true.

        ENDIF.

      ENDLOOP.

      mo_grid_1->refresh_table_display(
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

      MESSAGE 'Select at least one row to modify!' TYPE 'S' DISPLAY LIKE 'E'.

    ENDIF.

  ENDMETHOD.

  METHOD save_to_db.

    DATA: ls_return     TYPE bapiret2,
          lt_return     TYPE STANDARD TABLE OF bapiret2,
          lt_xekes      TYPE STANDARD TABLE OF uekes,
          lt_poitem     TYPE STANDARD TABLE OF bapimepoitem,
          lt_poitemx    TYPE STANDARD TABLE OF bapimepoitemx,
          lt_poschedule TYPE STANDARD TABLE OF bapimeposchedule,
          lt_poschedulx TYPE STANDARD TABLE OF bapimeposchedulx,
          lt_messages   TYPE esp1_message_tab_type.

    LOOP AT mt_alv_1 ASSIGNING FIELD-SYMBOL(<ls_display>) WHERE edited = abap_true
      GROUP BY ( ebeln = <ls_display>-ebeln ) ASSIGNING FIELD-SYMBOL(<lt_po_items>).

      CLEAR: lt_return, lt_poitem, lt_poitemx, lt_poschedule, lt_poschedulx.

      LOOP AT GROUP <lt_po_items> ASSIGNING FIELD-SYMBOL(<ls_item>).

        APPEND VALUE #( ebeln = <ls_item>-ebeln
                        ebelp = <ls_item>-ebelp
                        ebtyp = <ls_item>-ebtyp
                        eindt = <ls_item>-ekes_eindt
                        menge = <ls_item>-ekes_menge
                        etens = 0001
                        kz    = 'U' ) TO lt_xekes.

        APPEND VALUE #( po_item    = <ls_item>-ebelp
                        acknowl_no = <ls_item>-labnr
                        no_more_gr = <ls_item>-elikz ) TO lt_poitem.

        APPEND VALUE #( po_item    = <ls_item>-ebelp
                        po_itemx   = abap_true
                        acknowl_no = abap_true
                        no_more_gr = abap_true ) TO lt_poitemx.

        APPEND VALUE #( po_item  = <ls_item>-ebelp
                        quantity = <ls_item>-ekes_menge ) TO lt_poschedule.

        APPEND VALUE #( po_item  = <ls_item>-ebelp
                        po_itemx = abap_true
                        quantity = abap_true ) TO lt_poschedulx.

        <ls_item>-edited = abap_false.

      ENDLOOP.

      CALL FUNCTION 'BAPI_PO_CHANGE'
        EXPORTING
          purchaseorder = <lt_po_items>-ebeln
        TABLES
          return        = lt_return
          poitem        = lt_poitem
          poitemx       = lt_poitemx
          poschedule    = lt_poschedule
          poschedulex   = lt_poschedulx.

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

        CALL FUNCTION 'ME_CONFIRMATION_UPDATE'
          EXPORTING
            i_ebeln                    = <lt_po_items>-ebeln
            i_update_check_deactivated = 'X'
          TABLES
            xekes                      = lt_xekes.

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

  METHOD import_date.

    LOOP AT mt_alv_2 ASSIGNING FIELD-SYMBOL(<ls_display>).

      DATA(lv_tabkey) = |%{ <ls_display>-ebeln }%{ <ls_display>-ebelp }%|.

      SELECT SINGLE @abap_true
        FROM cdpos
        INTO @DATA(lv_exists)
        WHERE objectid = @<ls_display>-ebeln
          AND tabkey   LIKE @lv_tabkey
          AND tabname  = 'EKES'
          AND fname    = 'EINDT'
          AND chngind  = 'U'.

      IF sy-subrc = 0.

        <ls_display>-date_changed = abap_true.

        SELECT value_old
          FROM cdpos
          WHERE objectid = @<ls_display>-ebeln
            AND tabkey LIKE @lv_tabkey
            AND tabname  = 'EKES'
            AND fname    = 'EINDT'
            AND chngind  = 'U'
          ORDER BY changenr DESCENDING
          INTO @<ls_display>-prev_date
          UP TO 1 ROWS.
        ENDSELECT.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD download_excel.

    DATA: lt_bin_tab  TYPE STANDARD TABLE OF soli,
          lv_xstring  TYPE xstring,
          lv_fullpath TYPE string,
          lv_filepath TYPE string,
          lv_filename TYPE string,
          lv_filesize TYPE i.

    CLEAR: lv_xstring.

    GET REFERENCE OF mt_alv_2 INTO DATA(lo_ref_tab).

    FIELD-SYMBOLS: <lt_ref_data> TYPE ANY TABLE.

    ASSIGN lo_ref_tab->* TO <lt_ref_data>.

    TRY.

        cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_tab)
        CHANGING t_table = <lt_ref_data> ).

        lv_xstring = lo_tab->to_xml( xml_type = if_salv_bs_xml=>c_type_xlsx ).

      CATCH cx_root INTO DATA(lx_salv).

        MESSAGE lx_salv->get_longtext( ) TYPE 'E'.

    ENDTRY.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_xstring
      IMPORTING
        output_length = lv_filesize
      TABLES
        binary_tab    = lt_bin_tab.

    CONCATENATE 'Excel Table ' sy-datum '_' sy-uzeit '.xlsx' INTO DATA(lv_default_name).

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
        data_tab                = lt_bin_tab[]
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
      CLEAR: lt_bin_tab.

    ENDIF.

  ENDMETHOD.

  METHOD handle_grid_ucomm.

    LOOP AT er_data_changed->mt_mod_cells ASSIGNING FIELD-SYMBOL(<ls_cells>).

      READ TABLE mt_alv_1 ASSIGNING FIELD-SYMBOL(<ls_display>) INDEX <ls_cells>-row_id.

      IF sy-subrc = 0.

        CASE <ls_cells>-fieldname.

          WHEN 'EKET_MENGE' OR 'EKES_MENGE' OR 'EKES_EINDT' OR 'LABNR' OR 'ELIKZ'.

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
