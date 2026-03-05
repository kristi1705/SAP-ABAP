*&---------------------------------------------------------------------*
*& Report ZKP_E37
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_e37.

TABLES: ekko, ekpo, marc, eket, ekes.

TYPES: BEGIN OF ty_scr_100,
         ok_code TYPE sy-ucomm,
       END OF ty_scr_100.

TYPES: BEGIN OF ty_scr_200,
         ok_code TYPE sy-ucomm,
       END OF ty_scr_200.

DATA: gs_scr_100 TYPE ty_scr_100,
      gs_scr_200 TYPE ty_scr_200.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.

  SELECT-OPTIONS:
    s_matnr FOR ekpo-matnr,
    s_werks FOR ekpo-werks,
    s_beskz FOR marc-beskz,
    s_sobsl FOR marc-sobsl,
    s_dispo FOR marc-dispo,
    s_matkl FOR ekpo-matkl,
    s_lifnr FOR ekko-lifnr,
    s_ebeln FOR ekko-ebeln,
    s_ebelp FOR ekpo-ebelp,
    s_bukrs FOR ekko-bukrs,
    s_bstyp FOR ekko-bstyp,
    s_bsart FOR ekko-bsart,
    s_ekgrp FOR ekko-ekgrp,
    s_idnlf FOR ekpo-idnlf,
    s_dlv_d FOR eket-eindt,
    s_aedat FOR ekko-aedat,
    s_wemng FOR eket-wemng,
    s_fixkz FOR eket-fixkz,
    s_con_d FOR ekes-eindt,
    s_labnr FOR ekpo-labnr.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.

  PARAMETERS:
    p_olines RADIOBUTTON GROUP rb1,
    p_clines RADIOBUTTON GROUP rb1,
    p_alines RADIOBUTTON GROUP rb1,
    p_slines RADIOBUTTON GROUP rb1.

SELECTION-SCREEN END OF BLOCK b2.

INCLUDE zkp_e37_class.

DATA: go_po_management TYPE REF TO lcl_po_management.

START-OF-SELECTION.

  CREATE OBJECT go_po_management.

  CASE abap_true.

    WHEN p_slines.

      CALL SCREEN 200.

    WHEN OTHERS.

      CALL SCREEN 100.

  ENDCASE.

  INCLUDE zkp_e37_pbo.

  INCLUDE zkp_e37_pai.
