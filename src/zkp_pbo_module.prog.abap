*&---------------------------------------------------------------------*
*& Include          ZKP_PBO_MODULE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

 SET PF-STATUS 'STATUS_0100'.
 SET TITLEBAR 'TB_0100'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_object OUTPUT.

  CREATE OBJECT go_tab_control.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0110 OUTPUT.

 SET PF-STATUS 'STATUS_0110'.
 SET TITLEBAR 'TB_0110'.

 IF gt_container IS INITIAL.

    APPEND INITIAL LINE TO gt_container.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module VRM_SET_VALUE_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE vrm_set_values_0110 OUTPUT.

  go_tab_control->set_vrm_values( ).

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SCREEN_STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE screen_status_0110 OUTPUT.

      LOOP AT SCREEN.

    CASE gv_screen_status.

      WHEN 'X'.

        screen-input = 1.

       CASE screen-name.

       	WHEN 'GS_CONTAINER-MAKTX'.

          screen-input = 0.

       	WHEN 'GS_CONTAINER-DATS'.

          screen-input = 0.

       	WHEN 'GS_CONTAINER-USERN'.

          screen-input = 0.

       ENDCASE.

      WHEN ' '.

        screen-input = 0.

    ENDCASE.

    MODIFY SCREEN.

  ENDLOOP.

ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TAB_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TAB_CONTROL_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE gt_container LINES TAB_CONTROL-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TAB_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE TAB_CONTROL_GET_LINES OUTPUT.
  G_TAB_CONTROL_LINES = SY-LOOPC.
ENDMODULE.
