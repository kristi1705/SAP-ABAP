*&---------------------------------------------------------------------*
*& Include          ZKP_TAB_CONTROL_DEF
*&---------------------------------------------------------------------*

CLASS lcl_tab_control DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_cl_container,
             sel_line TYPE abap_bool,
             mandt    TYPE mandt,
             cn       TYPE zkp_cn,
             matnr    TYPE makt-matnr,
             maktx    TYPE maktx,
             quant    TYPE zkp_quant,
             shift    TYPE zkp_shift,
             dats     TYPE sydatum,
             usern    TYPE syuname,
             del      TYPE zkp_del,
           END OF ty_cl_container.

    TYPES: BEGIN OF ty_exceltab,
             cn    TYPE zkp_cn,
             matnr TYPE makt-matnr,
             maktx TYPE maktx,
             quant TYPE zkp_quant,
             shift TYPE zkp_shift,
             dats  TYPE sydatum,
             usern TYPE syuname,
             del   TYPE zkp_del,
           END OF ty_exceltab.

    TYPES: BEGIN OF ty_dbtab,
             mandt TYPE mandt,
             cn    TYPE zkp_cn,
             matnr TYPE makt-matnr,
             maktx TYPE maktx,
             quant TYPE zkp_quant,
             shift TYPE zkp_shift,
             dats  TYPE sydatum,
             usern TYPE syuname,
             del   TYPE zkp_del,
           END OF ty_dbtab.

    TYPES: BEGIN OF ty_bin_tab,
             data(255) TYPE x,
           END OF ty_bin_tab.

    TYPES: tt_exceltab     TYPE STANDARD TABLE OF ty_exceltab.
    TYPES: tt_bin_tab      TYPE STANDARD TABLE OF ty_bin_tab.
    TYPES: tt_dbtab        TYPE STANDARD TABLE OF ty_dbtab.
    TYPES: tt_cl_container TYPE STANDARD TABLE OF ty_cl_container.

    DATA: mt_bin_tab TYPE tt_bin_tab,
          ms_bin_tab TYPE ty_bin_tab.

    METHODS: container_exists IMPORTING iv_cn_100 TYPE c.

    METHODS: confirm_choice IMPORTING iv_cn_110 TYPE c
                            CHANGING  cv_cn_110 TYPE c.

    METHODS: get_ok_code_100 IMPORTING iv_ok_code_100 TYPE sy-ucomm.
    METHODS: get_ok_code_110 IMPORTING iv_ok_code_110 TYPE sy-ucomm.

    METHODS: get_data IMPORTING iv_cn_100    TYPE c
                      EXPORTING et_container TYPE tt_cl_container
                      CHANGING  cv_cn_110    TYPE c.

    METHODS: screen_status EXPORTING ev_screen_status TYPE abap_bool.

    METHODS: set_vrm_values.

    METHODS: get_maktx IMPORTING iv_curr_line TYPE i
                       CHANGING  cs_container TYPE ty_cl_container
                                 ct_container TYPE tt_cl_container.

    METHODS: show_del_items IMPORTING iv_cn_110    TYPE c
                                      iv_del_items TYPE abap_bool
                            CHANGING  ct_container TYPE tt_cl_container.

    METHODS: save_to_db IMPORTING iv_cn_110    TYPE c
                        CHANGING  ct_container TYPE tt_cl_container.

    METHODS: upload_to_server.

    METHODS: download_excel.

    METHODS: send_via_email IMPORTING iv_cn_110 TYPE c.

    METHODS: convert_to_excel IMPORTING iv_cn_110    TYPE c
                              EXPORTING ev_filesize  TYPE i
                                        ev_row_count TYPE string
                              CHANGING  ct_container TYPE tt_cl_container.

ENDCLASS.
