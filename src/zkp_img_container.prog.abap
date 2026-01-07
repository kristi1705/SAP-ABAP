*&---------------------------------------------------------------------*
*& Report ZKP_IMG_CONTAINER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_img_container.

TYPES: BEGIN OF ty_scr_100,
         ok_code TYPE syucomm,
       END OF ty_scr_100.

CONSTANTS: c_objid TYPE w3objid VALUE 'ZKP_IMAGE'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  PARAMETERS: p_img RADIOBUTTON GROUP rb1 DEFAULT 'X' USER-COMMAND ucomm,
              p_web RADIOBUTTON GROUP rb1,
              p_url TYPE char255 LOWER CASE MODIF ID 001
              DEFAULT 'https://i.postimg.cc/t4CP5q3W/9AAA5695-9DB5-4D73-9695-C2252E12E2F3.jpg'.

SELECTION-SCREEN END OF BLOCK b1.

INCLUDE zkp_img_class.

DATA: go_image_viewer TYPE REF TO lcl_image_viewer,
      gs_scr_100      TYPE ty_scr_100.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.

    CASE screen-group1.

      WHEN '001'.

        CASE p_web.

          WHEN 'X'.

            screen-active = 1.

          WHEN ' '.

            screen-active = 0.

        ENDCASE.

        MODIFY SCREEN.

    ENDCASE.

  ENDLOOP.

START-OF-SELECTION.

  CREATE OBJECT go_image_viewer
    EXPORTING
      iv_url  = p_url
      iv_html = p_web.

  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'PF_STATUS_0100'.
  SET TITLEBAR 'TB_0100'.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  go_image_viewer->execute( iv_ok_code = gs_scr_100-ok_code ).

ENDMODULE.
