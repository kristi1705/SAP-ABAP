*&---------------------------------------------------------------------*
*& Report ZKP_E36
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_e36.

TABLES: eban.

TYPES: BEGIN OF ty_scr_100,
         ok_code TYPE sy-ucomm,
       END OF ty_scr_100.

SELECT-OPTIONS:
s_lifnr FOR eban-lifnr,
s_matnr FOR eban-matnr,
s_lgort FOR eban-lgort,
s_dispo FOR eban-dispo,
s_matkl FOR eban-matkl,
s_ekgrp FOR eban-ekgrp,
s_banfn FOR eban-banfn,
s_badat FOR eban-badat,
s_lpein FOR eban-lpein,
s_pstyp FOR eban-pstyp,
s_knttp FOR eban-knttp,
s_fixkz FOR eban-fixkz.

PARAMETERS: p_total RADIOBUTTON GROUP rb1,
            p_attr  RADIOBUTTON GROUP rb1.

INCLUDE zkp_e36_class.

DATA: go_pr_management TYPE REF TO lcl_pr_management,
      gs_scr_100       TYPE ty_scr_100.

START-OF-SELECTION.

  CREATE OBJECT go_pr_management.

  CALL SCREEN 100.

  INCLUDE zkp_e36_pbo.

  INCLUDE zkp_e36_pai.
