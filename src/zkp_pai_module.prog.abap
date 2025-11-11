*&---------------------------------------------------------------------*
*& Include          ZKP_PAI_MODULE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  go_tab_control->get_ok_code_100(
  EXPORTING iv_ok_code_100 = gs_scr_100-ok_code ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.

  CASE gs_scr_100-ok_code.

    WHEN 'FC_BACK'.

      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.

  go_tab_control->get_ok_code_110(
  EXPORTING iv_ok_code_110 = gs_scr_110-ok_code ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0110 INPUT.

  CASE gs_scr_110-ok_code.

    WHEN 'FC_BACK'.

      LEAVE TO SCREEN 100.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_MAKTX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_maktx INPUT.

  go_tab_control->get_maktx( EXPORTING iv_curr_line = tab_control-current_line
                             CHANGING  cs_container = gs_container
                                       ct_container = gt_container ).

ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TAB_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TAB_CONTROL_MODIFY INPUT.
  MODIFY gt_container
    FROM gs_container
    INDEX TAB_CONTROL-CURRENT_LINE.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TAB_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TAB_CONTROL_MARK INPUT.
  DATA: g_TAB_CONTROL_wa2 like line of gt_container.
    if TAB_CONTROL-line_sel_mode = 1
    and gs_container-SEL_LINE = 'X'.
     loop at gt_container into g_TAB_CONTROL_wa2
       where SEL_LINE = 'X'.
       g_TAB_CONTROL_wa2-SEL_LINE = ''.
       modify gt_container
         from g_TAB_CONTROL_wa2
         transporting SEL_LINE.
     endloop.
  endif.
  MODIFY gt_container
    FROM gs_container
    INDEX TAB_CONTROL-CURRENT_LINE
    TRANSPORTING SEL_LINE.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TAB_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TAB_CONTROL_USER_COMMAND INPUT.
  gs_scr_110-OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TAB_CONTROL'
                              'GT_CONTAINER'
                              'SEL_LINE'
                     CHANGING gs_scr_110-OK_CODE.
  SY-UCOMM = gs_scr_110-OK_CODE.
ENDMODULE.
