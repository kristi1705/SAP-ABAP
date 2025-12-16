*&---------------------------------------------------------------------*
*& Report ZKP_HIERARCHY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_hierarchy.

TYPE-POOLS icon.

TYPES: BEGIN OF ty_scr_100,
         ok_code TYPE syucomm,
         hier(12) TYPE c,
       END OF ty_scr_100.

DATA: gs_scr_100 TYPE ty_scr_100.

INCLUDE zkp_hier_class_def.

DATA: go_hierarchy TYPE REF TO lcl_hierarchy.

INCLUDE zkp_hierarchy_pbo.

INCLUDE zkp_hierarchy_pai.

START-OF-SELECTION.

  CREATE OBJECT go_hierarchy.
